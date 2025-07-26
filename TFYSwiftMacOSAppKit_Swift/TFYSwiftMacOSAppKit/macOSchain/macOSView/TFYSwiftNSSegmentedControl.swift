//
//  TFYSwiftNSSegmentedControl.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSSegmentedControl {
    
    @discardableResult
    func segmentCount(_ count: Int) -> Self {
        base.segmentCount = count
        return self
    }
    
    @discardableResult
    func selectedSegment(_ paste: Int) -> Self {
        base.selectedSegment = paste
        return self
    }
    
    @discardableResult
    func segmentStyle(_ style: NSSegmentedControl.Style) -> Self {
        base.segmentStyle = style
        return self
    }
    
    @discardableResult
    func springLoaded(_ paste: Bool) -> Self {
        base.isSpringLoaded = paste
        return self
    }
    
    @discardableResult
    func trackingMode(_ paste: NSSegmentedControl.SwitchTracking) -> Self {
        base.trackingMode = paste
        return self
    }
    
    @discardableResult
    func selectedSegmentBezelColor(_ color: NSColor) -> Self {
        base.selectedSegmentBezelColor = color
        return self
    }
    
    @discardableResult
    func segmentDistribution(_ paste: NSSegmentedControl.Distribution) -> Self {
        base.segmentDistribution = paste
        return self
    }
}
