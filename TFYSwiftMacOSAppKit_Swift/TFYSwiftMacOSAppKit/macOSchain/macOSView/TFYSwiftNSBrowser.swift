//
//  TFYSwiftNSBrowser.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSBrowser {
    
    @discardableResult
    func doubleAction(_ auto: Selector) -> Self {
        base.doubleAction = auto
        return self
    }
    
    @discardableResult
    func cellPrototype(_ auto: Any) -> Self {
        base.cellPrototype = auto
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: (any NSBrowserDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func reusesColumns(_ auto: Bool) -> Self {
        base.reusesColumns = auto
        return self
    }
    
    @discardableResult
    func hasHorizontalScroller(_ auto: Bool) -> Self {
        base.hasHorizontalScroller = auto
        return self
    }
    
    @discardableResult
    func autohidesScroller(_ auto: Bool) -> Self {
        base.autohidesScroller = auto
        return self
    }
    
    @discardableResult
    func separatesColumns(_ auto: Bool) -> Self {
        base.separatesColumns = auto
        return self
    }
    
    @discardableResult
    func titled(_ auto: Bool) -> Self {
        base.isTitled = auto
        return self
    }
    
    @discardableResult
    func minColumnWidth(_ min: CGFloat) -> Self {
        base.minColumnWidth = min
        return self
    }
    
    @discardableResult
    func maxVisibleColumns(_ max: Int) -> Self {
        base.maxVisibleColumns = max
        return self
    }
    
    @discardableResult
    func allowsMultipleSelection(_ auto: Bool) -> Self {
        base.allowsMultipleSelection = auto
        return self
    }
    
    @discardableResult
    func allowsBranchSelection(_ auto: Bool) -> Self {
        base.allowsBranchSelection = auto
        return self
    }
    
    @discardableResult
    func allowsEmptySelection(_ auto: Bool) -> Self {
        base.allowsEmptySelection = auto
        return self
    }
    
    @discardableResult
    func takesTitleFromPreviousColumn(_ auto: Bool) -> Self {
        base.takesTitleFromPreviousColumn = auto
        return self
    }
    
    @discardableResult
    func sendsActionOnArrowKeys(_ auto: Bool) -> Self {
        base.sendsActionOnArrowKeys = auto
        return self
    }
    
    @discardableResult
    func pathSeparator(_ path: String) -> Self {
        base.pathSeparator = path
        return self
    }
    
    @discardableResult
    func selectionIndexPath(_ indexPath: IndexPath) -> Self {
        base.selectionIndexPath = indexPath
        return self
    }
    
    @discardableResult
    func selectionIndexPaths(_ indexPaths: [IndexPath]) -> Self {
        base.selectionIndexPaths = indexPaths
        return self
    }
    
    @discardableResult
    func lastColumn(_ last: Int) -> Self {
        base.lastColumn = last
        return self
    }
    
    @discardableResult
    func columnResizingType(_ type: NSBrowser.ColumnResizingType) -> Self {
        base.columnResizingType = type
        return self
    }
    
    @discardableResult
    func prefersAllColumnUserResizing(_ auto: Bool) -> Self {
        base.prefersAllColumnUserResizing = auto
        return self
    }
    
    @discardableResult
    func rowHeight(_ rowHeight: CGFloat) -> Self {
        base.rowHeight = rowHeight
        return self
    }
    
    @discardableResult
    func columnsAutosaveName(_ auto: NSBrowser.ColumnsAutosaveName) -> Self {
        base.columnsAutosaveName = auto
        return self
    }
    
    @discardableResult
    func allowsTypeSelect(_ auto: Bool) -> Self {
        base.allowsTypeSelect = auto
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
}
