//
//  Timer+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

// MARK: - Timer 扩展
public extension Timer {
    
    /**
     创建并调度一个定时器到当前 RunLoop 的默认模式
     
     - Parameters:
        - interval: 定时器触发间隔(秒)
        - block: 定时器触发时执行的闭包
        - repeats: 是否重复执行
     - Returns: 新创建的定时器对象
     
     - Note: 闭包会被定时器强引用,直到定时器失效
     */
    @discardableResult
    class func scheduledTimer(withTimeInterval interval: TimeInterval,
                            block: @escaping (Timer) -> Void,
                            repeats: Bool) -> Timer {
        // 创建定时器并保存闭包
        let timer = Timer.scheduledTimer(timeInterval: interval,
                                       target: self,
                                       selector: #selector(executeTimerBlock(_:)),
                                       userInfo: block,
                                       repeats: repeats)
        return timer
    }
    
    /**
     创建一个定时器(需要手动添加到 RunLoop)
     
     - Parameters:
        - interval: 定时器触发间隔(秒)
        - block: 定时器触发时执行的闭包
        - repeats: 是否重复执行
     - Returns: 新创建的定时器对象
     */
    class func timer(withTimeInterval interval: TimeInterval,
                    block: @escaping (Timer) -> Void,
                    repeats: Bool) -> Timer {
        let timer = Timer(timeInterval: interval,
                         target: self,
                         selector: #selector(executeTimerBlock(_:)),
                         userInfo: block,
                         repeats: repeats)
        return timer
    }
    
    // 执行定时器闭包
    @objc private class func executeTimerBlock(_ timer: Timer) {
        if let block = timer.userInfo as? (Timer) -> Void {
            block(timer)
        }
    }
    
    // MARK: - 高级定时器功能
    
    /// 创建延迟执行的定时器
    /// - Parameters:
    ///   - delay: 延迟时间
    ///   - block: 执行块
    /// - Returns: 定时器
    @discardableResult
    class func scheduledTimer(afterDelay delay: TimeInterval,
                            block: @escaping () -> Void) -> Timer {
        return scheduledTimer(withTimeInterval: delay, block: { _ in
            block()
        }, repeats: false)
    }
    
    /// 创建倒计时定时器
    /// - Parameters:
    ///   - duration: 倒计时总时长
    ///   - interval: 更新间隔
    ///   - onTick: 每次tick的回调
    ///   - onComplete: 完成回调
    /// - Returns: 定时器
    @discardableResult
    class func countdownTimer(duration: TimeInterval,
                            interval: TimeInterval = 1.0,
                            onTick: @escaping (TimeInterval) -> Void,
                            onComplete: @escaping () -> Void) -> Timer {
        var remainingTime = duration
        
        return scheduledTimer(withTimeInterval: interval, block: { timer in
            remainingTime -= interval
            onTick(remainingTime)
            
            if remainingTime <= 0 {
                timer.invalidate()
                onComplete()
            }
        }, repeats: true)
    }
    
    /// 创建脉冲定时器（执行指定次数后停止）
    /// - Parameters:
    ///   - interval: 间隔时间
    ///   - count: 执行次数
    ///   - block: 执行块
    ///   - onComplete: 完成回调
    /// - Returns: 定时器
    @discardableResult
    class func pulseTimer(interval: TimeInterval,
                         count: Int,
                         block: @escaping (Int) -> Void,
                         onComplete: @escaping () -> Void) -> Timer {
        var currentCount = 0
        
        return scheduledTimer(withTimeInterval: interval, block: { timer in
            currentCount += 1
            block(currentCount)
            
            if currentCount >= count {
                timer.invalidate()
                onComplete()
            }
        }, repeats: true)
    }
    
