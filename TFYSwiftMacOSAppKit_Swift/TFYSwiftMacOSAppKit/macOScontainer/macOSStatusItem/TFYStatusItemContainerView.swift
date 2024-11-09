//
//  TFYStatusItemContainerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYStatusItemContainerView: NSView {
    public var target: AnyObject?
    public var action: Selector?
    public var backgroundDefaultColor: NSColor = .clear
    public var backgroundHighlightColor: NSColor = .selectedContentBackgroundColor
    public var highlighted: Bool = false

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        highlighted = false
        backgroundDefaultColor = .clear
        backgroundHighlightColor = .selectedContentBackgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        target = nil
        action = nil
    }

    public override func draw(_ dirtyRect: NSRect) {
        let bgPath = NSBezierPath(rect: bounds)
        (highlighted ? backgroundHighlightColor : backgroundDefaultColor).setFill()
        bgPath.fill()
    }

    public override func mouseDown(with event: NSEvent) {
        highlighted = true
        needsDisplay = true
        if let target = target, let action = action {
            target.perform(action, with: self, afterDelay: 0)
        }
    }

    public override func mouseUp(with event: NSEvent) {
        highlighted = false
        needsDisplay = true
        super.mouseUp(with: event)
    }
}
