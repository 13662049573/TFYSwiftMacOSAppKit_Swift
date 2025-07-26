//
//  TFYSwiftNSColorWell.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSColorWell {
    
    @discardableResult
    func color(_ color: NSColor) -> Self {
        base.color = color
        return self
    }
    
    @available(macOS 13.0, *)
    @discardableResult
    func colorWellStyle(_ style: NSColorWell.Style) -> Self {
        base.colorWellStyle = style
        return self
    }
    @available(macOS 13.0, *)
    @discardableResult
    func image(_ image: NSImage) -> Self {
        base.image = image
        return self
    }
    @available(macOS 13.0, *)
    @discardableResult
    func pulldownTarget(_ pull: AnyObject) -> Self {
        base.pulldownTarget = pull
        return self
    }
    @available(macOS 13.0, *)
    @discardableResult
    func pulldownAction(_ auto: Selector) -> Self {
        base.pulldownAction = auto
        return self
    }
}
