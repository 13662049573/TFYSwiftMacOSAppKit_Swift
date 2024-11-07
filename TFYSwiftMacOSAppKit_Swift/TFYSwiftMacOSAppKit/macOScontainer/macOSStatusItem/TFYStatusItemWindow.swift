//
//  TFYStatusItemWindow.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYStatusItemWindow: NSPanel {
    
    private var _configuration: TFYStatusItemWindowConfiguration?
    private var userContentView: NSView?
    private var backgroundView: TFYStatusItemWindowBackgroundView?

    public class func statusItemWindowWithConfiguration(configuration: TFYStatusItemWindowConfiguration) -> TFYStatusItemWindow {
        return TFYStatusItemWindow(contentRect:.zero, styleMask:.nonactivatingPanel, backing:.buffered, defer: true, configuration: configuration)
    }

    public init(contentRect: NSRect, styleMask: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool, configuration: TFYStatusItemWindowConfiguration) {
        _configuration = configuration
        super.init(contentRect: contentRect, styleMask: styleMask, backing: bufferingType, defer: flag)
        isOpaque = false
        hasShadow = true
        level = NSWindow.Level.statusBar
        backgroundColor = .clear
        collectionBehavior = [.canJoinAllSpaces,.ignoresCycle]
        appearance = NSAppearance.current
    }

    // 重写 canBecomeKey 属性
    public override var canBecomeKey: Bool {
        return true
    }
    
    public override var contentView: NSView? {
        set {
            guard let contentView = newValue else { return }
            if userContentView === contentView { return }
            let userContentView = contentView
            let bounds = userContentView.bounds
            let antialiasingMask: CAEdgeAntialiasingMask = [.layerLeftEdge,.layerRightEdge,.layerBottomEdge,.layerTopEdge]

            if backgroundView == nil {
                backgroundView = TFYStatusItemWindowBackgroundView(frame: bounds, windowConfiguration: _configuration!)
                backgroundView?.wantsLayer = true
                backgroundView?.layer?.frame = bounds
                backgroundView?.layer?.cornerRadius = TFYDefaultCornerRadius
                backgroundView?.layer?.masksToBounds = true
                backgroundView?.layer?.edgeAntialiasingMask = antialiasingMask
                super.contentView = backgroundView
            }

            if let oldContentView = self.userContentView {
                oldContentView.removeFromSuperview()
            }

            self.userContentView = userContentView
            userContentView.frame = contentRect(forFrameRect: bounds)
            userContentView.autoresizingMask = [.width,.height]
            userContentView.wantsLayer = true
            userContentView.layer?.frame = bounds
            userContentView.layer?.cornerRadius = TFYDefaultCornerRadius
            userContentView.layer?.masksToBounds = true
            userContentView.layer?.edgeAntialiasingMask = antialiasingMask

            backgroundView?.addSubview(userContentView)
        }
        get {
            return userContentView
        }
    }

    public override func frameRect(forContentRect contentRect: NSRect) -> NSRect {
        return NSRect(x: contentRect.minX, y: contentRect.minY, width: contentRect.width, height: contentRect.height + TFYDefaultArrowHeight)
    }
}
