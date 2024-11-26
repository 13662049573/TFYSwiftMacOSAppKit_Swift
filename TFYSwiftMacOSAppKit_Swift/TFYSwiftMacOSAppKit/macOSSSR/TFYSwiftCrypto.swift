//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

/// 加密工具基类 - 提供AES加密解密功能
public class TFYSwiftCrypto {
    /// 支持的加密方法枚举
    public enum CryptoMethod: String, CaseIterable {
        case aes128cfb = "aes-128-cfb"
        case aes192cfb = "aes-192-cfb"
        case aes256cfb = "aes-256-cfb"
        case aes128ctr = "aes-128-ctr"
        case aes192ctr = "aes-192-ctr"
        case aes256ctr = "aes-256-ctr"
        case camellia128cfb = "camellia-128-cfb"
        case camellia192cfb = "camellia-192-cfb"
        case camellia256cfb = "camellia-256-cfb"
        case chacha20 = "chacha20"
        case chacha20ietf = "chacha20-ietf"
        case rc4md5 = "rc4-md5"
        case none = "none"
        
        /// 密钥长度
        var keySize: Int {
            switch self {
            case .aes128cfb, .aes128ctr, .camellia128cfb, .rc4md5:
                return 16
            case .aes192cfb, .aes192ctr, .camellia192cfb:
                return 24
            case .aes256cfb, .aes256ctr, .camellia256cfb, .chacha20, .chacha20ietf:
                return 32
            case .none:
                return 0
            }
        }
        
        /// IV长度
        var ivSize: Int {
            switch self {
            case .aes128cfb, .aes192cfb, .aes256cfb,
                 .aes128ctr, .aes192ctr, .aes256ctr,
                 .camellia128cfb, .camellia192cfb, .camellia256cfb,
                 .rc4md5:
                return 16
            case .chacha20:
                return 8
            case .chacha20ietf:
                return 12
            case .none:
                return 0
            }
        }
        
        /// 是否支持该加密方法
        public static func isSupported(_ method: String) -> Bool {
            return CryptoMethod.allCases.contains { $0.rawValue == method.lowercased() }
        }
        
        /// 获取所有支持的加密方法
        public static var supportedMethods: [String] {
            return CryptoMethod.allCases.map { $0.rawValue }
        }
    }
    
    private let method: CryptoMethod
    private let key: Data
    private var iv: Data
    private let cryptoQueue = DispatchQueue(label: "com.tfyswift.crypto")
    
    /// 初始化加密器
    /// - Parameters:
    ///   - password: 密码
    ///   - method: 加密方法
    public convenience init(password: String, method: String) throws {
        guard let cryptoMethod = CryptoMethod(rawValue: method.lowercased()) else {
            throw TFYSwiftError.configurationError("不支持的加密方法: \(method)")
        }
        
        let key = TFYSwiftCrypto.generateKey(from: password, size: cryptoMethod.keySize)
        let iv = TFYSwiftCrypto.generateRandomIV(size: cryptoMethod.ivSize)
        
        try self.init(method: cryptoMethod, key: key, iv: iv)
    }
    
    /// 指定初始化方法
    public init(method: CryptoMethod, key: Data, iv: Data) throws {
        guard key.count == method.keySize else {
            throw TFYSwiftError.configurationError("密钥长度不正确")
        }
        guard iv.count == method.ivSize else {
            throw TFYSwiftError.configurationError("IV长度不正确")
        }
        
        self.method = method
        self.key = key
        self.iv = iv
    }
    
