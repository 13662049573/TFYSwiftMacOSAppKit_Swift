//
//  TFYSwiftNSRuleEditor.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSRuleEditor {
    @discardableResult
    func delegate(_ delegate: (any NSRuleEditorDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func formattingStringsFilename(_ value: String) -> Self {
        base.formattingStringsFilename = value
        return self
    }
    
    @discardableResult
    func formattingDictionary(_ value: [String : String]) -> Self {
        base.formattingDictionary = value
        return self
    }
    
    @discardableResult
    func nestingMode(_ value: NSRuleEditor.NestingMode) -> Self {
        base.nestingMode = value
        return self
    }
    
    @discardableResult
    func rowHeight(_ value: CGFloat) -> Self {
        base.rowHeight = value
        return self
    }
    
    @discardableResult
    func editable(_ value: Bool) -> Self {
        base.isEditable = value
        return self
    }
    
    @discardableResult
    func canRemoveAllRows(_ value: Bool) -> Self {
        base.canRemoveAllRows = value
        return self
    }
    
    @discardableResult
    func rowClass(_ value: AnyClass) -> Self {
        base.rowClass = value
        return self
    }
    
    @discardableResult
    func rowTypeKeyPath(_ value: String) -> Self {
        base.rowTypeKeyPath = value
        return self
    }
    
    @discardableResult
    func subrowsKeyPath(_ value: String) -> Self {
        base.subrowsKeyPath = value
        return self
    }
    
    @discardableResult
    func criteriaKeyPath(_ value: String) -> Self {
        base.criteriaKeyPath = value
        return self
    }
    
    @discardableResult
    func displayValuesKeyPath(_ value: String) -> Self {
        base.displayValuesKeyPath = value
        return self
    }
}
