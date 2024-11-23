//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import CommonCrypto

/// 加密工具基类 - 提供AES加密解密功能
public class TFYSwiftCrypto {
    // MARK: - 属性
    /// 加密密钥
    private let key: Data
    
    /// 初始化向量
    private let iv: Data
    
    /// 用于同步加密操作的串行队列
    private let cryptoQueue = DispatchQueue(label: "com.tfyswift.crypto")
    
    // MARK: - 初始化方法
    /// 便利初始化方法
    /// - Parameters:
    ///   - password: 用户密码
    ///   - method: 加密方法（支持 aes-128-cfb 和 aes-256-cfb）
    /// - Throws: 不支持的加密方法时抛出错误
    convenience init(password: String, method: String) throws {
        // 根据加密方法确定密钥长度
        let keySize: Int
        switch method.lowercased() {
        case "aes-128-cfb":
            keySize = 16  // 128位密钥
        case "aes-256-cfb":
            keySize = 32  // 256位密钥
        default:
            throw TFYSwiftError.configurationError("不支持的加密方法: \(method)")
        }
        
        // 从密码生成密钥
        let key = TFYSwiftCrypto.generateKey(from: password, size: keySize)
        
        // 生成随机IV（初始化向量）
        var iv = Data(count: 16)
        iv.withUnsafeMutableBytes { buffer in
            if let baseAddress = buffer.baseAddress {
                arc4random_buf(baseAddress, 16)
            }
        }
        
        self.init(key: key, iv: iv)
    }
    
    /// 指定初始化方法
    /// - Parameters:
    ///   - key: 加密密钥
    ///   - iv: 初始化向量
    init(key: Data, iv: Data) {
        self.key = key
        self.iv = iv
    }
    
    // MARK: - 公共方法
    /// 加密数据
    /// - Parameter data: 待加密的数据
    /// - Returns: 加密后的数据
    /// - Throws: 加密失败时抛出错误
    func encrypt(_ data: Data) throws -> Data {
        return try cryptoQueue.sync {
            var outLength = 0
            var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
            
            // 调用CommonCrypto进行加密
            let status = key.withUnsafeBytes { keyBytes in
                iv.withUnsafeBytes { ivBytes in
                    data.withUnsafeBytes { dataBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),      // 加密操作
                            CCAlgorithm(kCCAlgorithmAES), // AES算法
                            CCOptions(kCCOptionPKCS7Padding), // PKCS7填充
                            keyBytes.baseAddress,         // 密钥指针
                            key.count,                    // 密钥长度
                            ivBytes.baseAddress,          // IV指针
                            dataBytes.baseAddress,        // 输入数据指针
                            data.count,                   // 输入数据长度
                            &outBytes,                    // 输出缓冲区
                            outBytes.count,               // 输出缓冲区大小
                            &outLength                    // 实际输出长度
                        )
                    }
                }
            }
            
            guard status == kCCSuccess else {
                throw TFYSwiftError.encryptionError("加密失败，状态码: \(status)")
            }
            
            return Data(outBytes.prefix(outLength))
        }
    }
    
    /// 解密数据
    /// - Parameter data: 待解密的数据
    /// - Returns: 解密后的数据
    /// - Throws: 解密失败时抛出错误
    func decrypt(_ data: Data) throws -> Data {
        return try cryptoQueue.sync {
            var outLength = 0
            var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
            
            // 调用CommonCrypto进行解密
            let status = key.withUnsafeBytes { keyBytes in
                iv.withUnsafeBytes { ivBytes in
                    data.withUnsafeBytes { dataBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),      // 解密操作
                            CCAlgorithm(kCCAlgorithmAES), // AES算法
                            CCOptions(kCCOptionPKCS7Padding), // PKCS7填充
                            keyBytes.baseAddress,         // 密钥指针
                            key.count,                    // 密钥长度
                            ivBytes.baseAddress,          // IV指针
                            dataBytes.baseAddress,        // 输入数据指针
                            data.count,                   // 输入数据长度
                            &outBytes,                    // 输出缓冲区
                            outBytes.count,               // 输出缓冲区大小
                            &outLength                    // 实际输出长度
                        )
                    }
                }
            }
            
            guard status == kCCSuccess else {
                throw TFYSwiftError.decryptionError("解密失败，状态码: \(status)")
            }
            
            return Data(outBytes.prefix(outLength))
        }
    }
    
    // MARK: - 静态方法
    /// 从密码生成密钥
    /// - Parameters:
    ///   - password: 用户密码
    ///   - size: 需要的密钥大小（字节）
    /// - Returns: 生成的密钥数据
    static func generateKey(from password: String, size: Int) -> Data {
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
                
                // 使用PBKDF2算法从密码派生密钥
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),        // PBKDF2算法
                    passwordPtr,                         // 密码指针
                    passwordData.count,                  // 密码长度
                    nil,                                // 盐（此处未使用）
                    0,                                  // 盐长度
                    CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), // 使用HMAC-SHA256
                    10000,                              // 迭代次数
                    keyPtr,                             // 输出密钥指针
                    size                                // 密钥大小
                )
            }
        }
        
        return key
    }
} 
