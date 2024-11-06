//
//  TFYSwiftHasFont.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import AppKit

public protocol TFYSwiftHasFont: AnyObject {
    func set(font:NSFont)
}

extension NSButton: TFYSwiftHasFont {
    
    public func set(font: NSFont) {
        self.font = font
    }
}

extension NSTextField: TFYSwiftHasFont {
    
    public func set(font: NSFont) {
        self.font = font
    }
}

extension NSTextView: TFYSwiftHasFont {
    
    public func set(font: NSFont) {
        self.font = font
    }
}

public extension Chain where Base: TFYSwiftHasFont {
    
    @discardableResult
    func font(_ font: NSFont) -> Chain {
        base.set(font:font)
        return self
    }
    
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat) -> Chain {
        base.set(font: NSFont.systemFont(ofSize: fontSize))
        return self
    }
    
    @discardableResult
    func boldSystemFont(ofSize fontSize: CGFloat) -> Chain {
        base.set(font: NSFont.boldSystemFont(ofSize: fontSize))
        return self
    }
    
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat, weight: NSFont.Weight) -> Chain {
        base.set(font: NSFont.systemFont(ofSize: fontSize, weight: weight))
        return self
    }
}
