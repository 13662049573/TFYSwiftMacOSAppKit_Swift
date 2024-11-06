//
//  TFYSwiftStatusItemBackgroundView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

public class TFYSwiftStatusItemBackgroundView: NSView {

    public var windowConfiguration:TFYSwiftStatusItemConfiguration?
    
    public convenience init(frame frameRect: NSRect,configuration:TFYSwiftStatusItemConfiguration) {
        self.init(frame: frameRect)
        self.windowConfiguration = configuration
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.needsDisplay = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        let arrowHeight:CGFloat = TFYDefaultArrowHeight
        let arrowWidth:CGFloat = TFYDefaultArrowWidth
        let cornerRadius:CGFloat = TFYDefaultCornerRadius
        
        let backgroundRect:NSRect = NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), NSHeight(self.bounds)-arrowHeight)
        
        let windowPath:NSBezierPath = NSBezierPath()
        let arrowPath:NSBezierPath = NSBezierPath()
        let backgroundPath:NSBezierPath = NSBezierPath(roundedRect: backgroundRect, xRadius: cornerRadius, yRadius: cornerRadius)
        
        let leftPoint:NSPoint = NSPoint(x: NSWidth(backgroundRect)/2 - arrowWidth/2, y: NSMaxY(backgroundRect))
        let topPoint:NSPoint = NSPoint(x: NSWidth(backgroundRect)/2, y: NSMaxY(backgroundRect) + arrowHeight)
        let rightPoint:NSPoint = NSPoint(x: NSWidth(backgroundRect)/2 + arrowWidth/2, y: NSMaxY(backgroundRect))
        
        arrowPath.move(to: leftPoint)
        arrowPath.curve(to: topPoint, controlPoint1: NSPoint(x: NSWidth(backgroundRect)/2 - arrowWidth/4, y: NSMaxY(backgroundRect)), controlPoint2: NSPoint(x: NSWidth(backgroundRect)/2 - arrowWidth/7, y: NSMaxY(backgroundRect) + arrowHeight))
        arrowPath.curve(to: rightPoint, controlPoint1: NSPoint(x: NSWidth(backgroundRect)/2 + arrowWidth/7, y: NSMaxY(backgroundRect) + arrowHeight), controlPoint2: NSPoint(x: NSWidth(backgroundRect)/2 + arrowWidth/4, y: NSMaxY(backgroundRect)))
        arrowPath.line(to: leftPoint)
        arrowPath.close()
        
        windowPath.append(arrowPath)
        windowPath.append(backgroundPath)
    
        self.windowConfiguration?.backgroundColor?.setFill()
        windowPath.fill()
    }
}
