//
//  TFYSwiftNSComboBox.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSComboBox {
    
    @discardableResult
    func hasVerticalScroller(_ delay: Bool) -> Self {
        base.hasVerticalScroller = delay
        return self
    }
    
    @discardableResult
    func intercellSpacing(_ size: NSSize) -> Self {
        base.intercellSpacing = size
        return self
    }
    
    @discardableResult
    func itemHeight(_ delay: CGFloat) -> Self {
        base.itemHeight = delay
        return self
    }
    
    @discardableResult
    func numberOfVisibleItems(_ num: Int) -> Self {
        base.numberOfVisibleItems = num
        return self
    }
    
    @discardableResult
    func buttonBordered(_ delay: Bool) -> Self {
        base.isButtonBordered = delay
        return self
    }
    
    @discardableResult
    func usesDataSource(_ delay: Bool) -> Self {
        base.usesDataSource = delay
        return self
    }
    
    @discardableResult
    func completes(_ delay: Bool) -> Self {
        base.completes = delay
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: (any NSComboBoxDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func dataSource(_ dataSource: (any NSComboBoxDataSource)) -> Self {
        base.dataSource = dataSource
        return self
    }
}
