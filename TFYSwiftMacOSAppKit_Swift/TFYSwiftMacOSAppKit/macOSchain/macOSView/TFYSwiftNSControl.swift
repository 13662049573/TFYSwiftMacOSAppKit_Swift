//
//  TFYSwiftNSControl.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSControl {
    
    @discardableResult
    func makeTag(_ makeTag: Int) -> Self {
        base.tag = makeTag
        return self
    }
    
    @discardableResult
    func addTarget(_ target: AnyObject?,action:Selector?) -> Self {
        base.target = target
        base.action = action
        return self
    }
    
    @discardableResult
    func ignoresMultiClick(_ click: Bool) -> Self {
        base.ignoresMultiClick = click
        return self
    }
    
    @discardableResult
    func continuous(_ continuous: Bool) -> Self {
        base.isContinuous = continuous
        return self
    }
    
    @discardableResult
    func enabled(_ enabled: Bool) -> Self {
        base.isEnabled = enabled
        return self
    }
    
    @discardableResult
    func refusesFirstResponder(_ refuses: Bool) -> Self {
        base.refusesFirstResponder = refuses
        return self
    }
    
    @discardableResult
    func highlighted(_ highlighted: Bool) -> Self {
        base.isHighlighted = highlighted
        return self
    }
    
    @discardableResult
    func controlSize(_ size: NSControl.ControlSize) -> Self {
        base.controlSize = size
        return self
    }
    
    @discardableResult
    func formatter(_ formatter: Formatter) -> Self {
        base.formatter = formatter
        return self
    }
    
    @discardableResult
    func objectValue(_ objectValue: Any) -> Self {
        base.objectValue = objectValue
        return self
    }
    
    @discardableResult
    func stringValue(_ stringValue: String) -> Self {
        base.stringValue = stringValue
        return self
    }
    
    @discardableResult
    func attributedStringValue(_ attr: NSAttributedString) -> Self {
        base.attributedStringValue = attr
        return self
    }
    
    @discardableResult
    func integerValue(_ integerValue: Int) -> Self {
        base.integerValue = integerValue
        return self
    }
    
    @discardableResult
    func intValue(_ intValue: Int32) -> Self {
        base.intValue = intValue
        return self
    }
    
    @discardableResult
    func floatValue(_ floatValue: Float) -> Self {
        base.floatValue = floatValue
        return self
    }
    
    @discardableResult
    func doubleValue(_ doubleValue: Double) -> Self {
        base.doubleValue = doubleValue
        return self
    }
    
    @discardableResult
    func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
        base.lineBreakMode = mode
        return self
    }
    
    @discardableResult
    func usesSingleLineMode(_ usesSingleLineMode: Bool) -> Self {
        base.usesSingleLineMode = usesSingleLineMode
        return self
    }
    
    @discardableResult
    func alignment(_ alignment: NSTextAlignment) -> Self {
        base.alignment = alignment
        return self
    }
    
    @discardableResult
    func baseWritingDirection(_ direction: NSWritingDirection) -> Self {
        base.baseWritingDirection = direction
        return self
    }
    
    @discardableResult
    func allowsExpansionToolTips(_ tips: Bool) -> Self {
        base.allowsExpansionToolTips = tips
        return self
    }
    
    @discardableResult
    func cell(_ cell: NSCell) -> Self {
        base.cell = cell
        return self
    }
    
    @discardableResult
    func sizeToFit() -> Self {
        base.sizeToFit()
        return self
    }
}
