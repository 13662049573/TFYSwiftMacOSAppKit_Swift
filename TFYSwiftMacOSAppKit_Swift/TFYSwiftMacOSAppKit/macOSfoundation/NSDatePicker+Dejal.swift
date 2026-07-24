//
//  NSDatePicker+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/17/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Foundation
import Cocoa
// MARK: - NSDatePicker 扩展

@MainActor public extension NSDatePicker {
    /// 设置日期范围
    /// - Parameters:
    ///   - minDate: 最小日期
    ///   - maxDate: 最大日期
    func setDateRange(from minDate: Date?, to maxDate: Date?) {
        self.minDate = minDate
        self.maxDate = maxDate
    }

    /// 重置为当前日期
    func resetToNow() {
        dateValue = Date()
    }

    /// 当前日期值是否在指定范围内
    /// - Parameters:
    ///   - start: 起始日期
    ///   - end: 结束日期
    /// - Returns: 是否在范围内
    func isDateInRange(from start: Date, to end: Date) -> Bool {
        return dateValue >= start && dateValue <= end
    }
}
