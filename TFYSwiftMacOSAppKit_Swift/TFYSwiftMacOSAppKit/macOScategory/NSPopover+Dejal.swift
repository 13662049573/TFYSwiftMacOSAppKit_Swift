//
//  NSPopover+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

private enum TFYPopoverAssociatedKeys {
    static var delegate: UInt8 = 0
}

public extension NSPopover {
    
    /// 创建弹窗
    /// - Parameter controller: 内容视图控制器
    /// - Returns: 创建的弹窗
    static func create(with controller: NSViewController) -> NSPopover {
        let popover = NSPopover()
        popover.appearance = NSAppearance()
        popover.behavior = .transient
        popover.contentViewController = controller
        return popover
    }

    /// 在指定视图中显示弹窗
    /// - Parameters:
    ///   - view: 相对于的视图
    ///   - preferredEdge: 首选边缘
    func show(in view: NSView, preferredEdge: NSRectEdge) {
        if isShown {
            close()
        }
        show(relativeTo: view.bounds, of: view, preferredEdge: preferredEdge)
    }
    
    /// 在指定位置显示弹窗
    /// - Parameters:
    ///   - view: 相对于的视图
    ///   - point: 显示位置
    func show(in view: NSView, at point: NSPoint) {
        if isShown {
            close()
        }
        show(relativeTo: NSRect(origin: point, size: .zero), of: view, preferredEdge: .minY)
    }
    
    /// 设置弹窗内容
    /// - Parameter viewController: 内容视图控制器
    func setContent(_ viewController: NSViewController) {
        self.contentViewController = viewController
    }
    
    /// 设置弹窗内容视图
    /// - Parameter view: 内容视图
    func setContentView(_ view: NSView) {
        let controller = NSViewController()
        controller.view = view
        self.contentViewController = controller
    }
    
    /// 切换弹窗显示状态
    /// - Parameter view: 相对于的视图
    func toggle(in view: NSView) {
        if isShown {
            close()
        } else {
            show(in: view, preferredEdge: .minY)
        }
    }

    /// 切换弹窗显示状态
    /// - Parameters:
    ///   - view: 相对于的视图
    ///   - preferredEdge: 首选边缘
    func toggle(in view: NSView, preferredEdge: NSRectEdge) {
        if isShown {
            close()
        } else {
            show(in: view, preferredEdge: preferredEdge)
        }
    }
    
    /// 创建带标题的弹窗
    /// - Parameters:
    ///   - title: 弹窗标题
    ///   - contentView: 内容视图
    /// - Returns: 创建的弹窗
    static func createWithTitle(_ title: String, contentView: NSView) -> NSPopover {
        let controller = NSViewController()
        controller.title = title
        controller.view = contentView
        return create(with: controller)
    }
    
    /// 创建信息弹窗
    /// - Parameters:
    ///   - message: 消息内容
    ///   - informativeText: 详细信息
    /// - Returns: 创建的信息弹窗
    static func createInfoPopover(message: String, informativeText: String? = nil) -> NSPopover {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 8
        stackView.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let messageLabel = NSTextField(labelWithString: message)
        messageLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        stackView.addArrangedSubview(messageLabel)
        
        if let informativeText = informativeText {
            let infoLabel = NSTextField(labelWithString: informativeText)
            infoLabel.font = NSFont.systemFont(ofSize: 12)
            infoLabel.textColor = .secondaryLabelColor
            stackView.addArrangedSubview(infoLabel)
        }
        
        let popover = createWithTitle("信息", contentView: stackView)
        popover.contentSize = NSSize(width: 300, height: stackView.fittingSize.height)
        
        return popover
    }
    
