//
//  TFYStatusItemWindowController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

// 定义淡入淡出的方向枚举
public enum TFYFadeDirection {
    case fadeIn
    case fadeOut
}

// 定义窗口动画完成后的回调类型别名
public typealias TFYStatusItemWindowAnimationCompletion = () -> Void

// 定义过渡距离常量
public let TFYTransitionDistance: CGFloat = 8.0

// 定义状态项主题改变的通知名称
public let TFYStatusItemThemeChangedNotification = Notification.Name("AppleInterfaceThemeChangedNotification")
// 定义状态项窗口即将显示的通知名称
public let TFYStatusItemWindowWillShowNotification = Notification.Name("TFYStatusItemWindowWillShowNotification")
// 定义状态项窗口已经显示的通知名称
public let TFYStatusItemWindowDidShowNotification = Notification.Name("TFYStatusItemWindowDidShowNotification")
// 定义状态项窗口即将消失的通知名称
public let TFYStatusItemWindowWillDismissNotification = Notification.Name("TFYStatusItemWindowWillDismissNotification")
// 定义状态项窗口已经消失的通知名称
public let TFYStatusItemWindowDidDismissNotification = Notification.Name("TFYStatusItemWindowDidDismissNotification")
// 定义系统界面主题改变的通知名称
public let TFYSystemInterfaceThemeChangedNotification = Notification.Name("TFYSystemInterfaceThemeChangedNotification")

// TFYStatusItemWindowController类用于管理状态项窗口的显示、隐藏、动画等操作
public class TFYStatusItemWindowController: NSWindowController {

    // 关联的状态项视图
    public var statusItemView: TFYStatusItem?
    // 窗口配置信息
    public var windowConfiguration: TFYStatusItemWindowConfiguration?
    // 标记窗口是否已经打开
    public var isWindowOpen = false
    // 标记动画是否正在运行
    public var animationIsRunning = false

    // 初始化方法，用于创建TFYStatusItemWindowController实例
    public init(connectedStatusItem statusItem: TFYStatusItem, contentViewController: NSViewController, windowConfiguration: TFYStatusItemWindowConfiguration) {

        // 确保contentViewController的首选内容大小不为零，否则抛出异常
        assert(contentViewController.preferredContentSize.width != 0 && contentViewController.preferredContentSize.height != 0, "[\(type(of: self))] contentViewController 的 preferredContentSize 不能是 NSZeroSize!")

        // 初始化相关属性
        self.statusItemView = statusItem
        self.windowConfiguration = windowConfiguration

        // 调用父类的指定初始化方法来创建窗口
        super.init(window: TFYStatusItemWindow.statusItemWindowWithConfiguration(configuration: windowConfiguration))
        self.contentViewController = contentViewController

        // 添加观察者，当窗口失去关键状态时调用handleWindowDidResignKeyNotification方法
        NotificationCenter.default.addObserver(self, selector: #selector(handleWindowDidResignKeyNotification(_:)), name: NSWindow.didResignKeyNotification, object: nil)

        // 添加分布式观察者，当苹果界面主题改变时调用handleAppleInterfaceThemeChangedNotification方法
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(handleAppleInterfaceThemeChangedNotification(_:)), name: TFYStatusItemThemeChangedNotification, object: nil)
    }

    // 必要的初始化方法，这里由于未实现所以抛出错误（如果通过编码方式初始化实例时会用到）
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 更新内容视图控制器的方法
    func updateContenetViewController(_ contentViewController: NSViewController) {
        // 先设置为nil，触发窗口大小调整
        self.contentViewController = nil
        self.contentViewController = contentViewController
        updateWindowFrame()
    }

