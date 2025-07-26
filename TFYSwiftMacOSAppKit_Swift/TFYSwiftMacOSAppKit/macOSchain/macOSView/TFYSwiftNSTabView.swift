//
//  TFYSwiftNSTabView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSTabView {
    
    @discardableResult
    func tabViewType(_ type:NSTabView.TabType) -> Self {
        base.tabViewType = type
        return self
    }
    
    @discardableResult
    func tabPosition(_ postion:NSTabView.TabPosition) -> Self {
        base.tabPosition = postion
        return self
    }
    
    @discardableResult
    func tabViewBorderType(_ type:NSTabView.TabViewBorderType) -> Self {
        base.tabViewBorderType = type
        return self
    }
    
    @discardableResult
    func tabViewItems(_ tabViewItems:[NSTabViewItem]) -> Self {
        base.tabViewItems = tabViewItems
        return self
    }
    
    @discardableResult
    func allowsTruncatedLabels(_ allows:Bool) -> Self {
        base.allowsTruncatedLabels = allows
        return self
    }
    
    @discardableResult
    func drawsBackground(_ draws:Bool) -> Self {
        base.drawsBackground = draws
        return self
    }
    
    @discardableResult
    func controlSize(_ size:NSControl.ControlSize) -> Self {
        base.controlSize = size
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSTabViewDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func selectTabViewItem(_ tabViewItem: NSTabViewItem) -> Self {
        base.selectTabViewItem(tabViewItem)
        return self
    }
    
    @discardableResult
    func selectTabViewItem(_ at:Int) -> Self {
        base.selectTabViewItem(at: at)
        return self
    }
    
    @discardableResult
    func selectTabViewItem(_ withIdentifier:Any) -> Self {
        base.selectTabViewItem(withIdentifier: withIdentifier)
        return self
    }
    
    @discardableResult
    func takeSelectedTabViewItemFromSender(_ sender:Any) -> Self {
        base.takeSelectedTabViewItemFromSender(sender)
        return self
    }
    
    @discardableResult
    func selectFirstTabViewItem(_ sender:Any) -> Self {
        base.selectFirstTabViewItem(sender)
        return self
    }
    
    @discardableResult
    func selectLastTabViewItem(_ sender:Any) -> Self {
        base.selectLastTabViewItem(sender)
        return self
    }
    
    @discardableResult
    func selectNextTabViewItem(_ sender:Any) -> Self {
        base.selectNextTabViewItem(sender)
        return self
    }
    
    @discardableResult
    func selectPreviousTabViewItem(_ sender:Any) -> Self {
        base.selectPreviousTabViewItem(sender)
        return self
    }
    
    @discardableResult
    func addTabViewItem(_ tabViewItem: NSTabViewItem) -> Self {
        base.addTabViewItem(tabViewItem)
        return self
    }
    
    @discardableResult
    func removeTabViewItem(_ tabViewItem: NSTabViewItem) -> Self {
        base.removeTabViewItem(tabViewItem)
        return self
    }
    
    @discardableResult
    func insertTabViewItem(_ tabViewItem: NSTabViewItem,at:Int) -> Self {
        base.insertTabViewItem(tabViewItem, at: at)
        return self
    }
}
