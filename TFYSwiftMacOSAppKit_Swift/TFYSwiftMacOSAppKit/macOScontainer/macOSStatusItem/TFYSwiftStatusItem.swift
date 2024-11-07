//
//  TFYSwiftStatusItem.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

private let TFYStatusItemFrameKeyPath:String = "statusItem.button.window.frame"
private let TFYStatusItemWindowConfigurationPinnedPath:String = "windowConfiguration.pinned"

public enum TFYStatusItemPresentationMode : Int, @unchecked Sendable {
    case TFYStatusItemPresentationModeUndefined = 0
    case TFYStatusItemPresentationModeImage = 1
    case TFYStatusItemPresentationModeCustomView = 2
}

public enum TFYStatusItemProximityDragStatus : Int, @unchecked Sendable {
    case TFYProximityDragStatusEntered = 0
    case TFYProximityDragStatusExited = 1
}

public typealias TFYStatusItemDropHandler = ((_ sharedItem:TFYSwiftStatusItem,_ pasteboardType:String,_ droppedObjects:Any?) -> Void)?
public typealias TFYStatusItemProximityDragDetectionHandler = (_ sharedItem:TFYSwiftStatusItem,_ eventLocation:NSPoint,_ proxymityDragStatus:TFYStatusItemProximityDragStatus) -> Void
public typealias TFYStatusItemShouldShowHandler = (_ sharedItem:TFYSwiftStatusItem) -> Void


public class TFYSwiftStatusItem: NSObject {

    static let sharedInstance: TFYSwiftStatusItem = {
        let instance = TFYSwiftStatusItem().initSingleton()
        return instance
    }()

    private override init() {
        let exceptionMessage = "You must NOT init '\(String(describing: type(of: self)))' manually! Use class method 'sharedInstance' instead."
        fatalError(exceptionMessage)
    }
    
    public var statusItem:NSStatusItem?
    public var dropHandler:TFYStatusItemDropHandler? {
        didSet {
            if dropHandler != nil {
                self.configureDropView()
            }
        }
    }
    public var shouldShowHandler:TFYStatusItemShouldShowHandler?
    public var isDarkMode:Bool? {
        set {}
        get {
            let dict = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
            let style:String = dict?["AppleInterfaceStyle"] as! String
            let darkMode:Bool = style.isEmpty && (style ).lowercased() == "dark"
            return darkMode
        }
    }
    public var appearsDisabled:Bool? {
        set {
            if let appearsDisabled = newValue {
                self.statusItem?.button!.appearsDisabled = appearsDisabled
            }
        }
        get {
            return self.statusItem?.button!.appearsDisabled
        }
    }
    public var enabled:Bool? {
        set {
            if let enabled = newValue {
                self.statusItem?.button?.isEnabled = enabled
            }
        }
        get {
            return self.statusItem?.button?.isEnabled
        }
    }
    public var isStatusItemWindowVisible:Bool? {
        get {
            return ((self.statusItemWindowController != nil) ? self.statusItemWindowController?.windowIsOpen : false)
        }
        set {}
    }
    public var proximityDragDetectionEnabled:Bool? {
        didSet {
            if let proximityDraggingDetectionEnabled = proximityDragDetectionEnabled {
                if proximityDraggingDetectionEnabled && !(self.windowConfiguration?.pinned)! {
                    self.configureProximityDragCollisionArea()
                    self.enableDragEventMonitor()
                } else {
                    self.disableDragEventMonitor()
                }
            }
        }
    }
    public var proximityDragZoneDistance:CGFloat? {
        didSet {
            if proximityDragZoneDistance != nil {
                self.configureProximityDragCollisionArea()
            }
        }
    }
    public var proximityDragDetectionHandler:TFYStatusItemProximityDragDetectionHandler?
    public var dropTypes:[NSPasteboard.PasteboardType]?
    public var windowConfiguration:TFYSwiftStatusItemConfiguration? {
        didSet {
            if let configuration = windowConfiguration {
                self.statusItem?.button?.toolTip = configuration.toolTip
            }
        }
    }
    
