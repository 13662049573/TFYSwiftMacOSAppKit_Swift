//
//  TFYSwiftGCD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

/// 异步闭包类型别名
public typealias AsyncClosure = (@escaping () -> Void) -> Void

/// 任务完成回调类型别名
public typealias TaskCompletionHandler = (Bool) -> Void

/// 任务错误类型
public enum TFYGCDError: Error, LocalizedError {
    case timeout
    case cancelled
    case invalidQueue
    case taskFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .timeout:
            return "任务执行超时"
        case .cancelled:
            return "任务被取消"
        case .invalidQueue:
            return "无效的队列"
        case .taskFailed(let message):
            return "任务执行失败: \(message)"
        }
    }
}

/// GCD工具类 - 提供完整的Grand Central Dispatch功能封装
/// 支持异步/同步执行、队列管理、并发控制、任务组、信号量等高级功能
@available(macOS 10.15, *)
public class TFYSwiftGCD: NSObject {
    
    // MARK: - 队列管理
    
    /// 获取主队列
    public static var mainQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    /// 获取全局并发队列
    /// - Parameter qos: 服务质量级别
    /// - Returns: 全局并发队列
    public static func globalQueue(qos: DispatchQoS.QoSClass = .userInitiated) -> DispatchQueue {
        return DispatchQueue.global(qos: qos)
    }
    
    /// 创建自定义串行队列
    /// - Parameter label: 队列标签
    /// - Returns: 串行队列
    public static func serialQueue(label: String) -> DispatchQueue {
        return DispatchQueue(label: label)
    }
    
    /// 创建自定义并发队列
    /// - Parameters:
    ///   - label: 队列标签
    ///   - qos: 服务质量级别
    ///   - attributes: 队列属性
    /// - Returns: 并发队列
    public static func concurrentQueue(label: String, qos: DispatchQoS = .userInitiated, attributes: DispatchQueue.Attributes = []) -> DispatchQueue {
        return DispatchQueue(label: label, qos: qos, attributes: attributes)
    }
    
    // MARK: - 异步执行
    
    /// 在主队列异步执行任务
    /// - Parameter work: 要执行的任务闭包
    public static func asyncInMainQueue(execute work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
        
    /// 在全局队列异步执行任务
    /// - Parameters:
    ///   - qos: 服务质量级别
    ///   - work: 要执行的任务闭包
    public static func asyncInGlobalQueue(qos: DispatchQoS.QoSClass = .userInitiated, execute work: @escaping () -> Void) {
        DispatchQueue.global(qos: qos).async(execute: work)
    }
    
    /// 在指定队列异步执行任务
    /// - Parameters:
    ///   - queue: 目标队列
    ///   - work: 要执行的任务闭包
    public static func async(in queue: DispatchQueue, execute work: @escaping () -> Void) {
        queue.async(execute: work)
    }
    
    /// 异步延迟执行任务
    /// - Parameters:
    ///   - seconds: 延迟秒数
    ///   - queue: 执行队列，默认为主队列
    ///   - work: 要执行的任务闭包
    public static func asyncAfter(seconds: TimeInterval, queue: DispatchQueue = .main, execute work: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + seconds, execute: work)
    }
    
    // MARK: - 同步执行
    
    /// 在主队列同步执行任务
    /// - Parameter work: 要执行的任务闭包
    public static func syncInMainQueue(execute work: () -> Void) {
        DispatchQueue.main.sync(execute: work)
    }
    
    /// 在全局队列同步执行任务
    /// - Parameters:
    ///   - qos: 服务质量级别
    ///   - work: 要执行的任务闭包
    public static func syncInGlobalQueue(qos: DispatchQoS.QoSClass = .userInitiated, execute work: () -> Void) {
        DispatchQueue.global(qos: qos).sync(execute: work)
    }
    
    /// 在指定队列同步执行任务
    /// - Parameters:
    ///   - queue: 目标队列
    ///   - work: 要执行的任务闭包
    public static func sync(in queue: DispatchQueue, execute work: () -> Void) {
        queue.sync(execute: work)
    }
    
    // MARK: - 任务组管理
    
    /// 创建任务组
    /// - Returns: 任务组
    public static func createGroup() -> DispatchGroup {
        return DispatchGroup()
    }
    
