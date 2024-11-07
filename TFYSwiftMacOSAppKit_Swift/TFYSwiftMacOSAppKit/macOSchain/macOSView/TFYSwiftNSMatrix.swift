//
//  TFYSwiftNSMatrix.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSMatrix {
    
    @discardableResult
    func selectCell(_ at:Int) -> Self {
        base.selectCell(withTag: at)
        return self
    }
    
    @discardableResult
    func cellClass(_ cell:AnyClass) -> Self {
        base.cellClass = cell
        return self
    }
    
    @discardableResult
    func prototype(_ cell:NSCell) -> Self {
        base.prototype = cell
        return self
    }
    
    @discardableResult
    func mode(_ mode:NSMatrix.Mode) -> Self {
        base.mode = mode
        return self
    }
    
    @discardableResult
    func allowsEmptySelection(_ allow:Bool) -> Self {
        base.allowsEmptySelection = allow
        return self
    }
    
    @discardableResult
    func selectionByRect(_ by:Bool) -> Self {
        base.isSelectionByRect = by
        return self
    }
    
    @discardableResult
    func cellSize(_ size: NSSize) -> Self {
        base.cellSize = size
        return self
    }
    
    @discardableResult
    func intercellSpacing(_ size: NSSize) -> Self {
        base.intercellSpacing = size
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func drawsCellBackground(_ draws: Bool) -> Self {
        base.drawsCellBackground = draws
        return self
    }
    
    @discardableResult
    func drawsBackground(_ draws: Bool) -> Self {
        base.drawsBackground = draws
        return self
    }
    
    @discardableResult
    func autosizesCells(_ auto: Bool) -> Self {
        base.autosizesCells = auto
        return self
    }
    
    @discardableResult
    func doubleAction(_ auto: Selector) -> Self {
        base.doubleAction = auto
        return self
    }
    
    @discardableResult
    func autoscroll(_ event: NSEvent) -> Self {
        base.autoscroll(with: event)
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSMatrixDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func autorecalculatesCellSize(_ auto: Bool) -> Self {
        base.autorecalculatesCellSize = auto
        return self
    }
    
    @discardableResult
    func tabKeyTraversesCells(_ takey: Bool) -> Self {
        base.tabKeyTraversesCells = takey
        return self
    }
    
    @discardableResult
    func keyCell(_ cell: NSCell) -> Self {
        base.keyCell = cell
        return self
    }
}
