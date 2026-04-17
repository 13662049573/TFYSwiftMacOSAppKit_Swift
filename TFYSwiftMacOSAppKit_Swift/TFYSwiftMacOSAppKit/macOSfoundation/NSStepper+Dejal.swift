//
//  NSStepper+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/17/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - NSStepper 扩展

@MainActor public extension NSStepper {
    /// 配置步进器
    /// - Parameters:
    ///   - min: 最小值
    ///   - max: 最大值
    ///   - increment: 步进值
    ///   - current: 当前值
    func configure(min: Double, max: Double, increment: Double = 1, current: Double? = nil) {
        minValue = min
        maxValue = max
        self.increment = increment
        if let current {
            doubleValue = Swift.min(Swift.max(current, min), max)
        }
    }

    /// 重置到最小值
    func resetToMinimum() {
        doubleValue = minValue
    }
}
