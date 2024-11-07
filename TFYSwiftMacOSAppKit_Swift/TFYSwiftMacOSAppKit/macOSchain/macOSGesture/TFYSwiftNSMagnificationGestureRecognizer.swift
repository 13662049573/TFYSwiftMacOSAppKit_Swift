//
//  TFYSwiftNSMagnificationGestureRecognizer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSMagnificationGestureRecognizer {
    
    @discardableResult
    func magnification(_ value:CGFloat) -> Self {
        base.magnification = value
        return self
    }
}
