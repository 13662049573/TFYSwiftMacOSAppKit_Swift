//
//  TFYSwiftNSGestureRecognizer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSGestureRecognizer {
    
    @discardableResult
    func delegate(_ delegate:(any NSGestureRecognizerDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func enabled(_ enabled:Bool) -> Self {
        base.isEnabled = enabled
        return self
    }
    
    @discardableResult
    func delaysPrimaryMouseButtonEvents(_ content:Bool) -> Self {
        base.delaysPrimaryMouseButtonEvents = content
        return self
    }
    
    @discardableResult
    func delaysOtherMouseButtonEvents(_ content:Bool) -> Self {
        base.delaysOtherMouseButtonEvents = content
        return self
    }
    
    @discardableResult
    func delaysKeyEvents(_ content:Bool) -> Self {
        base.delaysKeyEvents = content
        return self
    }
    
    @discardableResult
    func delaysMagnificationEvents(_ content:Bool) -> Self {
        base.delaysMagnificationEvents = content
        return self
    }
    
    @discardableResult
    func delaysRotationEvents(_ content:Bool) -> Self {
        base.delaysRotationEvents = content
        return self
    }
    
    @discardableResult
    func pressureConfiguration(_ content:NSPressureConfiguration) -> Self {
        base.pressureConfiguration = content
        return self
    }
    
    @discardableResult
    func target(_ target:AnyObject) -> Self {
        base.target = target
        return self
    }
    
    @discardableResult
    func action(_ action:Selector) -> Self {
        base.action = action
        return self
    }
    
    @discardableResult
    func addTarget(_ target:AnyObject,action:Selector) -> Self {
        base.target = target
        base.action = action
        return self
    }
}
