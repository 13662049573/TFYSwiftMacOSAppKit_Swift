//
//  TFYSwiftHasFont.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - 字体设置协议

/// 字体设置协议
/// 用于统一处理可以设置字体的控件
public protocol TFYSwiftHasFont: AnyObject {
    /// 设置字体
    /// - Parameter font: 要设置的字体
    func set(font: NSFont)
}

// MARK: - NSText 扩展

extension NSText: TFYSwiftHasFont {
    public func set(font: NSFont) {
        self.font = font
    }
}

// MARK: - NSControl 扩展

extension NSControl: TFYSwiftHasFont {
    public func set(font: NSFont) {
        self.font = font
    }
}

// MARK: - 链式调用扩展

public extension Chain where Base: TFYSwiftHasFont {
    
    /// 设置自定义字体
    /// - Parameter font: 要设置的字体
    /// - Returns: 链式调用对象
    @discardableResult
    func font(_ font: NSFont) -> Self {
        base.set(font: font)
        return self
    }
    
    /// 设置系统字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: 链式调用对象
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat) -> Self {
        base.set(font: NSFont.systemFont(ofSize: fontSize))
        return self
    }
    
    /// 设置粗体系统字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: 链式调用对象
    @discardableResult
    func boldSystemFont(ofSize fontSize: CGFloat) -> Self {
        base.set(font: NSFont.boldSystemFont(ofSize: fontSize))
        return self
    }
    
    /// 设置指定粗细的系统字体
    /// - Parameters:
    ///   - fontSize: 字体大小
    ///   - weight: 字体粗细
    /// - Returns: 链式调用对象
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat, weight: NSFont.Weight) -> Self {
        base.set(font: NSFont.systemFont(ofSize: fontSize, weight: weight))
        return self
    }
    
    /// 设置斜体系统字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: 链式调用对象
    @discardableResult
    func italicSystemFont(ofSize fontSize: CGFloat) -> Self {
        if let font = NSFontManager.shared.font(withFamily: ".AppleSystemUIFont",
                                              traits: .italicFontMask,
                                              weight: 5,
                                              size: fontSize) {
            base.set(font: font)
        }
        return self
    }
    
    /// 设置等宽系统字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: 链式调用对象
    @discardableResult
    func monospaceSystemFont(ofSize fontSize: CGFloat) -> Self {
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        base.set(font: font)
        return self
    }
    
    /// 设置自定义字体族的字体
    /// - Parameters:
    ///   - familyName: 字体族名称
    ///   - fontSize: 字体大小
    /// - Returns: 链式调用对象
    @discardableResult
    func customFont(familyName: String, size fontSize: CGFloat) -> Self {
        if let font = NSFont(name: familyName, size: fontSize) {
            base.set(font: font)
        }
        return self
    }
}
