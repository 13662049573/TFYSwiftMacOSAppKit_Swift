//
//  NSSlider+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/17/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - NSSlider 扩展

@MainActor public extension NSSlider {
    /// 当前值的归一化百分比（0.0 ~ 1.0）
    var normalizedValue: Double {
        get {
            guard maxValue > minValue else { return 0 }
            return (doubleValue - minValue) / (maxValue - minValue)
        }
        set {
            let clamped = min(max(newValue, 0), 1)
            doubleValue = minValue + clamped * (maxValue - minValue)
        }
    }

    /// 设置值，可选动画
    /// - Parameters:
    ///   - value: 目标值
    ///   - animated: 是否使用动画
    func setValue(_ value: Double, animated: Bool) {
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                context.allowsImplicitAnimation = true
                self.animator().doubleValue = value
            }
        } else {
            doubleValue = value
        }
    }

    /// 重置滑块到最小值
    func resetToMinimum() {
        doubleValue = minValue
    }

    /// 重置滑块到最大值
    func resetToMaximum() {
        doubleValue = maxValue
    }

    /// 重置滑块到中间值
    func resetToCenter() {
        doubleValue = (minValue + maxValue) / 2
    }

    /// 按步长递增
    /// - Parameter step: 步长
    func increment(by step: Double = 1) {
        doubleValue = min(doubleValue + step, maxValue)
    }

    /// 按步长递减
    /// - Parameter step: 步长
    func decrement(by step: Double = 1) {
        doubleValue = max(doubleValue - step, minValue)
    }

    /// 配置滑块范围
    /// - Parameters:
    ///   - min: 最小值
    ///   - max: 最大值
    ///   - current: 当前值
    func configure(min: Double, max: Double, current: Double? = nil) {
        minValue = min
        maxValue = max
        if let current {
            doubleValue = Swift.min(Swift.max(current, min), max)
        }
    }
}
