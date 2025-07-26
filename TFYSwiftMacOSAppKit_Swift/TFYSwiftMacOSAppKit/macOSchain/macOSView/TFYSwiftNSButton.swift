//
//  TFYSwiftNSButton.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSButton {
    
    @discardableResult
    func title(_ title: String) -> Self {
        base.title = title
        return self
    }
    
    @discardableResult
    func attributedTitle(_ attr: NSAttributedString) -> Self {
        base.attributedTitle = attr
        return self
    }
    
    @discardableResult
    func alternateTitle(_ title: String) -> Self {
        base.alternateTitle = title
        return self
    }
    
    @discardableResult
    func attributedAlternateTitle(_ attr: NSAttributedString) -> Self {
        base.attributedAlternateTitle = attr
        return self
    }
    
    @discardableResult
    func hasDestructiveAction(_ has: Bool) -> Self {
        base.hasDestructiveAction = has
        return self
    }
    
    @discardableResult
    func sound(_ sound: NSSound) -> Self {
        base.sound = sound
        return self
    }
    
    @discardableResult
    func springLoaded(_ appar: Bool) -> Self {
        base.isSpringLoaded = appar
        return self
    }
    
    @discardableResult
    func maxAcceleratorLevel(_ max: Int) -> Self {
        base.maxAcceleratorLevel = max
        return self
    }
    
    @discardableResult
    func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
        base.bezelStyle = style
        return self
    }
    
    @discardableResult
    func bordered(_ appar: Bool) -> Self {
        base.isBordered = appar
        return self
    }
    
    @discardableResult
    func transparent(_ appar: Bool) -> Self {
        base.isTransparent = appar
        return self
    }
    
    @discardableResult
    func showsBorderOnlyWhileMouseInside(_ appar: Bool) -> Self {
        base.showsBorderOnlyWhileMouseInside = appar
        return self
    }
    
    @discardableResult
    func image(_ image: NSImage) -> Self {
        base.image = image
        return self
    }
    
    @discardableResult
    func alternateImage(_ image: NSImage) -> Self {
        base.alternateImage = image
        return self
    }
    
    @discardableResult
    func imagePosition(_ position: NSControl.ImagePosition) -> Self {
        base.imagePosition = position
        return self
    }
    
    @discardableResult
    func imageScaling(_ scaling: NSImageScaling) -> Self {
        base.imageScaling = scaling
        return self
    }
    
    @discardableResult
    func imageHugsTitle(_ hug: Bool) -> Self {
        base.imageHugsTitle = hug
        return self
    }
    
    @discardableResult
    func symbolConfiguration(_ appar: NSImage.SymbolConfiguration) -> Self {
        base.symbolConfiguration = appar
        return self
    }
    
    @discardableResult
    func bezelColor(_ color: NSColor) -> Self {
        base.bezelColor = color
        return self
    }
    
    @discardableResult
    func contentTintColor(_ color: NSColor) -> Self {
        base.contentTintColor = color
        return self
    }
    
    @discardableResult
    func state(_ state: NSControl.StateValue) -> Self {
        base.state = state
        return self
    }
    
    @discardableResult
    func allowsMixedState(_ appar: Bool) -> Self {
        base.allowsMixedState = appar
        return self
    }
    
    @discardableResult
    func keyEquivalent(_ key: String) -> Self {
        base.keyEquivalent = key
        return self
    }
    
    @discardableResult
    func keyEquivalentModifierMask(_ appar: NSEvent.ModifierFlags) -> Self {
        base.keyEquivalentModifierMask = appar
        return self
    }
    
    @discardableResult
    func setButtonType(_ type: NSButton.ButtonType) -> Self {
        base.setButtonType(type)
        return self
    }
    
    @discardableResult
    func setPeriodicDelay(_ delay: Float,interval: Float) -> Self {
        base.setPeriodicDelay(delay, interval: interval)
        return self
    }
    
    @discardableResult
    func allowsMixedState(_ delay: UnsafeMutablePointer<Float>,interval:UnsafeMutablePointer<Float>) -> Self {
        base.getPeriodicDelay(delay, interval: interval)
        return self
    }
}
