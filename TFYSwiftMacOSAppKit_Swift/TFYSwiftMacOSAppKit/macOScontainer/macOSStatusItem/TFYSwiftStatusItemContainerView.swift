//
//  TFYSwiftStatusItemContainerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

public typealias actionContainerBlock = (_ view:TFYSwiftStatusItemContainerView) -> Void

public class TFYSwiftStatusItemContainerView: NSControl {

    var backgroundDefaultColor:NSColor?
    var backgroundHighlightColor:NSColor?

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.backgroundDefaultColor = .clear
        self.backgroundHighlightColor = .selectedContentBackgroundColor
        
        self.target = nil
        self.action = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.target = nil
        self.action = nil
        self.backgroundDefaultColor = nil
        self.backgroundHighlightColor = nil
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        let bgPath:NSBezierPath = NSBezierPath(rect: self.bounds)
        (self.isHighlighted ? self.backgroundHighlightColor : self.backgroundDefaultColor)!.setFill()
        bgPath.fill()
    }
    
    public override func moveDown(_ sender: Any?) {
        self.isHighlighted = true
        self.needsDisplay = true
        if (self.target != nil) && (self.action != nil) {
            self.target?.perform(self.action!, with: self, afterDelay: 0)
        }
    }
    
    public override func moveUp(_ sender: Any?) {
        self.isHighlighted = false
        self.needsDisplay = true
        super.moveUp(sender)
    }
}

