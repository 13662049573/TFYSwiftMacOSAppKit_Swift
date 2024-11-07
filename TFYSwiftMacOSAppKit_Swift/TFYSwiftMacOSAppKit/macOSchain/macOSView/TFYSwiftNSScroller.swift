//
//  TFYSwiftNSScroller.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSScroller {
    
    @discardableResult
    func scrollerStyle(_ style: NSScroller.Style) -> Self {
        base.scrollerStyle = style
        return self
    }
    
    @discardableResult
    func knobStyle(_ paste: NSScroller.KnobStyle) -> Self {
        base.knobStyle = paste
        return self
    }
    
    @discardableResult
    func knobProportion(_ paste: CGFloat) -> Self {
        base.knobProportion = paste
        return self
    }
}