    /// 在任务组中异步执行任务
    /// - Parameters:
    ///   - group: 任务组
    ///   - queue: 执行队列
    ///   - work: 要执行的任务闭包
    public static func async(in group: DispatchGroup, queue: DispatchQueue = .global(), execute work: @escaping () -> Void) {
        queue.async(group: group, execute: work)
    }
    
    /// 等待任务组完成
    /// - Parameters:
    ///   - group: 任务组
    ///   - timeout: 超时时间，nil表示无限等待
    /// - Returns: 是否在超时前完成
    @discardableResult
    public static func wait(for group: DispatchGroup, timeout: DispatchTime? = nil) -> DispatchTimeoutResult {
        if let timeout = timeout {
            return group.wait(timeout: timeout)
        } else {
            group.wait()
            return .success
        }
    }
    
    /// 任务组完成回调
    /// - Parameters:
    ///   - group: 任务组
    ///   - queue: 回调队列
    ///   - work: 完成回调闭包
    public static func notify(group: DispatchGroup, queue: DispatchQueue = .main, execute work: @escaping () -> Void) {
        group.notify(queue: queue, execute: work)
    }
    
    // MARK: - 信号量管理
    
    /// 创建信号量
    /// - Parameter value: 信号量初始值
    /// - Returns: 信号量
    public static func createSemaphore(value: Int) -> DispatchSemaphore {
        return DispatchSemaphore(value: value)
    }
    
    /// 等待信号量
    /// - Parameters:
    ///   - semaphore: 信号量
    ///   - timeout: 超时时间，nil表示无限等待
    /// - Returns: 是否在超时前获得信号量
    @discardableResult
    public static func wait(semaphore: DispatchSemaphore, timeout: DispatchTime? = nil) -> DispatchTimeoutResult {
        if let timeout = timeout {
            return semaphore.wait(timeout: timeout)
        } else {
            semaphore.wait()
            return .success
        }
    }
    
    /// 释放信号量
    /// - Parameter semaphore: 信号量
    public static func signal(semaphore: DispatchSemaphore) {
        semaphore.signal()
    }
    
    // MARK: - 屏障操作
    
    /// 异步屏障操作
    /// - Parameters:
    ///   - queue: 目标队列
    ///   - work: 屏障任务闭包
    public static func asyncBarrier(in queue: DispatchQueue, execute work: @escaping () -> Void) {
        queue.async(flags: .barrier, execute: work)
    }
    
    /// 同步屏障操作
    /// - Parameters:
    ///   - queue: 目标队列
    ///   - work: 屏障任务闭包
    public static func syncBarrier(in queue: DispatchQueue, execute work: () -> Void) {
        queue.sync(flags: .barrier, execute: work)
    }
    
    // MARK: - 批量任务执行
    
    /// 批量异步执行任务
    /// - Parameters:
    ///   - tasks: 任务数组
    ///   - queue: 执行队列
    ///   - completion: 完成回调
    public static func asyncBatch(tasks: [() -> Void], queue: DispatchQueue = .global(), completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for task in tasks {
            queue.async(group: group, execute: task)
        }
        
        group.notify(queue: .main, execute: completion)
    }
    
    /// 批量同步执行任务
    /// - Parameters:
    ///   - tasks: 任务数组
    ///   - queue: 执行队列
    public static func syncBatch(tasks: [() -> Void], queue: DispatchQueue = .global()) {
        for task in tasks {
            queue.sync(execute: task)
        }
    }
    
    // MARK: - 条件执行
    
    /// 条件异步执行
    /// - Parameters:
    ///   - condition: 执行条件
    ///   - queue: 执行队列
    ///   - work: 要执行的任务闭包
    public static func asyncIf(_ condition: Bool, in queue: DispatchQueue = .main, execute work: @escaping () -> Void) {
        guard condition else { return }
        queue.async(execute: work)
    }
    
    /// 条件同步执行
    /// - Parameters:
    ///   - condition: 执行条件
    ///   - queue: 执行队列
    ///   - work: 要执行的任务闭包
    public static func syncIf(_ condition: Bool, in queue: DispatchQueue = .main, execute work: () -> Void) {
        guard condition else { return }
        queue.sync(execute: work)
    }
    
