//
//  StatusItemDragDropView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 状态项拖拽视图类
public class StatusItemDragDropView: NSView {

    // 状态项实例
    public var statusItem: StatusItemManager?
    // 拖拽处理方法
    public var dropHandler: StatusItemDropHandler?
    // 可拖拽类型
    public var dropTypes: [NSPasteboard.PasteboardType] {
        set {
            internalDropTypes = newValue
            registerForDraggedTypes(internalDropTypes)
        }
        get {
            return internalDropTypes
        }
    }
    private var internalDropTypes: [NSPasteboard.PasteboardType] = []

    // 检查粘贴板类型是否在可拖拽类型中
    public func dropTypeInPasteboardTypes(pasteboardTypes: [NSPasteboard.PasteboardType]) -> String? {
        for type in dropTypes {
            if pasteboardTypes.contains(type) {
                return type.rawValue
            }
        }
        return nil
    }

    // 拖拽进入时的处理
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard
        if let type = dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!) {
            return.copy
        } else {
            return.private
        }
    }

    // 执行拖拽操作
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        if let type = dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!) {
            let items = pboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: type))
            if dropHandler != nil {
                dropHandler!!(statusItem!, type, items)
                return true
            }
        }
        return false
    }
}
