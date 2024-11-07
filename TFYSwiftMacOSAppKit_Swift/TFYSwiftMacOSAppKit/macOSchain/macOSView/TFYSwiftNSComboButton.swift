//
//  TFYSwiftNSComboButton.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

@available(macOS 13.0, *)
public extension Chain where Base: NSComboButton {
    
    @discardableResult
    func title(_ title: String) -> Self {
        base.title = title
        return self
    }
    
    @discardableResult
    func image(_ image: NSImage) -> Self {
        base.image = image
        return self
    }
    
    @discardableResult
    func imageScaling(_ imageScaling: NSImageScaling) -> Self {
        base.imageScaling = imageScaling
        return self
    }
    
    @discardableResult
    func menu(_ menu: NSMenu) -> Self {
        base.menu = menu
        return self
    }
    
    @discardableResult
    func style(_ style: NSComboButton.Style) -> Self {
        base.style = style
        return self
    }
}
