//
//  TFYStatusItemWindowBackgroundView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYStatusItemWindowBackgroundView: NSView {
    
    public var windowConfiguration: TFYStatusItemWindowConfiguration?

    public init(frame: NSRect, windowConfiguration: TFYStatusItemWindowConfiguration) {
        self.windowConfiguration = windowConfiguration
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ dirtyRect: NSRect) {
        let arrowHeight: CGFloat = TFYDefaultArrowHeight
        let arrowWidth: CGFloat = TFYDefaultArrowWidth
        let cornerRadius: CGFloat = TFYDefaultCornerRadius
        let backgroundRect = NSRect(x: dirtyRect.minX, y: dirtyRect.minY, width: dirtyRect.width, height: dirtyRect.height - arrowHeight)

        let windowPath = NSBezierPath()
        let arrowPath = NSBezierPath()
        let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: cornerRadius, yRadius: cornerRadius)

        let leftPoint = NSPoint(x: backgroundRect.width / 2 - arrowWidth / 2, y: backgroundRect.maxY)
        let topPoint = NSPoint(x: backgroundRect.width / 2, y: backgroundRect.maxY + arrowHeight)
        let rightPoint = NSPoint(x: backgroundRect.width / 2 + arrowWidth / 2, y: backgroundRect.maxY)

        arrowPath.move(to: leftPoint)
        arrowPath.curve(to: topPoint, controlPoint1: NSPoint(x: backgroundRect.width / 2 - arrowWidth / 4, y: backgroundRect.maxY), controlPoint2: NSPoint(x: backgroundRect.width / 2 - arrowWidth / 7, y: backgroundRect.maxY + arrowHeight))
        arrowPath.curve(to: rightPoint, controlPoint1: NSPoint(x: backgroundRect.width / 2 + arrowWidth / 7, y: backgroundRect.maxY + arrowHeight), controlPoint2: NSPoint(x: backgroundRect.width / 2 + arrowWidth / 4, y: backgroundRect.maxY))
        arrowPath.line(to: leftPoint)
        arrowPath.close()

        windowPath.append(arrowPath)
        windowPath.append(backgroundPath)

        windowConfiguration?.backgroundColor?.setFill()
        windowPath.fill()
    }

    public override var frame: NSRect {
        didSet {
            self.needsDisplay = true
        }
    }
}
