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
        }
        item.notify(queue: .global(qos: .utility)) {
            removeTask(identifier: identifier)
        }

        storeTask(item, forIdentifier: identifier)
        queue.async(execute: item)
    }

    @discardableResult
    public static func asyncCancellableDelay(
        identifier: String,
        seconds: Double,
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping TFYSwiftBlock
    ) -> DispatchWorkItem {
        cancelTask(identifier: identifier)

        let item = DispatchWorkItem {
            block()
        }
        item.notify(queue: .global(qos: .utility)) {
            removeTask(identifier: identifier)
        }

        storeTask(item, forIdentifier: identifier)
        queue.asyncAfter(deadline: .now() + seconds, execute: item)
        return item
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

    public static func hasPendingTask(identifier: String) -> Bool {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        return workItems[identifier] != nil
    }

    public static var pendingTaskCount: Int {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        return workItems.count
    }

    // MARK: - Retry
    /// Retry a block up to `maxAttempts` times with an exponential backoff delay.
    public static func retry<T>(
        maxAttempts: Int,
        initialDelay: Double = 0.5,
        multiplier: Double = 2.0,
        on queue: DispatchQueue = DispatchQueue.global(),
        block: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let attempts = max(1, maxAttempts)
        func attempt(_ remaining: Int, _ delay: Double) {
            queue.async {
                block { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async { completion(result) }
                    case .failure:
                        if remaining <= 1 {
                            DispatchQueue.main.async { completion(result) }
                        } else {
                            queue.asyncAfter(deadline: .now() + delay) {
                                attempt(remaining - 1, delay * multiplier)
                            }
                        }
                    }
                }
            }
        }
        attempt(attempts, initialDelay)
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

// MARK: - Async/Await Bridges
@available(macOS 10.15, *)
public extension TFYSwiftAsync {

    /// Run a synchronous block on the specified queue and return asynchronously.
    static func run<T>(
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping () -> T
    ) async -> T {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: block())
            }
        }
    }

    /// Run a throwing synchronous block on the specified queue and return asynchronously.
    static func runThrowing<T>(
        on queue: DispatchQueue = DispatchQueue.global(),
        _ block: @escaping () throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    continuation.resume(returning: try block())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Sleep for the given number of seconds without blocking a thread.
    static func sleep(seconds: Double) async {
        let nanos = UInt64(max(0, seconds) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanos)
    }
}

// MARK: - DispatchQueue Extension
extension DispatchQueue {
    private static var _onceTokens: Set<String> = []
    private static let onceTokensLock = NSLock()

    /// Execute `block` exactly once for the given `token` during the lifetime of the process.
    /// Tokens are retained for the process lifetime by design; use distinct, namespaced tokens.
    public class func once(token: String, block: () -> Void) {
        onceTokensLock.lock()
        if _onceTokens.contains(token) {
            onceTokensLock.unlock()
            return
        }
        _onceTokens.insert(token)
        onceTokensLock.unlock()
        block()
    }

    /// Remove a previously registered once token. Primarily useful for tests.
    public class func resetOnceToken(_ token: String) {
        onceTokensLock.lock()
        defer { onceTokensLock.unlock() }
        _onceTokens.remove(token)
    }

    /// Remove all once tokens. Primarily useful for tests.
    public class func resetAllOnceTokens() {
        onceTokensLock.lock()
        defer { onceTokensLock.unlock() }
        _onceTokens.removeAll()
    }

    /// Execute `block` on the main queue. If already on main, runs synchronously.
    public class func safeMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
