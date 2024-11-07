//
//  TFYSwiftStatusItemContainerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYSwiftStatusItemContainerView: NSView {
    
    weak var target: AnyObject?
        var action: Selector?
        var backgroundDefaultColor: NSColor? = .clear
        var backgroundHighlightColor: NSColor? = .selectedContentBackgroundColor
        var highlighted = false

        override init(frame: NSRect) {
            super.init(frame: frame)
            self.highlighted = false
            self.backgroundDefaultColor = .clear
            self.backgroundHighlightColor = .selectedContentBackgroundColor
            self.target = nil
            self.action = nil
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit {
            target = nil
            action = nil
            backgroundDefaultColor = nil
            backgroundHighlightColor = nil
        }

    public override func draw(_ dirtyRect: NSRect) {
            let bgPath = NSBezierPath(rect: self.bounds)
        (highlighted ? backgroundHighlightColor : backgroundDefaultColor)!.setFill()
            bgPath.fill()
        }

    public override func mouseDown(with theEvent: NSEvent) {
            highlighted = true
             self.needsDisplay = true
            
            if let target = target, let action = action {
                target.perform(action, with: self)
            }
        }

    public override func mouseUp(with theEvent: NSEvent) {
            highlighted = false
        self.needsDisplay = true
            super.mouseUp(with: theEvent)
        }
}

