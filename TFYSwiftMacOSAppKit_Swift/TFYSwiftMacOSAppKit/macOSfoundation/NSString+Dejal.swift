//
//  NSString+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import CommonCrypto
import zlib
import AppKit

extension String {
    
    static func tfy_getCurrentTimes() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let datenow = Date()
        let currentTimeString = formatter.string(from: datenow)
        print("currentTimeString = \(currentTimeString)")
        return currentTimeString
    }
    
    static func tfy_getNowTimeTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let timeZone = TimeZone(identifier: "Asia/Shanghai")!
        formatter.timeZone = timeZone
        let datenow = Date()
        let timeSp = String(Int64(datenow.timeIntervalSince1970))
        return timeSp
    }
    /**
     移除结尾的子字符串, 使用数组传递多个
     */
    func tfy_removeLastSubStringsArray(_ strings: [String]) -> String {
        var result = self
        var isHaveSubString = false
        for subString in strings {
            if result.hasSuffix(subString) {
                result = String(result[..<result.index(result.endIndex, offsetBy: -subString.count)])
                isHaveSubString = true
            }
        }
        if isHaveSubString {
            return result.tfy_removeLastSubStringsArray(strings)
        }
        return result
    }
    /**
     移除结尾的子字符串
     */
    func tfy_removeLastSubString(_ string: String) -> String {
        var result = self
        if result.hasSuffix(string) {
            result = String(result.prefix(result.count - string.count))
            return result.tfy_removeLastSubString(string)
        }
        return result
    }
    
}
