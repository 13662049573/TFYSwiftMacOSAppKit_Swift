//
//  StatusItemWindowController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 定义通知名称
public let themeChangedNotification = Notification.Name("AppleInterfaceThemeChangedNotification")
public let statusItemWindowWillShowNotification = Notification.Name("StatusItemWindowWillShowNotification")
public let statusItemWindowDidShowNotification = Notification.Name("StatusItemWindowDidShowNotification")
public let statusItemWindowWillDismissNotification = Notification.Name("StatusItemWindowWillDismissNotification")
public let statusItemWindowDidDismissNotification = Notification.Name("StatusItemWindowDidDismissNotification")
public let systemInterfaceThemeChangedNotification = Notification.Name("SystemInterfaceThemeChangedNotification")

// 淡入淡出方向枚举
public enum FadeDirection: Int {
    case fadeIn = 0
    case fadeOut = 1
}

// 窗口动画完成处理类型别名
public typealias WindowAnimationCompletion = (() -> Void)?

// 状态项窗口控制器类
public class StatusItemWindowController: NSWindowController {

    // 状态项视图
    private var statusItem: StatusItemManager?
    // 窗口配置
    private var windowConfig: StatusItemConfig?

    // 过渡距离
    public var transitionDistance: CGFloat = 8.0

    // 窗口是否打开
    public var isWindowOpen: Bool = false
    // 动画是否正在运行
    public var isAnimationRunning: Bool = false

    // 便利初始化方法
    public convenience init(statusItem: StatusItemManager, contentViewController: NSViewController?, windowConfiguration: StatusItemConfig) {
        self.init()

        if contentViewController == nil {
            return
        }
        assert(contentViewController!.preferredContentSize.width != 0 && contentViewController!.preferredContentSize.height != 0, "[\(type(of: self))] contentViewController 的 preferredContentSize 不能是 NSZeroSize!")

        self.isWindowOpen = false
        self.statusItem = statusItem
        self.windowConfig = windowConfiguration

        self.window = StatusItemWindow.statusItemWindowWithConfiguration(configuration: windowConfiguration)
        self.contentViewController = contentViewController

        NotificationCenter.default.addObserver(self, selector: #selector(handleWindowDidResignKeyNotification(note:)), name: NSWindow.didResignKeyNotification, object: nil)

        DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleAppleInterfaceThemeChangedNotification(note:)), name: themeChangedNotification, object: nil)
    }

    // 初始化方法
    public override init(window: NSWindow?) {
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 处理窗口失去焦点通知
    @objc func handleWindowDidResignKeyNotification(note: Notification) {
        if !(note.object as! NSObject).isEqual(self.window) {
            return
        }
        if !(self.windowConfig?.pinned ?? false) {
            self.dismissStatusItemWindow()
        }
    }

    // 处理主题变化通知
    @objc func handleAppleInterfaceThemeChangedNotification(note: Notification) {
        NotificationCenter.default.post(name: systemInterfaceThemeChangedNotification, object: nil)
    }

    // 更新内容视图控制器
    public func updateContenetViewController(contentViewController: NSViewController) {
        self.contentViewController = nil
        self.contentViewController = contentViewController
        self.updateWindowFrame()
    }

    // 更新窗口框架
    private func updateWindowFrame() {
        guard let statusItemRect = statusItem?.statusItem?.button?.window?.frame else { return }

        guard let windRect = self.window?.frame else { return }

        let nsX: CGFloat = NSMinX(statusItemRect) - NSWidth(windRect)/2 + NSWidth(statusItemRect)/2

        let nsY: CGFloat = min(NSMidY(statusItemRect), NSApp.mainWindow!.frame.size.height - NSHeight(windRect) - (windowConfig?.windowToStatusItemMargin ?? 0))

        let nsW: CGFloat = windRect.size.width

        let nsH: CGFloat = windRect.size.height

        let windowFrame = NSMakeRect(nsX, nsY, nsW, nsH)

        self.window?.setFrame(windowFrame, display: true)

        self.window?.appearance = NSAppearance.current
    }

    // 显示窗口
    public func showStatusItemWindow() {
        if isAnimationRunning {
            return
        }
        updateWindowFrame()
        self.window?.alphaValue = 0
        self.showWindow(nil)
        animateWindow(window: self.window as! StatusItemWindow, fadeDirection:.fadeIn)
    }

    // 隐藏窗口
    public func dismissStatusItemWindow() {
        if isAnimationRunning {
            return
        }
        animateWindow(window: self.window as! StatusItemWindow, fadeDirection:.fadeOut)
    }

    // 动画窗口
    public func animateWindow(window: StatusItemWindow, fadeDirection: FadeDirection) {
        switch windowConfig?.presentationTransition {
        case.none?:
            break
        case.fade:
            withFadeTransitionUsingFadeDirection(window: window, fadeDirection: fadeDirection)
            break
        case.slideAndFade:
            withSlideAndFadeTransitionUsingFadeDirection(window: window, fadeDirection: fadeDirection)
            break
        default:
            break
        }
    }

    // 使用淡入淡出过渡
    public func withFadeTransitionUsingFadeDirection(window: StatusItemWindow, fadeDirection: FadeDirection) {
        let notificationName = fadeDirection == .fadeIn ? statusItemWindowWillShowNotification : statusItemWindowWillDismissNotification

        NotificationCenter.default.post(name: notificationName, object: window)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.windowConfig?.animationDuration ?? 0.0
            context.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
            window.animator().alphaValue = fadeDirection == .fadeIn ? 1 : 0
        }, completionHandler: animationCompletionForWindow(window: window, fadeDirection: fadeDirection))
    }

    // 使用滑动和淡入淡出过渡
    public func withSlideAndFadeTransitionUsingFadeDirection(window: StatusItemWindow, fadeDirection: FadeDirection) {
        let notificationName = fadeDirection == .fadeIn ? statusItemWindowWillShowNotification : statusItemWindowWillDismissNotification

        NotificationCenter.default.post(name: notificationName, object: window)

        var windowStartFrame: NSRect?
        var windowEndFrame: NSRect?

        let calculatedFrame = NSMakeRect(NSMinX(window.frame), NSMinY(window.frame) + transitionDistance, NSWidth(window.frame), NSHeight(window.frame))
        switch fadeDirection {
        case.fadeIn:
            windowStartFrame = calculatedFrame
            windowEndFrame = window.frame
            break
        case.fadeOut:
            windowStartFrame = window.frame
            windowEndFrame = calculatedFrame
            break
        }
        window.setFrame(windowStartFrame!, display: false)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.windowConfig?.animationDuration ?? 0.0
            context.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
            window.animator().setFrame(windowEndFrame!, display: false)
            window.animator().alphaValue = fadeDirection == .fadeIn ? 1 : 0
        }, completionHandler: animationCompletionForWindow(window: window, fadeDirection: fadeDirection))
    }

    // 窗口动画完成处理
    public func animationCompletionForWindow(window: StatusItemWindow, fadeDirection: FadeDirection) -> WindowAnimationCompletion {
        let not = NotificationCenter.default
        return { [self] in
            self.isAnimationRunning = false
            self.isWindowOpen = fadeDirection == .fadeIn
            if fadeDirection == .fadeIn {
                window.makeMain()
                not.post(name: statusItemWindowDidShowNotification, object: window)
            } else {
                window.orderOut(self)
                window.close()
                not.post(name: statusItemWindowDidDismissNotification, object: window)
            }
        }
    }
}
