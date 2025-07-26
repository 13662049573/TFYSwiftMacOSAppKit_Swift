//
//  TFYSwiftNSPopUpButton.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSPopUpButton {
    
    @discardableResult
    func menu(_ menu: NSMenu) -> Self {
        base.menu = menu
        return self
    }
    @discardableResult
    func pullsDown(_ pullsDown: Bool) -> Self {
        base.pullsDown = pullsDown
        return self
    }
    @discardableResult
    func autoenablesItems(_ auto: Bool) -> Self {
        base.autoenablesItems = auto
        return self
    }
    @discardableResult
    func preferredEdge(_ edge: NSRectEdge) -> Self {
        base.preferredEdge = edge
        return self
    }
    @discardableResult
    func addItem(_ title: String) -> Self {
        base.addItem(withTitle: title)
        return self
    }
    @discardableResult
    func addItems(_ titles: [String]) -> Self {
        base.addItems(withTitles: titles)
        return self
    }
    @discardableResult
    func insertItem(_ title: String,at:Int) -> Self {
        base.insertItem(withTitle: title, at: at)
        return self
    }
    @discardableResult
    func removeItemWithTitle(_ at: Int) -> Self {
        base.removeItem(at: at)
        return self
    }
    @discardableResult
    func removeItem(_ title: String) -> Self {
        base.removeItem(withTitle: title)
        return self
    }
    @discardableResult
    func removeAllItems() -> Self {
        base.removeAllItems()
        return self
    }
    @discardableResult
    func selectItem(_ at: Int) -> Self {
        base.selectItem(at: at)
        return self
    }
    @discardableResult
    func selectItemWithTitle(_ title: String) -> Self {
        base.selectItem(withTitle: title)
        return self
    }
    @discardableResult
    func selectItemWithTag(_ withTag: Int) -> Self {
        base.selectItem(withTag: withTag)
        return self
    }
    @discardableResult
    func setTitle(_ setTitle: String) -> Self {
        base.setTitle(setTitle)
        return self
    }
}
