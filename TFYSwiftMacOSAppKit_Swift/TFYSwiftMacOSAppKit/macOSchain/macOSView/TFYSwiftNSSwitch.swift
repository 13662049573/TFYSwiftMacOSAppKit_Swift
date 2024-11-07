//
//  TFYSwiftNSSwitch.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSSwitch {
    
    @discardableResult
    func state(_ state: NSControl.StateValue) -> Self {
        base.state = state
        return self
    }
}
