//
//  TFYSwiftNSRotationGestureRecognizer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSRotationGestureRecognizer {
    
    @discardableResult
    func rotation(_ value:CGFloat) -> Self {
        base.rotation = value
        return self
    }
    
    @discardableResult
    func rotationInDegrees(_ value:CGFloat) -> Self {
        base.rotationInDegrees = value
        return self
    }
}
