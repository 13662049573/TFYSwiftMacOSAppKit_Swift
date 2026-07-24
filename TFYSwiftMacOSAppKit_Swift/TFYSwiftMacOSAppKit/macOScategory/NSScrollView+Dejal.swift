//
//  NSScrollView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/16/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSScrollView {
    /// 使用内容视图创建滚动视图
    /// - Parameters:
    ///   - documentView: 文档视图
    ///   - hasVerticalScroller: 是否显示垂直滚动条
    ///   - hasHorizontalScroller: 是否显示水平滚动条
    ///   - drawsBackground: 是否绘制背景
    /// - Returns: 创建的滚动视图
    static func wrap(
        _ documentView: NSView,
        hasVerticalScroller: Bool = true,
        hasHorizontalScroller: Bool = false,
        drawsBackground: Bool = false
    ) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.documentView = documentView
        scrollView.hasVerticalScroller = hasVerticalScroller
        scrollView.hasHorizontalScroller = hasHorizontalScroller
        scrollView.drawsBackground = drawsBackground
        return scrollView
    }

    /// 内容偏移量
    var contentOffset: CGPoint {
        get { contentView.bounds.origin }
        set {
            contentView.scroll(to: newValue)
            reflectScrolledClipView(contentView)
        }
    }

    /// 滚动到顶部
    func scrollToTop() {
        contentOffset = CGPoint(x: contentOffset.x, y: 0)
    }

    /// 滚动到底部
    func scrollToBottom() {
        guard let documentView else { return }
        let maxY = max(documentView.bounds.height - contentView.bounds.height, 0)
        contentOffset = CGPoint(x: contentOffset.x, y: maxY)
    }

    /// 让文档视图宽度自适应滚动容器
    func fitDocumentViewWidth() {
        guard let documentView else { return }
        var frame = documentView.frame
        frame.size.width = contentSize.width
        documentView.frame = frame
    }

    /// 让文档视图高度自适应滚动容器
    func fitDocumentViewHeight() {
        guard let documentView else { return }
        var frame = documentView.frame
        frame.size.height = contentSize.height
        documentView.frame = frame
    }

    /// 带动画滚动到指定偏移量
    /// - Parameters:
    ///   - offset: 目标偏移量
    ///   - duration: 动画时长
    func scrollToOffset(_ offset: CGPoint, duration: TimeInterval = 0.3) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.allowsImplicitAnimation = true
            contentView.animator().setBoundsOrigin(offset)
            reflectScrolledClipView(contentView)
        }
    }

    /// 带动画滚动到顶部
    /// - Parameter duration: 动画时长
    func scrollToTopAnimated(duration: TimeInterval = 0.3) {
        scrollToOffset(CGPoint(x: contentOffset.x, y: 0), duration: duration)
    }

    /// 带动画滚动到底部
    /// - Parameter duration: 动画时长
    func scrollToBottomAnimated(duration: TimeInterval = 0.3) {
        guard let documentView else { return }
        let maxY = max(documentView.bounds.height - contentView.bounds.height, 0)
        scrollToOffset(CGPoint(x: contentOffset.x, y: maxY), duration: duration)
    }

    /// 滚动到左侧
    func scrollToLeft() {
        contentOffset = CGPoint(x: 0, y: contentOffset.y)
    }

    /// 滚动到右侧
    func scrollToRight() {
        guard let documentView else { return }
        let maxX = max(documentView.bounds.width - contentView.bounds.width, 0)
        contentOffset = CGPoint(x: maxX, y: contentOffset.y)
    }

    /// 是否已滚动到顶部
    var isAtTop: Bool {
        contentOffset.y <= 0
    }

    /// 是否已滚动到底部
    var isAtBottom: Bool {
        guard let documentView else { return true }
        let maxY = max(documentView.bounds.height - contentView.bounds.height, 0)
        return contentOffset.y >= maxY
    }

    /// 可见区域百分比（垂直）
    var verticalScrollPercentage: CGFloat {
        guard let documentView else { return 0 }
        let maxY = documentView.bounds.height - contentView.bounds.height
        guard maxY > 0 else { return 0 }
        return contentOffset.y / maxY
    }

    /// 设置弹性滚动
    /// - Parameters:
    ///   - horizontal: 水平弹性
    ///   - vertical: 垂直弹性
    func setElasticity(horizontal: NSScrollView.Elasticity = .automatic,
                       vertical: NSScrollView.Elasticity = .automatic) {
        horizontalScrollElasticity = horizontal
        verticalScrollElasticity = vertical
    }

    /// 闪烁滚动条以提示用户内容可滚动
    func flashScrollIndicators() {
        flashScrollers()
    }
}
