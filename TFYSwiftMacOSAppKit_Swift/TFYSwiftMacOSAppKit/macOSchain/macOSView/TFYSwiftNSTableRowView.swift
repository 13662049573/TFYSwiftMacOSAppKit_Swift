//
//  TFYSwiftNSTableRowView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSTableRowView {
    
    @discardableResult
    func selectionHighlightStyle(_ style:NSTableView.SelectionHighlightStyle) -> Self {
        base.selectionHighlightStyle = style
        return self
    }
    
    @discardableResult
    func emphasized(_ emphasized:Bool) -> Self {
        base.isEmphasized = emphasized
        return self
    }
    
    @discardableResult
    func groupRowStyle(_ style:Bool) -> Self {
        base.isGroupRowStyle = style
        return self
    }
    
    @discardableResult
    func selected(_ selected:Bool) -> Self {
        base.isSelected = selected
        return self
    }
    
    @discardableResult
    func previousRowSelected(_ selected:Bool) -> Self {
        base.isPreviousRowSelected = selected
        return self
    }
    
    @discardableResult
    func nextRowSelected(_ selected:Bool) -> Self {
        base.isNextRowSelected = selected
        return self
    }
    
    @discardableResult
    func floating(_ floating:Bool) -> Self {
        base.isFloating = floating
        return self
    }
    
    @discardableResult
    func targetForDropOperation(_ oper:Bool) -> Self {
        base.isTargetForDropOperation = oper
        return self
    }
    
    @discardableResult
    func draggingDestinationFeedbackStyle(_ style:NSTableView.DraggingDestinationFeedbackStyle) -> Self {
        base.draggingDestinationFeedbackStyle = style
        return self
    }
    
    @discardableResult
    func indentationForDropOperation(_ oper:CGFloat) -> Self {
        base.indentationForDropOperation = oper
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color:NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
}
