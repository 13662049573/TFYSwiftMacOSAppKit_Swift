//
//  NSStackView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/16/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSStackView {
    /// 批量添加 arranged subviews
    /// - Parameter views: 视图数组
    func addArrangedSubviews(_ views: [NSView]) {
        views.forEach(addArrangedSubview(_:))
    }

    /// 移除所有 arranged subviews
    func removeAllArrangedSubviews() {
        let arrangedSubviews = self.arrangedSubviews
        arrangedSubviews.forEach(removeArrangedSubview(_:))
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    /// 设置多个 arranged subviews 的隐藏状态
    /// - Parameters:
    ///   - hidden: 是否隐藏
    ///   - animated: 是否动画
    func setArrangedSubviewsHidden(_ hidden: Bool, animated: Bool = false) {
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                arrangedSubviews.forEach { $0.animator().isHidden = hidden }
            }
        } else {
            arrangedSubviews.forEach { $0.isHidden = hidden }
        }
    }

    /// 创建垂直栈视图
    /// - Parameters:
    ///   - spacing: 间距
    ///   - alignment: 对齐方式
    ///   - views: 初始子视图
    /// - Returns: 创建的栈视图
    static func makeVertical(
        spacing: CGFloat = 8,
        alignment: NSLayoutConstraint.Attribute = .leading,
        views: [NSView] = []
    ) -> NSStackView {
        let stackView = NSStackView(views: views)
        stackView.orientation = .vertical
        stackView.spacing = spacing
        stackView.alignment = alignment
        return stackView
    }

    /// 创建水平栈视图
    /// - Parameters:
    ///   - spacing: 间距
    ///   - alignment: 对齐方式
    ///   - distribution: 分布方式
    ///   - views: 初始子视图
    /// - Returns: 创建的栈视图
    static func makeHorizontal(
        spacing: CGFloat = 8,
        alignment: NSLayoutConstraint.Attribute = .centerY,
        distribution: NSStackView.Distribution = .gravityAreas,
        views: [NSView] = []
    ) -> NSStackView {
        let stackView = NSStackView(views: views)
        stackView.orientation = .horizontal
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        return stackView
    }

    /// 安全地在指定位置插入 arranged subview（自动钳制索引）
    /// - Parameters:
    ///   - view: 待插入视图
    ///   - index: 插入位置
    func insertArrangedSubviewSafely(_ view: NSView, at index: Int) {
        let clampedIndex = min(max(index, 0), arrangedSubviews.count)
        insertArrangedSubview(view, at: clampedIndex)
    }

    /// 替换指定位置的 arranged subview
    /// - Parameters:
    ///   - index: 替换位置
    ///   - newView: 新视图
    func replaceArrangedSubview(at index: Int, with newView: NSView) {
        guard index < arrangedSubviews.count else { return }
        let oldView = arrangedSubviews[index]
        insertArrangedSubview(newView, at: index)
        removeArrangedSubview(oldView)
        oldView.removeFromSuperview()
    }

    /// 设置边距
    /// - Parameter insets: 边距值
    func setEdgeInsets(_ insets: NSEdgeInsets) {
        edgeInsets = insets
    }

    /// 设置统一边距
    /// - Parameter value: 边距值
    func setUniformPadding(_ value: CGFloat) {
        edgeInsets = NSEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    /// 添加分隔视图
    /// - Parameters:
    ///   - color: 分隔线颜色
    ///   - thickness: 分隔线厚度
    func addSeparator(color: NSColor = .separatorColor, thickness: CGFloat = 1) {
        let separator = NSView()
        separator.wantsLayer = true
        separator.layer?.backgroundColor = color.cgColor
        addArrangedSubview(separator)
        if orientation == .vertical {
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        } else {
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.widthAnchor.constraint(equalToConstant: thickness).isActive = true
        }
    }

    /// 添加弹性空间
    /// - Parameter priority: 内容拥抱优先级
    func addFlexibleSpace(priority: NSLayoutConstraint.Priority = .defaultLow) {
        let spacer = NSView()
        spacer.setContentHuggingPriority(priority, for: orientation == .vertical ? .vertical : .horizontal)
        addArrangedSubview(spacer)
    }

    /// 添加固定间距
    /// - Parameter spacing: 间距值
    func addFixedSpace(_ spacing: CGFloat) {
        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(spacer)
        if orientation == .vertical {
            spacer.heightAnchor.constraint(equalToConstant: spacing).isActive = true
            spacer.widthAnchor.constraint(equalToConstant: 0).isActive = true
        } else {
            spacer.widthAnchor.constraint(equalToConstant: spacing).isActive = true
            spacer.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }

    /// 当前可见 arranged subviews
    var visibleArrangedSubviews: [NSView] {
        arrangedSubviews.filter { !$0.isHidden }
    }
}
