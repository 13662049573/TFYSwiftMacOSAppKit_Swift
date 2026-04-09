//
//  StatusItemDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

final class StatusItemDemoViewController: NSViewController {
    
    private let statusItem = TFYStatusItem.shared
    
    private var iconPopUp: NSPopUpButton!
    private var transitionPopUp: NSPopUpButton!
    private var themePopUp: NSPopUpButton!
    private var dragSwitch: NSButton!
    private var pinnedSwitch: NSButton!
    private var statusTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatusItemDemo()
    }
    
    private func setupStatusItemDemo() {
        let scrollView = NSScrollView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .hasVerticalScroller(true)
            .autohidesScrollers(true)
            .build
        view.addSubview(scrollView)
        
        let containerView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scrollView.chain.documentView(containerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        var yOffset: CGFloat = 20
        
        let titleLabel = makeTitleLabel("状态栏项功能演示")
        titleLabel.frame.origin = NSPoint(x: 20, y: yOffset)
        containerView.addSubview(titleLabel)
        yOffset += 38
        
        let subtitleLabel = makeBodyLabel("这里会真实创建和销毁 NSStatusItem，支持图片模式、自定义视图模式、弹窗窗口、拖拽检测以及 pinned 行为验证。", width: 760, height: 34)
        subtitleLabel.frame.origin = NSPoint(x: 20, y: yOffset)
        containerView.addSubview(subtitleLabel)
        yOffset += 56
        
        yOffset = setupConfigurationSection(in: containerView, yOffset: yOffset)
        yOffset = setupActionSection(in: containerView, yOffset: yOffset)
        yOffset = setupStatusSection(in: containerView, yOffset: yOffset)
        
        containerView.frame.size.height = yOffset + 24
        appendStatus("状态栏页已加载，可按需创建状态项；默认不会在应用启动时自动占用系统状态栏。")
    }
    
    private func setupConfigurationSection(in containerView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("配置选项")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        containerView.addSubview(sectionLabel)
        currentOffset += 34
        
        let iconLabel = makeBodyLabel("展示模式", width: 70, height: 18)
        iconLabel.frame.origin = NSPoint(x: 20, y: currentOffset + 8)
        containerView.addSubview(iconLabel)
        
        iconPopUp = NSPopUpButton().chain
            .frame(NSRect(x: 92, y: currentOffset + 4, width: 140, height: 26))
            .addItems(["星形图标", "铃铛图标", "纸飞机图标", "火焰图标", "自定义条"])
            .build
        containerView.addSubview(iconPopUp)
        
        let transitionLabel = makeBodyLabel("过渡动画", width: 70, height: 18)
        transitionLabel.frame.origin = NSPoint(x: 260, y: currentOffset + 8)
        containerView.addSubview(transitionLabel)
        
        transitionPopUp = NSPopUpButton().chain
            .frame(NSRect(x: 332, y: currentOffset + 4, width: 130, height: 26))
            .addItems(["淡入", "滑动 + 淡入", "无动画"])
            .build
        containerView.addSubview(transitionPopUp)
        
        let themeLabel = makeBodyLabel("背景主题", width: 70, height: 18)
        themeLabel.frame.origin = NSPoint(x: 490, y: currentOffset + 8)
        containerView.addSubview(themeLabel)
        
        themePopUp = NSPopUpButton().chain
            .frame(NSRect(x: 562, y: currentOffset + 4, width: 140, height: 26))
            .addItems(["系统窗口色", "深色面板", "品牌蓝", "琥珀色"])
            .build
        containerView.addSubview(themePopUp)
        
        currentOffset += 42
        
        dragSwitch = NSButton().chain
            .frame(NSRect(x: 20, y: currentOffset + 4, width: 140, height: 20))
            .setButtonType(.switch)
            .title("启用拖拽检测")
            .state(.on)
            .build
        containerView.addSubview(dragSwitch)
        
        pinnedSwitch = NSButton().chain
            .frame(NSRect(x: 180, y: currentOffset + 4, width: 140, height: 20))
            .setButtonType(.switch)
            .title("窗口保持 pinned")
            .state(.off)
            .build
        containerView.addSubview(pinnedSwitch)
        
        let tipLabel = makeBodyLabel("选择“自定义条”时会改为 customView 模式，其余项走 image 模式。修改配置后可点“创建 / 重建”立即重配。", width: 430, height: 32)
        tipLabel.frame.origin = NSPoint(x: 340, y: currentOffset)
        containerView.addSubview(tipLabel)
        
        return currentOffset + 54
    }
    
    private func setupActionSection(in containerView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("操作按钮")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        containerView.addSubview(sectionLabel)
        currentOffset += 34
        
        let buttons: [(String, Selector, CGFloat, CGFloat)] = [
            ("创建 / 重建", #selector(createOrRebuildStatusItem), 20, currentOffset),
            ("移除状态项", #selector(removeStatusItem), 140, currentOffset),
            ("切换启用", #selector(toggleStatusItemEnabled), 260, currentOffset),
            ("切换置灰外观", #selector(toggleDisabledAppearance), 380, currentOffset),
            ("显示窗口", #selector(showStatusItemWindow), 530, currentOffset),
            ("隐藏窗口", #selector(hideStatusItemWindow), 640, currentOffset),
            ("切换窗口", #selector(toggleStatusItemWindow), 20, currentOffset + 44)
        ]
        
        for (title, action, x, y) in buttons {
            let button = makeActionButton(title: title, frame: NSRect(x: x, y: y, width: title == "切换置灰外观" ? 130 : 100, height: 32), action: action)
            containerView.addSubview(button)
        }
        
        let noteLabel = makeBodyLabel("状态栏按钮行为来自 TFYStatusItem，窗口展示来自 TFYStatusItemWindowController。拖拽检测会在非 pinned 状态下生效。", width: 760, height: 22)
        noteLabel.frame.origin = NSPoint(x: 20, y: currentOffset + 84)
        containerView.addSubview(noteLabel)
        
        return currentOffset + 116
    }
    
    private func setupStatusSection(in containerView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("运行状态")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        containerView.addSubview(sectionLabel)
        currentOffset += 30
        
        let clearButton = makeActionButton(title: "清空日志", frame: NSRect(x: 680, y: currentOffset - 4, width: 90, height: 28), action: #selector(clearStatusLog))
        containerView.addSubview(clearButton)
        
        statusTextView = NSTextView().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 750, height: 200))
            .editable(false)
            .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .backgroundColor(.textBackgroundColor)
            .textColor(.labelColor)
            .string("")
            .build
        containerView.addSubview(statusTextView)
        
        return currentOffset + 220
    }
    
    private func rebuildStatusItem() {
        statusItem.reset()
        
        let configuration = TFYStatusItem.StatusItemConfiguration(
            image: selectedStatusItemImage(),
            customView: selectedCustomView(),
            viewController: makeContentViewController(),
            windowConfiguration: makeWindowConfiguration()
        )
        
        do {
            try statusItem.configure(with: configuration)
            statusItem.proximityDragDetectionEnabled = dragSwitch.state == .on
            statusItem.proximityDragDetectionHandler = { [weak self] _, point, status in
                let statusText = status == .entered ? "进入" : "离开"
                self?.appendStatus("拖拽检测：\(statusText) 状态栏区域，坐标 \(Int(point.x)), \(Int(point.y))")
            }
            appendStatus("状态栏项已创建：模式 \(selectedPresentationModeDescription())，过渡 \(transitionPopUp.titleOfSelectedItem ?? "-")，主题 \(themePopUp.titleOfSelectedItem ?? "-")")
        } catch {
            appendStatus("状态栏项创建失败：\(error.localizedDescription)")
        }
    }
    
    private func makeWindowConfiguration() -> TFYStatusItemWindowConfiguration {
        let configuration = TFYStatusItemWindowConfiguration.defaultConfiguration()
        configuration.isPinned = pinnedSwitch.state == .on
        configuration.toolTip = "TFYSwiftMacOSAppKit Demo"
        
        switch transitionPopUp.indexOfSelectedItem {
        case 0:
            configuration.setPresentationTransition(.fade)
        case 1:
            configuration.setPresentationTransition(.slideAndFade)
        default:
            configuration.setPresentationTransition(.none)
        }
        
        switch themePopUp.indexOfSelectedItem {
        case 1:
            configuration.backgroundColor = NSColor(calibratedWhite: 0.16, alpha: 1)
        case 2:
            configuration.backgroundColor = NSColor(calibratedRed: 0.19, green: 0.38, blue: 0.86, alpha: 1)
        case 3:
            configuration.backgroundColor = NSColor(calibratedRed: 0.94, green: 0.68, blue: 0.16, alpha: 1)
        default:
            configuration.backgroundColor = .windowBackgroundColor
        }
        
        return configuration
    }
    
    private func selectedStatusItemImage() -> NSImage? {
        guard selectedCustomView() == nil else { return nil }
        
        let symbolName: String
        switch iconPopUp.indexOfSelectedItem {
        case 1:
            symbolName = "bell.fill"
        case 2:
            symbolName = "paperplane.fill"
        case 3:
            symbolName = "flame.fill"
        default:
            symbolName = "star.fill"
        }
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
    }
    
    private func selectedCustomView() -> NSView? {
        guard iconPopUp.indexOfSelectedItem == 4 else { return nil }
        
        let badgeView = NSView().chain
            .frame(NSRect(x: 0, y: 0, width: 42, height: 22))
            .wantsLayer(true)
            .backgroundColor(.systemOrange)
            .cornerRadius(11)
            .build
        
        let badgeLabel = NSTextField(labelWithString: "TFY").chain
            .font(.systemFont(ofSize: 11, weight: .bold))
            .textColor(.white)
            .alignment(.center)
            .frame(badgeView.bounds)
            .build
        badgeView.addSubview(badgeLabel)
        return badgeView
    }
    
    private func makeContentViewController() -> NSViewController {
        let viewController = NSViewController()
        viewController.preferredContentSize = NSSize(width: 260, height: 180)
        viewController.view = NSView().chain
            .frame(NSRect(x: 0, y: 0, width: 260, height: 180))
            .wantsLayer(true)
            .backgroundColor(makeWindowConfiguration().backgroundColor)
            .build
        
        let titleLabel = NSTextField(labelWithString: "TFYStatusItem Demo").chain
            .font(.boldSystemFont(ofSize: 17))
            .textColor(themePopUp.indexOfSelectedItem == 1 ? .white : .labelColor)
            .frame(NSRect(x: 20, y: 132, width: 220, height: 24))
            .build
        viewController.view.addSubview(titleLabel)
        
        let description = NSTextField(labelWithString: "模式：\(selectedPresentationModeDescription())\n拖拽检测：\(dragSwitch.state == .on ? "开启" : "关闭")\nPinned：\(pinnedSwitch.state == .on ? "开启" : "关闭")").chain
            .font(.systemFont(ofSize: 12))
            .textColor(themePopUp.indexOfSelectedItem == 1 ? .white.withAlphaComponent(0.88) : .secondaryLabelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .frame(NSRect(x: 20, y: 74, width: 220, height: 52))
            .build
        viewController.view.addSubview(description)
        
        let closeButton = makeActionButton(title: "关闭窗口", frame: NSRect(x: 84, y: 24, width: 90, height: 30), action: #selector(hideStatusItemWindow))
        closeButton.bezelStyle = .rounded
        viewController.view.addSubview(closeButton)
        
        return viewController
    }
    
    private func selectedPresentationModeDescription() -> String {
        iconPopUp.indexOfSelectedItem == 4 ? "自定义视图" : "系统图标"
    }
    
    private func ensureStatusItemReady() -> Bool {
        guard statusItem.presentationMode != .undefined else {
            appendStatus("请先创建状态栏项")
            return false
        }
        return true
    }
    
    private func appendStatus(_ message: String) {
        let current = statusTextView?.string ?? ""
        statusTextView?.string = current + "• " + message + "\n"
        statusTextView?.scrollToEndOfDocument(nil)
    }
    
    private func makeTitleLabel(_ text: String) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.boldSystemFont(ofSize: 22))
            .textColor(.labelColor)
            .frame(NSRect(x: 0, y: 0, width: 360, height: 28))
            .build
    }
    
    private func makeSectionLabel(_ text: String) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.systemFont(ofSize: 16, weight: .semibold))
            .textColor(.labelColor)
            .frame(NSRect(x: 0, y: 0, width: 320, height: 22))
            .build
    }
    
    private func makeBodyLabel(_ text: String, width: CGFloat, height: CGFloat) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .frame(NSRect(x: 0, y: 0, width: width, height: height))
            .build
    }
    
    private func makeActionButton(title: String, frame: NSRect, action: Selector) -> NSButton {
        NSButton().chain
            .frame(frame)
            .title(title)
            .font(.systemFont(ofSize: 12, weight: .medium))
            .bezelStyle(.rounded)
            .addTarget(self, action: action)
            .build
    }
    
    @objc private func createOrRebuildStatusItem() {
        rebuildStatusItem()
    }
    
    @objc private func removeStatusItem() {
        statusItem.reset()
        appendStatus("状态栏项已移除")
    }
    
    @objc private func toggleStatusItemEnabled() {
        guard ensureStatusItemReady() else { return }
        statusItem.enabled.toggle()
        appendStatus("状态栏项启用状态：\(statusItem.enabled ? "启用" : "禁用")")
    }
    
    @objc private func toggleDisabledAppearance() {
        guard ensureStatusItemReady() else { return }
        statusItem.appearsDisabled.toggle()
        appendStatus("状态栏按钮外观：\(statusItem.appearsDisabled ? "置灰" : "正常")")
    }
    
    @objc private func showStatusItemWindow() {
        guard ensureStatusItemReady() else { return }
        statusItem.showStatusItemWindow()
        appendStatus("状态栏窗口已显示")
    }
    
    @objc private func hideStatusItemWindow() {
        guard ensureStatusItemReady() else { return }
        statusItem.dismissStatusItemWindow()
        appendStatus("状态栏窗口已隐藏")
    }
    
    @objc private func toggleStatusItemWindow() {
        guard ensureStatusItemReady() else { return }
        if statusItem.isStatusItemWindowVisible {
            statusItem.dismissStatusItemWindow()
            appendStatus("状态栏窗口已切换为隐藏")
        } else {
            statusItem.showStatusItemWindow()
            appendStatus("状态栏窗口已切换为显示")
        }
    }
    
    @objc private func clearStatusLog() {
        statusTextView.string = ""
    }
}
