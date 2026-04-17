//
//  NSSegmentedControl+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/17/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

@MainActor public extension NSSegmentedControl {
    /// 所有分段标题
    var segmentTitles: [String] {
        (0..<segmentCount).map { label(forSegment: $0) ?? "" }
    }

    /// 批量设置标题
    /// - Parameter titles: 标题数组
    func setSegmentTitles(_ titles: [String]) {
        segmentCount = titles.count
        for (index, title) in titles.enumerated() {
            setLabel(title, forSegment: index)
        }
    }

    /// 取消全部选中状态
    func deselectAllSegments() {
        selectedSegment = -1
    }

    /// 选中下一个分段
    /// - Parameter wrapping: 是否循环
    func selectNextSegment(wrapping: Bool = true) {
        guard segmentCount > 0 else { return }
        let nextIndex = selectedSegment + 1
        if nextIndex < segmentCount {
            selectedSegment = nextIndex
        } else if wrapping {
            selectedSegment = 0
        }
    }

    /// 选中上一个分段
    /// - Parameter wrapping: 是否循环
    func selectPreviousSegment(wrapping: Bool = true) {
        guard segmentCount > 0 else { return }
        let prevIndex = selectedSegment - 1
        if prevIndex >= 0 {
            selectedSegment = prevIndex
        } else if wrapping {
            selectedSegment = segmentCount - 1
        }
    }

    /// 批量设置分段图标
    /// - Parameter images: 图标数组
    func setSegmentImages(_ images: [NSImage]) {
        for (index, image) in images.enumerated() where index < segmentCount {
            setImage(image, forSegment: index)
        }
    }

    /// 批量设置分段宽度
    /// - Parameter width: 每个分段的宽度（0 表示自适应）
    func setUniformSegmentWidth(_ width: CGFloat) {
        for i in 0..<segmentCount {
            setWidth(width, forSegment: i)
        }
    }

    /// 设置指定分段的启用状态
    /// - Parameters:
    ///   - enabled: 是否启用
    ///   - segment: 分段索引
    func setSegmentEnabled(_ enabled: Bool, forSegment segment: Int) {
        guard segment >= 0, segment < segmentCount else { return }
        setEnabled(enabled, forSegment: segment)
    }

    /// 设置分段的 ToolTip
    /// - Parameters:
    ///   - toolTip: 提示文本
    ///   - segment: 分段索引
    func setSegmentToolTip(_ toolTip: String, forSegment segment: Int) {
        guard segment >= 0, segment < segmentCount else { return }
        setToolTip(toolTip, forSegment: segment)
    }
}
