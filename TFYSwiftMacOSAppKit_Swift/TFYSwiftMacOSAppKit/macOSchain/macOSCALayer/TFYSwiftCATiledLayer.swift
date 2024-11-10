//
//  TFYSwiftCATiledLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public extension Chain where Base: CATiledLayer {
    
    @discardableResult
    func levelsOfDetail(_ value:Int) -> Self {
        base.levelsOfDetail = value
        return self
    }
    
    @discardableResult
    func levelsOfDetailBias(_ value:Int) -> Self {
        base.levelsOfDetailBias = value
        return self
    }
    
    @discardableResult
    func tileSize(_ value:NSSize) -> Self {
        base.tileSize = value
        return self
    }
}
