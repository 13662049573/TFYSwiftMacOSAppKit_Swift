//
//  TFYSwiftCATextLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

/// CATextLayer的链式扩展
public extension Chain where Base: CATextLayer {
    
    /// 设置文本内容
    /// - Parameter value: 要显示的文本内容（可以是String或NSAttributedString）
    /// - Returns: 链式调用对象
    @discardableResult
    func string(_ value: Any) -> Self {
        base.string = value
        return self
    }
    
    /// 设置字体
    /// - Parameter value: 字体（CFTypeRef类型，通常是CGFont或CTFont）
    /// - Returns: 链式调用对象
    @discardableResult
    func font(_ value: CFTypeRef) -> Self {
        base.font = value
        return self
    }
    
    /// 设置字体大小
    /// - Parameter value: 字体大小（点数）
    /// - Returns: 链式调用对象
    @discardableResult
    func fontSize(_ value: CGFloat) -> Self {
        base.fontSize = value
        return self
    }
    
    /// 设置文本颜色
    /// - Parameter value: 文本颜色（CGColor类型）
    /// - Returns: 链式调用对象
    @discardableResult
    func foregroundColor(_ value: CGColor) -> Self {
        base.foregroundColor = value
        return self
    }
    
    /// 设置是否自动换行
    /// - Parameter value: true表示自动换行，false表示不换行
    /// - Returns: 链式调用对象
    @discardableResult
    func wrapped(_ value: Bool) -> Self {
        base.isWrapped = value
        return self
    }
    
    /// 设置文本截断模式
    /// - Parameter value: 截断模式（开始、中间或结尾）
    /// - Returns: 链式调用对象
    @discardableResult
    func truncationMode(_ value: CATextLayerTruncationMode) -> Self {
        base.truncationMode = value
        return self
    }
    
    /// 设置文本对齐方式
    /// - Parameter value: 对齐方式（左、中、右等）
    /// - Returns: 链式调用对象
    @discardableResult
    func alignmentMode(_ value: CATextLayerAlignmentMode) -> Self {
        base.alignmentMode = value
        return self
    }
    
    /// 设置是否允许字体子像素量化
    /// - Parameter value: true表示允许，false表示不允许
    /// - Returns: 链式调用对象
    @discardableResult
    func allowsFontSubpixelQuantization(_ value: Bool) -> Self {
        base.allowsFontSubpixelQuantization = value
        return self
    }
}

// MARK: - 常量定义

public extension CATextLayer {
    /// 文本截断模式常量
    struct TruncationMode {
        public static let start = CATextLayerTruncationMode.start
        public static let end = CATextLayerTruncationMode.end
        public static let middle = CATextLayerTruncationMode.middle
        public static let none = CATextLayerTruncationMode.none
    }
    
    /// 文本对齐方式常量
    struct AlignmentMode {
        public static let natural = CATextLayerAlignmentMode.natural
        public static let left = CATextLayerAlignmentMode.left
        public static let right = CATextLayerAlignmentMode.right
        public static let center = CATextLayerAlignmentMode.center
        public static let justified = CATextLayerAlignmentMode.justified
    }
}
