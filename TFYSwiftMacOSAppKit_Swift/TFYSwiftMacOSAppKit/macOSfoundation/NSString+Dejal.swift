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
    
    /// 检查字符串是否是有效的URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        // 在macOS中，我们无法使用UIApplication，所以只检查URL格式
        return url.scheme != nil && url.host != nil
    }
    
    /// 检查字符串是否是有效的手机号码（中国大陆）
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^1[3-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    /// 检查字符串是否是有效的身份证号码（中国大陆）
    var isValidIDCard: Bool {
        let idCardRegex = "^[1-9]\\d{5}(18|19|20)\\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$"
        let idCardPredicate = NSPredicate(format: "SELF MATCHES %@", idCardRegex)
        return idCardPredicate.evaluate(with: self)
    }
    
    /// 检查字符串是否是有效的邮政编码（中国大陆）
    var isValidPostalCode: Bool {
        let postalRegex = "^[1-9]\\d{5}$"
        let postalPredicate = NSPredicate(format: "SELF MATCHES %@", postalRegex)
        return postalPredicate.evaluate(with: self)
    }
    
    /// 检查字符串是否是有效的IPv4地址
    var isValidIPv4: Bool {
        let ipv4Regex = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        let ipv4Predicate = NSPredicate(format: "SELF MATCHES %@", ipv4Regex)
        return ipv4Predicate.evaluate(with: self)
    }
    
    /// 检查字符串是否是有效的IPv6地址
    var isValidIPv6: Bool {
        let ipv6Regex = "^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$"
        let ipv6Predicate = NSPredicate(format: "SELF MATCHES %@", ipv6Regex)
        return ipv6Predicate.evaluate(with: self)
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
    /// 计算 SHA256 哈希值（替代已弃用的MD5）
    var sha256String: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { buffer in
            CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    /// 计算 MD5 哈希值（已弃用，建议使用SHA256）
    @available(*, deprecated, message: "MD5已被弃用，建议使用sha256String")
    var md5String: String? {
        return sha256String
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
    

    
    // MARK: - HMAC 函数
    
    /**
     使用指定密钥计算 HMAC-SHA256
     
     - Parameter key: HMAC 密钥
     - Returns: HMAC 哈希值
     */
    func hmacSHA256String(key: String) -> String? {
        guard let keyData = key.data(using: .utf8),
              let messageData = self.data(using: .utf8) else { return nil }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        keyData.withUnsafeBytes { keyBuffer in
            messageData.withUnsafeBytes { messageBuffer in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
                      keyBuffer.baseAddress,
                      keyBuffer.count,
                      messageBuffer.baseAddress,
                      messageBuffer.count,
                      &digest)
            }
        }
        
        return digest.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    /**
     使用指定密钥计算 HMAC-MD5（已弃用，建议使用HMAC-SHA256）
     
     - Parameter key: HMAC 密钥
     - Returns: HMAC 哈希值
     */
    @available(*, deprecated, message: "HMAC-MD5已被弃用，建议使用hmacSHA256String")
    func hmacMD5String(key: String) -> String? {
        return hmacSHA256String(key: key)
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
    
    // MARK: - 高级字符串处理
    
    /// 获取字符串的字符数（考虑表情符号）
    var characterCount: Int {
        return self.count
    }
    
    /// 获取字符串的字节数
    var byteCount: Int {
        return self.utf8.count
    }
    
    /// 获取字符串的单词数
    var wordCount: Int {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.count
    }
    
    /// 获取字符串的行数
    var lineCount: Int {
        return self.components(separatedBy: .newlines).count
    }
    
    /// 截取字符串到指定长度，并添加省略号
    /// - Parameter length: 最大长度
    /// - Returns: 截取后的字符串
    func truncated(to length: Int) -> String {
        guard self.count > length else { return self }
        let index = self.index(self.startIndex, offsetBy: length - 3)
        return String(self[..<index]) + "..."
    }
    
    /// 将字符串按指定长度分割
    /// - Parameter length: 分割长度
    /// - Returns: 分割后的字符串数组
    func split(by length: Int) -> [String] {
        var result: [String] = []
        var currentIndex = self.startIndex
        
        while currentIndex < self.endIndex {
            let endIndex = self.index(currentIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            result.append(String(self[currentIndex..<endIndex]))
            currentIndex = endIndex
        }
        
        return result
    }
    
    /// 将字符串转换为驼峰命名
    var camelCase: String {
        let components = self.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let words = components.filter { !$0.isEmpty }
        
        guard !words.isEmpty else { return self }
        
        let firstWord = words[0].lowercased()
        let remainingWords = words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
        
        return firstWord + remainingWords.joined()
    }
    
    /// 将字符串转换为帕斯卡命名
    var pascalCase: String {
        let camelCase = self.camelCase
        return camelCase.prefix(1).uppercased() + camelCase.dropFirst()
    }
    
    /// 将字符串转换为蛇形命名
    var snakeCase: String {
        return self.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9_]", with: "_", options: .regularExpression)
            .replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
    
    /// 将字符串转换为短横线命名
    var kebabCase: String {
        return self.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1-$2", options: .regularExpression)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9-]", with: "-", options: .regularExpression)
            .replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
    
    /// 将字符串转换为标题格式
    var titleCase: String {
        return self.components(separatedBy: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
    
    /// 将字符串转换为句子格式
    var sentenceCase: String {
        guard !self.isEmpty else { return self }
        return self.prefix(1).uppercased() + self.dropFirst().lowercased()
    }
    
    /// 反转字符串
    var reversed: String {
        return String(self.reversed())
    }
    
    /// 检查字符串是否是回文
    var isPalindrome: Bool {
        let cleaned = self.lowercased().replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
        return cleaned == cleaned.reversed
    }
    
    /// 获取字符串中最常见的字符
    var mostCommonCharacter: Character? {
        let characterCounts = self.reduce(into: [Character: Int]()) { counts, character in
            counts[character, default: 0] += 1
        }
        return characterCounts.max(by: { $0.value < $1.value })?.key
    }
    
    /// 获取字符串中字符的频率分布
    var characterFrequency: [Character: Int] {
        return self.reduce(into: [Character: Int]()) { counts, character in
            counts[character, default: 0] += 1
        }
    }
    
    /// 移除字符串中的重复字符
    var removingDuplicates: String {
        var seen = Set<Character>()
        return self.filter { character in
            if seen.contains(character) {
                return false
            } else {
                seen.insert(character)
                return true
            }
        }
    }
    
    /// 检查字符串是否包含所有指定的字符
    /// - Parameter characters: 要检查的字符集合
    /// - Returns: 是否包含所有字符
    func containsAll(_ characters: Set<Character>) -> Bool {
        let stringCharacters = Set(self)
        return characters.isSubset(of: stringCharacters)
    }
    
    /// 检查字符串是否只包含指定的字符
    /// - Parameter characters: 允许的字符集合
    /// - Returns: 是否只包含指定字符
    func containsOnly(_ characters: Set<Character>) -> Bool {
        let stringCharacters = Set(self)
        return stringCharacters.isSubset(of: characters)
    }
    
    /// 获取字符串的相似度（使用编辑距离）
    /// - Parameter other: 要比较的字符串
    /// - Returns: 相似度（0-1）
    func similarity(to other: String) -> Double {
        let distance = self.levenshteinDistance(to: other)
        let maxLength = max(self.count, other.count)
        return maxLength == 0 ? 1.0 : 1.0 - Double(distance) / Double(maxLength)
    }
    
    /// 计算两个字符串的编辑距离
    /// - Parameter other: 要比较的字符串
    /// - Returns: 编辑距离
    func levenshteinDistance(to other: String) -> Int {
        let selfArray = Array(self)
        let otherArray = Array(other)
        
        var matrix = Array(repeating: Array(repeating: 0, count: otherArray.count + 1), count: selfArray.count + 1)
        
        for i in 0...selfArray.count {
            matrix[i][0] = i
        }
        
        for j in 0...otherArray.count {
            matrix[0][j] = j
        }
        
        for i in 1...selfArray.count {
            for j in 1...otherArray.count {
                if selfArray[i - 1] == otherArray[j - 1] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = Swift.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + 1)
                }
            }
        }
        
        return matrix[selfArray.count][otherArray.count]
    }
}
