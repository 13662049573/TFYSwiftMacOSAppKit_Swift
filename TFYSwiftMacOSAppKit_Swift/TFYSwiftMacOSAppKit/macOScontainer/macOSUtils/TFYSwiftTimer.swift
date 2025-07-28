//
//  TFYSwiftTimer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

/// 定时器错误类型
public enum TFYTimerError: Error, LocalizedError {
    case invalidInterval
    case timerNotRunning
    case timerAlreadyRunning
    case invalidTimes
    case timerCancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidInterval:
            return "无效的时间间隔"
        case .timerNotRunning:
            return "定时器未运行"
        case .timerAlreadyRunning:
            return "定时器已在运行"
        case .invalidTimes:
            return "无效的倒计时次数"
        case .timerCancelled:
            return "定时器已取消"
        }
    }
}

/// 定时器状态枚举
public enum TFYTimerState {
    case idle      // 空闲状态
    case running   // 运行中
    case paused    // 暂停
    case cancelled // 已取消
    case finished  // 已完成
}

/// 定时器工具类 - 提供完整的定时器功能封装
/// 支持单次/重复定时器、倒计时、防抖、节流等高级功能
@available(macOS 10.15, *)
public class TFYSwiftTimer: NSObject {
    
    // MARK: - Properties
    
    /// 内部定时器
    private var internalTimer: DispatchSourceTimer!
    
    /// 是否正在运行
    private var isRunning = false
    
    /// 是否重复执行
    public let repeats: Bool
    
    /// 定时器状态
    public private(set) var state: TFYTimerState = .idle
    
    /// 定时器处理器类型别名
    public typealias SwiftTimerHandler = (TFYSwiftTimer?) -> Void
    
    /// 定时器处理器
    private var handler: SwiftTimerHandler
    
    /// 时间间隔
    public let interval: DispatchTimeInterval
    
    /// 执行队列
    public let queue: DispatchQueue
    
    /// 容差时间
    public let leeway: DispatchTimeInterval
    
    /// 创建时间
    public let creationDate: Date
    
    /// 开始时间
    public private(set) var startDate: Date?
    
    /// 暂停时间
    public private(set) var pauseDate: Date?
    
    /// 总运行时间
    public var totalRunningTime: TimeInterval {
        guard let startDate = startDate else { return 0 }
        let endDate = pauseDate ?? Date()
        return endDate.timeIntervalSince(startDate)
    }
    
    // MARK: - Initialization
    
    /// 初始化定时器
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - repeats: 是否重复执行
    ///   - leeway: 容差时间
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    public init(interval: DispatchTimeInterval, repeats: Bool = false, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        self.repeats = repeats
        self.interval = interval
        self.queue = queue
        self.leeway = leeway
        self.creationDate = Date()
        
        super.init()
        
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        internalTimer.setEventHandler { [weak self] in
            self?.handler(self)
        }
        internalTimer.schedule(deadline: .now() + interval, repeating: repeats ? interval : .never, leeway: leeway)
    }
    
    deinit {
        if !isRunning {
            internalTimer.resume() // 确保定时器被恢复以正确释放
        }
        internalTimer.cancel()
    }
    
    // MARK: - Factory Methods
    
    /// 创建重复定时器
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - leeway: 容差时间
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    /// - Returns: 重复定时器
    public static func repeatingTimer(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) -> TFYSwiftTimer {
        return TFYSwiftTimer(interval: interval, repeats: true, leeway: leeway, queue: queue, handler: handler)
    }
    
    /// 创建单次定时器
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    /// - Returns: 单次定时器
    public static func singleTimer(interval: DispatchTimeInterval, queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) -> TFYSwiftTimer {
        return TFYSwiftTimer(interval: interval, repeats: false, queue: queue, handler: handler)
    }
    
    /// 创建延迟执行定时器
    /// - Parameters:
    ///   - delay: 延迟时间
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    /// - Returns: 延迟定时器
    public static func delayedTimer(delay: DispatchTimeInterval, queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) -> TFYSwiftTimer {
        return TFYSwiftTimer(interval: delay, repeats: false, queue: queue, handler: handler)
    }
    
    // MARK: - Control Methods
    
    /// 立即触发定时器
    public func fire() {
        guard state != .cancelled else { return }
        handler(self)
        if !repeats {
            state = .finished
            internalTimer.cancel()
        }
    }
    