    // 更新窗口框架的方法
    func updateWindowFrame() {
        // 获取状态项视图的相关窗口框架信息，如果为空则直接返回
        guard let statusItemRect = statusItemView?.statusItem?.button?.window?.frame else { return }

        // 计算窗口的新框架位置
        let windowFrame = CGRect(x: statusItemRect.minX - window!.frame.width / 2 + statusItemRect.width / 2,
                                 y: min(statusItemRect.minY, NSScreen.main!.frame.size.height) - window!.frame.height - windowConfiguration!.windowToStatusItemMargin,
                                 width: window!.frame.width,
                                 height: window!.frame.height)

        // 设置窗口的新框架并显示更新
        window?.setFrame(windowFrame, display: true)
        // 设置窗口的外观为当前外观
        if #available(macOS 12.0, *) {
            // 使用 +currentDrawingAppearance 来获取当前绘制外观并设置给窗口
            window?.appearance = NSAppearance.currentDrawing()
        } else {
            // 在macOS 12.0以下版本，仍使用原来的方式
            window?.appearance = NSAppearance.current
        }
    }

    // 显示状态项窗口的方法
    func showStatusItemWindow() {
        // 如果动画正在运行，则直接返回
        if animationIsRunning { return }
        // 更新窗口框架
        updateWindowFrame()
        // 设置窗口的初始透明度为0
        window?.alphaValue = 0.0
        // 显示窗口
        showWindow(nil)
        // 执行窗口淡入动画
        animateWindow(window as! TFYStatusItemWindow, withFadeDirection:.fadeIn)
    }

    // 隐藏状态项窗口的方法
    func dismissStatusItemWindow() {
        // 如果动画正在运行，则直接返回
        if animationIsRunning { return }
        // 执行窗口淡出动画
        animateWindow(window as! TFYStatusItemWindow, withFadeDirection:.fadeOut)
    }

    // 根据配置执行窗口动画的方法
    func animateWindow(_ window: TFYStatusItemWindow, withFadeDirection fadeDirection: TFYFadeDirection) {

        // 根据窗口配置的呈现过渡类型来决定执行哪种具体的动画方式
        switch windowConfiguration?.presentationTransition ?? TFYPresentationTransition.none {
        case.none,.fade:
            animateWindow(window, withFadeTransitionUsingFadeDirection: fadeDirection)
        case.slideAndFade:
            animateWindow(window, withSlideAndFadeTransitionUsingFadeDirection: fadeDirection)
        }
    }

    // 使用淡入淡出过渡方式执行窗口动画的方法
    func animateWindow(_ window: TFYStatusItemWindow, withFadeTransitionUsingFadeDirection fadeDirection: TFYFadeDirection) {
        // 根据淡入淡出方向确定要发送的通知名称
        let notificationName = fadeDirection == .fadeIn ? TFYStatusItemWindowWillShowNotification : TFYStatusItemWindowWillDismissNotification
        // 发送窗口即将显示或即将隐藏的通知
        NotificationCenter.default.post(name: notificationName, object: window)

        // 在动画上下文中执行动画操作
        NSAnimationContext.runAnimationGroup({ context in
            // 设置动画持续时间
            context.duration = windowConfiguration!.animationDuration
            // 设置动画的时间函数，这里使用缓入缓出
            let customTimingFunction = CAMediaTimingFunction(controlPoints: 0.1, 0.1, 0.9, 0.9)
            context.timingFunction = customTimingFunction
            // 设置窗口的透明度，根据淡入淡出方向设置为1或0
            window.animator().alphaValue = fadeDirection == .fadeIn ? 1.0 : 0.0
            
        }, completionHandler: animationCompletionForWindow(window, fadeDirection: fadeDirection))
    }

    // 使用滑动和淡入淡出过渡方式执行窗口动画的方法
    func animateWindow(_ window: TFYStatusItemWindow, withSlideAndFadeTransitionUsingFadeDirection fadeDirection: TFYFadeDirection) {

        // 根据淡入淡出方向确定要发送的通知名称
        let notificationName = fadeDirection == .fadeIn ? TFYStatusItemWindowWillShowNotification : TFYStatusItemWindowWillDismissNotification
        // 发送窗口即将显示或即将隐藏的通知
        NotificationCenter.default.post(name: notificationName, object: window)

        // 定义窗口起始框架和结束框架
        var windowStartFrame: CGRect
        var windowEndFrame: CGRect

        // 计算一个过渡用的框架位置
        let calculatedFrame = CGRect(x: window.frame.minX, y: window.frame.minY + TFYTransitionDistance, width: window.frame.width, height: window.frame.height)

        // 根据淡入淡出方向设置起始框架和结束框架
        switch fadeDirection {
        case.fadeIn:
            windowStartFrame = calculatedFrame
            windowEndFrame = window.frame
        case.fadeOut:
            windowStartFrame = window.frame
            windowEndFrame = calculatedFrame
        }

        // 设置窗口的起始框架（不显示更新）
        window.setFrame(windowStartFrame, display: false)

        // 在动画上下文中执行动画操作
        NSAnimationContext.runAnimationGroup({ context in
            // 设置动画持续时间
            context.duration = windowConfiguration!.animationDuration
            // 设置动画的时间函数，这里使用缓入缓出
            let customTimingFunction = CAMediaTimingFunction(controlPoints: 0.1, 0.1, 0.9, 0.9)
            context.timingFunction = customTimingFunction
            // 设置窗口的最终框架（不显示更新）
            window.animator().setFrame(windowEndFrame, display: false)
            // 设置窗口的透明度，根据淡入淡出方向设置为1或0
            window.animator().alphaValue = fadeDirection == .fadeIn ? 1 : 0
        }, completionHandler: animationCompletionForWindow(window, fadeDirection: fadeDirection))
    }

    // 窗口动画完成后的处理方法
    func animationCompletionForWindow(_ window: TFYStatusItemWindow, fadeDirection: TFYFadeDirection) -> TFYStatusItemWindowAnimationCompletion {

        // 获取通知中心实例
        let nc = NotificationCenter.default
        // 使用弱引用避免循环引用
        weak var wSelf = self

        return {
            // 更新动画运行状态标记
            wSelf?.animationIsRunning = false
            // 更新窗口打开状态标记
            wSelf?.isWindowOpen = fadeDirection == .fadeIn
            if fadeDirection == .fadeIn {
                // 如果是淡入，设置窗口为关键窗口
                window.makeKey()
                // 发送窗口已经显示的通知
                nc.post(name: TFYStatusItemWindowDidShowNotification, object: window)
            } else {
                // 如果是淡出，将窗口移出视图层级并关闭
                window.orderOut(wSelf!)
                window.close()
                // 发送窗口已经消失的通知
                nc.post(name: TFYStatusItemWindowDidDismissNotification, object: window)
            }
        }
    }

    // 处理窗口失去关键状态的通知方法
    @objc func handleWindowDidResignKeyNotification(_ note: Notification) {
        // 确保通知对象是当前窗口，否则直接返回
        guard let window = note.object as? NSWindow, window == self.window else { return }

        // 如果窗口未固定，则隐藏窗口
        if !windowConfiguration!.isPinned {
            dismissStatusItemWindow()
        }
    }

    // 处理苹果界面主题改变的通知方法
    @objc func handleAppleInterfaceThemeChangedNotification(_ note: Notification) {
        // 发送系统界面主题改变的通知
        NotificationCenter.default.post(name: TFYSystemInterfaceThemeChangedNotification, object: nil)
    }
}