    /// 加密数据
    public func encrypt(_ data: Data) throws -> Data {
        return try cryptoQueue.sync {
            // 应用协议处理
            let protocolData = protocolHandler?(data) ?? data
            
            // 加密数据
            let encrypted: Data
            switch method {
            case .aes128cfb, .aes192cfb, .aes256cfb:
                encrypted = try encryptAESCFB(protocolData)
            case .aes128ctr, .aes192ctr, .aes256ctr:
                encrypted = try encryptAESCTR(protocolData)
            case .camellia128cfb, .camellia192cfb, .camellia256cfb:
                encrypted = try encryptCamelliaCFB(protocolData)
            case .chacha20:
                encrypted = try encryptChaCha20(protocolData)
            case .chacha20ietf:
                encrypted = try encryptChaCha20IETF(protocolData)
            case .rc4md5:
                encrypted = try encryptRC4MD5(protocolData)
            case .none:
                encrypted = protocolData
            }
            
            // 应用混淆处理
            return obfsHandler?(encrypted) ?? encrypted
        }
    }
    
    /// 解密数据
    public func decrypt(_ data: Data) throws -> Data {
        return try cryptoQueue.sync {
            // 移除混淆
            let deobfsData = deobfsHandler?(data) ?? data
            
            // 解密数据
            let decrypted: Data
            switch method {
            case .aes128cfb, .aes192cfb, .aes256cfb:
                decrypted = try decryptAESCFB(deobfsData)
            case .aes128ctr, .aes192ctr, .aes256ctr:
                decrypted = try decryptAESCTR(deobfsData)
            case .camellia128cfb, .camellia192cfb, .camellia256cfb:
                decrypted = try decryptCamelliaCFB(deobfsData)
            case .chacha20:
                decrypted = try decryptChaCha20(deobfsData)
            case .chacha20ietf:
                decrypted = try decryptChaCha20IETF(deobfsData)
            case .rc4md5:
                decrypted = try decryptRC4MD5(deobfsData)
            case .none:
                decrypted = deobfsData
            }
            
            // 移除协议处理
            return deprotocolHandler?(decrypted) ?? decrypted
        }
    }
    
    // MARK: - 私有加密方法
    
