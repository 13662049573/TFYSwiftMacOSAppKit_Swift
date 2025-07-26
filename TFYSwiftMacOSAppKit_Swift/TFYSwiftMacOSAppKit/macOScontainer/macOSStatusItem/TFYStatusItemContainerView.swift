//
//  TFYStatusItemContainerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

/// 状态栏项容器视图
public class TFYStatusItemContainerView: NSView {
    
    // MARK: - Properties
    
    /// 目标对象
    public weak var target: AnyObject?
    /// 动作选择器
    public var action: Selector?
    
    /// 默认背景颜色
    public var backgroundDefaultColor: NSColor {
        didSet { needsDisplay = true }
    }
    
    /// 高亮背景颜色
    public var backgroundHighlightColor: NSColor {
        didSet { needsDisplay = true }
    }
    
    /// 是否高亮显示
    public var highlighted: Bool = false {
        didSet { needsDisplay = true }
    }
    
    // MARK: - 初始化方法
    
    public override init(frame frameRect: NSRect) {
        backgroundDefaultColor = .clear
        backgroundHighlightColor = .selectedContentBackgroundColor
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 绘制方法
    
    public override func draw(_ dirtyRect: NSRect) {
        let bgPath = NSBezierPath(rect: bounds)
        (highlighted ? backgroundHighlightColor : backgroundDefaultColor).setFill()
        bgPath.fill()
    }
    
    // MARK: - 鼠标事件处理
    
    public override func mouseDown(with event: NSEvent) {
        highlighted = true
        if let action = action {
            target?.perform(action, with: self, afterDelay: 0)
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        highlighted = false
        super.mouseUp(with: event)
    }
}