    // MARK: - 超时控制
    
    /// 带超时的异步执行
    /// - Parameters:
    ///   - timeout: 超时时间
    ///   - queue: 执行队列
    ///   - work: 要执行的任务闭包
    ///   - completion: 完成回调
    public static func asyncWithTimeout(_ timeout: TimeInterval, queue: DispatchQueue = .global(), execute work: @escaping () -> Void, completion: @escaping (Result<Void, TFYGCDError>) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        var isCompleted = false
        
        queue.async {
            work()
            if !isCompleted {
                isCompleted = true
                semaphore.signal()
            }
        }
        
        let result = semaphore.wait(timeout: .now() + timeout)
        if !isCompleted {
            isCompleted = true
            completion(.failure(.timeout))
        } else {
            completion(result == .success ? .success(()) : .failure(.timeout))
        }
    }
    
    // MARK: - 取消控制
    
    /// 可取消的异步执行
    /// - Parameters:
    ///   - queue: 执行队列
    ///   - work: 要执行的任务闭包
    ///   - completion: 完成回调
    /// - Returns: 取消令牌
    @discardableResult
    public static func asyncCancellable(in queue: DispatchQueue = .global(), execute work: @escaping () -> Void, completion: @escaping (Result<Void, TFYGCDError>) -> Void) -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            work()
            completion(.success(()))
        }
        
        workItem.notify(queue: .main) {
            if workItem.isCancelled {
                completion(.failure(.cancelled))
            }
        }
        
        queue.async(execute: workItem)
        return workItem
    }
    
    // MARK: - 性能优化
    
    /// 并发执行任务（限制并发数）
    /// - Parameters:
    ///   - tasks: 任务数组
    ///   - maxConcurrent: 最大并发数
    ///   - queue: 执行队列
    ///   - completion: 完成回调
    public static func asyncConcurrent(tasks: [() -> Void], maxConcurrent: Int = 4, queue: DispatchQueue = .global(), completion: @escaping () -> Void) {
        let semaphore = DispatchSemaphore(value: maxConcurrent)
        let group = DispatchGroup()
        
        for task in tasks {
            queue.async(group: group) {
                semaphore.wait()
                task()
                semaphore.signal()
            }
        }
        
        group.notify(queue: .main, execute: completion)
    }
    
    // MARK: - 便利方法
    
    /// 在主队列执行UI更新
    /// - Parameter work: UI更新闭包
    public static func updateUI(execute work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
    
    /// 在后台队列执行耗时操作
    /// - Parameter work: 耗时操作闭包
    public static func backgroundTask(execute work: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async(execute: work)
    }
        
    /// 延迟执行（便利方法）
    /// - Parameters:
    ///   - seconds: 延迟秒数
    ///   - work: 要执行的任务闭包
    public static func delay(_ seconds: TimeInterval, execute work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
    
    /// 重复执行任务
    /// - Parameters:
    ///   - interval: 重复间隔
    ///   - queue: 执行队列
    ///   - work: 要执行的任务闭包
    /// - Returns: 定时器
    @discardableResult
    public static func repeatTask(interval: TimeInterval, queue: DispatchQueue = .main, execute work: @escaping () -> Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: interval)
        timer.setEventHandler(handler: work)
        timer.resume()
        return timer
    }
}

// MARK: - 扩展方法

@available(macOS 10.15, *)
public extension TFYSwiftGCD {
    
    /// 安全的主队列同步执行（避免死锁）
    /// - Parameter work: 要执行的任务闭包
    static func safeSyncInMainQueue(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
    
    /// 带重试的异步执行
    /// - Parameters:
    ///   - retryCount: 重试次数
    ///   - queue: 执行队列
    ///   - work: 要执行的任务闭包
    ///   - completion: 完成回调
    static func asyncWithRetry(retryCount: Int, queue: DispatchQueue = .global(), execute work: @escaping () -> Bool, completion: @escaping (Bool) -> Void) {
        var currentRetry = 0
        
        func attempt() {
            queue.async {
                let success = work()
                if success || currentRetry >= retryCount {
                    DispatchQueue.main.async {
                        completion(success)
                    }
                } else {
                    currentRetry += 1
                    attempt()
                }
            }
        }
        
        attempt()
    }
}
