//
//  TFYSwiftNSPanGestureRecognizer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSPanGestureRecognizer {
    
    @discardableResult
    func buttonMask(_ value:Int) -> Self {
        base.buttonMask = value
        return self
    }
    
    @discardableResult
    func numberOfTouchesRequired(_ value:Int) -> Self {
        base.numberOfTouchesRequired = value
        return self
    }
    
    @discardableResult
    func translation(_ value:NSView) -> Self {
        base.translation(in: value)
        return self
    }
    
    @discardableResult
    func setTranslation(_ point:NSPoint,view:NSView) -> Self {
        base.setTranslation(point, in: view)
        return self
    }

}
