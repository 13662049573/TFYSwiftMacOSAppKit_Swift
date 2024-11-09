//
//  TFYStatusItemWindowController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public enum TFYFadeDirection {
    case fadeIn
    case fadeOut
}

public typealias TFYStatusItemWindowAnimationCompletion = () -> Void

public let TFYTransitionDistance: CGFloat = 8.0
public let TFYStatusItemThemeChangedNotification = Notification.Name("AppleInterfaceThemeChangedNotification")
public let TFYStatusItemWindowWillShowNotification = Notification.Name("TFYStatusItemWindowWillShowNotification")
public let TFYStatusItemWindowDidShowNotification = Notification.Name("TFYStatusItemWindowDidShowNotification")
public let TFYStatusItemWindowWillDismissNotification = Notification.Name("TFYStatusItemWindowWillDismissNotification")
public let TFYStatusItemWindowDidDismissNotification = Notification.Name("TFYStatusItemWindowDidDismissNotification")
public let TFYSystemInterfaceThemeChangedNotification = Notification.Name("TFYSystemInterfaceThemeChangedNotification")

public class TFYStatusItemWindowController: NSWindowController {

    public var statusItemView: TFYStatusItem?
    public var windowConfiguration: TFYStatusItemWindowConfiguration?
    public  var isWindowOpen = false
    public  var animationIsRunning = false

    public init(connectedStatusItem statusItem: TFYStatusItem, contentViewController: NSViewController, windowConfiguration: TFYStatusItemWindowConfiguration) {
        
        assert(contentViewController.preferredContentSize.width != 0 && contentViewController.preferredContentSize.height != 0, "[\(type(of: self))] contentViewController 的 preferredContentSize 不能是 NSZeroSize!")
        
        self.statusItemView = statusItem
        self.windowConfiguration = windowConfiguration
        // 调用指定初始化方法
        super.init(window: TFYStatusItemWindow.statusItemWindowWithConfiguration(configuration: windowConfiguration))
        self.contentViewController = contentViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWindowDidResignKeyNotification(_:)), name: NSWindow.didResignKeyNotification, object: nil)
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(handleAppleInterfaceThemeChangedNotification(_:)), name: TFYStatusItemThemeChangedNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateContenetViewController(_ contentViewController: NSViewController) {
        // Set nil first to trigger window resize
        self.contentViewController = nil
        self.contentViewController = contentViewController
        updateWindowFrame()
    }

    func updateWindowFrame() {
        guard let statusItemRect = statusItemView?.statusItem?.button?.window?.frame else { return }
        let windowFrame = CGRect(x: statusItemRect.minX - window!.frame.width / 2 + statusItemRect.width / 2,
                                 y: min(statusItemRect.minY, NSScreen.main!.frame.size.height) - window!.frame.height - windowConfiguration!.windowToStatusItemMargin,
                                 width: window!.frame.width,
                                 height: window!.frame.height)
        window?.setFrame(windowFrame, display: true)
        window?.appearance = NSAppearance.current
    }

    func showStatusItemWindow() {
        if animationIsRunning { return }
        updateWindowFrame()
        window?.alphaValue = 0.0
        showWindow(nil)
        
        animateWindow(window as! TFYStatusItemWindow, withFadeDirection: .fadeIn)
    }

    func dismissStatusItemWindow() {
        if animationIsRunning { return }
        animateWindow(window as! TFYStatusItemWindow, withFadeDirection:.fadeOut)
    }

    func animateWindow(_ window: TFYStatusItemWindow, withFadeDirection fadeDirection: TFYFadeDirection) {
        
        switch windowConfiguration?.presentationTransition ?? TFYPresentationTransition.none {
        case.none,.fade:
            animateWindow(window, withFadeTransitionUsingFadeDirection: fadeDirection)
        case.slideAndFade:
            animateWindow(window, withSlideAndFadeTransitionUsingFadeDirection: fadeDirection)
        }
    }

    func animateWindow(_ window: TFYStatusItemWindow, withFadeTransitionUsingFadeDirection fadeDirection: TFYFadeDirection) {
        let notificationName = fadeDirection == .fadeIn ? TFYStatusItemWindowWillShowNotification : TFYStatusItemWindowWillDismissNotification
        NotificationCenter.default.post(name: notificationName, object: window)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = windowConfiguration!.animationDuration
            context.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
            window.animator().alphaValue = fadeDirection == .fadeIn ? 1.0 : 0.0
        }, completionHandler: animationCompletionForWindow(window, fadeDirection: fadeDirection))
    }

    func animateWindow(_ window: TFYStatusItemWindow, withSlideAndFadeTransitionUsingFadeDirection fadeDirection: TFYFadeDirection) {
        
        let notificationName = fadeDirection == .fadeIn ? TFYStatusItemWindowWillShowNotification : TFYStatusItemWindowWillDismissNotification
        NotificationCenter.default.post(name: notificationName, object: window)
        var windowStartFrame: CGRect
        var windowEndFrame: CGRect
        let calculatedFrame = CGRect(x: window.frame.minX, y: window.frame.minY + TFYTransitionDistance, width: window.frame.width, height: window.frame.height)
        switch fadeDirection {
        case.fadeIn:
            windowStartFrame = calculatedFrame
            windowEndFrame = window.frame
        case.fadeOut:
            windowStartFrame = window.frame
            windowEndFrame = calculatedFrame
        }
        window.setFrame(windowStartFrame, display: false)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = windowConfiguration!.animationDuration
            context.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
            window.animator().setFrame(windowEndFrame, display: false)
            window.animator().alphaValue = fadeDirection == .fadeIn ? 1 : 0
        }, completionHandler: animationCompletionForWindow(window, fadeDirection: fadeDirection))
    }

    func animationCompletionForWindow(_ window: TFYStatusItemWindow, fadeDirection: TFYFadeDirection) -> TFYStatusItemWindowAnimationCompletion {
        
        let nc = NotificationCenter.default
        weak var wSelf = self
        return {
            wSelf?.animationIsRunning = false
            wSelf?.isWindowOpen = fadeDirection == .fadeIn
            if fadeDirection == .fadeIn {
                window.makeKey()
                nc.post(name: TFYStatusItemWindowDidShowNotification, object: window)
            } else {
                window.orderOut(wSelf!)
                window.close()
                nc.post(name: TFYStatusItemWindowDidDismissNotification, object: window)
            }
        }
    }

    @objc func handleWindowDidResignKeyNotification(_ note: Notification) {
        guard let window = note.object as? NSWindow, window == self.window else { return }
        if !windowConfiguration!.isPinned {
            dismissStatusItemWindow()
        }
    }

    @objc func handleAppleInterfaceThemeChangedNotification(_ note: Notification) {
        NotificationCenter.default.post(name: TFYSystemInterfaceThemeChangedNotification, object: nil)
    }
}



