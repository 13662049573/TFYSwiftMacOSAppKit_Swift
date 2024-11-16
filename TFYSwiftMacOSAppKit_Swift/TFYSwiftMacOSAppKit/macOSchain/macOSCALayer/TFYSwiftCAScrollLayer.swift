//
//  TFYSwiftCAScrollLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public extension Chain where Base: CAScrollLayer {
    
    @discardableResult
    func scroll_to(_ value:NSPoint) -> Self {
        base.scroll(to: value)
        return self
    }
    
    @discardableResult
    func scroll_p(_ value:NSPoint) -> Self {
        base.scroll(value)
        return self
    }

    @discardableResult
    func scrollRectToVisible(_ value:NSRect) -> Self {
        base.scrollRectToVisible(value)
        return self
    }
    
    @discardableResult
    func scrollMode(_ value:String) -> Self {
        base.scrollMode = CAScrollLayerScrollMode(rawValue: value)
        return self
    }
}
