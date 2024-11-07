//
//  TFYSwiftNSBox.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSBox {
    
    @discardableResult
    func boxType(_ type:NSBox.BoxType) -> Self {
        base.boxType = type
        return self
    }
    
    @discardableResult
    func titlePosition(_ position:NSBox.TitlePosition) -> Self {
        base.titlePosition = position
        return self
    }
    
    @discardableResult
    func title(_ title:String) -> Self {
        base.title = title
        return self
    }
    
    @discardableResult
    func titleFont(_ font:NSFont) -> Self {
        base.titleFont = font
        return self
    }
    
    @discardableResult
    func contentViewMargins(_ size:NSSize) -> Self {
        base.contentViewMargins = size
        return self
    }
    
    @discardableResult
    func contentView(_ view:NSView) -> Self {
        base.contentView = view
        return self
    }
    
    @discardableResult
    func transparent(_ transparent:Bool) -> Self {
        base.isTransparent = transparent
        return self
    }
    
    @discardableResult
    func fillColor(_ color:NSColor) -> Self {
        base.fillColor = color
        return self
    }
    
    @discardableResult
    func sizeToFit() -> Self {
        base.sizeToFit()
        return self
    }
}
