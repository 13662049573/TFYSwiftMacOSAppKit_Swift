//
//  TFYSwiftNSTextField.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSTextField {
    
    @discardableResult
    func placeholderString(_ placeholderString: String) -> Self {
        base.placeholderString = placeholderString
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: NSColor) -> Self {
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func attributedStringValue(_ attr: NSAttributedString) -> Self {
        base.attributedStringValue = attr
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
    func delegate(_ delegate: NSTextFieldDelegate) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func bezelStyle(_ style: NSTextField.BezelStyle) -> Self {
        base.bezelStyle = style
        return self
    }
    
    @discardableResult
    func preferredMaxLayoutWidth(_ width: CGFloat) -> Self {
        base.preferredMaxLayoutWidth = width
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
    func lineBreakStrategy(_ strategy: NSParagraphStyle.LineBreakStrategy) -> Self {
        base.lineBreakStrategy = strategy
        return self
    }
    
    @discardableResult
    func automaticTextCompletionEnabled(_ enabled: Bool) -> Self {
        base.isAutomaticTextCompletionEnabled = enabled
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
    func importsGraphics(_ imports: Bool) -> Self {
        base.importsGraphics = imports
        return self
    }
}

// MARK: - TFYSwiftTextField Chain Extension
public extension Chain where Base: TFYSwiftTextField {
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
    func placeholderColor(_ color: NSColor) -> Self {
        base.placeholderColor = color
        return self
    }
    
    @discardableResult
    func delegate_swift(_ delegate: TFYSwiftNotifyingDelegate) -> Self {
        base.delegate_swift = delegate
        return self
    }
}
