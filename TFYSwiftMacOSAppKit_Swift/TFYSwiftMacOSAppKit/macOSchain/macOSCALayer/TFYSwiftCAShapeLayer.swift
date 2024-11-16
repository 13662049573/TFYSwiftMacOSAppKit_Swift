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
    
    @discardableResult
    func path(_ value:CGPath) -> Self {
        base.path = value
        return self
    }
    
    @discardableResult
    func fillColor(_ value:CGColor?) -> Self {
        base.fillColor = value
        return self
    }
    
    @discardableResult
    func fillRule(_ value:String) -> Self {
        base.fillRule = CAShapeLayerFillRule(rawValue: value)
        return self
    }
    
    @discardableResult
    func strokeColor(_ value:CGColor) -> Self {
        base.strokeColor = value
        return self
    }
    
    @discardableResult
    func strokeStart(_ value:CGFloat) -> Self {
        base.strokeStart = value
        return self
    }
    
    @discardableResult
    func strokeEnd(_ value:CGFloat) -> Self {
        base.strokeEnd = value
        return self
    }
    
    @discardableResult
    func lineWidth(_ value:CGFloat) -> Self {
        base.lineWidth = value
        return self
    }
    
    @discardableResult
    func miterLimit(_ value:CGFloat) -> Self {
        base.miterLimit = value
        return self
    }
    
    @discardableResult
    func lineCap(_ value:String) -> Self {
        base.lineCap = CAShapeLayerLineCap(rawValue: value)
        return self
    }
    
    @discardableResult
    func lineJoin(_ value:String) -> Self {
        base.lineJoin = CAShapeLayerLineJoin(rawValue: value)
        return self
    }
    
    @discardableResult
    func lineDashPhase(_ value:CGFloat) -> Self {
        base.lineDashPhase = value
        return self
    }
    
    @discardableResult
    func lineDashPattern(_ value:[NSNumber]) -> Self {
        base.lineDashPattern = value
        return self
    }
}