    private var globalDragEventMonitor:Any?
    private var proximityDragCollisionHandled:Bool?
    private var proximityDragCollisionArea:NSBezierPath?
    private var pbChangeCount:Int?
    private var customViewContainer:TFYSwiftStatusItemContainerView?
    private var customView:NSView?
    private var presentationMode:TFYStatusItemPresentationMode?
    private var dropView:TFYSwiftStatusItemDropView?
    private var statusItemWindowController:TFYSwiftStatusItemWindowController?

    
    private func initSingleton() -> TFYSwiftStatusItem {
        self.globalDragEventMonitor = nil
        self.proximityDragCollisionHandled = nil
        self.pbChangeCount = NSPasteboard.general.changeCount
        self.customViewContainer = nil
        self.statusItem = nil
        self.customView = nil
        self.presentationMode = .TFYStatusItemPresentationModeUndefined
        self.isStatusItemWindowVisible = false
        self.statusItemWindowController = nil
        self.windowConfiguration = TFYSwiftStatusItemConfiguration.defaultConfiguration
        self.appearsDisabled = false
        self.enabled = true
        
        self.dropTypes = [.fileURL]
        self.dropHandler = nil
        self.proximityDragDetectionEnabled = false
        self.proximityDragZoneDistance = 23
        self.proximityDragDetectionHandler = nil
        
        self.addObserver(self, forKeyPath: TFYStatusItemFrameKeyPath, options: .new, context: nil)
        self.addObserver(self, forKeyPath: TFYStatusItemWindowConfigurationPinnedPath, options:[.new,.old,.prior], context: nil)
        
        DistributedNotificationCenter.default().addObserver(forName: themeChangedNotification, object: nil, queue: nil) { note in
            NotificationCenter.default.post(name: TFYSystemInterfaceThemeChangedNotification, object: nil)
        }
        
        return self
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: TFYStatusItemFrameKeyPath)
        self.removeObserver(self, forKeyPath: TFYStatusItemWindowConfigurationPinnedPath)
        
