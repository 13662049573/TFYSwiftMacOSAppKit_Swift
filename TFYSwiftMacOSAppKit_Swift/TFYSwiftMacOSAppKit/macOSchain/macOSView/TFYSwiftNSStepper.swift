//
//  TFYSwiftNSStepper.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSStepper {
    
    @discardableResult
    func minValue(_ value: Double) -> Self {
        base.minValue = value
        return self
    }
    
    @discardableResult
    func maxValue(_ value: Double) -> Self {
        base.maxValue = value
        return self
    }
    
    @discardableResult
    func increment(_ value: Double) -> Self {
        base.increment = value
        return self
    }
    
    @discardableResult
    func valueWraps(_ value: Bool) -> Self {
        base.valueWraps = value
        return self
    }
    
    @discardableResult
    func autorepeat(_ value: Bool) -> Self {
        base.autorepeat = value
        return self
    }
}
