//
//  NSString+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import CommonCrypto
import CryptoKit

public extension String {
    /// 日期格式化器，使用静态属性避免重复创建
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return formatter
    }()
    
    /// 获取当前时间的字符串表示
    /// - Parameter format: 日期格式，默认为 "YYYY-MM-dd HH:mm:ss"
    /// - Returns: 格式化后的时间字符串
    static func getCurrentTime(format: String = "YYYY-MM-dd HH:mm:ss") -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }

    /// 获取当前时间的时间戳
    /// - Parameter isMilliseconds: 是否返回毫秒级时间戳
    /// - Returns: 时间戳字符串
    static func getCurrentTimestamp(isMilliseconds: Bool = false) -> String {
        let timeInterval = Date().timeIntervalSince1970
        if isMilliseconds {
            return String(Int64(timeInterval * 1000))
        }
        return String(Int64(timeInterval))
    }

    /// 递归移除字符串末尾的多个子字符串
    /// - Parameter strings: 要移除的子字符串数组
    /// - Returns: 处理后的字符串
    func removeLastSubstrings(_ strings: [String]) -> String {
        var result = self
        while let substringToRemove = strings.first(where: result.hasSuffix) {
            result.removeLast(substringToRemove.count)
        }
        return result
    }

    /// 递归移除字符串末尾的指定子字符串
    /// - Parameter string: 要移除的子字符串
    /// - Returns: 处理后的字符串
    func removeLastSubstring(_ string: String) -> String {
        var result = self
        while result.hasSuffix(string) {
            result.removeLast(string.count)
        }
        return result
    }
    
    /// 将十六进制字符串转换为整数值
    var hexValue: Int {
        let hexString = self.hasPrefix("0x") ? String(self.dropFirst(2)) : self
        return Int(hexString, radix: 16) ?? 0
    }
    
    /// 检查字符串是否为空或仅包含空白字符
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 将字符串转换为URL安全的格式
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
    /// 将字符串转换为Base64编码
    var base64Encoded: String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// 从Base64字符串解码
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// 检查字符串是否是有效的邮箱地址
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// 将字符串转换为日期
    /// - Parameter format: 日期格式
    /// - Returns: 转换后的日期，如果转换失败则返回nil
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        String.dateFormatter.dateFormat = format
        return String.dateFormatter.date(from: self)
    }
    
    /// 获取字符串的哈希值
        /// - Returns: SHA-256 哈希值的十六进制字符串
        var sha256: String {
            guard let data = self.data(using: .utf8) else { return "" }
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()
        }
        
        /// 获取字符串的哈希值（较短版本）
        /// - Returns: SHA-256 哈希值的前16字节的十六进制字符串
        var shortHash: String {
            guard let data = self.data(using: .utf8) else { return "" }
            let hash = SHA256.hash(data: data)
            // 只取前16字节
            return hash.prefix(16).compactMap { String(format: "%02x", $0) }.joined()
        }
        
        /// 获取字符串的 HMAC 哈希值
        /// - Parameter key: 密钥
        /// - Returns: HMAC-SHA256 哈希值的十六进制字符串
        func hmac(key: String) -> String {
            guard let keyData = key.data(using: .utf8),
                  let messageData = self.data(using: .utf8) else { return "" }
            
            let symmetricKey = SymmetricKey(data: keyData)
            let signature = HMAC<SHA256>.authenticationCode(
                for: messageData,
                using: symmetricKey
            )
            return Data(signature).map { String(format: "%02x", $0) }.joined()
        }
}


// MARK: - String 扩展
extension String {
    /// 计算 MD5 哈希值
    var md5String: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { buffer in
            CC_MD5(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    /// 计算 SHA1 哈希值
    var sha1String: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { buffer in
            CC_SHA1(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return digest.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    /// 计算 SHA256 哈希值
    var sha256String: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { buffer in
            CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return digest.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    // MARK: - HMAC 函数
    
    /**
     使用指定密钥计算 HMAC-MD5
     
     - Parameter key: HMAC 密钥
     - Returns: HMAC 哈希值
     */
    func hmacMD5String(key: String) -> String? {
        guard let keyData = key.data(using: .utf8),
              let messageData = self.data(using: .utf8) else { return nil }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        keyData.withUnsafeBytes { keyBuffer in
            messageData.withUnsafeBytes { messageBuffer in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5),
                      keyBuffer.baseAddress,
                      keyBuffer.count,
                      messageBuffer.baseAddress,
                      messageBuffer.count,
                      &digest)
            }
        }
        
        return digest.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    /// URL 解码
    var urlDecoded: String {
        return self.removingPercentEncoding ?? self
    }
    
    // MARK: - 字符串处理
    
    /// 去除首尾空白字符
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 检查字符串是否不为空白
    var isNotBlank: Bool {
        return !self.trimmed.isEmpty
    }
    
    /**
     为文件名添加屏幕缩放倍数后缀
     
     - Parameter scale: 屏幕缩放倍数
     - Returns: 添加缩放倍数后的文件名
     */
    func appendingNameScale(_ scale: CGFloat) -> String {
        guard scale != 1.0, !self.isEmpty, !self.hasSuffix("/") else {
            return self
        }
        return self + "@\(Int(scale))x"
    }
    
    /**
     为文件路径添加屏幕缩放倍数后缀
     
     - Parameter scale: 屏幕缩放倍数
     - Returns: 添加缩放倍数后的文件路径
     */
    func appendingPathScale(_ scale: CGFloat) -> String {
        guard scale != 1.0, !self.isEmpty, !self.hasSuffix("/") else {
            return self
        }
        
        let ext = (self as NSString).pathExtension
        let scaleSuffix = "@\(Int(scale))x"
        
        if ext.isEmpty {
            return self + scaleSuffix
        } else {
            let basePath = (self as NSString).deletingPathExtension
            return basePath + scaleSuffix + "." + ext
        }
    }
    
    // MARK: - JSON 处理
    
    /// 解析 JSON 字符串
    var jsonValueDecoded: Any? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }
    
    // MARK: - 静态方法
    
    /**
     从 Bundle 中加载文本文件
     
     - Parameter name: 文件名
     - Returns: 文件内容
     */
    static func stringNamed(_ name: String) -> String? {
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            return nil
        }
        
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
