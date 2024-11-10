//
//  TFYSwiftCAReplicatorLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public extension Chain where Base: CAReplicatorLayer {
    
    @discardableResult
    func instanceCount(_ value:Int) -> Self {
        base.instanceCount = value
        return self
    }
    
    @discardableResult
    func preservesDepth(_ value:Bool) -> Self {
        base.preservesDepth = value
        return self
    }
    
    @discardableResult
    func instanceDelay(_ value:CFTimeInterval) -> Self {
        base.instanceDelay = value
        return self
    }
    
    @discardableResult
    func instanceTransform(_ value:CATransform3D) -> Self {
        base.instanceTransform = value
        return self
    }
    
    @discardableResult
    func instanceColor(_ value:CGColor?) -> Self {
        base.instanceColor = value
        return self
    }
    
    @discardableResult
    func instanceRedOffset(_ value:Float) -> Self {
        base.instanceRedOffset = value
        return self
    }
    
    @discardableResult
    func instanceGreenOffset(_ value:Float) -> Self {
        base.instanceGreenOffset = value
        return self
    }
    
    @discardableResult
    func instanceBlueOffset(_ value:Float) -> Self {
        base.instanceBlueOffset = value
        return self
    }
    
    @discardableResult
    func instanceAlphaOffset(_ value:Float) -> Self {
        base.instanceAlphaOffset = value
        return self
    }

}
