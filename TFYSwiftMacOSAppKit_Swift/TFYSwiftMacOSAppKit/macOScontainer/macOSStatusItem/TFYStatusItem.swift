//
//  TFYStatusItem.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - 枚举定义

/// 状态栏项展示模式
public enum TFYStatusItemPresentationMode {
    case undefined   // 未定义状态
    case image      // 图片模式
    case customView // 自定义视图模式
}

/// 拖拽状态
public enum TFYStatusItemProximityDragStatus {
    case entered    // 进入拖拽区域
    case exited     // 离开拖拽区域
}

// MARK: - 类型别名

/// 拖拽检测处理回调
public typealias TFYStatusItemProximityDragDetectionHandler = (TFYStatusItem, NSPoint, TFYStatusItemProximityDragStatus) -> Void
/// 显示条件判断回调
public typealias TFYStatusItemShouldShowHandler = (TFYStatusItem) -> Bool

// MARK: - 主类

/// 状态栏项管理类
public class TFYStatusItem: NSObject, NSWindowDelegate {
    
    // MARK: - 公开属性
    
    /// 共享实例
    public static let shared = TFYStatusItem()
    
    /// 窗口配置
    public var windowConfiguration: TFYStatusItemWindowConfiguration? {
        didSet {
            setupPinnedObserver()
        }
    }
    
    /// 是否启用拖拽检测
    public var proximityDragDetectionEnabled: Bool = false {
        didSet {
            guard proximityDragDetectionEnabled != oldValue else { return }
            handleDragDetectionChange()
        }
    }
    
    /// 拖拽检测区域距离
    public var proximityDragZoneDistance: CGFloat = 23 {
        didSet {
            configureProximityDragCollisionArea()
        }
    }
    
    /// 拖拽检测处理器
    public var proximityDragDetectionHandler: TFYStatusItemProximityDragDetectionHandler?
    
    /// 状态栏项是否可用
    public var enabled: Bool {
        get { statusItem?.button?.isEnabled ?? false }
        set { statusItem?.button?.isEnabled = newValue }
    }
    
    /// 状态栏项是否显示为禁用状态
    public var appearsDisabled: Bool {
        get { statusItem?.button?.appearsDisabled ?? false }
        set { statusItem?.button?.appearsDisabled = newValue }
    }
    
    // MARK: - 私有属性
    
    private var statusItem: NSStatusItem?
    private var observerStatusItemFrame: NSKeyValueObservation?
    private var observerisPinned: NSKeyValueObservation?
    private var globalDragEventMonitor: Any?
    private var proximityDragCollisionHandled: Bool = false
    private var proximityDragCollisionArea: NSBezierPath?
    private var pbChangeCount: Int = 0
    private var customViewContainer: TFYStatusItemContainerView?
    private var customView: NSView?
    private var presentationMode: TFYStatusItemPresentationMode = .undefined
    private var statusItemWindowController: TFYStatusItemWindowController?
    
    @Published private(set) var isStatusItemWindowVisible: Bool = true
    
    // MARK: - 初始化方法
    
    private override init() {
        pbChangeCount = NSPasteboard.general.changeCount
        super.init()
        setupStatusItem()
        setupObservers()
    }
    
    deinit {
        cleanup()
    }
   
    /// 状态栏项内容配置
    public struct StatusItemConfiguration {
        /// 图片
        public var image: NSImage?
        /// 自定义视图
        public var customView: NSView?
        /// 视图控制器
        public var viewController: NSViewController?
        /// 窗口配置
        public var windowConfiguration: TFYStatusItemWindowConfiguration?
        
        public init(image: NSImage? = nil,
                    customView: NSView? = nil,
                    viewController: NSViewController? = nil,
                    windowConfiguration: TFYStatusItemWindowConfiguration? = nil) {
            self.image = image
            self.customView = customView
            self.viewController = viewController
            self.windowConfiguration = windowConfiguration
        }
    }

