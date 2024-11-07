//
//  TFYSwiftCAGradientLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: CAGradientLayer {
    
    @discardableResult
    func colors(_ value:[Any]) -> Self {
        base.colors = value
        return self
    }
    
    @discardableResult
    func locations(_ value:[NSNumber]) -> Self {
        base.locations = value
        return self
    }
    
    @discardableResult
    func startPoint(_ value:CGPoint) -> Self {
        base.startPoint = value
        return self
    }
    
    @discardableResult
    func endPoint(_ value:CGPoint) -> Self {
        base.endPoint = value
        return self
    }
}
