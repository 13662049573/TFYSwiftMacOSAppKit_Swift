//
//  NSSplitView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSSplitView {
    // 第一个分割分隔符的位置属性，可以通过 animator 进行动画设置
    var splitPosition: CGFloat {
        get {
            return splitPositionOfDividerAtIndex(0)
        }
        set {
            setPosition(newValue, ofDividerAt: 0)
        }
    }

    // 获取指定索引的分割分隔符位置
    func splitPositionOfDividerAtIndex(_ idx: Int) -> CGFloat {
        let frame = subviews[idx].frame
        return isVertical ? NSMaxX(frame) : NSMaxY(frame)
    }

    // 切换指定索引子视图的可见性（假设只使用了两个子视图）
    func toggleSubviewAtIndex(_ idx: Int) {
        let isCollapsed = isSubviewCollapsed(subviews[idx])
        if isCollapsed {
            expandSubviewAtIndex(idx)
        } else {
            collapseSubviewAtIndex(idx)
        }
    }

    // 折叠指定索引的子视图（假设只使用了两个子视图）
    func collapseSubviewAtIndex(_ idx: Int) {
        let other = idx == 0 ? 1 : 0
        let remaining = subviews[other]
        let collapsing = subviews[idx]
        let remainingFrame = remaining.frame
        let overallFrame = frame

        if collapsing.isHidden {
            return
        }

        collapsing.isHidden = true

        if isVertical {
            remaining.frame.size = NSSize(width: overallFrame.size.width, height: remainingFrame.size.height)
        } else {
            remaining.frame.size = NSSize(width: remainingFrame.size.width, height: overallFrame.size.height)
        }

        display()
    }

    // 展开指定索引的子视图（假设只使用了两个子视图）
    func expandSubviewAtIndex(_ idx: Int) {
        let other = idx == 0 ? 1 : 0
        let remaining = subviews[other]
        let collapsing = subviews[idx]
        let thickness = dividerThickness

        if !collapsing.isHidden {
            return
        }

        collapsing.isHidden = false

        let remainingFrame = remaining.frame
        var collapsingFrame = collapsing.frame

        if isVertical {
            remaining.frame.size.height = remainingFrame.height - collapsingFrame.height - thickness
            collapsingFrame.origin.y = remainingFrame.height + thickness
        } else {
            remaining.frame.size.width = remainingFrame.width - collapsingFrame.width - thickness
            collapsingFrame.origin.x = remainingFrame.width + thickness
        }

        remaining.frame.size = remainingFrame.size
        collapsing.frame = collapsingFrame

        display()
    }
}

// 为 splitPosition 键添加可动画属性
public extension NSSplitView {
    
    override class func defaultAnimation(forKey key: String) -> Any? {
        if key == "splitPosition" {
            let animation = CABasicAnimation()
            animation.duration = 0.2
            return animation
        } else {
            return super.defaultAnimation(forKey: key)
        }
    }
}
