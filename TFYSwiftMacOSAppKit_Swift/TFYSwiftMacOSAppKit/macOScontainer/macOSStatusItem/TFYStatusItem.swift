//
//  TFYStatusItem.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public enum TFYStatusItemPresentationMode {
    case undefined
    case image
    case customView
}

public enum TFYStatusItemProximityDragStatus {
    case entered
    case exited
}

public typealias TFYStatusItemProximityDragDetectionHandler = (TFYStatusItem, NSPoint, TFYStatusItemProximityDragStatus) -> Void
public typealias TFYStatusItemShouldShowHandler = (TFYStatusItem) -> Bool

public class TFYStatusItem: NSObject, NSWindowDelegate {
    
    static let sharedInstance = TFYStatusItem()

    var statusItem: NSStatusItem?
    var observerStatusItemFrame: NSKeyValueObservation?
    var observerisPinned: NSKeyValueObservation?
    // 私有变量
    private var globalDragEventMonitor: Any?
    private var proximityDragCollisionHandled: Bool?
    private var proximityDragCollisionArea: NSBezierPath?
    private var pbChangeCount: Int?
    private var customViewContainer: TFYStatusItemContainerView?
    private var customView: NSView?
    private var presentationMode: TFYStatusItemPresentationMode = .undefined
    
    private var statusItemWindowController: TFYStatusItemWindowController?

    // 邻近拖拽检测处理方法
    public var proximityDragDetectionHandler: TFYStatusItemProximityDragDetectionHandler?
    
    private override init() {
        super.init()
        
        globalDragEventMonitor = nil
        proximityDragCollisionHandled = false
        pbChangeCount = NSPasteboard.general.changeCount
        customViewContainer = nil
        
        statusItem = nil
        customView = nil
        presentationMode = .undefined
        isStatusItemWindowVisible = false
        statusItemWindowController = nil
        windowConfiguration = TFYStatusItemWindowConfiguration.defaultConfiguration()
        appearsDisabled = false
        enabled = true
        proximityDragDetectionEnabled = false
        proximityDragZoneDistance = 23
        proximityDragDetectionHandler = nil
        
    
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button, let _ = button.window {
            observerStatusItemFrame = button.window?.observe(\.frame, options: [.new]) { window, change in
                // 在这里处理窗口框架变化
                print("Window frame changed: \(window.frame)")
                self.configureProximityDragCollisionArea()
            }
        }
        
        observerisPinned = windowConfiguration?.observe(\.isPinned, options: [.prior,.new,.old]) { [self] config, change in
            // 在这里处理 isPinned 属性变化
            print("isPinned changed to: \(config.isPinned)")
            if let oldValue = change.oldValue, oldValue == false {
                dismissStatusItemWindow()
            } else {
                dismissStatusItemWindow()
                if proximityDragDetectionEnabled! {
                    enableDragEventMonitor()
                }
            }
        }
        
        DistributedNotificationCenter.default().addObserver(forName: TFYStatusItemThemeChangedNotification, object: nil, queue: nil) { note in
            NotificationCenter.default.post(name: TFYSystemInterfaceThemeChangedNotification, object: nil)
        }
        
    }

    deinit {
        observerStatusItemFrame?.invalidate()
        observerisPinned?.invalidate()
        statusItem = nil
        customView = nil
        statusItemWindowController = nil
        windowConfiguration = nil
        proximityDragDetectionHandler = nil
        proximityDragCollisionArea = nil
        customViewContainer = nil
    }