    /// 配置状态栏项
    /// - Parameter config: 状态栏项配置
    /// - Throws: TFYStatusItemError
    public func configure(with config: StatusItemConfiguration) throws {
        // 检查初始化状态
        guard presentationMode == .undefined else {
            throw TFYStatusItemError.alreadyInitialized
        }
        
        // 检查状态栏按钮是否可用
        guard let button = statusItem?.button else {
            throw TFYStatusItemError.invalidView
        }
        
        // 配置图片或自定义视图
        if let image = config.image {
            button.image = image
            button.target = self
            button.action = #selector(handleStatusItemButtonAction(_:))
            presentationMode = .image
        } else if let view = config.customView {
            let containerView = TFYStatusItemContainerView(frame: view.bounds)
            containerView.target = self
            containerView.action = #selector(handleStatusItemButtonAction(_:))
            containerView.addSubview(view)
            
            customViewContainer = containerView
            customView = view
            
            button.frame = containerView.bounds
            button.addSubview(containerView)
            presentationMode = .customView
        }
        
        // 配置视图控制器(如果有)
        if let viewController = config.viewController {
            guard let configuration = config.windowConfiguration ?? windowConfiguration else {
                throw TFYStatusItemError.configurationMissing
            }
            
            guard viewController.preferredContentSize != .zero else {
                throw TFYStatusItemError.invalidContentSize
            }
            
            statusItemWindowController = TFYStatusItemWindowController(
                connectedStatusItem: self,
                contentViewController: viewController,
                windowConfiguration: configuration
            )
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        windowConfiguration = TFYStatusItemWindowConfiguration.defaultConfiguration()
    }
    
    private func setupObservers() {
        if let button = statusItem?.button, let window = button.window {
            observerStatusItemFrame = window.observe(\.frame) { [weak self] _, _ in
                self?.configureProximityDragCollisionArea()
            }
        }
        
        setupPinnedObserver()
        setupThemeObserver()
    }
    
    private func setupPinnedObserver() {
        observerisPinned = windowConfiguration?.observe(\.isPinned) { [weak self] _, change in
            if let oldValue = change.oldValue, !oldValue {
                self?.handlePinnedStateChange(false)
            } else {
                self?.handlePinnedStateChange(true)
            }
        }
    }
    
    private func setupThemeObserver() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: .statusItemThemeChanged,
            object: nil
        )
    }
    
    @objc private func handleStatusItemButtonAction(_ sender: Any) {
        isStatusItemWindowVisible = !isStatusItemWindowVisible
        if isStatusItemWindowVisible {
            dismissStatusItemWindow()
        } else {
            showStatusItemWindow()
        }
    }
    
    private func cleanup() {
        observerStatusItemFrame?.invalidate()
        observerisPinned?.invalidate()
        disableDragEventMonitor()
        NotificationCenter.default.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    // MARK: - 拖拽检测相关方法
    
    private func handleDragDetectionChange() {
        if proximityDragDetectionEnabled && !(windowConfiguration?.isPinned ?? false) {
            configureProximityDragCollisionArea()
            enableDragEventMonitor()
        } else {
            disableDragEventMonitor()
        }
    }
    
    private func configureProximityDragCollisionArea() {
        guard let statusItemFrame = statusItem?.button?.window?.frame else { return }
        
        let expandedFrame = NSRect(
            x: statusItemFrame.minX - proximityDragZoneDistance,
            y: statusItemFrame.minY - proximityDragZoneDistance,
            width: statusItemFrame.width + (proximityDragZoneDistance * 2),
            height: statusItemFrame.height + (proximityDragZoneDistance * 2)
        )
        
        proximityDragCollisionArea = NSBezierPath(rect: expandedFrame)
    }
    
    private func enableDragEventMonitor() {
        guard globalDragEventMonitor == nil else { return }
        
        globalDragEventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: .leftMouseDragged
        ) { [weak self] event in
            self?.handleDragEvent(event)
        }
    }
    
    private func handleDragEvent(_ event: NSEvent) {
        let location = event.locationInWindow
        guard let collisionArea = proximityDragCollisionArea else { return }
        
        if collisionArea.contains(location) {
            handleDragEntered(at: location)
        } else {
            handleDragExited(at: location)
        }
    }
    
    private func handleDragEntered(at location: NSPoint) {
        let currentChangeCount = NSPasteboard(name: .drag).changeCount
        guard pbChangeCount != currentChangeCount else { return }
        
        if !proximityDragCollisionHandled {
            proximityDragDetectionHandler?(self, location, .entered)
            proximityDragCollisionHandled = true
            pbChangeCount = currentChangeCount
        }
    }
    
    private func handleDragExited(at location: NSPoint) {
        if proximityDragCollisionHandled {
            proximityDragDetectionHandler?(self, location, .exited)
            proximityDragCollisionHandled = false
            pbChangeCount -= 1
        }
    }
    
    private func disableDragEventMonitor() {
        if let monitor = globalDragEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalDragEventMonitor = nil
        }
    }
    
    // MARK: - 通知处理
    
    @objc private func handleThemeChanged() {
        NotificationCenter.default.post(name: .systemInterfaceThemeChanged, object: nil)
    }
    
    private func handlePinnedStateChange(_ isPinned: Bool) {
        dismissStatusItemWindow()
        if !isPinned && proximityDragDetectionEnabled {
            enableDragEventMonitor()
        }
    }
    
    // MARK: - 公开方法
    
    /// 显示状态栏窗口
    public func showStatusItemWindow() {
        statusItemWindowController?.showStatusItemWindow()
    }
    
    /// 关闭状态栏窗口
    public func dismissStatusItemWindow() {
        statusItemWindowController?.dismissStatusItemWindow()
    }
    
    /// 获取状态栏项的frame
    public func getStatusItemFrame() -> NSRect? {
        return statusItem?.button?.window?.frame
    }
}

public extension TFYStatusItem {
    /// 安全配置状态栏项(不抛出错误)
    @discardableResult
    func configureSafely(with config: StatusItemConfiguration) -> Bool {
        do {
            try configure(with: config)
            return true
        } catch {
            print("配置状态栏项失败: \(error.localizedDescription)")
            return false
        }
    }
}
