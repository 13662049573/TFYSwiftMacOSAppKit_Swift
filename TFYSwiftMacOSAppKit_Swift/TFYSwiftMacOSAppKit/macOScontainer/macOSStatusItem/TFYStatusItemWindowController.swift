//
//  TFYStatusItemWindowController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

// MARK: - Types

public enum TFYFadeDirection {
    case fadeIn
    case fadeOut
}

public typealias TFYStatusItemWindowAnimationCompletion = () -> Void

// MARK: - Constants

private struct Constants {
    static let transitionDistance: CGFloat = 8.0
    static let timingControlPoints = (0.1, 0.1, 0.9, 0.9)
}

// MARK: - Main Class

public class TFYStatusItemWindowController: NSWindowController {
    
    // MARK: - Properties
    
    public weak var statusItemView: TFYStatusItem?
    public var windowConfiguration: TFYStatusItemWindowConfiguration?
    
    @Published private(set) var isWindowOpen = false
    private var animationIsRunning = false
    
    // MARK: - Initialization
    
    public init(connectedStatusItem statusItem: TFYStatusItem,
                contentViewController: NSViewController,
                windowConfiguration: TFYStatusItemWindowConfiguration) {
        
        assert(contentViewController.preferredContentSize != .zero,
               "ContentViewController的preferredContentSize不能为零!")
        
        self.statusItemView = statusItem
        self.windowConfiguration = windowConfiguration
        
        super.init(window: TFYStatusItemWindow.statusItemWindowWithConfiguration(configuration: windowConfiguration))
        
        self.contentViewController = contentViewController
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowDidResignKeyNotification(_:)),
            name: NSWindow.didResignKeyNotification,
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleAppleInterfaceThemeChangedNotification(_:)),
            name: .statusItemThemeChanged,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    
    func updateContentViewController(_ contentViewController: NSViewController) {
        self.contentViewController = nil
        self.contentViewController = contentViewController
        updateWindowFrame()
    }
    
    func showStatusItemWindow() {
        guard !animationIsRunning,
              let window = window as? TFYStatusItemWindow else { return }
        
        updateWindowFrame()
        window.alphaValue = 0.0
        showWindow(nil)
        animateWindow(window, withFadeDirection: .fadeIn)
    }
    
    func dismissStatusItemWindow() {
        guard !animationIsRunning,
              let window = window as? TFYStatusItemWindow else { return }
        
        animateWindow(window, withFadeDirection: .fadeOut)
    }
    
    // MARK: - Private Methods
    
    private func updateWindowFrame() {
        guard let statusItemRect = statusItemView?.getStatusItemFrame(),
              let window = window,
              let screen = NSScreen.main else { return }
        
        let windowFrame = CGRect(
            x: statusItemRect.minX - window.frame.width / 2 + statusItemRect.width / 2,
            y: min(statusItemRect.minY, screen.frame.height) - window.frame.height - windowConfiguration!.windowToStatusItemMargin,
            width: window.frame.width,
            height: window.frame.height
        )
        
        window.setFrame(windowFrame, display: true)
        
        if #available(macOS 12.0, *) {
            window.appearance = NSAppearance.currentDrawing()
        } else {
            window.appearance = NSAppearance.current
        }
    }
    
    private func animateWindow(_ window: TFYStatusItemWindow, withFadeDirection fadeDirection: TFYFadeDirection) {
        switch windowConfiguration?.presentationTransition ?? .none {
        case .none, .fade:
            animateWindow(window, withFadeTransitionUsingFadeDirection: fadeDirection)
        case .slideAndFade:
            animateWindow(window, withSlideAndFadeTransitionUsingFadeDirection: fadeDirection)
        }
    }
    
    private func animateWindow(_ window: TFYStatusItemWindow,
                             withFadeTransitionUsingFadeDirection fadeDirection: TFYFadeDirection) {
        NotificationCenter.default.post(
            name: fadeDirection == .fadeIn ? .statusItemWindowWillShow : .statusItemWindowWillDismiss,
            object: window
        )
        
        performAnimation(window: window, fadeDirection: fadeDirection)
    }
    
    private func animateWindow(_ window: TFYStatusItemWindow,
                             withSlideAndFadeTransitionUsingFadeDirection fadeDirection: TFYFadeDirection) {
        NotificationCenter.default.post(
            name: fadeDirection == .fadeIn ? .statusItemWindowWillShow : .statusItemWindowWillDismiss,
            object: window
        )
        
        let calculatedFrame = CGRect(
            x: window.frame.minX,
            y: window.frame.minY + Constants.transitionDistance,
            width: window.frame.width,
            height: window.frame.height
        )
        
        let (startFrame, endFrame) = fadeDirection == .fadeIn
            ? (calculatedFrame, window.frame)
            : (window.frame, calculatedFrame)
        
        window.setFrame(startFrame, display: false)
        performAnimation(window: window,
                        fadeDirection: fadeDirection,
                        endFrame: endFrame)
    }
    
    private func performAnimation(window: TFYStatusItemWindow,
                                fadeDirection: TFYFadeDirection,
                                endFrame: CGRect? = nil) {
        animationIsRunning = true
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = windowConfiguration?.animationDuration ?? TFYDefaultConstants.animationDuration
            context.timingFunction = CAMediaTimingFunction(
                controlPoints: Float(Constants.timingControlPoints.0),
                Float(Constants.timingControlPoints.1),
                Float(Constants.timingControlPoints.2),
                Float(Constants.timingControlPoints.3)
            )
            
            if let endFrame = endFrame {
                window.animator().setFrame(endFrame, display: false)
            }
            window.animator().alphaValue = fadeDirection == .fadeIn ? 1.0 : 0.0
            
        }) { [weak self] in
            self?.handleAnimationCompletion(window: window, fadeDirection: fadeDirection)
        }
    }
    
    private func handleAnimationCompletion(window: TFYStatusItemWindow, fadeDirection: TFYFadeDirection) {
        animationIsRunning = false
        isWindowOpen = fadeDirection == .fadeIn
        
        if fadeDirection == .fadeIn {
            window.makeKey()
            NotificationCenter.default.post(name: .statusItemWindowDidShow, object: window)
        } else {
            window.orderOut(self)
            window.close()
            NotificationCenter.default.post(name: .statusItemWindowDidDismiss, object: window)
        }
    }
    
    // MARK: - Notification Handlers
    
    @objc private func handleWindowDidResignKeyNotification(_ note: Notification) {
        guard let window = note.object as? NSWindow,
              window == self.window,
              !(windowConfiguration?.isPinned ?? false) else { return }
        
        dismissStatusItemWindow()
    }
    
    @objc private func handleAppleInterfaceThemeChangedNotification(_ note: Notification) {
        NotificationCenter.default.post(name: .systemInterfaceThemeChanged, object: nil)
    }
}
