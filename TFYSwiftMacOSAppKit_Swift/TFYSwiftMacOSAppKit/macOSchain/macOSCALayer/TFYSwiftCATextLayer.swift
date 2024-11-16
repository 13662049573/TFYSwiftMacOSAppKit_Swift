//
//  TFYSwiftCATextLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public extension Chain where Base: CATextLayer {
    
    @discardableResult
    func string(_ value:Any) -> Self {
        base.string = value
        return self
    }
    
    @discardableResult
    func font(_ value:CFTypeRef) -> Self {
        base.font = value
        return self
    }
    
    @discardableResult
    func fontSize(_ value:CGFloat) -> Self {
        base.fontSize = value
        return self
    }
    
    @discardableResult
    func foregroundColor(_ value:CGColor) -> Self {
        base.foregroundColor = value
        return self
    }
    
    @discardableResult
    func wrapped(_ value:Bool) -> Self {
        base.isWrapped = value
        return self
    }
    
    @discardableResult
    func truncationMode(_ value:String) -> Self {
        base.truncationMode = CATextLayerTruncationMode(rawValue: value)
        return self
    }
    
    @discardableResult
    func alignmentMode(_ value:String) -> Self {
        base.alignmentMode = CATextLayerAlignmentMode(rawValue: value)
        return self
    }
    
    @discardableResult
    func allowsFontSubpixelQuantization(_ value:Bool) -> Self {
        base.allowsFontSubpixelQuantization = value
        return self
    }
}