    func configureWithImage(itemImage: NSImage) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.isVisible = true
        if let button = statusItem?.button {
            button.target = self
            button.action = #selector(handleStatusItemButtonAction(_:))
            button.image = itemImage
        }
    }

    func configureWithView(itemView: NSView) {
        customView = itemView
        let itemFrame = itemView.frame
        customViewContainer = TFYStatusItemContainerView(frame: itemFrame)
        customViewContainer?.autoresizingMask = [.width,.height]
        if let layer = customView!.layer {
            let backgroundColor = layer.backgroundColor
            customViewContainer?.wantsLayer = true
            customViewContainer?.layer?.backgroundColor = backgroundColor
        }
        customViewContainer?.target = self
        customViewContainer?.action = #selector(handleStatusItemButtonAction(_:))
        customViewContainer?.addSubview(itemView)
        statusItem = NSStatusBar.system.statusItem(withLength: NSWidth(itemFrame))
        statusItem?.isVisible = true
        let containerBtn = NSStatusBarButton(frame: itemFrame)
        containerBtn.autoresizingMask = [.width,.height]
        containerBtn.target = self
        containerBtn.action = #selector(handleStatusItemButtonAction(_:))
        containerBtn.addSubview(itemView)
        if let button = statusItem?.button {
            button.frame = itemFrame
            button.addSubview(customViewContainer!)
            itemView.autoresizingMask = [.width,.height]
        }
    }

    func configureProximityDragCollisionArea() {
        if let statusItemFrame = statusItem?.button?.window?.frame {
            let collisionFrame = statusItemFrame.insetBy(dx: -proximityDragZoneDistance!, dy: -proximityDragZoneDistance!)
            proximityDragCollisionArea = NSBezierPath(roundedRect: collisionFrame, xRadius: NSWidth(collisionFrame) / 2, yRadius: NSHeight(collisionFrame) / 2)
        }
    }

    @objc public func presentStatusItemWithImage(itemImage: NSImage, contentViewController: NSViewController) {
        guard presentationMode == .undefined else { return }
        configureWithImage(itemImage: itemImage)
        configureProximityDragCollisionArea()
        presentationMode = .image
        statusItemWindowController = TFYStatusItemWindowController(connectedStatusItem: self, contentViewController: contentViewController, windowConfiguration: windowConfiguration!)
    }

    @objc public func presentStatusItemWithView(itemView: NSView, contentViewController: NSViewController) {
        guard presentationMode == .undefined else { return }
        configureWithView(itemView: itemView)
        configureProximityDragCollisionArea()
        presentationMode = .customView
        statusItemWindowController = TFYStatusItemWindowController(connectedStatusItem: self, contentViewController: contentViewController, windowConfiguration: windowConfiguration!)
    }

    @objc public func updateContentViewController(_ contentViewController: NSViewController) {
        statusItemWindowController?.updateContenetViewController(contentViewController)
    }

    @objc public func removeStatusItem() {
        guard let statusItem = statusItem else { return }
        NSStatusBar.system.removeStatusItem(statusItem)
        self.statusItem = nil
        presentationMode = .undefined
        isStatusItemWindowVisible = false
        statusItemWindowController = nil
    }

    @objc public func handleStatusItemButtonAction(_ sender: Any?) {
        if isStatusItemWindowVisible {
            dismissStatusItemWindow()
        } else {
            showStatusItemWindow()
        }
    }

    public var windowConfiguration: TFYStatusItemWindowConfiguration?

    // 是否暗黑模式
    public var isDarkMode: Bool? {
        set {}
        get {
            guard let dict = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain) else { return false }
            let style: String = dict["AppleInterfaceStyle"] as! String
            return style.isEmpty && style.lowercased() == "dark"
        }
    }
    // 是否禁用状态
    public var appearsDisabled: Bool? {
        set {
            guard let appearsDisabled = newValue else { return }
            statusItem?.button?.appearsDisabled = appearsDisabled
        }
        get {
            return statusItem?.button?.appearsDisabled
        }
    }
    // 是否可用状态
    public var enabled: Bool? {
        set {
            guard let enabled = newValue else { return }
            statusItem?.button?.isEnabled = enabled
        }
        get {
            return statusItem?.button?.isEnabled
        }
    }
    // 状态项窗口是否可见
    public var isStatusItemWindowVisible: Bool {
        get {
            let isWindowOpen = statusItemWindowController != nil && statusItemWindowController!.isWindowOpen
            return isWindowOpen
        }
        set {}
    }

    // 邻近拖拽检测是否启用
    public var proximityDragDetectionEnabled: Bool? {
        didSet {
            guard let proximityDraggingDetectionEnabled = proximityDragDetectionEnabled else { return }
            
            if proximityDraggingDetectionEnabled && !(windowConfiguration?.isPinned ?? false) {
                configureProximityDragCollisionArea()
                enableDragEventMonitor()
            } else {
                disableDragEventMonitor()
            }
        }
    }
    // 邻近拖拽区域距离
    public var proximityDragZoneDistance: CGFloat? {
        didSet {
            guard let _ = proximityDragZoneDistance else { return }
            configureProximityDragCollisionArea()
        }
    }

    private func enableDragEventMonitor() {
        guard globalDragEventMonitor == nil else { return }
        weak var wSelf = self
        globalDragEventMonitor = NSEvent.addGlobalMonitorForEvents(matching:.leftMouseDragged) { event in
            let eventLocation = event.locationInWindow
            if wSelf!.proximityDragCollisionArea?.contains(eventLocation) ?? false {
                let currentChangeCount = NSPasteboard(name:.drag).changeCount
                if wSelf!.pbChangeCount == currentChangeCount {
                    return
                }
                if !wSelf!.proximityDragCollisionHandled! {
                    if let handler = wSelf!.proximityDragDetectionHandler {
                        handler(wSelf!, eventLocation,.entered)
                        wSelf!.proximityDragCollisionHandled = true
                        wSelf!.pbChangeCount = currentChangeCount
                    }
                }
            } else {
                if wSelf!.proximityDragCollisionHandled! {
                    if let handler = wSelf!.proximityDragDetectionHandler {
                        handler(wSelf!, eventLocation,.exited)
                        wSelf!.proximityDragCollisionHandled = false
                        wSelf!.pbChangeCount! -= 1
                    }
                }
            }
        }
    }

    private func disableDragEventMonitor() {
        if let monitor = globalDragEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalDragEventMonitor = nil
        }
    }

    @objc func showStatusItemWindow() {
        statusItemWindowController?.showStatusItemWindow()
    }

    @objc func dismissStatusItemWindow() {
        statusItemWindowController?.dismissStatusItemWindow()
    }
}

