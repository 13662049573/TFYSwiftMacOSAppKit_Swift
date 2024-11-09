//
//  TFYSwiftAsynce.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public typealias TFYSwiftBlock = () -> Void

// 定义一个用于异步处理的工具类
public class TFYSwiftAsynce: NSObject {

    // 异步处理数据，不指定主线程回调
    public static func async(_ block: @escaping TFYSwiftBlock) {
        _async(block)
    }

    // 异步处理数据并指定主线程回调
    public static func async(_ block: @escaping TFYSwiftBlock, _ mainblock: @escaping TFYSwiftBlock) {
        _async(block, mainblock)
    }

    // 异步延迟执行，不指定主线程回调
    @discardableResult
    public static func asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock) -> DispatchWorkItem {
        return _asyncDelay(seconds, block)
    }

    // 异步延迟执行并指定主线程回调
    @discardableResult
    public static func asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock, _ mainblock: @escaping TFYSwiftBlock) -> DispatchWorkItem {
        return _asyncDelay(seconds, block, mainblock)
    }

    // 私有方法，异步执行任务，可指定主线程回调
    private static func _async(_ block: @escaping TFYSwiftBlock, _ mainblock: TFYSwiftBlock? = nil) {
        // 创建一个任务
        let item = DispatchWorkItem(block: block)
        // 在全局队列异步执行任务
        DispatchQueue.global().async(execute: item)
        // 如果有主线程回调，则在任务完成后在主线程执行回调
        if let main = mainblock {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
    }

    // 私有方法，异步延迟执行任务，可指定主线程回调
    private static func _asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock, _ mainblock: TFYSwiftBlock? = nil) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        // 在指定延迟时间后在全局队列异步执行任务
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        if let main = mainblock {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
        return item
    }
}

extension DispatchQueue {
    private static var onceTokens = [String]()
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        if !onceTokens.contains(token) {
            onceTokens.append(token)
            block()
        }
    }
}
