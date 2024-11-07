//
//  TFYSwiftNSTextField.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: TFYSwiftTextField {
    
    @discardableResult
    func placeholderString(_ placeholderString: String) -> Self {
        base.placeholderString = placeholderString
        return self
    }
    
    @discardableResult
    func placeholderStringColor(_ color: NSColor) -> Self {
        base.placeholderStringColor = color
        return self
    }
    
    @discardableResult
    func placeholderAttributedString(_ attr: NSAttributedString) -> Self {
        base.placeholderAttributedString = attr
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: NSColor) -> Self {
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func drawsBackground(_ draws: Bool) -> Self {
        base.drawsBackground = draws
        return self
    }
    
    @discardableResult
    func textColor(_ color: NSColor) -> Self {
        base.textColor = color
        return self
    }
    
    @discardableResult
    func bordered(_ bordered: Bool) -> Self {
        base.isBordered = bordered
        return self
    }
    
    @discardableResult
    func bezeled(_ bezeled: Bool) -> Self {
        base.isBezeled = bezeled
        return self
    }
    
    @discardableResult
    func editable(_ editable: Bool) -> Self {
        base.isEditable = editable
        return self
    }
    
    @discardableResult
    func selectable(_ selectable: Bool) -> Self {
        base.isSelectable = selectable
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSTextFieldDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func bezelStyle(_ state: NSTextField.BezelStyle) -> Self {
        base.bezelStyle = state
        return self
    }
    
    @discardableResult
    func preferredMaxLayoutWidth(_ pre: CGFloat) -> Self {
        base.preferredMaxLayoutWidth = pre
        return self
    }
    
    @discardableResult
    func maximumNumberOfLines(_ max: Int) -> Self {
        base.maximumNumberOfLines = max
        return self
    }
    
    @discardableResult
    func allowsDefaultTighteningForTruncation(_ allows: Bool) -> Self {
        base.allowsDefaultTighteningForTruncation = allows
        return self
    }
    
    @discardableResult
    func lineBreakStrategy(_ state: NSParagraphStyle.LineBreakStrategy) -> Self {
        base.lineBreakStrategy = state
        return self
    }
    
    @discardableResult
    func automaticTextCompletionEnabled(_ autom: Bool) -> Self {
        base.isAutomaticTextCompletionEnabled = autom
        return self
    }
    
    @discardableResult
    func allowsCharacterPickerTouchBarItem(_ allows: Bool) -> Self {
        base.allowsCharacterPickerTouchBarItem = allows
        return self
    }
    
    @discardableResult
    func allowsEditingTextAttributes(_ allows: Bool) -> Self {
        base.allowsEditingTextAttributes = allows
        return self
    }
    
    @discardableResult
    func importsGraphics(_ state: Bool) -> Self {
        base.importsGraphics = state
        return self
    }

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
    func delegate(_ value: (any TFYSwiftNotifyingDelegate)) -> Self {
        base.delegate_swift = value
        return self
    }
}
