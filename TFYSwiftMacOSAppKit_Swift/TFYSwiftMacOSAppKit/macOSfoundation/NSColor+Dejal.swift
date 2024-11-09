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
    // hex 颜色值
    convenience init(hexString: String,alpha:CGFloat = 1) {
         let subString = hexString.hasPrefix("0x") || hexString.hasPrefix("0X")
             ? hexString.dropFirst(2)
             : hexString[...]
         let hexString = String(subString)
         let value = hexString.hexValue
         let (r, g, b) = (value >> 16, (value >> 8) % 256, value % 256)
         self.init(red: CGFloat(r) / 256.0,
                   green: CGFloat(g) / 256.0,
                   blue: CGFloat(b) / 256.0,
                   alpha: alpha)
     }
}
