//
//  TFYSwiftTimer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// TFYSwiftTimer 类用于创建计时器
public class TFYSwiftTimer {

    // 内部的 DispatchSourceTimer 对象
    private let internalTimer: DispatchSourceTimer

    // 标记计时器是否正在运行
    private var isRunning = false

    // 表示计时器是否重复
    public let repeats: Bool

    // 计时器的处理闭包类型
    public typealias SwiftTimerHandler = (TFYSwiftTimer) -> Void

    // 计时器的处理闭包
    private var handler: SwiftTimerHandler

    // 初始化方法，创建一个计时器
    public init(interval: DispatchTimeInterval, repeats: Bool = false, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        self.repeats = repeats
        // 创建 DispatchSourceTimer 对象
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        // 设置计时器的事件处理闭包
        internalTimer.setEventHandler { [weak self] in
            if let strongSelf = self {
                handler(strongSelf)
            }
        }

        // 如果重复，设置重复的时间表；如果不重复，设置单次的时间表
        if repeats {
            internalTimer.schedule(deadline:.now() + interval, repeating: interval, leeway: leeway)
        } else {
            internalTimer.schedule(deadline:.now() + interval, leeway: leeway)
        }
    }

    // 创建一个重复的计时器的静态方法
    public static func repeaticTimer(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) -> TFYSwiftTimer {
        return TFYSwiftTimer(interval: interval, repeats: true, leeway: leeway, queue: queue, handler: handler)
    }

    // 析构函数，在对象销毁时，如果计时器未运行，恢复计时器
    deinit {
        if !self.isRunning {
            internalTimer.resume()
        }
    }

    // 触发计时器，如果是重复计时器，调用处理闭包；如果是非重复计时器，调用处理闭包并取消计时器
    public func fire() {
        if repeats {
            handler(self)
        } else {
            handler(self)
            internalTimer.cancel()
        }
    }

    // 启动计时器
    public func start() {
        if !isRunning {
            internalTimer.resume()
            isRunning = true
        }
    }

    // 暂停计时器
    public func suspend() {
        if isRunning {
            internalTimer.suspend()
            isRunning = false
        }
    }

    // 重新安排重复计时器的时间间隔
    public func rescheduleRepeating(interval: DispatchTimeInterval) {
        if repeats {
            internalTimer.schedule(deadline:.now() + interval, repeating: interval)
        }
    }

    // 重新设置计时器的处理闭包
    public func rescheduleHandler(handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        internalTimer.setEventHandler { [weak self] in
            if let strongSelf = self {
                handler(strongSelf)
            }
        }
    }
}

public extension TFYSwiftTimer {

    // 存储用于去抖动和节流的 DispatchWorkItem 的字典
    private static var workItems = [String: DispatchWorkItem]()

    // 去抖动方法，在指定时间间隔后调用处理闭包，如果在间隔时间内再次调用，将取消先前的调用
    static func debounce(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        // 如果已经存在对应的 DispatchWorkItem，取消它
        if let item = workItems[identifier] {
            item.cancel()
        }

        let item = DispatchWorkItem {
            handler()
            workItems.removeValue(forKey: identifier)
        }
        workItems[identifier] = item
        queue.asyncAfter(deadline:.now() + interval, execute: item)
    }

    // 节流方法，在指定时间间隔后调用处理闭包，如果在间隔时间内再次调用无效
    static func throttle(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        // 如果已经存在对应的 DispatchWorkItem，直接返回，不执行处理闭包
        if workItems[identifier] != nil {
            return
        }

        let item = DispatchWorkItem {
            handler()
            workItems.removeValue(forKey: identifier)
        }
        workItems[identifier] = item
        queue.asyncAfter(deadline:.now() + interval, execute: item)
    }

    // 取消节流计时器
    static func cancelThrottlingTimer(identifier: String) {
        if let item = workItems[identifier] {
            item.cancel()
            workItems.removeValue(forKey: identifier)
        }
    }
}

// MARK: Count Down
// TFYSwiftCountDownTimer 类用于创建倒计时计时器
public class TFYSwiftCountDownTimer {

    // 内部使用的 TFYSwiftTimer 对象
    private let internalTimer: TFYSwiftTimer

    // 剩余时间
    private var leftTimes: Int

    // 初始时间
    private let originalTimes: Int

    // 倒计时处理闭包
    private let handler: (TFYSwiftCountDownTimer, _ leftTimes: Int) -> Void

    // 初始化方法，创建一个倒计时计时器
    public init(interval: DispatchTimeInterval, times: Int, queue: DispatchQueue = .main, handler: @escaping (TFYSwiftCountDownTimer, _ leftTimes: Int) -> Void) {
        self.leftTimes = times
        self.originalTimes = times
        self.handler = handler
        // 创建一个重复的 TFYSwiftTimer 对象
        self.internalTimer = TFYSwiftTimer.repeaticTimer(interval: interval, queue: queue, handler: { _ in })
        // 重新设置内部计时器的处理闭包
        self.internalTimer.rescheduleHandler { [weak self] swiftTimer in
            if let strongSelf = self {
                if strongSelf.leftTimes > 0 {
                    strongSelf.leftTimes = strongSelf.leftTimes - 1
                    strongSelf.handler(strongSelf, strongSelf.leftTimes)
                } else {
                    strongSelf.internalTimer.suspend()
                }
            }
        }
    }

    // 启动倒计时计时器
    public func start() {
        self.internalTimer.start()
    }

    // 暂停倒计时计时器
    public func suspend() {
        self.internalTimer.suspend()
    }

    // 重新开始倒计时
    public func reCountDown() {
        self.leftTimes = self.originalTimes
    }
}

public extension DispatchTimeInterval {

    // 从秒数创建 DispatchTimeInterval 的静态方法
    static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
        return.milliseconds(Int(seconds * 1000))
    }
}
