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

    /// 设置窗口透明度并带动画
    /// - Parameters:
    ///   - alpha: 目标透明度
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func setAlpha(_ alpha: CGFloat, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            animator().alphaValue = alpha
        }, completionHandler: completion)
    }

    /// 淡入窗口
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func fadeIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        alphaValue = 0
        orderFront(nil)
        setAlpha(1.0, duration: duration, completion: completion)
    }

    /// 淡出窗口
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        setAlpha(0, duration: duration) { [weak self] in
            self?.orderOut(nil)
            self?.alphaValue = 1.0
            completion?()
        }
    }

    /// 设置窗口大小并带动画
    /// - Parameters:
    ///   - size: 目标大小
    ///   - animated: 是否动画
    func resize(to size: NSSize, animated: Bool = true) {
        var newFrame = frame
        let deltaHeight = size.height - newFrame.height
        newFrame.size = size
        newFrame.origin.y -= deltaHeight
        setFrame(newFrame, display: true, animate: animated)
    }

    /// 设置窗口最小/最大尺寸
    /// - Parameters:
    ///   - min: 最小尺寸
    ///   - max: 最大尺寸
    func setSizeConstraints(min: NSSize? = nil, max: NSSize? = nil) {
        if let min {
            minSize = min
        }
        if let max {
            maxSize = max
        }
    }

    /// 将窗口移动到指定屏幕
    /// - Parameter screen: 目标屏幕
    func move(to screen: NSScreen) {
        let visibleFrame = screen.visibleFrame
        let origin = NSPoint(
            x: visibleFrame.midX - frame.width / 2,
            y: visibleFrame.midY - frame.height / 2
        )
        setFrameOrigin(origin)
    }

    /// 窗口全屏切换
    func toggleFullScreen() {
        toggleFullScreen(nil)
    }

    /// 窗口是否处于全屏状态
    var isFullScreen: Bool {
        styleMask.contains(.fullScreen)
    }

    /// 设置窗口为浮动面板级别
    /// - Parameter floating: 是否浮动
    func setFloating(_ floating: Bool) {
        level = floating ? .floating : .normal
    }

    /// 设置标题栏透明
    /// - Parameter transparent: 是否透明
    func setTitleBarTransparent(_ transparent: Bool) {
        titlebarAppearsTransparent = transparent
        if transparent {
            styleMask.insert(.fullSizeContentView)
        } else {
            styleMask.remove(.fullSizeContentView)
        }
    }

    /// 窗口截图（通过内容视图缓存绘制）
    /// - Returns: 窗口截图
    func snapshot() -> NSImage? {
        guard let contentView else { return nil }
        let bounds = contentView.bounds
        guard let rep = contentView.bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        contentView.cacheDisplay(in: bounds, to: rep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(rep)
        return image
    }

    /// 抖动窗口（类似密码错误效果）
    func shake() {
        let numberOfShakes = 3
        let durationOfShake: CGFloat = 0.25
        let vigourOfShake: CGFloat = 0.04

        let currentFrame = frame
        let shakeAnimation = CAKeyframeAnimation()

        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x: currentFrame.minX, y: currentFrame.minY))

        for _ in 0..<numberOfShakes {
            shakePath.addLine(to: CGPoint(
                x: currentFrame.minX - currentFrame.size.width * vigourOfShake,
                y: currentFrame.minY
            ))
            shakePath.addLine(to: CGPoint(
                x: currentFrame.minX + currentFrame.size.width * vigourOfShake,
                y: currentFrame.minY
            ))
        }
        shakePath.closeSubpath()

        shakeAnimation.keyPath = "frameOrigin"
        shakeAnimation.path = shakePath
        shakeAnimation.duration = CFTimeInterval(durationOfShake)
        animations = ["frameOrigin": shakeAnimation]
        animator().setFrameOrigin(currentFrame.origin)
    }
}
