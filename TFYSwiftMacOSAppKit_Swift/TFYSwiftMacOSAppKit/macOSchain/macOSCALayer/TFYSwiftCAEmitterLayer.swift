//
//  TFYSwiftCAEmitterLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: CAEmitterLayer {
    
    @discardableResult
    func emitterCells(_ value:[CAEmitterCell]) -> Self {
        base.emitterCells = value
        return self
    }
    
    @discardableResult
    func birthRate(_ value:Float) -> Self {
        base.birthRate = value
        return self
    }
    
    @discardableResult
    func lifetime(_ value:Float) -> Self {
        base.lifetime = value
        return self
    }
    
    @discardableResult
    func emitterPosition(_ value:NSPoint) -> Self {
        base.emitterPosition = value
        return self
    }
    
    @discardableResult
    func emitterZPosition(_ value:CGFloat) -> Self {
        base.emitterZPosition = value
        return self
    }
    
    @discardableResult
    func emitterSize(_ value:NSSize) -> Self {
        base.emitterSize = value
        return self
    }
    
    @discardableResult
    func emitterDepth(_ value:CGFloat) -> Self {
        base.emitterDepth = value
        return self
    }
    
    @discardableResult
    func emitterShape(_ value:CAEmitterLayerEmitterShape) -> Self {
        base.emitterShape = value
        return self
    }
    
    @discardableResult
    func emitterMode(_ value:CAEmitterLayerEmitterMode) -> Self {
        base.emitterMode = value
        return self
    }
    
    @discardableResult
    func renderMode(_ value:CAEmitterLayerRenderMode) -> Self {
        base.renderMode = value
        return self
    }
    
    @discardableResult
    func preservesDepth(_ value:Bool) -> Self {
        base.preservesDepth = value
        return self
    }
    
    @discardableResult
    func velocity(_ value:Float) -> Self {
        base.velocity = value
        return self
    }
    
    @discardableResult
    func scale(_ value:Float) -> Self {
        base.scale = value
        return self
    }
    
    @discardableResult
    func spin(_ value:Float) -> Self {
        base.spin = value
        return self
    }
    
    @discardableResult
    func seed(_ value:UInt32) -> Self {
        base.seed = value
        return self
    }

}
