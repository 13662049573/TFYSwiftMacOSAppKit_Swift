//
//  TFYSwiftNSTableView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSTableView {
    
    @discardableResult
    func dataSource(_ dataSource: (any NSTableViewDataSource)) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: (any NSTableViewDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func headerView(_ view: NSTableHeaderView) -> Self {
        base.headerView = view
        return self
    }
    
    @discardableResult
    func cornerView(_ view: NSView) -> Self {
        base.cornerView = view
        return self
    }
    
    @discardableResult
    func allowsColumnReordering(_ allows: Bool) -> Self {
        base.allowsColumnReordering = allows
        return self
    }
    
    @discardableResult
    func allowsColumnResizing(_ allows: Bool) -> Self {
        base.allowsColumnResizing = allows
        return self
    }
    
    @discardableResult
    func columnAutoresizingStyle(_ style: NSTableView.ColumnAutoresizingStyle) -> Self {
        base.columnAutoresizingStyle = style
        return self
    }
    
    @discardableResult
    func gridStyleMask(_ mask: NSTableView.GridLineStyle) -> Self {
        base.gridStyleMask = mask
        return self
    }
    
    @discardableResult
    func intercellSpacing(_ size: NSSize) -> Self {
        base.intercellSpacing = size
        return self
    }
    
    @discardableResult
    func usesAlternatingRowBackgroundColors(_ user: Bool) -> Self {
        base.usesAlternatingRowBackgroundColors = user
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func gridColor(_ color: NSColor) -> Self {
        base.gridColor = color
        return self
    }
    
    @discardableResult
    func rowSizeStyle(_ style: NSTableView.RowSizeStyle) -> Self {
        base.rowSizeStyle = style
        return self
    }
    
    @discardableResult
    func rowHeight(_ rowHeight: CGFloat) -> Self {
        base.rowHeight = rowHeight
        return self
    }
    
    @discardableResult
    func doubleAction(_ action: Selector) -> Self {
        base.doubleAction = action
        return self
    }
    
    @discardableResult
    func sortDescriptors(_ menu: [NSSortDescriptor]) -> Self {
        base.sortDescriptors = menu
        return self
    }
    
    @discardableResult
    func highlightedTableColumn(_ menu: NSTableColumn) -> Self {
        base.highlightedTableColumn =  menu
        return self
    }
    
    @discardableResult
    func verticalMotionCanBeginDrag(_ menu: Bool) -> Self {
        base.verticalMotionCanBeginDrag = menu
        return self
    }
    
    @discardableResult
    func allowsMultipleSelection(_ menu: Bool) -> Self {
        base.allowsMultipleSelection = menu
        return self
    }
    
    @discardableResult
    func allowsEmptySelection(_ menu: Bool) -> Self {
        base.allowsEmptySelection = menu
        return self
    }
    
    @discardableResult
    func allowsColumnSelection(_ menu: Bool) -> Self {
        base.allowsColumnSelection = menu
        return self
    }
    
    @discardableResult
    func allowsTypeSelect(_ menu: Bool) -> Self {
        base.allowsTypeSelect = menu
        return self
    }
    
    @discardableResult
    func style(_ menu: NSTableView.Style) -> Self {
        base.style = menu
        return self
    }
    
    @discardableResult
    func selectionHighlightStyle(_ menu: NSTableView.SelectionHighlightStyle) -> Self {
        base.selectionHighlightStyle = menu
        return self
    }
    
    @discardableResult
    func draggingDestinationFeedbackStyle(_ menu: NSTableView.DraggingDestinationFeedbackStyle) -> Self {
        base.draggingDestinationFeedbackStyle = menu
        return self
    }
    
    @discardableResult
    func autosaveName(_ menu: NSTableView.AutosaveName) -> Self {
        base.autosaveName = menu
        return self
    }
    
    @discardableResult
    func autosaveTableColumns(_ menu: Bool) -> Self {
        base.autosaveTableColumns = menu
        return self
    }
    
    @discardableResult
    func floatsGroupRows(_ menu: Bool) -> Self {
        base.floatsGroupRows = menu
        return self
    }
    
    @discardableResult
    func rowActionsVisible(_ menu: Bool) -> Self {
        base.rowActionsVisible = menu
        return self
    }
    
    @discardableResult
    func usesStaticContents(_ menu: Bool) -> Self {
        base.usesStaticContents = menu
        return self
    }
    
    @discardableResult
    func userInterfaceLayoutDirection(_ menu: NSUserInterfaceLayoutDirection) -> Self {
        base.userInterfaceLayoutDirection = menu
        return self
    }
    
    @discardableResult
    func usesAutomaticRowHeights(_ menu: Bool) -> Self {
        base.usesAutomaticRowHeights = menu
        return self
    }
    
    @discardableResult
    func addTableColumn(_ tableColumn: NSTableColumn) -> Self {
        base.addTableColumn(tableColumn)
        return self
    }
    
    @discardableResult
    func removeTableColumn(_ tableColumn: NSTableColumn) -> Self {
        base.removeTableColumn(tableColumn)
        return self
    }
    
    @discardableResult
    func addTableColumn(_ old: Int,toColumn: Int) -> Self {
        base.moveColumn(old, toColumn: toColumn)
        return self
    }
}
