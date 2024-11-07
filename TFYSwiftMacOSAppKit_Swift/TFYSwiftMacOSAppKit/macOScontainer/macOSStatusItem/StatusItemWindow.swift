//
//  StatusItemWindow.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 状态项窗口类
public class StatusItemWindow: NSPanel {

    // 窗口配置
    private var windowConfiguration: StatusItemConfig?
    // 用户内容视图
    private var userContent: NSView?
    // 背景视图
    private var backgroundView: StatusItemBackgroundView?
    
    // 创建状态项窗口
    public static func statusItemWindowWithConfiguration(configuration: StatusItemConfig) -> StatusItemWindow {
        let panel = StatusItemWindow(contentRect:.zero, styleMask:.nonactivatingPanel, backing:.buffered, defer: true, configuration: configuration)
        return panel
    }
    
    // 便利初始化方法
    public convenience init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool, configuration: StatusItemConfig) {
        self.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.windowConfiguration = configuration
    }
    
    // 初始化方法
    public override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.isOpaque = false
        self.hasShadow = true
        self.level = NSWindow.Level.statusBar
        self.backgroundColor = .clear
        self.collectionBehavior = [.canJoinAllSpaces,.ignoresCycle]
        self.appearance = NSAppearance.current
    }
    
    // 重写 canBecomeKey 属性
    public override var canBecomeKey: Bool {
        return true
    }
    
    // 重写 contentView 属性的设置和获取
    public override var contentView: NSView? {
        set {
            guard ((self.userContent?.isEqual(newValue)) == nil) else { return }
            let oldContentView = self.userContent
            let bounds = newValue?.bounds ?? .zero
            let antialiasingMask: CAEdgeAntialiasingMask = [.layerLeftEdge,.layerRightEdge,.layerBottomEdge,.layerTopEdge]
            self.backgroundView = super.contentView as? StatusItemBackgroundView
            if self.backgroundView != nil {
                self.backgroundView = StatusItemBackgroundView(frame: bounds, configuration: windowConfiguration!)
                self.backgroundView?.wantsLayer = true
                self.backgroundView?.layer?.frame = bounds
                self.backgroundView?.layer?.cornerRadius = TFY_DEFAULT_CORNER_RADIUS
                self.backgroundView?.layer?.masksToBounds = true
                self.backgroundView?.layer?.edgeAntialiasingMask = antialiasingMask
                super.contentView = self.backgroundView
            }
            if oldContentView != nil {
                oldContentView?.removeFromSuperview()
            }
            self.userContent = newValue
            self.userContent?.frame = self.contentRect(forFrameRect: bounds)
            self.userContent?.wantsLayer = true
            self.userContent?.layer?.frame = bounds
            self.userContent?.layer?.cornerRadius = TFY_DEFAULT_CORNER_RADIUS
            self.userContent?.layer?.masksToBounds = true
            self.userContent?.layer?.edgeAntialiasingMask = antialiasingMask
            self.backgroundView?.addSubview(self.userContent!)
        }
        get {
            return self.userContent
        }
    }
    
    // 重写 frameRect(forContentRect:) 方法
    public override func frameRect(forContentRect contentRect: NSRect) -> NSRect {
        return NSMakeRect(NSMinX(contentRect), NSMinY(contentRect), NSWidth(contentRect), NSHeight(contentRect) + TFY_DEFAULT_ARROW_HEIGHT)
    }
}
