//
//  NSTextField+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSTextField {
    
    private struct AssociatedKeys {
        static var placeholderColorName:UnsafeRawPointer = UnsafeRawPointer(bitPattern: "textColor".hashValue)!
    }
    
    var placeholderStringColor:NSColor {
        set {
            objc_setAssociatedObject(self, AssociatedKeys.placeholderColorName,newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            msSetPlaceholder(placeholder: self.placeholderString, color: newValue)
        }
        get {
            return (objc_getAssociatedObject(self, AssociatedKeys.placeholderColorName) as? NSColor)!
        }
    }
    
    func msSetPlaceholder(placeholder: String?, color: NSColor) {
        let font = self.font
        let attrs: [NSAttributedString.Key: Any] = [
           .font: font!,
           .foregroundColor: color
        ]
        let titleStr = placeholder ?? ""
        if titleStr.count > 0 {
            let attributedString = NSMutableAttributedString(string: titleStr, attributes: attrs)
            let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            style.alignment = self.alignment
            attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: titleStr.count))
            self.placeholderAttributedString = attributedString
        }
    }
}
