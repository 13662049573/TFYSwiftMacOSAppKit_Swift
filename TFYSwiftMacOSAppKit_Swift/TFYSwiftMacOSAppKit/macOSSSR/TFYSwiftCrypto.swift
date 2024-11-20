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
    
    init(password: String, method: TFYSwiftConfig.CryptoMethod) throws {
        // 首先生成密钥
        let salt = "TFYSwift".data(using: .utf8)!
        let passwordData = password.data(using: .utf8)!
        
        // 使用临时方法生成密钥数据
        let keyData = try Self.deriveKey(password: passwordData, salt: salt, length: 32)
        
        // 初始化成员变量
        self.key = SymmetricKey(data: keyData)
        self.method = method
    }
    
    // 将 deriveKey 改为静态方法
    private static func deriveKey(password: Data, salt: Data, length: Int) throws -> Data {
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
                        10000,
                        resultBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        length
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSwiftError.cryptoError("Key derivation failed")
        }
        
        return result
    }
    
    func encrypt(_ data: Data) throws -> Data {
        switch method {
        case .aes256CFB:
            return try encryptAES256CFB(data)
        case .chacha20:
            return try encryptChacha20(data)
        default:
            throw TFYSwiftError.cryptoError("Unsupported method")
        }
    }
    
    private func encryptAES256CFB(_ data: Data) throws -> Data {
        let iv = generateIV(size: 16)
        var encrypted = Data()
        encrypted.append(iv)
        
        let sealedBox = try AES.GCM.seal(data,
                                        using: key,
                                        nonce: try AES.GCM.Nonce(data: iv))
        
        encrypted.append(sealedBox.ciphertext)
        encrypted.append(sealedBox.tag)
        return encrypted
    }
    
    private func encryptChacha20(_ data: Data) throws -> Data {
        let nonce = generateIV(size: 12)
        var encrypted = Data()
        encrypted.append(nonce)
        
        let sealedBox = try ChaChaPoly.seal(data,
                                           using: key,
                                           nonce: try ChaChaPoly.Nonce(data: nonce))
        
        encrypted.append(sealedBox.ciphertext)
        encrypted.append(sealedBox.tag)
        return encrypted
    }
    
    private func generateIV(size: Int) -> Data {
        var iv = Data(count: size)
        _ = iv.withUnsafeMutableBytes { ptr in
            SecRandomCopyBytes(kSecRandomDefault, size, ptr.baseAddress!)
        }
        return iv
    }
    
    func decrypt(_ data: Data) throws -> Data {
        switch method {
        case .aes256CFB:
            return try decryptAES256CFB(data)
        case .chacha20:
            return try decryptChacha20(data)
        default:
            throw TFYSwiftError.cryptoError("Unsupported method")
        }
    }
    
    private func decryptAES256CFB(_ data: Data) throws -> Data {
        guard data.count >= 16 + 16 else { // IV + TAG 最小长度
            throw TFYSwiftError.cryptoError("Invalid encrypted data")
        }
        
        let iv = data.prefix(16)
        let ciphertext = data.dropFirst(16).dropLast(16)
        let tag = data.suffix(16)
        
        let sealedBox = try AES.GCM.SealedBox(
            nonce: try AES.GCM.Nonce(data: iv),
            ciphertext: ciphertext,
            tag: tag
        )
        
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    private func decryptChacha20(_ data: Data) throws -> Data {
        guard data.count >= 12 + 16 else { // Nonce + TAG 最小长度
            throw TFYSwiftError.cryptoError("Invalid encrypted data")
        }
        
        let nonce = data.prefix(12)
        let ciphertext = data.dropFirst(12).dropLast(16)
        let tag = data.suffix(16)
        
        let sealedBox = try ChaChaPoly.SealedBox(
            nonce: try ChaChaPoly.Nonce(data: nonce),
            ciphertext: ciphertext,
            tag: tag
        )
        
        return try ChaChaPoly.open(sealedBox, using: key)
    }
} 
