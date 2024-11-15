//
//  TFYSwiftTimer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Timer Utility Class
public class TFYSwiftTimer {

    private let internalTimer: DispatchSourceTimer
    private var isRunning = false
    public let repeats: Bool
    public typealias SwiftTimerHandler = (TFYSwiftTimer?) -> Void
    private var handler: SwiftTimerHandler

    public init(interval: DispatchTimeInterval, repeats: Bool = false, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        self.repeats = repeats
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        internalTimer.setEventHandler { [weak self] in
            self?.handler(self)
        }
        internalTimer.schedule(deadline: .now() + interval, repeating: repeats ? interval : .never, leeway: leeway)
    }

    public static func repeatingTimer(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) -> TFYSwiftTimer {
        return TFYSwiftTimer(interval: interval, repeats: true, leeway: leeway, queue: queue, handler: handler)
    }

    deinit {
        if !isRunning {
            internalTimer.resume() // Ensure timer is resumed to properly release it
        }
        internalTimer.cancel()
    }

    public func fire() {
        handler(self)
        if !repeats {
            internalTimer.cancel()
        }
    }

    public func start() {
        guard !isRunning else { return }
        internalTimer.resume()
        isRunning = true
    }

    public func suspend() {
        guard isRunning else { return }
        internalTimer.suspend()
        isRunning = false
    }

    public func rescheduleRepeating(interval: DispatchTimeInterval) {
        if repeats {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval)
        }
    }

    public func rescheduleHandler(handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        internalTimer.setEventHandler { [weak self] in
            self?.handler(self)
        }
    }
}

// MARK: - Debounce and Throttle
public extension TFYSwiftTimer {

    private static var workItems = [String: DispatchWorkItem]()

    static func debounce(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        workItems[identifier]?.cancel()
        let item = DispatchWorkItem(block: handler)
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }

    static func throttle(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        guard workItems[identifier] == nil else { return }
        let item = DispatchWorkItem(block: handler)
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }

    static func cancelThrottlingTimer(identifier: String) {
        workItems[identifier]?.cancel()
        workItems.removeValue(forKey: identifier)
    }
}

public class TFYSwiftCountDownTimer {

    private lazy var internalTimer: TFYSwiftTimer = {
        let timer = TFYSwiftTimer.repeatingTimer(interval: interval, queue: queue, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.leftTimes > 0 {
                strongSelf.leftTimes -= 1
                strongSelf.handler(strongSelf, strongSelf.leftTimes)
            } else {
                strongSelf.internalTimer.suspend()
            }
        })
        return timer
    }()

    private var leftTimes: Int
    private let originalTimes: Int
    private let handler: (TFYSwiftCountDownTimer, _ leftTimes: Int) -> Void
    private let interval: DispatchTimeInterval
    private let queue: DispatchQueue

    public init(interval: DispatchTimeInterval, times: Int, queue: DispatchQueue = .main, handler: @escaping (TFYSwiftCountDownTimer, _ leftTimes: Int) -> Void) {
        self.interval = interval
        self.leftTimes = times
        self.originalTimes = times
        self.handler = handler
        self.queue = queue
    }

    public func start() {
        internalTimer.start()
    }

    public func suspend() {
        internalTimer.suspend()
    }

    public func reCountDown() {
        leftTimes = originalTimes
    }
}

public extension DispatchTimeInterval {

    static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
        return .milliseconds(Int(seconds * 1000))
    }
}
