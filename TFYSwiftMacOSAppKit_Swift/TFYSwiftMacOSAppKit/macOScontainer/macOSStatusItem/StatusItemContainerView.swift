//
//  StatusItemContainerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 状态项容器视图类
public class StatusItemContainerView: NSView {
    
    // 目标对象和选择器
    weak var target: AnyObject?
    var action: Selector?
    
    // 背景颜色
    @IBInspectable var defaultBackgroundColor: NSColor = .clear
    @IBInspectable var highlightedBackgroundColor: NSColor = .selectedContentBackgroundColor
    
    // 是否高亮状态
    var highlighted = false
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.highlighted = false
        self.defaultBackgroundColor = .clear
        self.highlightedBackgroundColor = .selectedContentBackgroundColor
        self.target = nil
        self.action = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        target = nil
        action = nil
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        let bgPath = NSBezierPath(rect: self.bounds)
        (highlighted ? highlightedBackgroundColor : defaultBackgroundColor).setFill()
        bgPath.fill()
    }
    
    // 处理鼠标按下事件
    public override func mouseDown(with event: NSEvent) {
        handleMouseDown()
    }
    
    // 处理鼠标抬起事件
    public override func mouseUp(with event: NSEvent) {
        handleMouseUp()
        super.mouseUp(with: event)
    }
    
    // 内部方法处理鼠标按下逻辑
    private func handleMouseDown() {
        highlighted = true
        self.needsDisplay = true
        if let target = target, let action = action {
            target.perform(action, with: self)
        }
    }
    
    // 内部方法处理鼠标抬起逻辑
    private func handleMouseUp() {
        highlighted = false
        self.needsDisplay = true
    }
}
