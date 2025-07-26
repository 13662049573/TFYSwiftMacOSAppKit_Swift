//
//  TFYSwiftNSTokenField.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSTokenField {
    
    @discardableResult
    func delegate(_ delegate: (any NSTokenFieldDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func tokenStyle(_ state: NSTokenField.TokenStyle) -> Self {
        base.tokenStyle = state
        return self
    }
    
    @discardableResult
    func completionDelay(_ delay: TimeInterval) -> Self {
        base.completionDelay = delay
        return self
    }
}
