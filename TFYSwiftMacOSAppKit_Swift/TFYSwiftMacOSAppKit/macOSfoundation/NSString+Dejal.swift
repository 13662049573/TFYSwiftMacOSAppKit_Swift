//
//  NSString+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

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
    
    /// 获取字符串的MD5值
    var md5: String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { buffer in
            CC_MD5(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
