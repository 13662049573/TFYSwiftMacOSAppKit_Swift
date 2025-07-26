//
//  TFYSwiftNSSlider.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSSlider {
    
    @discardableResult
    func sliderType(_ type: NSSlider.SliderType) -> Self {
        base.sliderType =  type
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
    func altIncrementValue(_ value: Double) -> Self {
        base.altIncrementValue = value
        return self
    }
    
    @discardableResult
    func trackFillColor(_ color: NSColor) -> Self {
        base.trackFillColor = color
        return self
    }
    
    @discardableResult
    func vertical(_ vertical: Bool) -> Self {
        base.isVertical = vertical
        return self
    }
    
    @discardableResult
    func numberOfTickMarks(_ num: Int) -> Self {
        base.numberOfTickMarks = num
        return self
    }
    
    @discardableResult
    func tickMarkPosition(_ tiak: NSSlider.TickMarkPosition) -> Self {
        base.tickMarkPosition = tiak
        return self
    }
    
    @discardableResult
    func allowsTickMarkValuesOnly(_ only: Bool) -> Self {
        base.allowsTickMarkValuesOnly = only
        return self
    }
    
}
