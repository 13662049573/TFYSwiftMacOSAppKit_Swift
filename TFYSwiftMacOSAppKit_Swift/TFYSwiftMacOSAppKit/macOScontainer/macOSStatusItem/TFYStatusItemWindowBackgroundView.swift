//
//  TFYStatusItemWindowBackgroundView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

/// 状态栏窗口背景视图
public class TFYStatusItemWindowBackgroundView: NSView {
    
    // MARK: - Properties
    
    /// 窗口配置
    public weak var windowConfiguration: TFYStatusItemWindowConfiguration?
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// - Parameters:
    ///   - frame: 视图框架
    ///   - windowConfiguration: 窗口配置
    public init(frame: NSRect, windowConfiguration: TFYStatusItemWindowConfiguration) {
        self.windowConfiguration = windowConfiguration
        super.init(frame: frame)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    
    public override func draw(_ dirtyRect: NSRect) {
        guard let backgroundColor = windowConfiguration?.backgroundColor else { return }
        
        let windowPath = createWindowPath(in: dirtyRect)
        backgroundColor.setFill()
        windowPath.fill()
    }
    
    /// 创建窗口路径
    private func createWindowPath(in rect: NSRect) -> NSBezierPath {
        let arrowHeight = TFYDefaultConstants.arrowHeight
        let arrowWidth = TFYDefaultConstants.arrowWidth
        let cornerRadius = TFYDefaultConstants.cornerRadius
        
        let backgroundRect = NSRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - arrowHeight
        )
        
        let windowPath = NSBezierPath()
        windowPath.append(createArrowPath(for: backgroundRect))
        windowPath.append(createBackgroundPath(for: backgroundRect, cornerRadius: cornerRadius))
        
        return windowPath
    }
    
    /// 创建箭头路径
    private func createArrowPath(for rect: NSRect) -> NSBezierPath {
        let arrowPath = NSBezierPath()
        let arrowHeight = TFYDefaultConstants.arrowHeight
        let arrowWidth = TFYDefaultConstants.arrowWidth
        
        let leftPoint = NSPoint(x: rect.width / 2 - arrowWidth / 2, y: rect.maxY)
        let topPoint = NSPoint(x: rect.width / 2, y: rect.maxY + arrowHeight)
        let rightPoint = NSPoint(x: rect.width / 2 + arrowWidth / 2, y: rect.maxY)
        
        arrowPath.move(to: leftPoint)
        arrowPath.curve(
            to: topPoint,
            controlPoint1: NSPoint(x: rect.width / 2 - arrowWidth / 4, y: rect.maxY),
            controlPoint2: NSPoint(x: rect.width / 2 - arrowWidth / 7, y: rect.maxY + arrowHeight)
        )
        arrowPath.curve(
            to: rightPoint,
            controlPoint1: NSPoint(x: rect.width / 2 + arrowWidth / 7, y: rect.maxY + arrowHeight),
            controlPoint2: NSPoint(x: rect.width / 2 + arrowWidth / 4, y: rect.maxY)
        )
        arrowPath.close()
        
        return arrowPath
    }
    
    /// 创建背景路径
    private func createBackgroundPath(for rect: NSRect, cornerRadius: CGFloat) -> NSBezierPath {
        return NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    }
}
