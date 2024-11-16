//
//  TFYSwiftCAScrollLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

/// CAScrollLayer的链式扩展
public extension Chain where Base: CAScrollLayer {
    
    /// 滚动到指定点
    /// - Parameter value: 目标点的坐标
    /// - Returns: 链式调用对象
    @discardableResult
    func scroll_to(_ value: NSPoint) -> Self {
        base.scroll(to: value)
        return self
    }
    
    /// 按指定偏移量滚动
    /// - Parameter value: 滚动的偏移量
    /// - Returns: 链式调用对象
    @discardableResult
    func scroll_p(_ value: NSPoint) -> Self {
        base.scroll(value)
        return self
    }

    /// 滚动使指定矩形区域可见
    /// - Parameter value: 要显示的矩形区域
    /// - Returns: 链式调用对象
    @discardableResult
    func scrollRectToVisible(_ value: NSRect) -> Self {
        base.scrollRectToVisible(value)
        return self
    }
    
    /// 设置滚动模式
    /// - Parameter value: 滚动模式
    /// - Returns: 链式调用对象
    @discardableResult
    func scrollMode(_ value: CAScrollLayerScrollMode) -> Self {
        base.scrollMode = value
        return self
    }
}
