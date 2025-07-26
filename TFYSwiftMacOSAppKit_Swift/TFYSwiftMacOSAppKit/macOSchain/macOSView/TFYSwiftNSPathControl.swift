//
//  TFYSwiftNSPathControl.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSPathControl {
    
    @discardableResult
    func editable(_ value: Bool) -> Self {
        base.isEditable = value
        return self
    }
    
    @discardableResult
    func allowedTypes(_ value: [String]) -> Self {
        base.allowedTypes = value
        return self
    }
    
    @discardableResult
    func placeholderString(_ value: String) -> Self {
        base.placeholderString = value
        return self
    }
    
    @discardableResult
    func placeholderAttributedString(_ value: NSAttributedString) -> Self {
        base.placeholderAttributedString = value
        return self
    }
    
    @discardableResult
    func url(_ value: URL) -> Self {
        base.url = value
        return self
    }
    
    @discardableResult
    func doubleAction(_ value: Selector) -> Self {
        base.doubleAction = value
        return self
    }
    
    @discardableResult
    func pathStyle(_ value: NSPathControl.Style) -> Self {
        base.pathStyle = value
        return self
    }
    
    @discardableResult
    func pathItems(_ value: [NSPathControlItem]) -> Self {
        base.pathItems = value
        return self
    }
    
    @discardableResult
    func backgroundColor(_ value: NSColor) -> Self {
        base.backgroundColor = value
        return self
    }
    
    @discardableResult
    func delegate(_ value: (any NSPathControlDelegate)) -> Self {
        base.delegate = value
        return self
    }
    
    @discardableResult
    func menu(_ value: NSMenu) -> Self {
        base.menu = value
        return self
    }
}
