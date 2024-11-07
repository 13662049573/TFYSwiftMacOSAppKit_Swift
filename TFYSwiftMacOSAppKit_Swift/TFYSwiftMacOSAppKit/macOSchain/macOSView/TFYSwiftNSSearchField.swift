//
//  TFYSwiftNSSearchField.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSSearchField {
    
    @discardableResult
    func recentSearches(_ searchs: [String]) -> Self {
        base.recentSearches = searchs
        return self
    }
    
    @discardableResult
    func recentsAutosaveName(_ delay: NSSearchField.RecentsAutosaveName) -> Self {
        base.recentsAutosaveName = delay
        return self
    }
    
    @discardableResult
    func searchMenuTemplate(_ menu: NSMenu) -> Self {
        base.searchMenuTemplate = menu
        return self
    }
    
    @discardableResult
    func sendsWholeSearchString(_ delay: Bool) -> Self {
        base.sendsWholeSearchString = delay
        return self
    }
    
    @discardableResult
    func maximumRecents(_ max: Int) -> Self {
        base.maximumRecents = max
        return self
    }
    
    @discardableResult
    func sendsSearchStringImmediately(_ delay: Bool) -> Self {
        base.sendsSearchStringImmediately = delay
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: (any NSSearchFieldDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
}
