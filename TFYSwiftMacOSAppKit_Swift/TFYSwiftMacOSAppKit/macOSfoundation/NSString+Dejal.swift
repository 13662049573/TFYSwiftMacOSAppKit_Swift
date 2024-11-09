//
//  NSString+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension String {
    // 获取当前时间的字符串表示，格式为 YYYY-MM-dd HH:mm:ss
    static func getCurrentTimes() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }

    // 获取当前时间的时间戳字符串表示
    static func getNowTimeTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let timeInterval = Date().timeIntervalSince1970
        return String(Int64(timeInterval))
    }

    // 递归地移除字符串结尾的多个子字符串，使用数组传递多个子字符串
    func removeLastSubStringsArray(_ strings: [String]) -> String {
        var currentStr = self
        while let substringToRemove = strings.first(where: currentStr.hasSuffix) {
            currentStr = String(currentStr[..<currentStr.index(currentStr.endIndex, offsetBy: -substringToRemove.count)])
        }
        return currentStr
    }

    // 递归地移除字符串结尾的单个子字符串
    func removeLastSubString(_ string: String) -> String {
        var currentStr = self
        while currentStr.hasSuffix(string) {
            currentStr = String(currentStr.prefix(currentStr.count - string.count))
        }
        return currentStr
    }
    
    internal var hexValue: Int {
        let string = self.hasPrefix("0x")
            ? self.dropFirst(2)
            : self[...]
        return Int(string, radix: 16) ?? 0
    }
}
