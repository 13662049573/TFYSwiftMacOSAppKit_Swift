//
//  TFYSwiftNSRulerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSRulerView {
    
    @discardableResult
    func scrollView(_ scrollView:NSScrollView) -> Self {
        base.scrollView = scrollView
        return self
    }
    
    @discardableResult
    func orientation(_ orientation:NSRulerView.Orientation) -> Self {
        base.orientation = orientation
        return self
    }
    
    @discardableResult
    func ruleThickness(_ oper:CGFloat) -> Self {
        base.ruleThickness = oper
        return self
    }
    
    @discardableResult
    func reservedThicknessForMarkers(_ oper:CGFloat) -> Self {
        base.reservedThicknessForMarkers = oper
        return self
    }
    
    @discardableResult
    func reservedThicknessForAccessoryView(_ oper:CGFloat) -> Self {
        base.reservedThicknessForAccessoryView = oper
        return self
    }
    
    @discardableResult
    func measurementUnits(_ oper:NSRulerView.UnitName) -> Self {
        base.measurementUnits = oper
        return self
    }
    
    @discardableResult
    func originOffset(_ oper:CGFloat) -> Self {
        base.originOffset = oper
        return self
    }
    
    @discardableResult
    func clientView(_ view:NSView) -> Self {
        base.clientView = view
        return self
    }
    
    @discardableResult
    func markers(_ markers:[NSRulerMarker]) -> Self {
        base.markers = markers
        return self
    }
    
    @discardableResult
    func accessoryView(_ view:NSView) -> Self {
        base.accessoryView = view
        return self
    }
}
