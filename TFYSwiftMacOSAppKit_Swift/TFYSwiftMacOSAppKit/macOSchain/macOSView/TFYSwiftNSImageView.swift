//
//  TFYSwiftNSImageView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSImageView {
    
    @discardableResult
    func image(_ image: NSImage) -> Self {
        base.image = image
        return self
    }
    
    @discardableResult
    func editable(_ editable: Bool) -> Self {
        base.isEditable = editable
        return self
    }
    
    @discardableResult
    func imageAlignment(_ alignment: NSImageAlignment) -> Self {
        base.imageAlignment = alignment
        return self
    }
    
    @discardableResult
    func imageScaling(_ imageScaling: NSImageScaling) -> Self {
        base.imageScaling = imageScaling
        return self
    }
    
    @discardableResult
    func imageFrameStyle(_ style: NSImageView.FrameStyle) -> Self {
        base.imageFrameStyle = style
        return self
    }
    
    @discardableResult
    func symbolConfiguration(_ sym: NSImage.SymbolConfiguration) -> Self {
        base.symbolConfiguration = sym
        return self
    }
    
    @discardableResult
    func contentTintColor(_ color: NSColor) -> Self {
        base.contentTintColor = color
        return self
    }
    
    @discardableResult
    func animates(_ animates: Bool) -> Self {
        base.animates = animates
        return self
    }
    
    @discardableResult
    func allowsCutCopyPaste(_ paste: Bool) -> Self {
        base.allowsCutCopyPaste = paste
        return self
    }
    
    @available(macOS 14.0, *)
    @discardableResult
    func preferredImageDynamicRange(_ paste: NSImage.DynamicRange) -> Self {
        base.preferredImageDynamicRange = paste
        return self
    }
}
