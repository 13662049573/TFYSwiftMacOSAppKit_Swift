//
//  NSCollectionView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/16/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSCollectionView {
    /// 安全刷新数据
    func reloadDataSafely() {
        guard dataSource != nil else { return }
        reloadData()
    }

    /// 注册 item class
    /// - Parameters:
    ///   - itemClass: item 类型
    ///   - identifier: 复用标识
    func registerItemClass<Item: NSCollectionViewItem>(_ itemClass: Item.Type, forItemWithIdentifier identifier: NSUserInterfaceItemIdentifier) {
        register(itemClass, forItemWithIdentifier: identifier)
    }

    /// 注册补充视图 class
    /// - Parameters:
    ///   - viewClass: 视图类型
    ///   - kind: 补充视图 kind
    ///   - identifier: 复用标识
    func registerSupplementaryViewClass<View: NSView>(
        _ viewClass: View.Type,
        ofKind kind: NSCollectionView.SupplementaryElementKind,
        withIdentifier identifier: NSUserInterfaceItemIdentifier
    ) {
        register(viewClass, forSupplementaryViewOfKind: kind, withIdentifier: identifier)
    }

    /// 安全滚动到指定 item
    /// - Parameters:
    ///   - indexPath: item 索引
    ///   - scrollPosition: 滚动位置
    func scrollToItemIfNeeded(at indexPath: IndexPath, scrollPosition: NSCollectionView.ScrollPosition = .nearestHorizontalEdge) {
        guard numberOfSections > indexPath.section else { return }
        guard numberOfItems(inSection: indexPath.section) > indexPath.item else { return }
        scrollToItems(at: Set([indexPath]), scrollPosition: scrollPosition)
    }

    /// 批量选中 item
    /// - Parameters:
    ///   - indexPaths: 索引集合
    ///   - scrollPosition: 滚动位置
    func selectItemsSafely(at indexPaths: Set<IndexPath>, scrollPosition: NSCollectionView.ScrollPosition = []) {
        selectItems(at: indexPaths, scrollPosition: scrollPosition)
    }

    /// 取消所有选中项
    func deselectAllItems() {
        selectionIndexPaths = []
    }

    /// 执行批量更新
    /// - Parameter updates: 更新闭包
    func performBatchUpdates(_ updates: @escaping () -> Void) {
        animator().performBatchUpdates(updates, completionHandler: nil)
    }

    /// 获取所有可见的 item
    var visibleItems: [NSCollectionViewItem] {
        visibleItems()
    }

    /// 获取指定 section 的 item 数量（安全版）
    /// - Parameter section: section 索引
    /// - Returns: item 数量，若 section 越界返回 0
    func numberOfItemsSafely(inSection section: Int) -> Int {
        guard section < numberOfSections else { return 0 }
        return numberOfItems(inSection: section)
    }

    /// 获取所有选中项的索引路径
    var selectedIndexPaths: Set<IndexPath> {
        selectionIndexPaths
    }

    /// 滚动到最后一个 item
    /// - Parameter scrollPosition: 滚动位置
    func scrollToLastItem(scrollPosition: NSCollectionView.ScrollPosition = .bottom) {
        let lastSection = numberOfSections - 1
        guard lastSection >= 0 else { return }
        let lastItem = numberOfItems(inSection: lastSection) - 1
        guard lastItem >= 0 else { return }
        let indexPath = IndexPath(item: lastItem, section: lastSection)
        scrollToItemIfNeeded(at: indexPath, scrollPosition: scrollPosition)
    }

    /// 重新加载指定 section
    /// - Parameter sections: section 索引集合
    func reloadSections(_ sections: IndexSet) {
        guard dataSource != nil else { return }
        reloadSections(sections)
    }

    /// 注册 Nib 为 item
    /// - Parameters:
    ///   - nib: Nib 对象
    ///   - identifier: 复用标识
    func registerItemNib(_ nib: NSNib, forItemWithIdentifier identifier: NSUserInterfaceItemIdentifier) {
        register(nib, forItemWithIdentifier: identifier)
    }
}