    private func encryptAESCFB(_ data: Data) throws -> Data {
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        
        let status = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCModeCFB),
                        keyBytes.baseAddress,
                        key.count,
                        ivBytes.baseAddress,
                        dataBytes.baseAddress,
                        data.count,
                        &outBytes,
                        outBytes.count,
                        &outLength
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSwiftError.encryptionError("AES-CFB加密失败: \(status)")
        }
        
        return Data(outBytes.prefix(outLength))
    }
    
    private func decryptAESCFB(_ data: Data) throws -> Data {
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        
        let status = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCModeCFB),
                        keyBytes.baseAddress,
                        key.count,
                        ivBytes.baseAddress,
                        dataBytes.baseAddress,
                        data.count,
                        &outBytes,
                        outBytes.count,
                        &outLength
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSwiftError.decryptionError("AES-CFB解密失败: \(status)")
        }
        
        return Data(outBytes.prefix(outLength))
    }
    
    private func encryptAESCTR(_ data: Data) throws -> Data {
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        
        let status = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCModeCTR),
                        keyBytes.baseAddress,
                        key.count,
                        ivBytes.baseAddress,
                        dataBytes.baseAddress,
                        data.count,
                        &outBytes,
                        outBytes.count,
                        &outLength
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSwiftError.encryptionError("AES-CTR加密失败: \(status)")
        }
        
        return Data(outBytes.prefix(outLength))
    }
    
    private func decryptAESCTR(_ data: Data) throws -> Data {
        // CTR模式下加密和解密操作相同
        return try encryptAESCTR(data)
    }
    
    private func encryptChaCha20(_ data: Data) throws -> Data {
        guard #available(macOS 11.0, *) else {
            throw TFYSwiftError.encryptionError("ChaCha20需要macOS 11.0或更高版本")
        }
        
        let chacha20 = try ChaChaPoly.seal(data,
                                          using: SymmetricKey(data: key),
                                          nonce: try ChaChaPoly.Nonce(data: iv))
        return chacha20.combined
    }
    
    private func decryptChaCha20(_ data: Data) throws -> Data {
        guard #available(macOS 11.0, *) else {
            throw TFYSwiftError.decryptionError("ChaCha20需要macOS 11.0或更高版本")
        }
        
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        return try ChaChaPoly.open(sealedBox, using: SymmetricKey(data: key))
    }
    
    private func encryptRC4MD5(_ data: Data) throws -> Data {
        // 使用MD5生成RC4密钥
        let md5Key = MD5(key + iv)
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count)
        
        let status = md5Key.withUnsafeBytes { keyBytes in
            data.withUnsafeBytes { dataBytes in
                CCCrypt(
                    CCOperation(kCCEncrypt),
                    CCAlgorithm(kCCAlgorithmRC4),
                    0, // RC4没有模式选项
                    keyBytes.baseAddress,
                    md5Key.count,
                    nil, // RC4不使用IV
                    dataBytes.baseAddress,
                    data.count,
                    &outBytes,
                    outBytes.count,
                    &outLength
                )
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSwiftError.encryptionError("RC4-MD5加密失败: \(status)")
        }
        
        return Data(outBytes.prefix(outLength))
    }
    
    private func decryptRC4MD5(_ data: Data) throws -> Data {
        // RC4是对称加密，加密和解密操作相同
        return try encryptRC4MD5(data)
    }
    
    private func encryptCamelliaCFB(_ data: Data) throws -> Data {
        // 由于 CommonCrypto 不直接支持 Camellia，需要使用第三方库或自实现
        // 这里使用简化的实现示例
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count + 16)
        
        let status = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    camellia_cfb_encrypt(
                        dataBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        &outBytes,
                        data.count,
                        keyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        key.count,
                        ivBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        &outLength
                    )
                }
            }
        }
        
        guard status == 0 else {
            throw TFYSwiftError.encryptionError("Camellia-CFB加密失败")
        }
        
        return Data(outBytes.prefix(outLength))
    }
    
    private func decryptCamelliaCFB(_ data: Data) throws -> Data {
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count + 16)
        
        let status = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    camellia_cfb_decrypt(
                        dataBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        &outBytes,
                        data.count,
                        keyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        key.count,
                        ivBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        &outLength
                    )
                }
            }
        }
        
        guard status == 0 else {
            throw TFYSwiftError.decryptionError("Camellia-CFB解密失败")
        }
        
        return Data(outBytes.prefix(outLength))
    }
    
    private func encryptChaCha20IETF(_ data: Data) throws -> Data {
        guard #available(macOS 11.0, *) else {
            throw TFYSwiftError.encryptionError("ChaCha20-IETF需要macOS 11.0或更高版本")
        }
        
        // ChaCha20-IETF 使用12字节的 nonce
        var nonce = iv
        if nonce.count < 12 {
            nonce.append(Data(repeating: 0, count: 12 - nonce.count))
        }
        
        let chacha20 = try ChaChaPoly.seal(
            data,
            using: SymmetricKey(data: key),
            nonce: try ChaChaPoly.Nonce(data: nonce)
        )
        return chacha20.combined
    }
    
    private func decryptChaCha20IETF(_ data: Data) throws -> Data {
        guard #available(macOS 11.0, *) else {
            throw TFYSwiftError.decryptionError("ChaCha20-IETF需要macOS 11.0或更高版本")
        }
        
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        return try ChaChaPoly.open(sealedBox, using: SymmetricKey(data: key))
    }
    
    // MARK: - 辅助方法
    
    /// 生成密钥
    private static func generateKey(from password: String, size: Int) -> Data {
        guard let passwordData = password.data(using: .utf8) else {
            return Data(repeating: 0, count: size)
        }
        
        var key = Data(count: size)
        key.withUnsafeMutableBytes { keyBuffer in
            passwordData.withUnsafeBytes { passwordBuffer in
                guard let keyPtr = keyBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self),
                      let passwordPtr = passwordBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    return
                }
                
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passwordPtr,
                    passwordData.count,
                    nil,
                    0,
                    CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256),
                    10000,
                    keyPtr,
                    size
                )
            }
        }
        
        return key
    }
    
    /// 生成随机IV
    private static func generateRandomIV(size: Int) -> Data {
        var iv = Data(count: size)
        iv.withUnsafeMutableBytes { buffer in
            if let baseAddress = buffer.baseAddress {
                arc4random_buf(baseAddress, size)
            }
        }
        return iv
    }
    
    /// MD5哈希计算
    private func MD5(_ data: Data) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return Data(digest)
    }
    
    /// 更新IV
    private func updateIV() {
        iv = TFYSwiftCrypto.generateRandomIV(size: method.ivSize)
    }
}

