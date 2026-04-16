//
//  NSWindow+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/16/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSWindow {
    /// 将窗口移动到当前屏幕中央
    func centerOnCurrentScreen() {
        if let screen = screen ?? NSScreen.main {
            let visibleFrame = screen.visibleFrame
            let origin = NSPoint(
                x: visibleFrame.midX - frame.width / 2,
                y: visibleFrame.midY - frame.height / 2
            )
            setFrameOrigin(origin)
        } else {
            center()
        }
    }

    /// 将窗口带到前台
    func bringToFront() {
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// 确保窗口位于可见屏幕内
    func constrainToVisibleScreen() {
        guard let screen = screen ?? NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame
        var nextFrame = frame
        
        if nextFrame.maxX > visibleFrame.maxX {
            nextFrame.origin.x = visibleFrame.maxX - nextFrame.width
        }
        if nextFrame.minX < visibleFrame.minX {
            nextFrame.origin.x = visibleFrame.minX
        }
        if nextFrame.maxY > visibleFrame.maxY {
            nextFrame.origin.y = visibleFrame.maxY - nextFrame.height
        }
        if nextFrame.minY < visibleFrame.minY {
            nextFrame.origin.y = visibleFrame.minY
        }
        
        setFrame(nextFrame, display: true, animate: false)
    }
}
