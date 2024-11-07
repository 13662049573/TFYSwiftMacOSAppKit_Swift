//
//  TFYSwiftNSOutlineView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSOutlineView {
    
    @discardableResult
    func delegate(_ delegate: (any NSOutlineViewDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func dataSource(_ dataSource: (any NSOutlineViewDataSource)) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func outlineTableColumn(_ menu: NSTableColumn) -> Self {
        base.outlineTableColumn = menu
        return self
    }
    
    @discardableResult
    func indentationPerLevel(_ menu: CGFloat) -> Self {
        base.indentationPerLevel = menu
        return self
    }
    
    @discardableResult
    func indentationMarkerFollowsCell(_ menu: Bool) -> Self {
        base.indentationMarkerFollowsCell = menu
        return self
    }
    
    @discardableResult
    func autoresizesOutlineColumn(_ menu: Bool) -> Self {
        base.autoresizesOutlineColumn = menu
        return self
    }
    
    @discardableResult
    func autosaveExpandedItems(_ menu: Bool) -> Self {
        base.autosaveExpandedItems = menu
        return self
    }
}
