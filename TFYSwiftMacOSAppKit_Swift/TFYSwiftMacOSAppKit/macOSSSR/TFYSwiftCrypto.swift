//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

class TFYSwiftCrypto {
    private let key: SymmetricKey
    private let method: TFYSwiftConfig.CryptoMethod
    private var ivCache: [String: Data] = [:]
    private let ivCacheLock = NSLock()
    
    init(password: String, method: TFYSwiftConfig.CryptoMethod) {
        // 获取密钥长度
        let keySize = method.keySize
        let ivSize = method.ivSize
        
        // 生成密钥
        self.key = TFYSwiftCrypto.generateKey(from: password, size: keySize)
        
        // 如果需要，生成 IV
        if method.requiresIV {
            self.iv = TFYSwiftCrypto.generateIV(size: ivSize)
        }
        
        self.method = method
    }
    
    // PBKDF2 密钥派生
    private static func deriveKey(password: Data, salt: Data, length: Int, rounds: UInt32) throws -> Data {
        var result = Data(count: length)
        let status = result.withUnsafeMutableBytes { resultBytes in
            salt.withUnsafeBytes { saltBytes in
                password.withUnsafeBytes { passwordBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        password.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        rounds,
                        resultBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        length
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSwiftError.cryptoError("Key derivation failed with status: \(status)")
        }
        
        return result
    }
    
    // 加密方法
    func encrypt(_ data: Data, sessionId: String? = nil) throws -> Data {
        switch method {
        case .aes256CFB, .aes128CFB:
            return try encryptAES(data, sessionId: sessionId)
        case .chacha20, .chacha20IETF:
            return try encryptChacha20(data, sessionId: sessionId)
        case .rc4MD5:
            return try encryptRC4MD5(data, sessionId: sessionId)
        case .salsa20:
            return try encryptSalsa20(data, sessionId: sessionId)
        }
    }
    
    // AES 加密
    private func encryptAES(_ data: Data, sessionId: String?) throws -> Data {
        let iv = try getIV(forSession: sessionId, size: method.ivSize)
        var encrypted = Data()
        
        if sessionId == nil {
            encrypted.append(iv)
        }
        
        let sealedBox = try AES.GCM.seal(data,
                                        using: key,
                                        nonce: try AES.GCM.Nonce(data: iv))
        
        encrypted.append(sealedBox.ciphertext)
        encrypted.append(sealedBox.tag)
        return encrypted
    }
    
    // ChaCha20 加密
    private func encryptChacha20(_ data: Data, sessionId: String?) throws -> Data {
        let nonce = try getIV(forSession: sessionId, size: method.ivSize)
        var encrypted = Data()
        
        if sessionId == nil {
            encrypted.append(nonce)
        }
        
        let sealedBox = try ChaChaPoly.seal(data,
                                           using: key,
                                           nonce: try ChaChaPoly.Nonce(data: nonce))
        
        encrypted.append(sealedBox.ciphertext)
        encrypted.append(sealedBox.tag)
        return encrypted
    }
    
    // RC4-MD5 加密
    private func encryptRC4MD5(_ data: Data, sessionId: String?) throws -> Data {
        // RC4-MD5 实现
        throw TFYSwiftError.cryptoError("RC4-MD5 not implemented yet")
    }
    
    // Salsa20 加密
    private func encryptSalsa20(_ data: Data, sessionId: String?) throws -> Data {
        // Salsa20 实现
        throw TFYSwiftError.cryptoError("Salsa20 not implemented yet")
    }
    
    // 解密方法
    func decrypt(_ data: Data, sessionId: String? = nil) throws -> Data {
        switch method {
        case .aes256CFB, .aes128CFB:
            return try decryptAES(data, sessionId: sessionId)
        case .chacha20, .chacha20IETF:
            return try decryptChacha20(data, sessionId: sessionId)
        case .rc4MD5:
            return try decryptRC4MD5(data, sessionId: sessionId)
        case .salsa20:
            return try decryptSalsa20(data, sessionId: sessionId)
        }
    }
    
    // AES 解密
    private func decryptAES(_ data: Data, sessionId: String?) throws -> Data {
        let ivSize = method.ivSize
        let tagSize = 16
        
        guard data.count >= ivSize + tagSize else {
            throw TFYSwiftError.cryptoError("Invalid encrypted data size")
        }
        
        let iv: Data
        let ciphertext: Data
        let tag: Data
        
        if let sessionId = sessionId, let cachedIV = getCachedIV(forSession: sessionId) {
            iv = cachedIV
            ciphertext = data.dropLast(tagSize)
            tag = data.suffix(tagSize)
        } else {
            iv = data.prefix(ivSize)
            ciphertext = data.dropFirst(ivSize).dropLast(tagSize)
            tag = data.suffix(tagSize)
            
            if let sessionId = sessionId {
                cacheIV(iv, forSession: sessionId)
            }
        }
        
        let sealedBox = try AES.GCM.SealedBox(
            nonce: try AES.GCM.Nonce(data: iv),
            ciphertext: ciphertext,
            tag: tag
        )
        
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    // ChaCha20 解密
    private func decryptChacha20(_ data: Data, sessionId: String?) throws -> Data {
        let nonceSize = method.ivSize
        let tagSize = 16
        
        guard data.count >= nonceSize + tagSize else {
            throw TFYSwiftError.cryptoError("Invalid encrypted data size")
        }
        
        let nonce: Data
        let ciphertext: Data
        let tag: Data
        
        if let sessionId = sessionId, let cachedNonce = getCachedIV(forSession: sessionId) {
            nonce = cachedNonce
            ciphertext = data.dropLast(tagSize)
            tag = data.suffix(tagSize)
        } else {
            nonce = data.prefix(nonceSize)
            ciphertext = data.dropFirst(nonceSize).dropLast(tagSize)
            tag = data.suffix(tagSize)
            
            if let sessionId = sessionId {
                cacheIV(nonce, forSession: sessionId)
            }
        }
        
        let sealedBox = try ChaChaPoly.SealedBox(
            nonce: try ChaChaPoly.Nonce(data: nonce),
            ciphertext: ciphertext,
            tag: tag
        )
        
        return try ChaChaPoly.open(sealedBox, using: key)
    }
    
    // RC4-MD5 解密
    private func decryptRC4MD5(_ data: Data, sessionId: String?) throws -> Data {
        // RC4-MD5 实现
        throw TFYSwiftError.cryptoError("RC4-MD5 not implemented yet")
    }
    
    // Salsa20 解密
    private func decryptSalsa20(_ data: Data, sessionId: String?) throws -> Data {
        // Salsa20 实现
        throw TFYSwiftError.cryptoError("Salsa20 not implemented yet")
    }
    
    // IV 管理
    private func getIV(forSession sessionId: String?, size: Int) throws -> Data {
        if let sessionId = sessionId, let cachedIV = getCachedIV(forSession: sessionId) {
            return cachedIV
        }
        return generateIV(size: size)
    }
    
    private func generateIV(size: Int) -> Data {
        var iv = Data(count: size)
        _ = iv.withUnsafeMutableBytes { ptr in
            SecRandomCopyBytes(kSecRandomDefault, size, ptr.baseAddress!)
        }
        return iv
    }
    
    private func cacheIV(_ iv: Data, forSession sessionId: String) {
        ivCacheLock.lock()
        defer { ivCacheLock.unlock() }
        ivCache[sessionId] = iv
    }
    
    private func getCachedIV(forSession sessionId: String) -> Data? {
        ivCacheLock.lock()
        defer { ivCacheLock.unlock() }
        return ivCache[sessionId]
    }
    
    // 清理缓存
    func clearCache() {
        ivCacheLock.lock()
        defer { ivCacheLock.unlock() }
        ivCache.removeAll()
    }
} 