    /// 启动定时器
    public func start() throws {
        guard state != .running else {
            throw TFYTimerError.timerAlreadyRunning
        }
        guard state != .cancelled else {
            throw TFYTimerError.timerCancelled
        }
        
        internalTimer.resume()
        isRunning = true
        state = .running
        startDate = Date()
        pauseDate = nil
    }
    
    /// 暂停定时器
    public func pause() throws {
        guard state == .running else {
            throw TFYTimerError.timerNotRunning
        }
        
        internalTimer.suspend()
        isRunning = false
        state = .paused
        pauseDate = Date()
    }
    
    /// 恢复定时器
    public func resume() throws {
        guard state == .paused else {
            throw TFYTimerError.timerNotRunning
        }
        
        internalTimer.resume()
        isRunning = true
        state = .running
        pauseDate = nil
    }
    
    /// 停止定时器
    public func stop() {
        internalTimer.suspend()
        isRunning = false
        state = .idle
        startDate = nil
        pauseDate = nil
    }
    
    /// 取消定时器
    public func cancel() {
        internalTimer.cancel()
        isRunning = false
        state = .cancelled
        startDate = nil
        pauseDate = nil
    }
    
    // MARK: - Configuration Methods
    
    /// 重新调度重复定时器
    /// - Parameter interval: 新的时间间隔
    public func rescheduleRepeating(interval: DispatchTimeInterval) {
        if repeats && state != .cancelled {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval, leeway: leeway)
        }
    }
    
    /// 重新设置处理器
    /// - Parameter handler: 新的处理器闭包
    public func rescheduleHandler(handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        internalTimer.setEventHandler { [weak self] in
            self?.handler(self)
        }
    }
    
    // MARK: - Utility Methods
    
    /// 检查定时器是否正在运行
    public var isActive: Bool {
        return state == .running
    }
    
    /// 获取剩余时间（仅适用于单次定时器）
    public var remainingTime: TimeInterval? {
        guard !repeats, let startDate = startDate else { return nil }
        let elapsed = Date().timeIntervalSince(startDate)
        let totalInterval = interval.toSeconds()
        return max(0, totalInterval - elapsed)
    }
    
    /// 获取已运行时间
    public var elapsedTime: TimeInterval {
        guard let startDate = startDate else { return 0 }
        let endDate = pauseDate ?? Date()
        return endDate.timeIntervalSince(startDate)
    }
}

// MARK: - Debounce and Throttle

@available(macOS 10.15, *)
public extension TFYSwiftTimer {
    
    /// 防抖和节流工作项存储
    private static var workItems = [String: DispatchWorkItem]()
    
    /// 防抖定时器
    /// - Parameters:
    ///   - interval: 防抖间隔
    ///   - identifier: 唯一标识符
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    static func debounce(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        workItems[identifier]?.cancel()
        let item = DispatchWorkItem(block: handler)
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }
    
    /// 节流定时器
    /// - Parameters:
    ///   - interval: 节流间隔
    ///   - identifier: 唯一标识符
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    static func throttle(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        guard workItems[identifier] == nil else { return }
        let item = DispatchWorkItem(block: handler)
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }
    
    /// 取消节流定时器
    /// - Parameter identifier: 唯一标识符
    static func cancelThrottlingTimer(identifier: String) {
        workItems[identifier]?.cancel()
        workItems.removeValue(forKey: identifier)
    }
    
    /// 清理所有工作项
    static func cleanupWorkItems() {
        workItems.values.forEach { $0.cancel() }
        workItems.removeAll()
    }
}

// MARK: - Countdown Timer

/// 倒计时定时器类
@available(macOS 10.15, *)
public class TFYSwiftCountDownTimer: NSObject {
    
    // MARK: - Properties
    
