//
//  TFYStatusItemDropView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYStatusItemDropView: NSView {
    weak var statusItem: TFYStatusItem?
    public var dropHandler: TFYStatusItemDropHandler?
    private var privateDropTypes: [NSPasteboard.PasteboardType] = []

    // 可拖拽类型
    public var dropTypes: [NSPasteboard.PasteboardType] {
        set {
            privateDropTypes = newValue
            registerForDraggedTypes(privateDropTypes)
        }
        get {
            return privateDropTypes
        }
    }

    // 检查粘贴板类型是否在可拖拽类型中
    public func dropTypeInPasteboardTypes(pasteboardTypes: [NSPasteboard.PasteboardType]) -> String? {
        for type in dropTypes {
            if pasteboardTypes.contains(type) {
                return type.rawValue
            }
        }
        return nil
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard
        if let type = dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!) {
            return .copy
        } else {
            return .private
        }
    }

    // 执行拖拽操作
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        if let type = dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!) {
            let items = pboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: type))
            if dropHandler != nil {
                dropHandler!(statusItem!, type, items as! [Any])
                return true
            }
        }
        return false
    }
}
