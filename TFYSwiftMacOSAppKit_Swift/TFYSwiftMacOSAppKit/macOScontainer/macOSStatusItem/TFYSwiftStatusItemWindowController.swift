//
//  TFYSwiftStatusItemWindowController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

public let themeChangedNotification = Notification.Name("AppleInterfaceThemeChangedNotification")
public let TFYStatusItemWindowWillShowNotification = Notification.Name("TFYStatusItemWindowWillShowNotification")
public let TFYStatusItemWindowDidShowNotification = Notification.Name("TFYStatusItemWindowDidShowNotification")
public let TFYStatusItemWindowWillDismissNotification = Notification.Name("TFYStatusItemWindowWillDismissNotification")
public let TFYStatusItemWindowDidDismissNotification = Notification.Name("TFYStatusItemWindowDidDismissNotification")
public let TFYSystemInterfaceThemeChangedNotification = Notification.Name("TFYSystemInterfaceThemeChangedNotification")

public enum TFYFadeDirection : Int {
    case TFYFadeDirectionFadeIn = 0
    case TFYFadeDirectionFadeOut = 1
}

public typealias TFYStatusItemWindowAnimationCompletion = (() -> Void)?

public class TFYSwiftStatusItemWindowController: NSWindowController {

    private var statusItemView:TFYSwiftStatusItem?
    private var windowConfiguration:TFYSwiftStatusItemConfiguration?
    
    public var TFYTransitionDistance:CGFloat = 8.0
    
    public var windowIsOpen:Bool = false
    public var animationIsRunning:Bool = false
    
