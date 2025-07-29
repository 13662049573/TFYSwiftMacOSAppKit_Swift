//
//  NSMenu+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSMenu {
    /// 向菜单中添加分隔符项。
    func addSeparatorItemSwift() {
        addItem(NSMenuItem.separator())
    }

    /// 类似于-addItemWithTitle:action:keyEquivalent:，但也允许指定目标对象。如果不需要，对应的键应该是@""，而不是 nil。
    func addItemWithTitleSwift(title: String, target: AnyObject?, action: Selector, keyEquivalent: String) -> NSMenuItem? {
        return addItemWithTitleSwift(title: title, target: target, action: action, keyEquivalent: keyEquivalent, icon: nil)
    }

    /// 类似于-addItemWithTitle:action:keyEquivalent:，但也允许指定目标对象。它允许设置所表示的对象和/或标记，而不是键等价。
    func addItemWithTitleSwift(title: String, target: AnyObject?, action: Selector, representedObject: AnyObject?, tag: Int) -> NSMenuItem? {
        return addItemWithTitleSwift(title: title, target: target, action: action, keyEquivalent: "", modifierMask:.capsLock, icon: nil, representedObject: representedObject, tag: tag)
    }

    /// 类似于-addItemWithTitle:target:action:keyEquivalent:，但也允许指定图标图像。如果不需要，对应的键应该是@""，而不是 nil。
    func addItemWithTitleSwift(title: String, target: AnyObject?, action: Selector, keyEquivalent: String, icon: NSImage?) -> NSMenuItem? {
        return addItemWithTitleSwift(title: title, target: target, action: action, keyEquivalent: keyEquivalent, icon: icon, representedObject: nil)
    }

    /// 类似于-addItemWithTitle:target:action:keyEquivalent:icon:，但也允许指定一个表示的对象。如果不需要，对应的键应该是@""，而不是 nil。
    func addItemWithTitleSwift(title: String, target: AnyObject?, action: Selector, keyEquivalent: String, icon: NSImage?, representedObject: AnyObject?) -> NSMenuItem? {
        return addItemWithTitleSwift(title: title, target: target, action: action, keyEquivalent: keyEquivalent, modifierMask: .capsLock, icon: icon, representedObject: representedObject, tag: 0)
    }

    /// 类似于-addItemWithTitle:target:action:keyEquivalent:icon:，但也允许指定一个表示的对象。如果不需要，对应的键应该是@""，而不是 nil。
    func addItemWithTitleSwift(title: String, target: AnyObject?, action: Selector, keyEquivalent: String, modifierMask: NSEvent.ModifierFlags, icon: NSImage?, representedObject: AnyObject?) -> NSMenuItem? {
        return addItemWithTitleSwift(title: title, target: target, action: action, keyEquivalent: keyEquivalent, modifierMask: modifierMask, icon: icon, representedObject: representedObject, tag: 0)
    }

    /// 类似于-addItemWithTitle:target:action:keyEquivalent:icon: representtedobject:，但也允许指定修饰符掩码；如果为零，表示掩码没有改变。如果不需要，对应的键应该是@""，而不是 nil。
    func addItemWithTitleSwift(title: String, target: AnyObject?, action: Selector, keyEquivalent: String = "", modifierMask: NSEvent.ModifierFlags, icon: NSImage?, representedObject: AnyObject?, tag: Int) -> NSMenuItem? {
        // 如果键为空字符串，则使用空字符串代替 nil
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.keyEquivalentModifierMask = modifierMask
        item.target = target
        item.image = icon
        item.representedObject = representedObject
        item.tag = tag
        addItem(item)
        return item
    }

    /// 根据菜单项的目标和操作移除菜单项。返回它的菜单项索引，以防相邻的项（例如分隔符）也需要删除。
    func removeItemWithTargetSwift(target: AnyObject?, action: Selector) -> Int {
        var index: Int?
       let tempIndex = indexOfItem(withTarget: target, andAction: action)
        index = tempIndex
        removeItem(at: tempIndex)
        return index ?? -1
    }

    /// 基于目标和操作移除所有菜单项。
    func removeItemsWithTargetSwift(target: AnyObject?, action: Selector) {
        var tempIndex: Int?
        while tempIndex != nil {
            tempIndex = indexOfItem(withTarget: target, andAction: action)
            if let index = tempIndex {
                removeItem(at: index)
            }
        }
    }

    /// 返回接收器中具有指定操作和目标的第一个菜单项的索引。如果 actionSelector 为 nil，则返回接收器中目标为 anObject 的第一个菜单项。
    func itemWithTargetSwift(target: AnyObject?, action: Selector) -> NSMenuItem? {
        let index = indexOfItem(withTarget: target, andAction: action)
        if index >= 0 {
            return item(at: index)
        }
        return nil
    }

    /// 返回带有给定目标、操作和标记值（如果有的话）的接收器中的菜单项。
    func itemWithTargetSwift(target: AnyObject?, action: Selector, tag: Int) -> NSMenuItem? {
        for item in items {
            if let itemTarget = item.target as AnyObject?, target != nil && itemTarget === target && item.action == action && item.tag == tag {
                return item
            }
        }
        return nil
    }

    /// 使用给定的目标和操作切换接收器中所有菜单项的状态，以便只检查与指定标记值匹配的项，不检查与其他标记值匹配的项。
    func setCheckedItemForTargetSwift(target: AnyObject?, action: Selector, tag: Int) {
        for item in items {
            if let itemTarget = item.target as AnyObject?, target != nil && itemTarget === target && item.action == action {
                item.state = item.tag == tag ? .on :.off
            }
        }
    }
    
    // MARK: - 新增实用方法
    
    /// 添加带回调的菜单项
    /// - Parameters:
    ///   - title: 菜单项标题
    ///   - icon: 菜单项图标
    ///   - keyEquivalent: 快捷键
    ///   - action: 点击回调
    /// - Returns: 创建的菜单项
    @discardableResult
    func addItem(title: String, icon: NSImage? = nil, keyEquivalent: String = "", action: @escaping (NSMenuItem) -> Void) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(handleMenuAction(_:)), keyEquivalent: keyEquivalent)
        item.image = icon
        item.target = self
        
        // 存储回调
        objc_setAssociatedObject(item, "menuAction", action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        addItem(item)
        return item
    }
    
    @objc private func handleMenuAction(_ sender: NSMenuItem) {
        if let action = objc_getAssociatedObject(sender, "menuAction") as? (NSMenuItem) -> Void {
            action(sender)
        }
    }
    
    /// 添加子菜单
    /// - Parameters:
    ///   - title: 子菜单标题
    ///   - icon: 子菜单图标
    /// - Returns: 创建的子菜单
    @discardableResult
    func addSubmenu(title: String, icon: NSImage? = nil) -> NSMenu {
        let submenu = NSMenu(title: title)
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.image = icon
        item.submenu = submenu
        addItem(item)
        return submenu
    }
    
    /// 批量添加菜单项
    /// - Parameter items: 菜单项配置数组
    func addItems(_ items: [(title: String, action: (NSMenuItem) -> Void, icon: NSImage?, keyEquivalent: String)]) {
        for itemConfig in items {
            addItem(title: itemConfig.title, icon: itemConfig.icon, keyEquivalent: itemConfig.keyEquivalent, action: itemConfig.action)
        }
    }
    
    /// 根据标题查找菜单项
    /// - Parameter title: 菜单项标题
    /// - Returns: 找到的菜单项
    func item(withTitle title: String) -> NSMenuItem? {
        return items.first { $0.title == title }
    }
    
    /// 根据标签查找菜单项
    /// - Parameter tag: 菜单项标签
    /// - Returns: 找到的菜单项
    func item(withTag tag: Int) -> NSMenuItem? {
        return items.first { $0.tag == tag }
    }
    
    /// 启用或禁用菜单项
    /// - Parameters:
    ///   - title: 菜单项标题
    ///   - enabled: 是否启用
    func setItemEnabled(title: String, enabled: Bool) {
        if let item = item(withTitle: title) {
            item.isEnabled = enabled
        }
    }
    
    /// 设置菜单项状态
    /// - Parameters:
    ///   - title: 菜单项标题
    ///   - state: 菜单项状态
    func setItemState(title: String, state: NSControl.StateValue) {
        if let item = item(withTitle: title) {
            item.state = state
        }
    }
    
    /// 移除所有菜单项
    func removeAllItems() {
        while items.count > 0 {
            removeItem(at: 0)
        }
    }
    
    /// 获取菜单项数量
    var itemCount: Int {
        return items.count
    }
    
    /// 检查菜单是否为空
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    /// 获取所有菜单项标题
    var itemTitles: [String] {
        return items.map { $0.title }
    }
}

// 扩展 NSMenuItem
extension NSMenuItem {
    /// 返回具有给定标题和其他设置的新菜单项实例。
    static func menuItemWithTitleSwift(title: String, settings: ((NSMenuItem) -> Void)? = nil) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        if let settingsBlock = settings {
            settingsBlock(menuItem)
        }
        return menuItem
    }
    
    /// 设置菜单项回调
    /// - Parameter action: 点击回调
    func setAction(_ action: @escaping (NSMenuItem) -> Void) {
        self.action = #selector(handleAction(_:))
        self.target = self
        
        // 存储回调
        objc_setAssociatedObject(self, "menuItemAction", action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    @objc private func handleAction(_ sender: NSMenuItem) {
        if let action = objc_getAssociatedObject(self, "menuItemAction") as? (NSMenuItem) -> Void {
            action(sender)
        }
    }
}
