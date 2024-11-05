//
//  TFYSwiftAsynce.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public typealias TFYSwiftBlock = () -> Void

public class TFYSwiftAsynce: NSObject {
    
    /// 异步处理数据
    public static func async(_ block: @escaping TFYSwiftBlock) {
        _async(block)
    }
    
    /// 异步 主线程 处理数据
    public static func async(_ block: @escaping TFYSwiftBlock, _ mainblock: @escaping TFYSwiftBlock) {
        _async(block,mainblock)
    }
    
    /// 异步延迟
    @discardableResult
    public static func asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock) -> DispatchWorkItem {
        return _asyncDelay(seconds, block)
    }
    
    /// 主线程延迟
    @discardableResult
    public static func asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock, _ mainblock: @escaping TFYSwiftBlock) -> DispatchWorkItem {
        return _asyncDelay(seconds, block, mainblock)
    }
}

extension TFYSwiftAsynce {
    
    private static func _async(_ block: @escaping TFYSwiftBlock, _ mainblock: TFYSwiftBlock? = nil) {
        let item = DispatchWorkItem(block: block)
        DispatchQueue.global().async(execute: item)
        if let main = mainblock {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
    }
    
    private static func _asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock, _ mainblock: TFYSwiftBlock? = nil) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        if let main = mainblock {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
        return item
    }
}