    public convenience init(statusItem:TFYSwiftStatusItem,
         contentViewController:NSViewController?,
         windowConfiguration:TFYSwiftStatusItemConfiguration) {
        
        self.init()
        
        if (contentViewController == nil) {
            return
        }
        assert(contentViewController!.preferredContentSize.width != 0 && contentViewController!.preferredContentSize.height != 0, "[\(type(of: self))] contentViewController 的 preferredContentSize 不能是 NSZeroSize!")
        
        self.windowIsOpen = false
        self.statusItemView = statusItem
        self.windowConfiguration = windowConfiguration
        
        self.window = TFYSwiftStatusItemWindow.statusItemWindowWithConfiguration(configuration: windowConfiguration)
        self.contentViewController = contentViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWindowDidResignKeyNotification(note:)), name: NSWindow.didResignKeyNotification, object: nil)
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleAppleInterfaceThemeChangedNotification(note:)), name: themeChangedNotification, object: nil)
    }
    
    public override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleWindowDidResignKeyNotification(note:Notification) {
        if !((note.object as! NSObject).isEqual(self.window)) {
            return
        }
        if !(self.windowConfiguration?.pinned)! {
            self.dismissStatusItemWindow()
        }
    }
    
    @objc func handleAppleInterfaceThemeChangedNotification(note:Notification) {
        NotificationCenter.default.post(name: TFYSystemInterfaceThemeChangedNotification, object: nil)
    }

    public func updateContenetViewController(contentViewController:NSViewController) {
        self.contentViewController = nil
        self.contentViewController = contentViewController
        self.updateWindowFrame()
    }
    
    private func updateWindowFrame() {
        let statusItemRect:NSRect = self.statusItemView!.statusItem?.button?.window?.frame ?? .zero
        
        let windRect:NSRect = self.window?.frame ?? .zero
    
        let nsX:CGFloat = NSMinX(statusItemRect) - NSWidth(windRect)/2 + NSWidth(statusItemRect)/2
        
        let nsY:CGFloat = min(NSMidY(statusItemRect), NSApp.mainWindow!.frame.size.height - NSHeight(windRect) - self.windowConfiguration!.windowToStatusItemMargin!)
        
        let nsW:CGFloat = windRect.size.width
        
        let nsH:CGFloat = windRect.size.height
        
        let windowFrame:NSRect = NSMakeRect(nsX,nsY,nsW,nsH)
        
        self.window?.setFrame(windowFrame, display: true)
        
        self.window?.appearance = NSAppearance.current
    }
    
    public func showStatusItemWindow() {
        if self.animationIsRunning {
            return
        }
        self.updateWindowFrame()
        self.window?.alphaValue = 0
        self.showWindow(nil)
        self.animateWindow(window: self.window as! TFYSwiftStatusItemWindow, fadeDirection: .TFYFadeDirectionFadeIn)
    }
    
    public func dismissStatusItemWindow() {
        if self.animationIsRunning {
            return
        }
        self.animateWindow(window: self.window as! TFYSwiftStatusItemWindow, fadeDirection: .TFYFadeDirectionFadeOut)
    }
    
    public func animateWindow(window:TFYSwiftStatusItemWindow,fadeDirection:TFYFadeDirection) {
        switch self.windowConfiguration?.presentationTransition {
        case .TFYSwiftTransitionNone:
            break
        case .TFYSwiftTransitionFade:
            self.withFadeTransitionUsingFadeDirection(window: window, fadeDirection: fadeDirection)
            break
        case .TFYSwiftTransitionSlideAndFade:
            self.withSlideAndFadeTransitionUsingFadeDirection(window: window, fadeDirection: fadeDirection)
            break
        default:
            break
        }
    }
    
    public func withFadeTransitionUsingFadeDirection(window:TFYSwiftStatusItemWindow,fadeDirection:TFYFadeDirection) {
        let notificationName = (fadeDirection == .TFYFadeDirectionFadeIn ? TFYStatusItemWindowWillShowNotification : TFYStatusItemWindowWillDismissNotification)

        NotificationCenter.default.post(name: notificationName, object: window)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.windowConfiguration?.animationDuration ?? 0.0
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().alphaValue = fadeDirection == .TFYFadeDirectionFadeIn ? 1 : 0
        }, completionHandler: animationCompletionForWindow(window:window,fadeDirection:fadeDirection))
    }
    
    public func withSlideAndFadeTransitionUsingFadeDirection(window:TFYSwiftStatusItemWindow,fadeDirection:TFYFadeDirection)  {
        let notificationName = (fadeDirection == .TFYFadeDirectionFadeIn ? TFYStatusItemWindowWillShowNotification : TFYStatusItemWindowWillDismissNotification)

        NotificationCenter.default.post(name: notificationName, object: window)
        
        var windowStartFrame:NSRect?
        var windowEndFrame:NSRect?
        
        let calculatedFrame:NSRect = NSMakeRect(NSMinX(window.frame), NSMinY(window.frame) + TFYTransitionDistance, NSWidth(window.frame), NSHeight(window.frame))
        switch fadeDirection {
        case .TFYFadeDirectionFadeIn:
            windowStartFrame = calculatedFrame
            windowEndFrame = window.frame
            break
        case .TFYFadeDirectionFadeOut:
            windowStartFrame = window.frame
            windowEndFrame = calculatedFrame
            break
        }
        window.setFrame(windowStartFrame!, display: false)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.windowConfiguration?.animationDuration ?? 0.0
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(windowEndFrame!, display: false)
            window.animator().alphaValue = fadeDirection == .TFYFadeDirectionFadeIn ? 1 : 0
        }, completionHandler: animationCompletionForWindow(window:window,fadeDirection:fadeDirection))
    }
    
    
    public func animationCompletionForWindow(window:TFYSwiftStatusItemWindow,fadeDirection:TFYFadeDirection) -> TFYStatusItemWindowAnimationCompletion {
        let not = NotificationCenter.default
        return (() -> Void)? { [self] in
            self.animationIsRunning = false
            self.windowIsOpen = (fadeDirection == .TFYFadeDirectionFadeIn)
            if fadeDirection == .TFYFadeDirectionFadeIn {
                window.makeMain()
                not.post(name: TFYStatusItemWindowDidShowNotification, object: window)
            } else {
                window.orderOut(self)
                window.close()
                not.post(name: TFYStatusItemWindowDidDismissNotification, object: window)
            }
        }
    }
}
