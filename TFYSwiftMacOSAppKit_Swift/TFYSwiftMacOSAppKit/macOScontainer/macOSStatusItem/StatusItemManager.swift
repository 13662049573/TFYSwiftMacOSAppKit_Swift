//
//  StatusItemManager.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 定义常量
private let STATUS_ITEM_FRAME_KEY_PATH = "statusItem.button.window.frame"
private let STATUS_ITEM_WINDOW_CONFIGURATION_PINNED_PATH = "windowConfiguration.pinned"

// 状态项展示模式枚举
public enum StatusItemPresentationMode: Int {
    case undefined = 0
    case image = 1
    case customView = 2
}

// 邻近拖拽状态枚举
public enum StatusItemProximityDragStatus: Int {
    case entered = 0
    case exited = 1
}

// 类型别名
public typealias StatusItemDropHandler = ((_ statusItemManager: StatusItemManager, _ pasteboardType: String, _ droppedObjects: Any?) -> Void)?
public typealias StatusItemProximityDragDetectionHandler = (_ statusItemManager: StatusItemManager, _ eventLocation: NSPoint, _ proxymityDragStatus: StatusItemProximityDragStatus) -> Void
public typealias StatusItemShouldShowHandler = (_ statusItemManager: StatusItemManager) -> Void

// 状态项管理类
public class StatusItemManager: NSObject {

    // 单例实例
    public static let shared = StatusItemManager()

