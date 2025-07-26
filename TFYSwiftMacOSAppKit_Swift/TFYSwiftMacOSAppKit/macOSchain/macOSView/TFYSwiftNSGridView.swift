//
//  TFYSwiftNSGridView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSGridView {
    
    @discardableResult
    func xPlacement(_ xp:NSGridCell.Placement) -> Self {
        base.xPlacement = xp
        return self
    }
    
    @discardableResult
    func yPlacement(_ yp:NSGridCell.Placement) -> Self {
        base.yPlacement = yp
        return self
    }
    
    @discardableResult
    func rowAlignment(_ alig:NSGridRow.Alignment) -> Self {
        base.rowAlignment = alig
        return self
    }
    
    @discardableResult
    func rowSpacing(_ spacing:CGFloat) -> Self {
        base.rowSpacing = spacing
        return self
    }
    
    @discardableResult
    func columnSpacing(_ spacing:CGFloat) -> Self {
        base.columnSpacing = spacing
        return self
    }
    
    @discardableResult
    func detachesHiddenViews(_ hRange:NSRange,vRange:NSRange) -> Self {
        base.mergeCells(inHorizontalRange: hRange, verticalRange: vRange)
        return self
    }
}
