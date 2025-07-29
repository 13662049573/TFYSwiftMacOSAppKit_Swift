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
    
    /// 检查子视图是否折叠
    /// - Parameter index: 子视图索引
    /// - Returns: 是否折叠
    func isSubviewCollapsed(atIndex index: Int) -> Bool {
        guard index < subviews.count else { return false }
        return isSubviewCollapsed(subviews[index])
    }
    
    /// 设置子视图的最小尺寸
    /// - Parameters:
    ///   - index: 子视图索引
    ///   - minSize: 最小尺寸
    func setMinimumSize(_ minSize: CGFloat, forSubviewAt index: Int) {
        guard index < subviews.count else { return }
        let subview = subviews[index]
        if isVertical {
            subview.frame.size.width = max(subview.frame.size.width, minSize)
        } else {
            subview.frame.size.height = max(subview.frame.size.height, minSize)
        }
    }
    
    /// 设置子视图的最大尺寸
    /// - Parameters:
    ///   - index: 子视图索引
    ///   - maxSize: 最大尺寸
    func setMaximumSize(_ maxSize: CGFloat, forSubviewAt index: Int) {
        guard index < subviews.count else { return }
        let subview = subviews[index]
        if isVertical {
            subview.frame.size.width = min(subview.frame.size.width, maxSize)
        } else {
            subview.frame.size.height = min(subview.frame.size.height, maxSize)
        }
    }
    
    /// 获取子视图的当前尺寸
    /// - Parameter index: 子视图索引
    /// - Returns: 子视图尺寸
    func sizeForSubview(at index: Int) -> CGFloat {
        guard index < subviews.count else { return 0 }
        let subview = subviews[index]
        return isVertical ? subview.frame.size.width : subview.frame.size.height
    }
    
    /// 设置子视图的尺寸
    /// - Parameters:
    ///   - index: 子视图索引
    ///   - size: 新尺寸
    func setSize(_ size: CGFloat, forSubviewAt index: Int) {
        guard index < subviews.count else { return }
        let subview = subviews[index]
        if isVertical {
            subview.frame.size.width = size
        } else {
            subview.frame.size.height = size
        }
        display()
    }
    
    /// 平均分配子视图尺寸
    func distributeSubviewsEqually() {
        let totalSize = isVertical ? frame.size.width : frame.size.height
        let dividerThickness = self.dividerThickness
        let availableSize = totalSize - (CGFloat(subviews.count - 1) * dividerThickness)
        let equalSize = availableSize / CGFloat(subviews.count)
        
        for (index, subview) in subviews.enumerated() {
            if isVertical {
                subview.frame.size.width = equalSize
                if index > 0 {
                    subview.frame.origin.x = CGFloat(index) * (equalSize + dividerThickness)
                }
            } else {
                subview.frame.size.height = equalSize
                if index > 0 {
                    subview.frame.origin.y = CGFloat(index) * (equalSize + dividerThickness)
                }
            }
        }
        display()
    }
    
    /// 交换子视图位置
    /// - Parameters:
    ///   - index1: 第一个子视图索引
    ///   - index2: 第二个子视图索引
    func swapSubviews(at index1: Int, and index2: Int) {
        guard index1 < subviews.count && index2 < subviews.count else { return }
        let subview1 = subviews[index1]
        let subview2 = subviews[index2]
        
        let frame1 = subview1.frame
        let frame2 = subview2.frame
        
        subview1.frame = frame2
        subview2.frame = frame1
    }
    
    /// 获取分割视图的总尺寸
    var totalSize: CGFloat {
        return isVertical ? frame.size.width : frame.size.height
    }
    
    /// 获取可用尺寸（减去分割器厚度）
    var availableSize: CGFloat {
        let totalSize = self.totalSize
        let dividerThickness = self.dividerThickness
        return totalSize - (CGFloat(subviews.count - 1) * dividerThickness)
    }
    
    /// 创建水平分割视图
    /// - Parameter subviews: 子视图数组
    /// - Returns: 创建的水平分割视图
    static func createHorizontalSplitView(with subviews: [NSView]) -> NSSplitView {
        let splitView = NSSplitView()
        splitView.isVertical = false
        splitView.dividerStyle = .thin
        
        for subview in subviews {
            splitView.addSubview(subview)
        }
        
        return splitView
    }
    
    /// 创建垂直分割视图
    /// - Parameter subviews: 子视图数组
    /// - Returns: 创建的垂直分割视图
    static func createVerticalSplitView(with subviews: [NSView]) -> NSSplitView {
        let splitView = NSSplitView()
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        
        for subview in subviews {
            splitView.addSubview(subview)
        }
        
        return splitView
    }
    
    /// 设置分割视图的动画
    /// - Parameter animated: 是否启用动画
    func setAnimated(_ animated: Bool) {
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.display()
            })
        } else {
            self.display()
        }
    }
    
    /// 获取分割视图的子视图标题
    var subviewTitles: [String] {
        return subviews.compactMap { subview in
            if let textField = subview as? NSTextField {
                return textField.stringValue
            } else if let label = subview as? NSTextField {
                return label.stringValue
            } else {
                return subview.accessibilityLabel()
            }
        }
    }
}
