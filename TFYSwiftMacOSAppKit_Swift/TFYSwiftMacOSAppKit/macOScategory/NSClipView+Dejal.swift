//
//  NSClipView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/16/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSClipView {
    /// 当前可见文档区域
    var visibleDocumentRect: NSRect {
        documentVisibleRect
    }

    /// 滚动到文档顶部
    func scrollToTop() {
        scroll(to: CGPoint(x: bounds.origin.x, y: 0))
        superview?.reflectScrolledClipView(self)
    }

    /// 滚动到文档底部
    func scrollToBottom() {
        guard let documentView else { return }
        let maxY = max(documentView.bounds.height - bounds.height, 0)
        scroll(to: CGPoint(x: bounds.origin.x, y: maxY))
        superview?.reflectScrolledClipView(self)
    }

    /// 将文档视图居中显示
    func centerDocumentView() {
        guard let documentView else { return }
        let x = max((documentView.bounds.width - bounds.width) / 2, 0)
        let y = max((documentView.bounds.height - bounds.height) / 2, 0)
        scroll(to: CGPoint(x: x, y: y))
        superview?.reflectScrolledClipView(self)
    }
}
