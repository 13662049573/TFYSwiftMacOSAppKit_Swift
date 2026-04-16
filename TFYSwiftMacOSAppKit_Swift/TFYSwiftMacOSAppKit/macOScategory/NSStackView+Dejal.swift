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
}
