//
//  TFYSwiftNSPressGestureRecognizer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSPressGestureRecognizer {
    
    @discardableResult
    func buttonMask(_ value:Int) -> Self {
        base.buttonMask = value
        return self
    }
    
    @discardableResult
    func minimumPressDuration(_ value:TimeInterval) -> Self {
        base.minimumPressDuration = value
        return self
    }
    
    @discardableResult
    func allowableMovement(_ value:CGFloat) -> Self {
        base.allowableMovement = value
        return self
    }
    
    @discardableResult
    func numberOfTouchesRequired(_ value:Int) -> Self {
        base.numberOfTouchesRequired = value
        return self
    }
}