    /// 创建确认弹窗
    /// - Parameters:
    ///   - message: 消息内容
    ///   - confirmAction: 确认操作
    ///   - cancelAction: 取消操作
    /// - Returns: 创建的确认弹窗
    static func createConfirmPopover(message: String, confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) -> NSPopover {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 12
        stackView.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let messageLabel = NSTextField(labelWithString: message)
        messageLabel.font = NSFont.systemFont(ofSize: 14)
        messageLabel.alignment = .center
        stackView.addArrangedSubview(messageLabel)
        
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        
        let cancelButton = NSButton(title: "取消", target: nil, action: nil)
        cancelButton.bezelStyle = .rounded
        cancelButton.onAction { _ in
            cancelAction()
        }
        
        let confirmButton = NSButton(title: "确认", target: nil, action: nil)
        confirmButton.bezelStyle = .rounded
        confirmButton.keyEquivalent = "\r"
        confirmButton.onAction { _ in
            confirmAction()
        }
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(confirmButton)
        stackView.addArrangedSubview(buttonStack)
        
        let popover = createWithTitle("确认", contentView: stackView)
        popover.contentSize = NSSize(width: 250, height: stackView.fittingSize.height)
        
        return popover
    }
    
    /// 创建输入弹窗
    /// - Parameters:
    ///   - message: 消息内容
    ///   - placeholder: 输入框占位符
    ///   - confirmAction: 确认操作
    ///   - cancelAction: 取消操作
    /// - Returns: 创建的输入弹窗
    static func createInputPopover(message: String, placeholder: String = "", confirmAction: @escaping (String) -> Void, cancelAction: @escaping () -> Void) -> NSPopover {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 12
        stackView.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let messageLabel = NSTextField(labelWithString: message)
        messageLabel.font = NSFont.systemFont(ofSize: 14)
        stackView.addArrangedSubview(messageLabel)
        
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.font = NSFont.systemFont(ofSize: 13)
        stackView.addArrangedSubview(textField)
        
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        
        let cancelButton = NSButton(title: "取消", target: nil, action: nil)
        cancelButton.bezelStyle = .rounded
        cancelButton.onAction { _ in
            cancelAction()
        }
        
        let confirmButton = NSButton(title: "确认", target: nil, action: nil)
        confirmButton.bezelStyle = .rounded
        confirmButton.keyEquivalent = "\r"
        confirmButton.onAction { _ in
            confirmAction(textField.stringValue)
        }
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(confirmButton)
        stackView.addArrangedSubview(buttonStack)
        
        let popover = createWithTitle("输入", contentView: stackView)
        popover.contentSize = NSSize(width: 280, height: stackView.fittingSize.height)
        
        return popover
    }

    /// 设置关闭回调
    /// - Parameter handler: 关闭回调
    func setCloseHandler(_ handler: @escaping () -> Void) {
        let delegate = PopoverDelegate(closeHandler: handler)
        self.delegate = delegate
        objc_setAssociatedObject(self, &TFYPopoverAssociatedKeys.delegate, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// 关闭当前弹窗（如果已显示）
    func closeIfNeeded() {
        guard isShown else { return }
        close()
    }

    /// 根据内容自动调整大小
    /// - Parameters:
    ///   - maxWidth: 最大宽度
    ///   - minWidth: 最小宽度
    func sizeToFitContent(maxWidth: CGFloat = 360, minWidth: CGFloat = 160) {
        guard let view = contentViewController?.view else { return }
        let fitting = view.fittingSize
        contentSize = NSSize(
            width: min(max(fitting.width, minWidth), maxWidth),
            height: fitting.height
        )
    }

    /// 使用视图直接创建弹窗
    /// - Parameters:
    ///   - view: 内容视图
    ///   - behavior: 弹窗行为
    /// - Returns: 创建的弹窗
    static func create(with view: NSView, behavior: NSPopover.Behavior = .transient) -> NSPopover {
        let popover = createWithTitle("", contentView: view)
        popover.behavior = behavior
        return popover
    }
}

// MARK: - 弹窗代理类
private class PopoverDelegate: NSObject, NSPopoverDelegate {
    private let closeHandler: () -> Void
    
    init(closeHandler: @escaping () -> Void) {
        self.closeHandler = closeHandler
        super.init()
    }
    
    func popoverDidClose(_ notification: Notification) {
        closeHandler()
    }
}

// MARK: - NSButton 扩展（用于支持闭包回调）