    // 状态项
    public var statusItem: NSStatusItem?
    // 拖拽处理方法
    public var dropHandler: StatusItemDropHandler? {
        didSet {
            if dropHandler != nil {
                configureDropView()
            }
        }
    }
    // 是否显示处理方法
    public var shouldShowHandler: StatusItemShouldShowHandler?
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
    public var isStatusItemWindowVisible: Bool? {
        get {
            return (statusItemWindowController != nil) ? (statusItemWindowController?.windowIsOpen) : false
        }
        set {}
    }
    // 邻近拖拽检测是否启用
    public var proximityDragDetectionEnabled: Bool? {
        didSet {
            guard let proximityDraggingDetectionEnabled = proximityDragDetectionEnabled else { return }
            
            if proximityDraggingDetectionEnabled && !(windowConfiguration?.pinned ?? false) {
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
    // 邻近拖拽检测处理方法
    public var proximityDragDetectionHandler: StatusItemProximityDragDetectionHandler?
    // 可拖拽类型
    public var dropTypes: [NSPasteboard.PasteboardType]?
    // 窗口配置
    public var windowConfiguration: StatusItemConfig? {
        didSet {
            guard let configuration = windowConfiguration else { return }
            statusItem?.button?.toolTip = configuration.toolTip
        }
    }

    // 私有变量
    private var globalDragEventMonitor: Any?
    private var proximityDragCollisionHandled: Bool?
    private var proximityDragCollisionArea: NSBezierPath?
    private var pbChangeCount: Int?
    private var customViewContainer: StatusItemContainerView?
    private var customView: NSView?
    private var presentationMode: StatusItemPresentationMode?
    private var dropView: StatusItemDragDropView?
    private var statusItemWindowController: StatusItemWindowController?

    // 禁止外部初始化
    private override init() {
        let exceptionMessage = "You must NOT init '\(String(describing: type(of: self)))' manually! Use class method 'sharedInstance' instead."
        fatalError(exceptionMessage)
    }

    // 单例初始化方法
    private func initSingleton() -> StatusItemManager {
        globalDragEventMonitor = nil
        proximityDragCollisionHandled = nil
        pbChangeCount = NSPasteboard.general.changeCount
        customViewContainer = nil
        statusItem = nil
        customView = nil
        presentationMode = .undefined
        isStatusItemWindowVisible = false
        statusItemWindowController = nil
        windowConfiguration = StatusItemConfig.defaultConfig
        appearsDisabled = false
        enabled = true

        dropTypes = [.fileURL]
        dropHandler = nil
        proximityDragDetectionEnabled = false
        proximityDragZoneDistance = 23
        proximityDragDetectionHandler = nil

        addObserver(self, forKeyPath: STATUS_ITEM_FRAME_KEY_PATH, options:.new, context: nil)
        addObserver(self, forKeyPath: STATUS_ITEM_WINDOW_CONFIGURATION_PINNED_PATH, options: [.new,.old,.prior], context: nil)

        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("themeChangedNotification"), object: nil, queue: nil) { note in
            NotificationCenter.default.post(name: NSNotification.Name("TFYSystemInterfaceThemeChangedNotification"), object: nil)
        }

        return self
    }

    deinit {
        removeObserver(self, forKeyPath: STATUS_ITEM_FRAME_KEY_PATH)
        removeObserver(self, forKeyPath: STATUS_ITEM_WINDOW_CONFIGURATION_PINNED_PATH)

        statusItem = nil
        customView = nil
        statusItemWindowController = nil
        windowConfiguration = nil
        dropHandler = nil
        proximityDragDetectionHandler = nil
        proximityDragCollisionArea = nil
        customViewContainer = nil
    }

    // 用给定的图像和视图控制器显示状态项
    public func presentStatusItemWithImage(itemImage: NSImage, contentViewController: NSViewController) {
        presentStatusItemWithImage(itemImage: itemImage, contentViewController: contentViewController, dropHandler: nil)
    }

    public func presentStatusItemWithImage(itemImage: NSImage, contentViewController: NSViewController, dropHandler: StatusItemDropHandler) {
        guard presentationMode == .undefined else { return }
        configureWithImage(itemImage: itemImage)
        configureProximityDragCollisionArea()

        self.dropHandler = dropHandler
        presentationMode = .image

        let window = StatusItemWindowController(statusItem: self, contentViewController: contentViewController, windowConfiguration: windowConfiguration!)
        statusItemWindowController = window
    }

    // 用给定的自定义视图和视图控制器显示状态项
    public func presentStatusItemWithView(itemView: NSView, contentViewController: NSViewController) {
        presentStatusItemWithView(itemView: itemView, contentViewController: contentViewController, dropHandler: nil)
    }

    public func presentStatusItemWithView(itemView: NSView, contentViewController: NSViewController, dropHandler: StatusItemDropHandler) {
        guard presentationMode == .undefined else { return }
        configureWithView(itemView: itemView)
        configureProximityDragCollisionArea()

        self.dropHandler = dropHandler
        presentationMode = .customView

        let window = StatusItemWindowController(statusItem: self, contentViewController: contentViewController, windowConfiguration: windowConfiguration!)
        statusItemWindowController = window
    }

    // 更新状态项窗口的视图控制器
    public func updateContentViewController(contentViewController: NSViewController) {
        statusItemWindowController?.updateContenetViewController(contentViewController: contentViewController)
    }

    // 移除状态项
    public func removeStatusItem() {
        guard let statusItem = statusItem else { return }
        NSStatusBar.system.removeStatusItem(statusItem)
        self.statusItem = nil
        presentationMode = .undefined
        isStatusItemWindowVisible = false
        statusItemWindowController = nil
    }

    // 用图像配置状态项
    private func configureWithImage(itemImage: NSImage) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.isVisible = true

        guard let button = statusItem?.button else { return }
        button.target = self
        button.action = #selector(handleStatusItemButtonAction)
        button.image = itemImage
    }

    // 用自定义视图配置状态项
    private func configureWithView(itemView: NSView) {
        customView = itemView
        let itemFrame = itemView.frame

        customViewContainer = StatusItemContainerView(frame: itemFrame)
        customViewContainer?.autoresizingMask = [.width,.height]
        customViewContainer?.target = self
        customViewContainer?.action = #selector(handleStatusItemButtonAction)
        customViewContainer?.addSubview(itemView)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.isVisible = true

        let containerBtn = NSStatusBarButton(frame: itemFrame)
        containerBtn.autoresizingMask = [.width,.height]
        containerBtn.target = self
        containerBtn.action = #selector(handleStatusItemButtonAction)
        containerBtn.addSubview(itemView)

        guard let button = statusItem?.button else { return }
        button.frame = itemFrame
        button.addSubview(customViewContainer!)
        button.autoresizingMask = [.width,.height]
    }

    // 处理状态项按钮动作
    @objc private func handleStatusItemButtonAction() {
        guard let shouldShow = shouldShowHandler else { return }
        if isStatusItemWindowVisible! {
            dismissStatusItemWindow()
        } else if shouldShow(self) {
            showStatusItemWindow()
        }
    }

    // 关闭状态项窗口
    private func dismissStatusItemWindow() {
        statusItemWindowController?.dismissStatusItemWindow()
    }

    // 显示状态项窗口
    private func showStatusItemWindow() {
        statusItemWindowController?.showStatusItemWindow()
    }

    // 禁用拖拽事件监视器
    private func disableDragEventMonitor() {
        NSEvent.removeMonitor(globalDragEventMonitor as Any)
        globalDragEventMonitor = nil
    }

    // 配置邻近拖拽碰撞区域
    private func configureProximityDragCollisionArea() {
        guard let statusItemFrame = statusItem?.button?.window?.frame else { return }
        let collisionFrame = NSInsetRect(statusItemFrame, -proximityDragZoneDistance!, -proximityDragZoneDistance!)
        proximityDragCollisionArea = NSBezierPath(roundedRect: collisionFrame, xRadius: NSWidth(collisionFrame)/2, yRadius: NSHeight(collisionFrame)/2)
    }

    // 配置拖拽视图
    private func configureDropView() {
        dropView?.removeFromSuperview()
        dropView = nil
        guard let dropHandler = dropHandler else { return }
        guard let button = statusItem?.button else { return }
        let buttonWindowFrame = button.window!.frame
        let statusItemFrame = NSMakeRect(0.0, 0.0, NSWidth(buttonWindowFrame), NSHeight(buttonWindowFrame))
        dropView = StatusItemDragDropView(frame: statusItemFrame)
        dropView?.statusItem = self
        dropView?.dropTypes = dropTypes!
        dropView?.dropHandler = dropHandler
        button.addSubview(dropView!)
        dropView?.autoresizingMask = [.width,.height]
    }

    // 启用拖拽事件监视器
    private func enableDragEventMonitor() {
        guard globalDragEventMonitor == nil else { return }
        globalDragEventMonitor = NSEvent.addGlobalMonitorForEvents(matching:.leftMouseDragged, handler: { event in
            let eventLocation = event.locationInWindow
            guard let proximityDragCollisionArea = self.proximityDragCollisionArea else { return }
            if proximityDragCollisionArea.contains(eventLocation) {
                let currentChangeCount = NSPasteboard(name:.drag).changeCount
                if self.pbChangeCount == currentChangeCount {
                    return
                }
                if !self.proximityDragCollisionHandled! {
                    if self.proximityDragDetectionHandler != nil {
                        self.proximityDragDetectionHandler!(self, eventLocation,.entered)
                        self.proximityDragCollisionHandled! = true
                        self.pbChangeCount = currentChangeCount
                    }
                }
            } else {
                if self.proximityDragCollisionHandled! {
                    if self.proximityDragDetectionHandler != nil {
                        self.proximityDragDetectionHandler!(self, eventLocation,.exited)
                        self.proximityDragCollisionHandled! = false
                        self.pbChangeCount! -= 1
                    }
                }
            }
        })
    }

    // 观察值变化
    public override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let sharedInstance = StatusItemManager.shared else { return }
        if keyPath == STATUS_ITEM_FRAME_KEY_PATH {
            sharedInstance.configureProximityDragCollisionArea()
        } else if keyPath == STATUS_ITEM_WINDOW_CONFIGURATION_PINNED_PATH {
            guard let oldKey = change?[.oldKey] as? String else { return }
            let value = oldKey.utf16.count == NSControl.StateValue.off.rawValue
            if value {
                sharedInstance.disableDragEventMonitor()
            } else {
                sharedInstance.dismissStatusItemWindow()
                if sharedInstance.proximityDragDetectionEnabled! {
                    sharedInstance.enableDragEventMonitor()
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