// 添加 SSR 特有的加密方法支持

extension TFYSwiftCrypto {
    /// SSR 支持的协议类型
    public enum SSRProtocol: String, CaseIterable {
        case origin = "origin"
        case verify_simple = "verify_simple"
        case verify_sha1 = "verify_sha1"
        case auth_sha1_v4 = "auth_sha1_v4"
        case auth_aes128_md5 = "auth_aes128_md5"
        case auth_aes128_sha1 = "auth_aes128_sha1"
        case auth_chain_a = "auth_chain_a"
        case auth_chain_b = "auth_chain_b"
        
        /// 获取所有支持的协议
        public static var supportedProtocols: [String] {
            return SSRProtocol.allCases.map { $0.rawValue }
        }
    }
    
    /// SSR 支持的混淆方式
    public enum SSRObfs: String, CaseIterable {
        case plain = "plain"
        case http_simple = "http_simple"
        case http_post = "http_post"
        case tls1_2_ticket_auth = "tls1.2_ticket_auth"
        
        /// 获取所有支持的混淆方式
        public static var supportedObfs: [String] {
            return SSRObfs.allCases.map { $0.rawValue }
        }
    }
    
    /// 创建 SSR 加密器
    /// - Parameters:
    ///   - method: 加密方法
    ///   - password: 密码
    ///   - protocol: 协议类型
    ///   - protocolParam: 协议参数
    ///   - obfs: 混淆方式
    ///   - obfsParam: 混淆参数
    /// - Returns: 配置好的加密器实例
    public static func createSSRCrypto(
        method: CryptoMethod,
        password: String,
        protocol: SSRProtocol,
        protocolParam: String?,
        obfs: SSRObfs,
        obfsParam: String?
    ) throws -> TFYSwiftCrypto {
        // 创建加密器实例
        let crypto = try TFYSwiftCrypto(password: password, method: method.rawValue)
        
        // 设置协议处理器
        crypto.protocolHandler = createProtocolHandler(
            type: `protocol`,
            param: protocolParam
        )
        crypto.deprotocolHandler = createDeprotocolHandler(
            type: `protocol`,
            param: protocolParam
        )
        
        // 设置混淆处理器
        crypto.obfsHandler = createObfsHandler(
            type: obfs,
            param: obfsParam
        )
        crypto.deobfsHandler = createDeobfsHandler(
            type: obfs,
            param: obfsParam
        )
        
        return crypto
    }
    
    /// 创建协议处理器
    private static func createProtocolHandler(
        type: SSRProtocol,
        param: String?
    ) -> ((Data) -> Data)? {
        // 根据协议类型返回对应的处理闭包
        switch type {
        case .origin:
            return nil
        case .verify_simple:
            return { data in
                // 实现 verify_simple 协议处理逻辑
                return data
            }
        // 实现其他协议类型...
        default:
            return nil
        }
    }
    
    /// 创建混淆处理器
    private static func createObfsHandler(
        type: SSRObfs,
        param: String?
    ) -> ((Data) -> Data)? {
        // 根据混淆类型返回对应的处理闭包
        switch type {
        case .plain:
            return nil
        case .http_simple:
            return { data in
                // 实现 http_simple 混淆处理逻辑
                return data
            }
        // 实现其他混淆类型...
        default:
            return nil
        }
    }
} 
