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
}
