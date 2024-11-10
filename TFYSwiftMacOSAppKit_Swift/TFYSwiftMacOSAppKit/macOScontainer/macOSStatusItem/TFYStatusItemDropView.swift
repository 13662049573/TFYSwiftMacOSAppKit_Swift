//
//  TFYStatusItemDropView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// TFYStatusItemDropView 类用于处理状态项的拖拽操作
public class TFYStatusItemDropView: NSView {

    // 弱引用状态项
    weak var statusItem: TFYStatusItem?

    // 拖拽处理闭包
    public var dropHandler: TFYStatusItemDropHandler?

    // 私有可拖拽类型数组
    private var privateDropTypes: [NSPasteboard.PasteboardType] = []

    // 可拖拽类型的属性，设置新值时更新注册的拖拽类型，获取时返回私有数组
    public var dropTypes: [NSPasteboard.PasteboardType] {
        set {
            // 设置新的可拖拽类型时，更新私有数组并注册这些类型
            privateDropTypes = newValue
            registerForDraggedTypes(privateDropTypes)
        }
        get {
            return privateDropTypes
        }
    }

    // 检查粘贴板类型是否在可拖拽类型中
    public func dropTypeInPasteboardTypes(pasteboardTypes: [NSPasteboard.PasteboardType]) -> NSPasteboard.PasteboardType? {
        // 遍历可拖拽类型，检查是否存在于传入的粘贴板类型数组中
        for type in dropTypes {
            if pasteboardTypes.contains(type) {
                return type
            }
        }
        return .string
    }

    // 当拖拽进入视图时调用
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard
        // 检查粘贴板类型是否在可拖拽类型中，如果是则返回复制操作，否则返回私有操作
        if dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!) != nil {
            return .copy
        } else {
            return .private
        }
    }

    // 执行拖拽操作
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        // 检查粘贴板类型是否在可拖拽类型中，并获取对应的类型字符串
        if let type = dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!) {
            // 根据类型获取粘贴板中的属性列表，并进行类型转换
            let items = pboard.propertyList(forType: type)
            // 如果有拖拽处理闭包，则调用闭包进行处理并返回处理结果
            if dropHandler != nil {
                dropHandler!(statusItem!, type, items as! [Any])
                return true
            }
        }
        return false
    }
}
