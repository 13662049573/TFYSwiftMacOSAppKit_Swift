//
//  TFYSwiftStatusItemWindow.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

public class TFYSwiftStatusItemWindow: NSPanel {

    private var configuration: TFYSwiftStatusItemConfiguration?
    private var userContentView:NSView?
    private var backgroundView:TFYSwiftStatusItemBackgroundView?
    
    static public func statusItemWindowWithConfiguration(configuration:TFYSwiftStatusItemConfiguration) -> TFYSwiftStatusItemWindow {
        let panel = TFYSwiftStatusItemWindow.init(contentRect: .zero, styleMask: .nonactivatingPanel, backing: .buffered, defer: true, configuration: configuration)
        return panel
    }
    
    public convenience init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool,configuration:TFYSwiftStatusItemConfiguration) {
        self.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.configuration = configuration
    }
    
    public override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.isOpaque = false
        self.hasShadow = true
        self.level = NSWindow.Level.statusBar
        self.backgroundColor = .clear
        self.collectionBehavior = [.canJoinAllSpaces,.ignoresCycle]
        self.appearance = NSAppearance.current
    }
    
    public override var canBecomeKey: Bool {
        return true
    }
    
    public override var contentView: NSView? {
        set {
            if ((self.userContentView?.isEqual(newValue)) != nil) {
                return
            }
            let userContentView:NSView = contentView!
            let bounds:NSRect = userContentView.bounds
            let antialiasingMask:CAEdgeAntialiasingMask = [.layerLeftEdge,.layerRightEdge,.layerBottomEdge,.layerTopEdge]
            self.backgroundView = (super.contentView as? TFYSwiftStatusItemBackgroundView)
            if self.backgroundView != nil {
                self.backgroundView = TFYSwiftStatusItemBackgroundView(frame: bounds, configuration: configuration!)
                self.backgroundView?.wantsLayer = true
                self.backgroundView?.layer?.frame = bounds
                self.backgroundView?.layer?.cornerRadius = TFYDefaultCornerRadius
                self.backgroundView?.layer?.masksToBounds = true
                self.backgroundView?.layer?.edgeAntialiasingMask = antialiasingMask
                super.contentView = self.backgroundView
            }
            if self.userContentView != nil {
                self.userContentView?.removeFromSuperview()
            }
            self.userContentView = userContentView
            self.userContentView?.frame = self.contentRect(forFrameRect: bounds)
            self.userContentView?.wantsLayer = true
            self.userContentView?.layer?.frame = bounds
            self.userContentView?.layer?.cornerRadius = TFYDefaultCornerRadius
            self.userContentView?.layer?.masksToBounds = true
            self.userContentView?.layer?.edgeAntialiasingMask = antialiasingMask
            self.backgroundView?.addSubview(self.userContentView!)
        }
        get {
            return self.userContentView
        }
    }
    
    public override func frameRect(forContentRect contentRect: NSRect) -> NSRect {
        return NSMakeRect(NSMinX(contentRect), NSMinY(contentRect), NSWidth(contentRect), NSHeight(contentRect) + TFYDefaultArrowHeight)
    }
}
