//
//  TFYSwiftHasText.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import AppKit

// MARK: - 文本设置协议

/// 文本设置协议
/// 用于统一处理可以设置文本属性的控件
public protocol TFYSwiftHasText: AnyObject {
    /// 设置文本内容
    /// - Parameter text: 要设置的文本
    func set(text: String)
    
    /// 设置文本颜色
    /// - Parameter color: 要设置的颜色
    func set(color: NSColor?)
    
    /// 设置文本对齐方式
    /// - Parameter alignment: 对齐方式
    func set(alignment: NSTextAlignment)
}

// MARK: - NSTextField 扩展

extension NSTextField: TFYSwiftHasText {
    public func set(text: String) {
        self.stringValue = text
    }
    
    public func set(color: NSColor?) {
        self.textColor = color
    }
    
    public func set(alignment: NSTextAlignment) {
        self.alignment = alignment
    }
}

// MARK: - NSText 扩展

extension NSText: TFYSwiftHasText {
    public func set(text: String) {
        self.string = text
    }
    
    public func set(color: NSColor?) {
        self.textColor = color
    }
    
    public func set(alignment: NSTextAlignment) {
        self.alignment = alignment
    }
}

// MARK: - NSButton 扩展

extension NSButton: TFYSwiftHasText {
    public func set(text: String) {
        self.title = text
    }
    
    public func set(color: NSColor?) {
        tfy_setTextColor(color)
    }
    
    public func set(alignment: NSTextAlignment) {
        self.alignment = alignment
    }
    
    /// 设置按钮文本颜色
    /// - Parameter textColor: 要设置的颜色
    private func tfy_setTextColor(_ textColor: NSColor?) {
        let attr = NSAttributedString(string: title)
        let attrTitle = NSMutableAttributedString(attributedString: attr)
        let range = NSRange(location: 0, length: attrTitle.length)
        
        // 设置文本颜色
        if let color = textColor {
            attrTitle.addAttribute(.foregroundColor, value: color, range: range)
        } else {
            attrTitle.removeAttribute(.foregroundColor, range: range)
        }
        
        // 设置字体
        let currentFont = font ?? NSFont.systemFont(ofSize: 14, weight: .regular)
        attrTitle.addAttribute(.font, value: currentFont, range: range)
        
        // 修复属性
        attrTitle.fixAttributes(in: range)
        attributedTitle = attrTitle
    }
}

// MARK: - 链式调用扩展

public extension Chain where Base: TFYSwiftHasText {
    
    /// 设置文本内容
    /// - Parameter text: 要设置的文本
    /// - Returns: 链式调用对象
    @discardableResult
    func text(_ text: String) -> Self {
        base.set(text: text)
        return self
    }
    
    /// 设置文本颜色
    /// - Parameter textColor: 要设置的颜色
    /// - Returns: 链式调用对象
    @discardableResult
    func textColor(_ textColor: NSColor) -> Self {
        base.set(color: textColor)
        return self
    }
    
    /// 设置文本对齐方式
    /// - Parameter textAlignment: 对齐方式
    /// - Returns: 链式调用对象
    @discardableResult
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        base.set(alignment: textAlignment)
        return self
    }
    
    /// 设置富文本内容
    /// - Parameter attributedString: 富文本字符串
    /// - Returns: 链式调用对象
    @discardableResult
    func attributedText(_ attributedString: NSAttributedString) -> Self {
        switch base {
        case let textField as NSTextField:
            textField.attributedStringValue = attributedString
        case let text as NSText:
            text.string = attributedString.string
            if let color = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor {
                text.textColor = color
            }
            if let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? NSFont {
                text.font = font
            }
        case let button as NSButton:
            button.attributedTitle = attributedString
        default:
            break
        }
        return self
    }
    
    /// 设置占位符文本（仅适用于NSTextField）
    /// - Parameter placeholder: 占位符文本
    /// - Returns: 链式调用对象
    @discardableResult
    func placeholder(_ placeholder: String) -> Self {
        if let textField = base as? NSTextField {
            textField.placeholderString = placeholder
        }
        return self
    }
}
