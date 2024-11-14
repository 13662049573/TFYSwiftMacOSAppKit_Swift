//
//  TFYSwiftHasText.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import AppKit

public protocol TFYSwiftHasText {
    
    func set(text: String)
    
    func set(color: NSColor?)
    
    func set(alignment: NSTextAlignment)

}

extension NSTextField: TFYSwiftHasText {
    
    public func set(text: String) {
        self.stringValue = text
    }
    
    public func set(color: NSColor?) {
        self.textColor = color
    }
    
    public func set(alignment: NSTextAlignment) {
        self.alignment = alignment
    }

}

extension NSText: TFYSwiftHasText {
    
    public func set(text: String) {
        self.string = text
    }
    
    public func set(color: NSColor?) {
        self.textColor = color
    }
    
    public func set(alignment: NSTextAlignment) {
        self.alignment = alignment
    }
    
}

extension NSButton: TFYSwiftHasText {
    
    public func set(text: String) {
        self.title = text
    }
    
    public func set(color: NSColor?) {
        tfy_setTextColor(color)
    }
    
    public func set(alignment: NSTextAlignment) {
        self.alignment = alignment
    }
    
    func tfy_setTextColor(_ textColor: NSColor?) {
        
        let attr:NSAttributedString = NSAttributedString(string: title)
        
        let attrTitle = NSMutableAttributedString(attributedString: attr)
        
        let range = NSRange(location: 0, length: attrTitle.length)
        if let color = textColor {
            attrTitle.addAttribute(.foregroundColor, value: color, range: range)
        } else {
            attrTitle.removeAttribute(.foregroundColor, range: range)
        }
        attrTitle.addAttribute(NSAttributedString.Key.font, value: font ?? NSFont.systemFont(ofSize: 14, weight: .regular), range: range)
        attrTitle.fixAttributes(in: range)
        attributedTitle = attrTitle
    }
}

public extension Chain where Base: TFYSwiftHasText {
    
    @discardableResult
    func text(_ text: String) -> Chain {
        base.set(text: text)
        return self
    }
    
    @discardableResult
    func textColor(_ textColor: NSColor) -> Chain {
        base.set(color: textColor)
        return self
    }
    
    @discardableResult
    func textAlignment(_ textAlignment: NSTextAlignment) -> Chain {
        base.set(alignment: textAlignment)
        return self
    }

}