    /// 内部定时器
    private lazy var internalTimer: TFYSwiftTimer = {
        let timer = TFYSwiftTimer.repeatingTimer(interval: interval, queue: queue, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.leftTimes > 0 {
                strongSelf.leftTimes -= 1
                strongSelf.handler(strongSelf, strongSelf.leftTimes)
                
                if strongSelf.leftTimes == 0 {
                    strongSelf.state = .finished
                    strongSelf.internalTimer.cancel()
                }
            } else {
                strongSelf.state = .finished
                strongSelf.internalTimer.cancel()
            }
        })
        return timer
    }()
    
    /// 剩余次数
    private var leftTimes: Int
    
    /// 原始次数
    private let originalTimes: Int
    
    /// 处理器闭包
    private let handler: (TFYSwiftCountDownTimer, _ leftTimes: Int) -> Void
    
    /// 时间间隔
    private let interval: DispatchTimeInterval
    
    /// 执行队列
    private let queue: DispatchQueue
    
    /// 定时器状态
    public private(set) var state: TFYTimerState = .idle
    
    /// 是否正在运行
    public var isRunning: Bool {
        return state == .running
    }
    
    /// 剩余时间（秒）
    public var remainingTime: Int {
        return leftTimes
    }
    
    /// 总时间（秒）
    public var totalTime: Int {
        return originalTimes
    }
    
    /// 进度（0.0 - 1.0）
    public var progress: Double {
        guard originalTimes > 0 else { return 0 }
        return Double(originalTimes - leftTimes) / Double(originalTimes)
    }
    
    // MARK: - Initialization
    
    /// 初始化倒计时定时器
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - times: 倒计时次数
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    public init(interval: DispatchTimeInterval, times: Int, queue: DispatchQueue = .main, handler: @escaping (TFYSwiftCountDownTimer, _ leftTimes: Int) -> Void) {
        guard times > 0 else {
            fatalError("倒计时次数必须大于0")
        }
        
        self.interval = interval
        self.leftTimes = times
        self.originalTimes = times
        self.handler = handler
        self.queue = queue
        
        super.init()
    }
    
    // MARK: - Control Methods
    
    /// 启动倒计时
    public func start() {
        guard state != .running else { return }
        state = .running
        try? internalTimer.start()
    }
    
    /// 暂停倒计时
    public func pause() {
        guard state == .running else { return }
        state = .paused
        try? internalTimer.pause()
    }
    
    /// 恢复倒计时
    public func resume() {
        guard state == .paused else { return }
        state = .running
        try? internalTimer.resume()
    }
    
    /// 停止倒计时
    public func stop() {
        state = .idle
        internalTimer.stop()
    }
    
    /// 取消倒计时
    public func cancel() {
        state = .cancelled
        internalTimer.cancel()
    }
    
    /// 重新开始倒计时
    public func restart() {
        leftTimes = originalTimes
        state = .idle
        internalTimer.stop()
        start()
    }
    
    /// 重置倒计时
    public func reset() {
        leftTimes = originalTimes
        state = .idle
        internalTimer.stop()
    }
    
    /// 设置剩余时间
    /// - Parameter times: 新的剩余时间
    public func setRemainingTime(_ times: Int) {
        guard times >= 0 && times <= originalTimes else { return }
        leftTimes = times
    }
}

// MARK: - DispatchTimeInterval Extensions

public extension DispatchTimeInterval {
    
    /// 从秒数创建时间间隔
    /// - Parameter seconds: 秒数
    /// - Returns: 时间间隔
    static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
        return .milliseconds(Int(seconds * 1000))
    }
    
    /// 转换为秒数
    /// - Returns: 秒数
    func toSeconds() -> TimeInterval {
        switch self {
        case .seconds(let value):
            return TimeInterval(value)
        case .milliseconds(let value):
            return TimeInterval(value) / 1000.0
        case .microseconds(let value):
            return TimeInterval(value) / 1_000_000.0
        case .nanoseconds(let value):
            return TimeInterval(value) / 1_000_000_000.0
        case .never:
            return 0
        @unknown default:
            return 0
        }
    }
    
    /// 转换为毫秒数
    /// - Returns: 毫秒数
    func toMilliseconds() -> Int {
        return Int(toSeconds() * 1000)
    }
}

// MARK: - Convenience Extensions

@available(macOS 10.15, *)
public extension TFYSwiftTimer {
    
    /// 便利方法：延迟执行
    /// - Parameters:
    ///   - delay: 延迟时间
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    static func delay(_ delay: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        let timer = delayedTimer(delay: .fromSeconds(delay), queue: queue) { _ in
            handler()
        }
        try? timer.start()
    }
    
    /// 便利方法：重复执行
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    /// - Returns: 定时器实例
    @discardableResult
    static func repeatTimer(interval: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) -> TFYSwiftTimer {
        let timer = repeatingTimer(interval: .fromSeconds(interval), queue: queue) { _ in
            handler()
        }
        try? timer.start()
        return timer
    }
    
    /// 便利方法：单次执行
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - queue: 执行队列
    ///   - handler: 处理器闭包
    /// - Returns: 定时器实例
    @discardableResult
    static func once(interval: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) -> TFYSwiftTimer {
        let timer = singleTimer(interval: .fromSeconds(interval), queue: queue) { _ in
            handler()
        }
        try? timer.start()
        return timer
    }
}
