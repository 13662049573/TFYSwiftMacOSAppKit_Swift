//
//  TFYSwiftAsynce.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

// MARK: - Type Definitions
public typealias TFYSwiftBlock = () -> Void
public typealias TFYSwiftResultBlock<T> = (T) -> Void
public typealias TFYSwiftErrorBlock = (Error) -> Void

// MARK: - Async Task Manager
public final class TFYSwiftAsync {
    
    // MARK: - Properties
    public static let defaultQueue = DispatchQueue.global()
    private static var workItems: [String: DispatchWorkItem] = [:]
    private static let workItemsLock = NSLock()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Basic Async Methods
    @discardableResult
    public static func async(
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping TFYSwiftBlock
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        queue.async(execute: item)
        return item
    }
    
    @discardableResult
    public static func async(
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping TFYSwiftBlock,
        mainCallback: @escaping TFYSwiftBlock
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem {
            block()
        }
        queue.async(execute: item)
        item.notify(queue: .main, execute: mainCallback)
        return item
    }
    
    // MARK: - Delayed Async Methods
    @discardableResult
    public static func asyncDelay(
        seconds: Double,
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping TFYSwiftBlock
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        queue.asyncAfter(deadline: .now() + seconds, execute: item)
        return item
    }
    
    @discardableResult
    public static func asyncDelay(
        seconds: Double,
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping TFYSwiftBlock,
        mainCallback: @escaping TFYSwiftBlock
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem {
            block()
        }
        queue.asyncAfter(deadline: .now() + seconds, execute: item)
        item.notify(queue: .main, execute: mainCallback)
        return item
    }
    
    // MARK: - Cancellable Tasks
    public static func asyncCancellable(
        identifier: String,
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping TFYSwiftBlock
    ) {
        cancelTask(identifier: identifier)
        
        let item = DispatchWorkItem {
            block()
            removeTask(identifier: identifier)
        }
        
        storeTask(item, forIdentifier: identifier)
        queue.async(execute: item)
    }
    
    public static func cancelTask(identifier: String) {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        
        workItems[identifier]?.cancel()
        workItems[identifier] = nil
    }
    
    public static func cancelAllTasks() {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        
        workItems.values.forEach { $0.cancel() }
        workItems.removeAll()
    }
    
    // MARK: - Private Methods
    private static func storeTask(_ item: DispatchWorkItem, forIdentifier identifier: String) {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        workItems[identifier] = item
    }
    
    private static func removeTask(identifier: String) {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        workItems[identifier] = nil
    }
}

// MARK: - DispatchQueue Extension
extension DispatchQueue {
    private static var _onceTokens: Set<String> = []
    private static let onceTokensLock = NSLock()
    
    public class func once(token: String, block: () -> Void) {
        onceTokensLock.lock()
        defer { onceTokensLock.unlock() }
        
        guard !_onceTokens.contains(token) else { return }
        _onceTokens.insert(token)
        block()
    }
}
