//
//  NSColor+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/8.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 扩展 NSColor，添加自定义方法
public extension NSColor {
    
    // 从给定字符串中提取特定位置和长度的颜色分量值
    static func colorComponent(from string: String, start: Int, length: Int) -> CGFloat {
        // 获取指定范围内的子字符串
        let substring = string.substring(with: string.index(string.startIndex, offsetBy: start)..<string.index(string.startIndex, offsetBy: start + length))
        // 如果长度为 2，则直接使用子字符串，否则重复子字符串
        let fullHex = length == 2 ? substring : substring + substring
        var hexComponent: UInt32 = 0
        // 使用 Scanner 扫描十六进制整数
        Scanner(string: fullHex).scanHexInt32(&hexComponent)
        // 返回标准化后的颜色分量值
        return CGFloat(hexComponent) / 255.0
    }

    // 根据十六进制字符串创建颜色对象
    static func color(withHexString hexString: String) -> NSColor {
        // 去除'#'并转换为大写
        let colorString = hexString.replacingOccurrences(of: "#", with: "").uppercased()
        var alpha: CGFloat = 1.0
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0

        // 根据不同的十六进制字符串长度进行处理
        switch colorString.count {
        case 3: // #RGB
            red = colorComponent(from: colorString, start: 0, length: 1)
            green = colorComponent(from: colorString, start: 1, length: 1)
            blue = colorComponent(from: colorString, start: 2, length: 1)
            break
        case 4: // #ARGB
            alpha = colorComponent(from: colorString, start: 0, length: 1)
            red = colorComponent(from: colorString, start: 1, length: 1)
            green = colorComponent(from: colorString, start: 2, length: 1)
            blue = colorComponent(from: colorString, start: 3, length: 1)
            break
        case 6: // #RRGGBB
            red = colorComponent(from: colorString, start: 0, length: 2)
            green = colorComponent(from: colorString, start: 2, length: 2)
            blue = colorComponent(from: colorString, start: 4, length: 2)
            break
        case 8: // #AARRGGBB
            alpha = colorComponent(from: colorString, start: 0, length: 2)
            red = colorComponent(from: colorString, start: 2, length: 2)
            green = colorComponent(from: colorString, start: 4, length: 2)
            blue = colorComponent(from: colorString, start: 6, length: 2)
            break
        default:
            // 如果十六进制字符串格式不正确，返回 nil
            return .clear
        }

        // 创建并返回颜色对象
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    // 获取预定义的浅蓝色
    static func lightBlue() -> NSColor {
        return hexValue(0x29B5FE, alpha: 1)
    }

    // 获取预定义的浅橙色
    static func lightOrange() -> NSColor {
        return hexValue(0xFFBB50, alpha: 1)
    }

    // 获取预定义的浅绿色
    static func lightGreen() -> NSColor {
        return hexValue(0x1AC756, alpha: 1)
    }

    // 获取预定义的线条颜色
    static func line() -> NSColor {
        return hexValue(0xe4e4e4, alpha: 1)
    }

    // 根据十六进制整数值和透明度创建颜色对象
    static func hexValue(_ rgbValue: Int, alpha: CGFloat) -> NSColor {
        return NSColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0xFF) / 255.0,
                       alpha: alpha)
    }
}
