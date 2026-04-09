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

    private var trackingAreaRef: NSTrackingArea?
    private var isMouseTrackingSelection = false
    
    // MARK: - 初始化方法
    
    public override init(frame frameRect: NSRect) {
        backgroundDefaultColor = .clear
        backgroundHighlightColor = .selectedContentBackgroundColor
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        backgroundDefaultColor = .clear
        backgroundHighlightColor = .selectedContentBackgroundColor
        super.init(coder: coder)
        wantsLayer = true
    }
    
    // MARK: - 绘制方法
    
    public override func draw(_ dirtyRect: NSRect) {
        let bgPath = NSBezierPath(rect: bounds)
        (highlighted ? backgroundHighlightColor : backgroundDefaultColor).setFill()
        bgPath.fill()
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingAreaRef {
            removeTrackingArea(trackingAreaRef)
        }
        
        let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .enabledDuringMouseDrag, .inVisibleRect]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
        trackingAreaRef = trackingArea
    }
    
    // MARK: - 鼠标事件处理
    
    public override func mouseDown(with event: NSEvent) {
        isMouseTrackingSelection = true
        highlighted = true
    }

    public override func mouseDragged(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        highlighted = bounds.contains(location)
        super.mouseDragged(with: event)
    }
    
    public override func mouseUp(with event: NSEvent) {
        defer {
            highlighted = false
            isMouseTrackingSelection = false
        }

        let location = convert(event.locationInWindow, from: nil)
        if bounds.contains(location), let action {
            NSApp.sendAction(action, to: target, from: self)
        }

        super.mouseUp(with: event)
    }
    
    public override func mouseEntered(with event: NSEvent) {
        if isMouseTrackingSelection {
            highlighted = true
        }
        super.mouseEntered(with: event)
    }
    
    public override func mouseExited(with event: NSEvent) {
        highlighted = false
        super.mouseExited(with: event)
    }
}
