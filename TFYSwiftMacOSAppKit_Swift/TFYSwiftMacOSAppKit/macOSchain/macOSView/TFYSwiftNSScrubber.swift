//
//  TFYSwiftNSScrubber.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSScrubber {
    
    @discardableResult
    func dataSource(_ dataSource:(any NSScrubberDataSource)) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSScrubberDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func scrubberLayout(_ layout:NSScrubberLayout) -> Self {
        base.scrubberLayout = layout
        return self
    }
    
    @discardableResult
    func selectedIndex(_ index:Int) -> Self {
        base.selectedIndex = index
        return self
    }
    
    @discardableResult
    func mode(_ mode:NSScrubber.Mode) -> Self {
        base.mode = mode
        return self
    }
    
    @discardableResult
    func itemAlignment(_ alignment:NSScrubber.Alignment) -> Self {
        base.itemAlignment = alignment
        return self
    }
    
    @discardableResult
    func continuous(_ continuous:Bool) -> Self {
        base.isContinuous = continuous
        return self
    }
    
    @discardableResult
    func floatsSelectionViews(_ floate:Bool) -> Self {
        base.floatsSelectionViews = floate
        return self
    }
    
    @discardableResult
    func selectionBackgroundStyle(_ style:NSScrubberSelectionStyle) -> Self {
        base.selectionBackgroundStyle = style
        return self
    }
    
    @discardableResult
    func selectionOverlayStyle(_ style:NSScrubberSelectionStyle) -> Self {
        base.selectionOverlayStyle = style
        return self
    }
    
    @discardableResult
    func showsArrowButtons(_ shows:Bool) -> Self {
        base.showsArrowButtons = shows
        return self
    }
    
    @discardableResult
    func showsAdditionalContentIndicators(_ shows:Bool) -> Self {
        base.showsAdditionalContentIndicators = shows
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color:NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func backgroundView(_ view:NSView) -> Self {
        base.backgroundView = view
        return self
    }
    
    @discardableResult
    func insertItems(_ at:IndexSet) -> Self {
        base.insertItems(at: at)
        return self
    }
    
    @discardableResult
    func reloadItems(_ at:IndexSet) -> Self {
        base.reloadItems(at: at)
        return self
    }
    
    @discardableResult
    func moveItem(_ at:Int,to:Int) -> Self {
        base.moveItem(at: at, to: to)
        return self
    }
    
    @discardableResult
    func moveItem(_ at:Int,to:NSScrubber.Alignment) -> Self {
        base.scrollItem(at: at, to: to)
        return self
    }
    
    @discardableResult
    func register(_ itemViewClass:AnyClass,itemIdentifier:NSUserInterfaceItemIdentifier) -> Self {
        base.register(itemViewClass, forItemIdentifier: itemIdentifier)
        return self
    }
    
    @discardableResult
    func register_Nib(_ nib:NSNib,itemIdentifier:NSUserInterfaceItemIdentifier) -> Self {
        base.register(nib, forItemIdentifier:itemIdentifier)
        return self
    }
}