        self.statusItem = nil
        self.customView = nil
        self.statusItemWindowController = nil
        self.windowConfiguration = nil
        self.dropHandler = nil
        self.proximityDragDetectionHandler = nil
        self.proximityDragCollisionArea = nil
        self.customViewContainer = nil
    }
    
    ///为弹出窗口显示共享的' CCNStatusItem '对象和给定的图像和contentViewController。
    public func presentStatusItemWithImage(itemImage:NSImage,contentViewController:NSViewController) {
        self.presentStatusItemWithImage(itemImage: itemImage, contentViewController: contentViewController, dropHandler: nil)
    }
    /// 为弹出窗口显示共享的' CCNStatusItem '对象和给定的图像和contentViewController。
    public func presentStatusItemWithImage(itemImage:NSImage,contentViewController:NSViewController,dropHandler: TFYStatusItemDropHandler) {
        if self.presentationMode != .TFYStatusItemPresentationModeUndefined {
            return
        }
        self.configureWithImage(itemImage: itemImage)
        self.configureProximityDragCollisionArea()
        
        self.dropHandler = dropHandler
        self.presentationMode = .TFYStatusItemPresentationModeImage
        
        let window = TFYSwiftStatusItemWindowController(statusItem: self, contentViewController: contentViewController, windowConfiguration: self.windowConfiguration!)
        self.statusItemWindowController = window
    }
    /// 用给定的自定义视图和弹出窗口的contentViewController显示共享的“CCNStatusItem”对象。
    public func presentStatusItemWithView(itemView:NSView,contentViewController:NSViewController) {
        self.presentStatusItemWithView(itemView: itemView, contentViewController: contentViewController, dropHandler: nil)
    }
    /// 用给定的自定义视图和弹出窗口的contentViewController显示共享的“CCNStatusItem”对象。
    public func presentStatusItemWithView(itemView:NSView,contentViewController:NSViewController,dropHandler: TFYStatusItemDropHandler) {
        if self.presentationMode != .TFYStatusItemPresentationModeUndefined {
            return
        }
        self.configureWithView(itemView: itemView)
        self.configureProximityDragCollisionArea()
        
        self.dropHandler = dropHandler
        self.presentationMode = .TFYStatusItemPresentationModeCustomView
        
        let window = TFYSwiftStatusItemWindowController(statusItem: self, contentViewController: contentViewController, windowConfiguration: self.windowConfiguration!)
        self.statusItemWindowController = window
        
    }
    /// 更新弹窗窗口的contentViewController。
    public func updateContentViewController(contentViewController: NSViewController) {
        self.statusItemWindowController?.updateContenetViewController(contentViewController: contentViewController)
    }
    /// 移除状态项。
    public func removeStatusItem() {
        if self.statusItem != nil {
            NSStatusBar.system.removeStatusItem(self.statusItem!)
            self.statusItem = nil
            self.presentationMode = .TFYStatusItemPresentationModeUndefined
            self.isStatusItemWindowVisible = false
            self.statusItemWindowController = nil
        }
    }
    
    private func configureWithImage(itemImage:NSImage) {
        self.statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        self.statusItem?.isVisible = true
        
        let button:NSStatusBarButton = self.statusItem!.button!
        button.target = self
        button.action = #selector(handleStatusItemButtonAction)
        button.image = itemImage
    }
    
    private func configureWithView(itemView:NSView) {
        self.customView = itemView
        let itemFrame:NSRect = self.customView!.frame
        
        self.customViewContainer = TFYSwiftStatusItemContainerView(frame: itemFrame)
        self.customViewContainer?.autoresizingMask = [.width,.height]
        self.customViewContainer?.target = self
        self.customViewContainer?.action = #selector(handleStatusItemButtonAction)
        self.customViewContainer?.addSubview(self.customView!)
        
        self.statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        self.statusItem?.isVisible = true
        
        let containerBtn:NSStatusBarButton = NSStatusBarButton(frame: itemFrame)
        containerBtn.autoresizingMask = [.width,.height]
        containerBtn.target = self
        containerBtn.action = #selector(handleStatusItemButtonAction)
        containerBtn.addSubview(self.customView!)
        
        let button:NSStatusBarButton = self.statusItem!.button!
        button.frame = itemFrame
        button.addSubview(self.customViewContainer!)
        button.autoresizingMask = [.width,.height]
    }
    
    @objc private func handleStatusItemButtonAction() {
        if self.isStatusItemWindowVisible! {
            self.dismissStatusItemWindow()
        } else if self.shouldShowHandler != nil {
            self.showStatusItemWindow()
        }
    }
    
    private func dismissStatusItemWindow() {
        self.statusItemWindowController?.dismissStatusItemWindow()
    }
    
    private func showStatusItemWindow() {
        self.statusItemWindowController?.showStatusItemWindow()
    }
    
    private func disableDragEventMonitor() {
        NSEvent.removeMonitor(globalDragEventMonitor as Any)
        globalDragEventMonitor = nil
    }
    
    private func configureProximityDragCollisionArea() {
        let statusItemFrame:NSRect = self.statusItem?.button?.window?.frame ?? .zero
        let collisionFrame:NSRect = NSInsetRect(statusItemFrame, -proximityDragZoneDistance!, -proximityDragZoneDistance!)
        self.proximityDragCollisionArea = NSBezierPath(roundedRect: collisionFrame, xRadius: NSWidth(collisionFrame)/2, yRadius: NSHeight(collisionFrame)/2)
        
    }
    
    private func configureDropView() {
        self.dropView?.removeFromSuperview()
        self.dropView = nil
        if self.dropHandler == nil {
            return
        }
        let button:NSStatusBarButton = self.statusItem!.button!
        let buttonWindowFrame:NSRect = button.window!.frame
        let statusItemFrame:NSRect = NSMakeRect(0.0, 0.0, NSWidth(buttonWindowFrame), NSHeight(buttonWindowFrame))
        self.dropView = TFYSwiftStatusItemDropView(frame: statusItemFrame)
        self.dropView?.statusItem = self
        self.dropView?.dropTypes = self.dropTypes!
        self.dropView?.dropHandler = self.dropHandler
        button.addSubview(self.dropView!)
        self.dropView?.autoresizingMask = [.width, .height]
    }
    
    private func enableDragEventMonitor() {
        if (self.globalDragEventMonitor != nil) {
            return
        }
        globalDragEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged, handler: { event in
            let eventLocation:NSPoint = event.locationInWindow
            if self.proximityDragCollisionArea!.contains(eventLocation) {
                let currentChangeCount:Int = NSPasteboard(name: .drag).changeCount
                if self.pbChangeCount == currentChangeCount {
                    return
                }
                if !self.proximityDragCollisionHandled! {
                    if self.proximityDragDetectionHandler != nil {
                        self.proximityDragDetectionHandler!(self,eventLocation,.TFYProximityDragStatusEntered)
                        self.proximityDragCollisionHandled! = true
                        self.pbChangeCount = currentChangeCount
                    }
                }
            } else {
                if self.proximityDragCollisionHandled! {
                    if self.proximityDragDetectionHandler != nil {
                        self.proximityDragDetectionHandler!(self,eventLocation,.TFYProximityDragStatusExited)
                        self.proximityDragCollisionHandled! = false
                        self.pbChangeCount!-=1
                    }
                }
            }
        })
    }
    
    public override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == TFYStatusItemFrameKeyPath {
            TFYSwiftStatusItem.sharedInstance.configureProximityDragCollisionArea()
        } else if keyPath == TFYStatusItemWindowConfigurationPinnedPath {
            let oldKey = change![.oldKey] as? String
            let value = oldKey?.utf16.count == NSControl.StateValue.off.rawValue
            if value {
                TFYSwiftStatusItem.sharedInstance.disableDragEventMonitor()
            } else {
                TFYSwiftStatusItem.sharedInstance.dismissStatusItemWindow()
                if TFYSwiftStatusItem.sharedInstance.proximityDragDetectionEnabled! {
                    TFYSwiftStatusItem.sharedInstance.enableDragEventMonitor()
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
