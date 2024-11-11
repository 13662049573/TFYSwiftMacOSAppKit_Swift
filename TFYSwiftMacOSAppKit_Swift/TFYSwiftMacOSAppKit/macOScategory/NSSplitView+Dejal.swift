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
            return splitPositionOfDivider(atIndex: 0)
        }
        set {
            setPosition(newValue, ofDividerAt: 0)
        }
    }

    // 获取指定索引的分割分隔符位置
    func splitPositionOfDivider(atIndex index: Int) -> CGFloat {
        let frame = subviews[index].frame
        return isVertical ? NSMaxX(frame) : NSMaxY(frame)
    }

    // 切换指定索引子视图的可见性（假设只使用了两个子视图）
    func toggleSubview(atIndex index: Int) {
        let isCollapsed = isSubviewCollapsed(subviews[index])
        if isCollapsed {
            expandSubview(atIndex: index)
        } else {
            collapseSubview(atIndex: index)
        }
    }

    // 折叠指定索引的子视图（假设只使用了两个子视图）
    func collapseSubview(atIndex index: Int) {
        let otherIndex = index == 0 ? 1 : 0
        let remainingSubview = subviews[otherIndex]
        let collapsingSubview = subviews[index]
        let remainingFrame = remainingSubview.frame
        let overallFrame = frame

        if collapsingSubview.isHidden {
            return
        }

        collapsingSubview.isHidden = true

        if isVertical {
            remainingSubview.frame.size = NSSize(width: overallFrame.size.width, height: remainingFrame.size.height)
        } else {
            remainingSubview.frame.size = NSSize(width: remainingFrame.size.width, height: overallFrame.size.height)
        }

        display()
    }

    // 展开指定索引的子视图（假设只使用了两个子视图）
    func expandSubview(atIndex index: Int) {
        let otherIndex = index == 0 ? 1 : 0
        let remainingSubview = subviews[otherIndex]
        let collapsingSubview = subviews[index]
        let thickness = dividerThickness

        if !collapsingSubview.isHidden {
            return
        }

        collapsingSubview.isHidden = false

        let remainingFrame = remainingSubview.frame
        var collapsingFrame = collapsingSubview.frame

        if isVertical {
            remainingSubview.frame.size.height = remainingFrame.height - collapsingFrame.height - thickness
            collapsingFrame.origin.y = remainingFrame.height + thickness
        } else {
            remainingSubview.frame.size.width = remainingFrame.width - collapsingFrame.width - thickness
            collapsingFrame.origin.x = remainingFrame.width + thickness
        }

        remainingSubview.frame.size = remainingFrame.size
        collapsingSubview.frame = collapsingFrame

        display()
    }
}

// 为 splitPosition 键添加可动画属性
public extension NSSplitView {
    // 定义一个新的类方法来处理特定的动画逻辑
    class func customAnimation(forKey key: String) -> Any? {
        if key == "splitPosition" {
            let animation = CABasicAnimation()
            animation.duration = 0.2
            return animation
        } else {
            return defaultAnimation(forKey: key)
        }
    }
}
