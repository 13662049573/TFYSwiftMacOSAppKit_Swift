//
//  StatusItemDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class StatusItemDemoViewController: NSViewController {
    
    private var statusItem: TFYStatusItem?
    private var statusItemWindowController: TFYStatusItemWindowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatusItemDemo()
    }
    
    private func setupStatusItemDemo() {
        // 创建主容器视图
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 创建标题
        let titleLabel = NSTextField()
        titleLabel.chain
            .text("状态栏项功能演示")
            .font(.boldSystemFont(ofSize: 20))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 20, width: 300, height: 30))
        
        containerView.addSubview(titleLabel)
        
        // 创建状态栏项控制区域
        createStatusItemControlSection(in: containerView)
        
        // 创建状态栏项配置区域
        createStatusItemConfigSection(in: containerView)
        
        // 创建状态栏项窗口区域
        createStatusItemWindowSection(in: containerView)
    }
    
    private func createStatusItemControlSection(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.chain
            .text("状态栏项控制")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 70, width: 200, height: 20))
        
        containerView.addSubview(sectionLabel)
        
        // 创建状态栏项按钮
        let createButton = NSButton()
        createButton.chain
            .frame(NSRect(x: 20, y: 100, width: 120, height: 30))
            .title("创建状态栏项")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(createStatusItem))
            
        containerView.addSubview(createButton)
        
        // 移除状态栏项按钮
        let removeButton = NSButton()
        removeButton.chain
            .frame(NSRect(x: 160, y: 100, width: 120, height: 30))
            .title("移除状态栏项")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(removeStatusItem))
            
        
        containerView.addSubview(removeButton)
        
        // 启用/禁用状态栏项按钮
        let toggleButton = NSButton()
        toggleButton.chain
            .frame(NSRect(x: 300, y: 100, width: 120, height: 30))
            .title("切换启用状态")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(toggleStatusItem))
            
        
        containerView.addSubview(toggleButton)
        
        // 显示/隐藏状态栏项按钮
        let showHideButton = NSButton()
        showHideButton.chain
            .frame(NSRect(x: 440, y: 100, width: 120, height: 30))
            .title("显示/隐藏")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(showHideStatusItem))
           
        
        containerView.addSubview(showHideButton)
    }
    
    private func createStatusItemConfigSection(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.chain
            .text("状态栏项配置")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 150, width: 200, height: 20))
        
        containerView.addSubview(sectionLabel)
        
        // 图标选择
        let iconLabel = NSTextField()
        iconLabel.chain
            .text("图标:")
            .font(.systemFont(ofSize: 12))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 180, width: 50, height: 20))
        
        containerView.addSubview(iconLabel)
        
        let iconPopUp = NSPopUpButton()
        iconPopUp.chain
            .frame(NSRect(x: 80, y: 180, width: 120, height: 20))
            .addItems(["星形", "圆形", "方形", "三角形", "自定义"])
            .selectItem(0)
            .addTarget(self, action: #selector(iconChanged))
           
        
        containerView.addSubview(iconPopUp)
        
        // 窗口位置选择
        let positionLabel = NSTextField()
        positionLabel.chain
            .text("窗口位置:")
            .font(.systemFont(ofSize: 12))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 220, y: 180, width: 80, height: 20))
        
        containerView.addSubview(positionLabel)
        
        let positionPopUp = NSPopUpButton()
        positionPopUp.chain
            .frame(NSRect(x: 310, y: 180, width: 120, height: 20))
            .addItems(["自动", "上方", "下方", "左侧", "右侧"])
            .selectItem(0)
            .addTarget(self, action: #selector(positionChanged))
            
        
        containerView.addSubview(positionPopUp)
        
        // 窗口样式选择
        let styleLabel = NSTextField()
        styleLabel.chain
            .text("窗口样式:")
            .font(.systemFont(ofSize: 12))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 450, y: 180, width: 80, height: 20))
        
        containerView.addSubview(styleLabel)
        
        let stylePopUp = NSPopUpButton()
        stylePopUp.chain
            .frame(NSRect(x: 540, y: 180, width: 120, height: 20))
            .addItems(["默认", "圆角", "阴影", "毛玻璃", "自定义"])
            .selectItem(0)
            .addTarget(self, action: #selector(styleChanged))
            
        
        containerView.addSubview(stylePopUp)
        
        // 拖拽检测开关
        let dragLabel = NSTextField()
        dragLabel.chain
            .text("拖拽检测:")
            .font(.systemFont(ofSize: 12))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 210, width: 80, height: 20))
        
        containerView.addSubview(dragLabel)
        
        let dragSwitch = NSButton()
        dragSwitch.chain
            .frame(NSRect(x: 110, y: 210, width: 60, height: 20))
            .setButtonType(.switch)
            .title("")
            .state(.off)
            .addTarget(self, action: #selector(dragDetectionChanged))
           
        
        containerView.addSubview(dragSwitch)
        
        // 自动隐藏开关
        let autoHideLabel = NSTextField()
        autoHideLabel.chain
            .text("自动隐藏:")
            .font(.systemFont(ofSize: 12))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 200, y: 210, width: 80, height: 20))
        
        containerView.addSubview(autoHideLabel)
        
        let autoHideSwitch = NSButton()
        autoHideSwitch.chain
            .frame(NSRect(x: 290, y: 210, width: 60, height: 20))
            .setButtonType(.switch)
            .title("")
            .state(.on)
            .addTarget(self, action: #selector(autoHideChanged))
           
        
        containerView.addSubview(autoHideSwitch)
    }
    
    private func createStatusItemWindowSection(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.chain
            .text("状态栏项窗口")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 250, width: 200, height: 20))
        
        containerView.addSubview(sectionLabel)
        
        // 显示窗口按钮
        let showWindowButton = NSButton()
        showWindowButton.chain
            .frame(NSRect(x: 20, y: 280, width: 120, height: 30))
            .title("显示窗口")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(showStatusItemWindow))
           
        
        containerView.addSubview(showWindowButton)
        
        // 隐藏窗口按钮
        let hideWindowButton = NSButton()
        hideWindowButton.chain
            .frame(NSRect(x: 160, y: 280, width: 120, height: 30))
            .title("隐藏窗口")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(hideStatusItemWindow))
            
        
        containerView.addSubview(hideWindowButton)
        
        // 切换窗口按钮
        let toggleWindowButton = NSButton()
        toggleWindowButton.chain
            .frame(NSRect(x: 300, y: 280, width: 120, height: 30))
            .title("切换窗口")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(toggleStatusItemWindow))
           
        
        containerView.addSubview(toggleWindowButton)
        
        // 窗口状态显示
        let statusLabel = NSTextField()
        statusLabel.chain
            .frame(NSRect(x: 20, y: 320, width: 400, height: 60))
            .text("状态栏项状态:\n- 未创建\n- 窗口未显示")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .alignment(.left)
        
        containerView.addSubview(statusLabel)
        
        // 使用说明
        let instructionLabel = NSTextField()
        instructionLabel.chain
            .frame(NSRect(x: 20, y: 400, width: 500, height: 80))
            .text("使用说明:\n1. 点击'创建状态栏项'在状态栏显示图标\n2. 配置图标、位置、样式等选项\n3. 启用拖拽检测可以监听拖拽事件\n4. 点击状态栏图标可以显示/隐藏窗口\n5. 使用'移除状态栏项'可以完全移除")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .alignment(.left)
        
        containerView.addSubview(instructionLabel)
    }
    
    // MARK: - Status Item Action Methods
    @objc private func createStatusItem() {
        do {
            // 检查是否已经初始化
            if statusItem != nil {
                let alert = NSAlert()
                alert.messageText = "提示"
                alert.informativeText = "状态栏项已经创建，请先移除再重新创建"
                alert.addButton(withTitle: "确定")
                alert.runModal()
                return
            }
            
            // 创建自定义视图控制器
            let contentViewController = createStatusItemContentViewController()
            
            // 确保视图控制器有有效的大小
            if contentViewController.preferredContentSize == .zero {
                contentViewController.preferredContentSize = NSSize(width: 200, height: 150)
            }
            
            // 配置状态栏项
            let config = TFYStatusItem.StatusItemConfiguration(
                image: getSelectedIcon(),
                customView: nil,
                viewController: contentViewController,
                windowConfiguration: createWindowConfiguration()
            )
            
            // 使用共享实例
            statusItem = TFYStatusItem.shared
            
            // 检查是否已经配置过，如果是则重置
            if statusItem?.presentationMode != .undefined {
                statusItem?.reset()
            }
            
            try statusItem?.configure(with: config)
            
            // 设置拖拽检测
            statusItem?.proximityDragDetectionEnabled = true
            statusItem?.proximityDragDetectionHandler = { [weak self] statusItem, point, status in
                self?.handleDragDetection(statusItem: statusItem, point: point, status: status)
            }
            
            // 更新状态显示
            updateStatusDisplay("状态栏项创建成功")
            print("状态栏项创建成功")
            
        } catch TFYStatusItemError.alreadyInitialized {
            let alert = NSAlert()
            alert.messageText = "错误"
            alert.informativeText = "状态栏项已经初始化，请先移除再重新创建"
            alert.addButton(withTitle: "确定")
            alert.runModal()
        } catch TFYStatusItemError.invalidContentSize {
            let alert = NSAlert()
            alert.messageText = "错误"
            alert.informativeText = "内容视图大小无效，请检查视图控制器设置"
            alert.addButton(withTitle: "确定")
            alert.runModal()
        } catch {
            let alert = NSAlert()
            alert.messageText = "错误"
            alert.informativeText = "创建状态栏项失败: \(error.localizedDescription)"
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }
    
    @objc private func removeStatusItem() {
        statusItem = nil
        statusItemWindowController = nil
        updateStatusDisplay("状态栏项已移除")
        print("状态栏项已移除")
    }
    
    @objc private func toggleStatusItem() {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        let isEnabled = statusItem.enabled
        statusItem.enabled = !isEnabled
        updateStatusDisplay("状态栏项启用状态: \(!isEnabled ? "启用" : "禁用")")
        print("状态栏项启用状态: \(!isEnabled ? "启用" : "禁用")")
    }
    
    @objc private func showHideStatusItem() {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        let isVisible = !statusItem.appearsDisabled
        statusItem.appearsDisabled = isVisible
        updateStatusDisplay("状态栏项显示状态: \(isVisible ? "隐藏" : "显示")")
        print("状态栏项显示状态: \(isVisible ? "隐藏" : "显示")")
    }
    
    @objc private func showStatusItemWindow() {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        statusItem.showStatusItemWindow()
        updateStatusDisplay("状态栏项窗口已显示")
        print("状态栏项窗口已显示")
    }
    
    @objc private func hideStatusItemWindow() {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        statusItem.dismissStatusItemWindow()
        updateStatusDisplay("状态栏项窗口已隐藏")
        print("状态栏项窗口已隐藏")
    }
    
    @objc private func toggleStatusItemWindow() {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        // 这里需要根据实际状态来判断
        statusItem.showStatusItemWindow()
        updateStatusDisplay("状态栏项窗口已切换")
        print("状态栏项窗口已切换")
    }
    
    // MARK: - Configuration Action Methods
    @objc private func iconChanged(_ sender: NSPopUpButton) {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        let iconName = sender.titleOfSelectedItem ?? ""
        updateStatusDisplay("图标已更改为: \(iconName)")
        print("图标已更改为: \(iconName)")
    }
    
    @objc private func positionChanged(_ sender: NSPopUpButton) {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        let position = sender.titleOfSelectedItem ?? ""
        updateStatusDisplay("窗口位置已更改为: \(position)")
        print("窗口位置已更改为: \(position)")
    }
    
    @objc private func styleChanged(_ sender: NSPopUpButton) {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        let style = sender.titleOfSelectedItem ?? ""
        updateStatusDisplay("窗口样式已更改为: \(style)")
        print("窗口样式已更改为: \(style)")
    }
    
    @objc private func dragDetectionChanged(_ sender: NSButton) {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        let enabled = sender.state == .on
        statusItem.proximityDragDetectionEnabled = enabled
        updateStatusDisplay("拖拽检测: \(enabled ? "启用" : "禁用")")
        print("拖拽检测: \(enabled ? "启用" : "禁用")")
    }
    
    @objc private func autoHideChanged(_ sender: NSButton) {
        guard let statusItem = statusItem else {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "请先创建状态栏项"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        let enabled = sender.state == .on
        updateStatusDisplay("自动隐藏: \(enabled ? "启用" : "禁用")")
        print("自动隐藏: \(enabled ? "启用" : "禁用")")
    }
    
    // MARK: - Helper Methods
    private func getSelectedIcon() -> NSImage {
        // 这里可以根据选择返回不同的图标
        return NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil) ?? NSImage()
    }
    
    private func createWindowConfiguration() -> TFYStatusItemWindowConfiguration {
        let config = TFYStatusItemWindowConfiguration.defaultConfiguration()
        config.isPinned = false
        return config
    }
    
    private func createStatusItemContentViewController() -> NSViewController {
        let viewController = NSViewController()
        viewController.view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 150))
        viewController.view.wantsLayer = true
        viewController.view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        // 添加一些内容到窗口
        let titleLabel = NSTextField()
        titleLabel.chain
            .text("状态栏项窗口")
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 120, width: 160, height: 20))
        
        viewController.view.addSubview(titleLabel)
        
        let infoLabel = NSTextField()
        infoLabel.chain
            .text("这是一个状态栏项的弹出窗口\n可以包含任何内容")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 80, width: 160, height: 40))
            .alignment(.center)
        
        viewController.view.addSubview(infoLabel)
        
        let closeButton = NSButton()
        closeButton.chain
            .frame(NSRect(x: 70, y: 20, width: 60, height: 30))
            .title("关闭")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(closeStatusItemWindow))
            
        
        viewController.view.addSubview(closeButton)
        
        return viewController
    }
    
    @objc private func closeStatusItemWindow() {
        statusItemWindowController?.close()
    }
    
    private func handleDragDetection(statusItem: TFYStatusItem, point: NSPoint, status: TFYStatusItemProximityDragStatus) {
        switch status {
        case .entered:
            print("拖拽进入状态栏项区域")
        case .exited:
            print("拖拽离开状态栏项区域")
        }
    }
    
    private func updateStatusDisplay(_ message: String) {
        // 查找状态标签并更新
        for subview in view.subviews {
            for subSubview in subview.subviews {
                if let statusLabel = subSubview as? NSTextField,
                   statusLabel.stringValue.contains("状态栏项状态") {
                    statusLabel.stringValue = "状态栏项状态:\n- \(message)"
                    return
                }
            }
        }
    }
} 
