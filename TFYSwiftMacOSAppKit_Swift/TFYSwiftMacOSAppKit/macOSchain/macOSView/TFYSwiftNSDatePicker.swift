//
//  TFYSwiftNSDatePicker.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSDatePicker {
    
    @discardableResult
    func datePickerStyle(_ value: NSDatePicker.Style) -> Self {
        base.datePickerStyle = value
        return self
    }
    
    @discardableResult
    func bezeled(_ value:Bool) -> Self {
        base.isBezeled = value
        return self
    }
    
    @discardableResult
    func bordered(_ value:Bool) -> Self {
        base.isBordered = value
        return self
    }
    
    @discardableResult
    func drawsBackground(_ value: Bool) -> Self {
        base.drawsBackground = value
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func textColor(_ color: NSColor) -> Self {
        base.textColor = color
        return self
    }
    
    @discardableResult
    func datePickerMode(_ value: NSDatePicker.Mode) -> Self {
        base.datePickerMode = value
        return self
    }
    
    @discardableResult
    func datePickerElements(_ value: NSDatePicker.ElementFlags) -> Self {
        base.datePickerElements = value
        return self
    }
    
    @discardableResult
    func calendar(_ value:Calendar) -> Self {
        base.calendar = value
        return self
    }
    
    @discardableResult
    func locale(_ value: Locale) -> Self {
        base.locale = value
        return self
    }
    
    @discardableResult
    func timeZone(_ value: TimeZone) -> Self {
        base.timeZone = value
        return self
    }
    
    @discardableResult
    func dateValue(_ value: Date) -> Self {
        base.dateValue = value
        return self
    }
    
//    @discardableResult
//    func timeInterval(_ value: TimeInterval) -> Self {
//        base.timeInterval = value
//        return self
//    }
    
    @discardableResult
    func minDate(_ value:Date) -> Self {
        base.minDate = value
        return self
    }
    
    @discardableResult
    func maxDate(_ value:Date) -> Self {
        base.maxDate = value
        return self
    }
    
    @discardableResult
    func presentsCalendarOverlay(_ value: Bool) -> Self {
        base.presentsCalendarOverlay = value
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: (any NSDatePickerCellDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
}
