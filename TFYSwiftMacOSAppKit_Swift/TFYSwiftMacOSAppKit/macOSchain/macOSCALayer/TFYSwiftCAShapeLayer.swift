//
//  TFYSwiftCAShapeLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public extension Chain where Base: CAShapeLayer {
    
    /// 设置路径
    @discardableResult
    func path(_ value: CGPath) -> Self {
        base.path = value
        return self
    }
    
    /// 设置填充颜色
    @discardableResult
    func fillColor(_ value: CGColor?) -> Self {
        base.fillColor = value
        return self
    }
    
    /// 设置填充规则
    @discardableResult
    func fillRule(_ value: CAShapeLayerFillRule) -> Self {
        base.fillRule = value
        return self
    }
    
    /// 设置描边颜色
    @discardableResult
    func strokeColor(_ value: CGColor) -> Self {
        base.strokeColor = value
        return self
    }
    
    /// 设置描边起始点
    @discardableResult
    func strokeStart(_ value: CGFloat) -> Self {
        base.strokeStart = value
        return self
    }
    
    /// 设置描边结束点
    @discardableResult
    func strokeEnd(_ value: CGFloat) -> Self {
        base.strokeEnd = value
        return self
    }
    
    /// 设置线宽
    @discardableResult
    func lineWidth(_ value: CGFloat) -> Self {
        base.lineWidth = value
        return self
    }
    
    /// 设置斜接限制
    @discardableResult
    func miterLimit(_ value: CGFloat) -> Self {
        base.miterLimit = value
        return self
    }
    
    /// 设置线帽样式
    @discardableResult
    func lineCap(_ value: CAShapeLayerLineCap) -> Self {
        base.lineCap = value
        return self
    }
    
    /// 设置线条连接样式
    @discardableResult
    func lineJoin(_ value: CAShapeLayerLineJoin) -> Self {
        base.lineJoin = value
        return self
    }
    
    /// 设置虚线偏移量
    @discardableResult
    func lineDashPhase(_ value: CGFloat) -> Self {
        base.lineDashPhase = value
        return self
    }
    
    /// 设置虚线模式
    @discardableResult
    func lineDashPattern(_ value: [NSNumber]) -> Self {
        base.lineDashPattern = value
        return self
    }
}

// MARK: - 常量定义

public extension CAShapeLayer {
    /// 填充规则常量
    struct FillRule {
        public static let nonZero = CAShapeLayerFillRule.nonZero
        public static let evenOdd = CAShapeLayerFillRule.evenOdd
    }
    
    /// 线帽样式常量
    struct LineCap {
        public static let butt = CAShapeLayerLineCap.butt
        public static let round = CAShapeLayerLineCap.round
        public static let square = CAShapeLayerLineCap.square
    }
    
    /// 线条连接样式常量
    struct LineJoin {
        public static let miter = CAShapeLayerLineJoin.miter
        public static let round = CAShapeLayerLineJoin.round
        public static let bevel = CAShapeLayerLineJoin.bevel
    }
}
