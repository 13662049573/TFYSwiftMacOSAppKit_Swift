//
//  TFYSwiftNSCollectionView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSCollectionView {
    
    @discardableResult
    func dataSource(_ dataSource:(any NSCollectionViewDataSource)) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func prefetchDataSource(_ prefetchDataSource:(any NSCollectionViewPrefetching)) -> Self {
        base.prefetchDataSource = prefetchDataSource
        return self
    }
    
    @discardableResult
    func content(_ content:[Any]) -> Self {
        base.content = content
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSCollectionViewDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func backgroundView(_ view:NSView) -> Self {
        base.backgroundView = view
        return self
    }
    
    @discardableResult
    func backgroundViewScrollsWithContent(_ scoll:Bool) -> Self {
        base.backgroundViewScrollsWithContent = scoll
        return self
    }
    
    @discardableResult
    func backgroundColors(_ colors:[NSColor]) -> Self {
        base.backgroundColors = colors
        return self
    }
    
    @discardableResult
    func collectionViewLayout(_ layout:NSCollectionViewLayout) -> Self {
        base.collectionViewLayout = layout
        return self
    }
    
    @discardableResult
    func selectable(_ selectable:Bool) -> Self {
        base.isSelectable = selectable
        return self
    }
    
    @discardableResult
    func allowsEmptySelection(_ allow:Bool) -> Self {
        base.allowsEmptySelection = allow
        return self
    }
    
    @discardableResult
    func allowsMultipleSelection(_ allows:Bool) -> Self {
        base.allowsMultipleSelection = allows
        return self
    }
    
    @discardableResult
    func selectionIndexes(_ index:IndexSet) -> Self {
        base.selectionIndexes = index
        return self
    }
    
    @discardableResult
    func selectionIndexPaths(_ indexs:Set<IndexPath>) -> Self {
        base.selectionIndexPaths = indexs
        return self
    }
    
    @discardableResult
    func selectItems(_ indexPaths: Set<IndexPath>, scrollPosition: NSCollectionView.ScrollPosition) -> Self {
        base.selectItems(at: indexPaths, scrollPosition: scrollPosition)
        return self
    }
    
    @discardableResult
    func deselectItems(_ paths:Set<IndexPath>) -> Self {
        base.deselectItems(at: paths)
        return self
    }
    
    @discardableResult
    func register_tifier(_ itemClass: AnyClass,identifier: NSUserInterfaceItemIdentifier) -> Self {
        base.register(itemClass, forItemWithIdentifier: identifier)
        return self
    }
    
    @discardableResult
    func register_Kind(_ viewClass: AnyClass,kind: NSCollectionView.SupplementaryElementKind,identifier: NSUserInterfaceItemIdentifier) -> Self {
        base.register(viewClass, forSupplementaryViewOfKind: kind, withIdentifier: identifier)
        return self
    }
    
    @discardableResult
    func register_Nibtifier(_ nib:NSNib,identifier:NSUserInterfaceItemIdentifier) -> Self {
        base.register(nib,forItemWithIdentifier:identifier)
        return self
    }
    
    @discardableResult
    func register_NibKind(_ nib:NSNib,kind:NSCollectionView.SupplementaryElementKind,identifier:NSUserInterfaceItemIdentifier) -> Self {
        base.register(nib, forSupplementaryViewOfKind: kind, withIdentifier:identifier )
        return self
    }
    
    @discardableResult
    func insertSections(_ inser:IndexSet) -> Self {
        base.insertSections(inser)
        return self
    }
    
    @discardableResult
    func deleteSections(_ inser:IndexSet) -> Self {
        base.deleteSections(inser)
        return self
    }
    
    @discardableResult
    func reloadSections(_ inser:IndexSet) -> Self {
        base.reloadSections(inser)
        return self
    }
    
    @discardableResult
    func moveSection(_ section:Int,tosection:Int) -> Self {
        base.moveSection(section, toSection: tosection)
        return self
    }
    
    @discardableResult
    func insertItems(_ at:Set<IndexPath>) -> Self {
        base.insertItems(at: at)
        return self
    }
    
    @discardableResult
    func deleteItems(_ at:Set<IndexPath>) -> Self {
        base.deleteItems(at: at)
        return self
    }
    
    @discardableResult
    func reloadItems(_ at:Set<IndexPath>) -> Self {
        base.reloadItems(at: at)
        return self
    }
    
    @discardableResult
    func moveItem(_ at:IndexPath,to:IndexPath) -> Self {
        base.moveItem(at: at, to: to)
        return self
    }
    
    @discardableResult
    func scrollToItems(_ at:Set<IndexPath>,scrollPosition:NSCollectionView.ScrollPosition) -> Self {
        base.scrollToItems(at: at, scrollPosition: scrollPosition)
        return self
    }
    
    @discardableResult
    func setDraggingSourceOperationMask(_ mask:NSDragOperation,local:Bool) -> Self {
        base.setDraggingSourceOperationMask(mask, forLocal: local)
        return self
    }
    
}
