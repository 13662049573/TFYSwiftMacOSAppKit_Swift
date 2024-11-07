//
//  TFYSwiftNSSecureTextField.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: TFYSwiftSecureTextField {
    
    @discardableResult
    func isTextAlignmentVerticalCenter(_ value: Bool) -> Self {
        base.isTextAlignmentVerticalCenter = value
        return self
    }
    
    @discardableResult
    func Xcursor(_ value: CGFloat) -> Self {
        base.Xcursor = value
        return self
    }
    
    @discardableResult
    func delegate(_ value: (any TFYSwiftSecureTextDelegate)) -> Self {
        base.delegate_swift = value
        return self
    }
}
