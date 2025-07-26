//
//  TFYSwiftNSLevelIndicator.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSLevelIndicator {
    
    @discardableResult
    func levelIndicatorStyle(_ value: NSLevelIndicator.Style) -> Self {
        base.levelIndicatorStyle = value
        return self
    }
    
    @discardableResult
    func editable(_ value: Bool) -> Self {
        base.isEditable = value
        return self
    }
    
    @discardableResult
    func minValue(_ value: Double) -> Self {
        base.minValue = value
        return self
    }
    
    @discardableResult
    func maxValue(_ value: Double) -> Self {
        base.maxValue = value
        return self
    }
    
    @discardableResult
    func warningValue(_ value: Double) -> Self {
        base.warningValue = value
        return self
    }
    
    @discardableResult
    func criticalValue(_ value: Double) -> Self {
        base.criticalValue = value
        return self
    }
    
    @discardableResult
    func tickMarkPosition(_ value: NSSlider.TickMarkPosition) -> Self {
        base.tickMarkPosition = value
        return self
    }
    
    @discardableResult
    func numberOfTickMarks(_ value: Int) -> Self {
        base.numberOfTickMarks = value
        return self
    }
    
    @discardableResult
    func numberOfMajorTickMarks(_ value: Int) -> Self {
        base.numberOfMajorTickMarks = value
        return self
    }
    
    @discardableResult
    func drawsTieredCapacityLevels(_ value: Bool) -> Self {
        base.drawsTieredCapacityLevels = value
        return self
    }
    
    @discardableResult
    func placeholderVisibility(_ value: NSLevelIndicator.PlaceholderVisibility) -> Self {
        base.placeholderVisibility = value
        return self
    }
    
    @discardableResult
    func ratingImage(_ value: NSImage) -> Self {
        base.ratingImage = value
        return self
    }
    
    @discardableResult
    func ratingPlaceholderImage(_ value: NSImage) -> Self {
        base.ratingPlaceholderImage = value
        return self
    }
}