    /// 创建自适应定时器（根据执行时间调整间隔）
    /// - Parameters:
    ///   - initialInterval: 初始间隔
    ///   - minInterval: 最小间隔
    ///   - maxInterval: 最大间隔
    ///   - block: 执行块
    /// - Returns: 定时器
    @discardableResult
    class func adaptiveTimer(initialInterval: TimeInterval,
                           minInterval: TimeInterval,
                           maxInterval: TimeInterval,
                           block: @escaping (TimeInterval) -> Void) -> Timer {
        var currentInterval = initialInterval
        
        return scheduledTimer(withTimeInterval: currentInterval, block: { timer in
            let startTime = Date()
            block(currentInterval)
            let executionTime = Date().timeIntervalSince(startTime)
            
            // 根据执行时间调整间隔
            if executionTime > currentInterval * 0.8 {
                currentInterval = min(currentInterval * 1.2, maxInterval)
            } else if executionTime < currentInterval * 0.2 {
                currentInterval = max(currentInterval * 0.8, minInterval)
            }
            
            timer.invalidate()
            let newTimer = Timer.scheduledTimer(withTimeInterval: currentInterval, block: { _ in
                block(currentInterval)
            }, repeats: true)
            
            // 替换定时器
            let runLoop = RunLoop.current
            runLoop.add(newTimer, forMode: .default)
        }, repeats: false)
    }
    
    /// 暂停定时器
    func pause() {
        fireDate = Date.distantFuture
    }
    
    /// 恢复定时器
    func resume() {
        fireDate = Date()
    }
    
    /// 检查定时器是否有效
    var isValid: Bool {
        return fireDate != Date.distantFuture
    }
    
    /// 获取定时器的剩余时间
    var remainingTime: TimeInterval {
        guard isValid else { return 0 }
        return fireDate.timeIntervalSinceNow
    }
}

// MARK: - 定时器管理器
public class TimerManager {
    private var timers: [String: Timer] = [:]
    private let queue = DispatchQueue(label: "TimerManager", attributes: .concurrent)
    
    /// 创建并管理定时器
    /// - Parameters:
    ///   - key: 定时器标识
    ///   - interval: 间隔时间
    ///   - block: 执行块
    ///   - repeats: 是否重复
    /// - Returns: 是否创建成功
    @discardableResult
    func createTimer(key: String,
                    interval: TimeInterval,
                    block: @escaping (Timer) -> Void,
                    repeats: Bool = true) -> Bool {
        queue.async(flags: .barrier) {
            // 如果已存在，先移除
            self.removeTimer(key: key)
            
            let timer = Timer.scheduledTimer(withTimeInterval: interval, block: block, repeats: repeats)
            self.timers[key] = timer
        }
        return true
    }
    
    /// 移除定时器
    /// - Parameter key: 定时器标识
    func removeTimer(key: String) {
        queue.async(flags: .barrier) {
            if let timer = self.timers[key] {
                timer.invalidate()
                self.timers.removeValue(forKey: key)
            }
        }
    }
    
    /// 移除所有定时器
    func removeAllTimers() {
        queue.async(flags: .barrier) {
            self.timers.values.forEach { $0.invalidate() }
            self.timers.removeAll()
        }
    }
    
    /// 暂停定时器
    /// - Parameter key: 定时器标识
    func pauseTimer(key: String) {
        queue.async {
            self.timers[key]?.pause()
        }
    }
    
    /// 恢复定时器
    /// - Parameter key: 定时器标识
    func resumeTimer(key: String) {
        queue.async {
            self.timers[key]?.resume()
        }
    }
    
    /// 检查定时器是否存在
    /// - Parameter key: 定时器标识
    /// - Returns: 是否存在
    func hasTimer(key: String) -> Bool {
        return queue.sync {
            return timers[key] != nil
        }
    }
    
    /// 获取定时器数量
    var timerCount: Int {
        return queue.sync {
            return timers.count
        }
    }
    
    deinit {
        removeAllTimers()
    }
}

// MARK: - 定时器错误类型
public enum TimerError: Error, LocalizedError {
    case invalidInterval
    case invalidCount
    case timerAlreadyExists(String)
    case timerNotFound(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidInterval:
            return "无效的时间间隔"
        case .invalidCount:
            return "无效的执行次数"
        case .timerAlreadyExists(let key):
            return "定时器已存在: \(key)"
        case .timerNotFound(let key):
            return "定时器未找到: \(key)"
        }
    }
}

