//
//  StatusItemBackgroundView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

import Cocoa

// 状态项背景视图类
public class StatusItemBackgroundView: NSView {

    // 背景配置
    public var backgroundConfig: StatusItemConfig?

    // 便利初始化方法
    public convenience init(frame frameRect: NSRect, configuration: StatusItemConfig) {
        self.init(frame: frameRect)
        self.backgroundConfig = configuration
    }

    // 初始化方法
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.needsDisplay = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 绘制方法
    public override func draw(_ dirtyRect: NSRect) {
        drawBackground()
    }

    // 绘制背景的方法
    private func drawBackground() {
        let arrowHeight = TFY_DEFAULT_ARROW_HEIGHT
        let arrowWidth = TFY_DEFAULT_ARROW_WIDTH
        let cornerRadius = TFY_DEFAULT_CORNER_RADIUS

        let backgroundRect = NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), NSHeight(self.bounds) - arrowHeight)

        let windowPath = NSBezierPath()
        let arrowPath = NSBezierPath()
        let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: cornerRadius, yRadius: cornerRadius)

        let leftPoint = NSPoint(x: NSWidth(backgroundRect)/2 - arrowWidth/2, y: NSMaxY(backgroundRect))
        let topPoint = NSPoint(x: NSWidth(backgroundRect)/2, y: NSMaxY(backgroundRect) + arrowHeight)
        let rightPoint = NSPoint(x: NSWidth(backgroundRect)/2 + arrowWidth/2, y: NSMaxY(backgroundRect))

        arrowPath.move(to: leftPoint)
        arrowPath.curve(to: topPoint, controlPoint1: NSPoint(x: NSWidth(backgroundRect)/2 - arrowWidth/4, y: NSMaxY(backgroundRect)), controlPoint2: NSPoint(x: NSWidth(backgroundRect)/2 - arrowWidth/7, y: NSMaxY(backgroundRect) + arrowHeight))
        arrowPath.curve(to: rightPoint, controlPoint1: NSPoint(x: NSWidth(backgroundRect)/2 + arrowWidth/7, y: NSMaxY(backgroundRect) + arrowHeight), controlPoint2: NSPoint(x: NSWidth(backgroundRect)/2 + arrowWidth/4, y: NSMaxY(backgroundRect)))
        arrowPath.line(to: leftPoint)
        arrowPath.close()

        windowPath.append(arrowPath)
        windowPath.append(backgroundPath)

        backgroundConfig?.backgroundColor?.setFill()
        windowPath.fill()
    }
}
