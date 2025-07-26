//
//  TFYSwiftNSProgressIndicator.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSProgressIndicator {
    
    @discardableResult
    func indeterminate(_ indeterminate: Bool) -> Self {
        base.isIndeterminate = indeterminate
        return self
    }
    
    @discardableResult
    func bezeled(_ bezeled: Bool) -> Self {
        base.isBezeled = bezeled
        return self
    }
    
    @discardableResult
    func controlTint(_ tint: NSControlTint) -> Self {
        base.controlTint = tint
        return self
    }
    
    @discardableResult
    func controlSize(_ size: NSControl.ControlSize) -> Self {
        base.controlSize = size
        return self
    }
    
    @discardableResult
    func doubleValue(_ doubleValue: Double) -> Self {
        base.doubleValue = doubleValue
        return self
    }
    
    @discardableResult
    func minValue(_ min: Double) -> Self {
        base.minValue = min
        return self
    }
    
    @discardableResult
    func maxValue(_ max: Double) -> Self {
        base.maxValue = max
        return self
    }
    
    @discardableResult
    func usesThreadedAnimation(_ indeterminate: Bool) -> Self {
        base.usesThreadedAnimation = indeterminate
        return self
    }
    
    @discardableResult
    func style(_ style: NSProgressIndicator.Style) -> Self {
        base.style = style
        return self
    }
    
    @discardableResult
    func displayedWhenStopped(_ stopped: Bool) -> Self {
        base.isDisplayedWhenStopped = stopped
        return self
    }
    
    @available(macOS 14.0, *)
    @discardableResult
    func observedProgress(_ progress: Progress) -> Self {
        base.observedProgress = progress
        return self
    }
    
    @discardableResult
    func increment(_ stopped: Double) -> Self {
        base.increment(by: stopped)
        return self
    }
    
    @discardableResult
    func startAnimation(_ stopped: Any) -> Self {
        base.startAnimation(stopped)
        return self
    }
    
    @discardableResult
    func stopAnimation(_ stopped: Any) -> Self {
        base.stopAnimation(stopped)
        return self
    }
    
    @discardableResult
    func sizeToFit() -> Self {
        base.sizeToFit()
        return self
    }
    
}
