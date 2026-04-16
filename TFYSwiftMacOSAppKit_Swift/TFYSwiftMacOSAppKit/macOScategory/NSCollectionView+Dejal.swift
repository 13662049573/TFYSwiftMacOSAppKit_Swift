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
}
