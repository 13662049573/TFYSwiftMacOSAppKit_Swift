//
//  StatusItemDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa
import Combine

final class StatusItemDemoViewController: NSViewController {
    
    private let statusItem = TFYStatusItem.shared
    
    // MARK: - Configuration Controls
    private var iconPopUp: NSPopUpButton!
    private var transitionPopUp: NSPopUpButton!
    private var themePopUp: NSPopUpButton!
    private var dragSwitch: NSButton!
    private var pinnedSwitch: NSButton!
    private var dragZoneSlider: NSSlider!
    private var dragZoneLabel: NSTextField!
    private var animDurationSlider: NSSlider!
    private var animDurationLabel: NSTextField!
    private var marginSlider: NSSlider!
    private var marginLabel: NSTextField!
    
    // MARK: - State Display
    private var stateGrid: [(String, NSTextField)] = []
    private var statusTextView: NSTextView!
    
    // MARK: - Notification Tracking
    private var notificationTokens: [NSObjectProtocol] = []
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDemo()
        observeNotifications()
    }
    
    // MARK: - Layout
    
    private func setupDemo() {
        let scrollView = NSScrollView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .hasVerticalScroller(true)
            .autohidesScrollers(true)
            .build
        view.addSubview(scrollView)
        
        let content = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scrollView.chain.documentView(content)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        var y: CGFloat = 20
        
        let title = makeTitle("TFYStatusItem 全功能演示")
        title.frame.origin = NSPoint(x: 20, y: y)
        content.addSubview(title)
        y += 36
        
        let subtitle = makeBody(
            "完整展示状态栏项的创建/销毁、图标/自定义视图模式、弹窗窗口控制、过渡动画、背景主题、拖拽检测、Pinned 行为、"
            + "窗口配置参数（间距/动画时长/拖拽区域）、通知事件监听与实时状态面板。",
            width: 760, height: 44
        )
        subtitle.frame.origin = NSPoint(x: 20, y: y)
        content.addSubview(subtitle)
        y += 56
        
        y = setupPresentationSection(in: content, y: y)
        y = setupWindowConfigSection(in: content, y: y)
        y = setupActionsSection(in: content, y: y)
        y = setupStatePanel(in: content, y: y)
        y = setupNotificationSection(in: content, y: y)
        y = setupLogSection(in: content, y: y)
        
        content.frame.size.height = y + 24
        appendLog("状态栏演示页已就绪。点击「创建/重建」在系统状态栏创建项目。")
    }
    
    // MARK: - Section 1: Presentation Mode
    
    private func setupPresentationSection(in container: NSView, y: CGFloat) -> CGFloat {
        var cy = y
        
        let header = makeSection("1. 展示模式与外观")
        header.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(header)
        cy += 30
        
        let desc = makeBody(
            "选择状态栏图标或自定义视图模式。图标模式支持 SF Symbols，自定义视图模式展示一个带圆角的徽章控件。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(desc)
        cy += 28
        
        // Row 1: icon + transition + theme
        let iconLbl = makeBody("图标", width: 36, height: 18)
        iconLbl.frame.origin = NSPoint(x: 20, y: cy + 6)
        container.addSubview(iconLbl)
        
        iconPopUp = NSPopUpButton().chain
            .frame(NSRect(x: 58, y: cy + 2, width: 150, height: 26))
            .addItems(["star.fill 星形", "bell.fill 铃铛", "paperplane.fill 飞机", "flame.fill 火焰",
                        "gearshape.fill 齿轮", "heart.fill 心形", "自定义徽章视图"])
            .build
        container.addSubview(iconPopUp)
        
        let transLbl = makeBody("过渡", width: 36, height: 18)
        transLbl.frame.origin = NSPoint(x: 224, y: cy + 6)
        container.addSubview(transLbl)
        
        transitionPopUp = NSPopUpButton().chain
            .frame(NSRect(x: 262, y: cy + 2, width: 130, height: 26))
            .addItems(["fade 淡入", "slideAndFade 滑入", "none 无动画"])
            .build
        container.addSubview(transitionPopUp)
        
        let themeLbl = makeBody("主题", width: 36, height: 18)
        themeLbl.frame.origin = NSPoint(x: 410, y: cy + 6)
        container.addSubview(themeLbl)
        
        themePopUp = NSPopUpButton().chain
            .frame(NSRect(x: 448, y: cy + 2, width: 150, height: 26))
            .addItems(["系统窗口色", "暗色面板", "品牌蓝", "琥珀橙", "翡翠绿", "玫瑰粉"])
            .build
        container.addSubview(themePopUp)
        
        cy += 38
        
        // Row 2: switches
        dragSwitch = NSButton().chain
            .frame(NSRect(x: 20, y: cy, width: 130, height: 20))
            .setButtonType(.switch)
            .title("启用拖拽检测")
            .state(.on)
            .build
        container.addSubview(dragSwitch)
        
        pinnedSwitch = NSButton().chain
            .frame(NSRect(x: 160, y: cy, width: 130, height: 20))
            .setButtonType(.switch)
            .title("窗口 Pinned")
            .state(.off)
            .build
        container.addSubview(pinnedSwitch)
        
        let hint = makeBody(
            "Pinned 开启时窗口不会因点击外部而自动关闭；拖拽检测可感知文件拖入状态栏区域。选择「自定义徽章视图」进入 customView 模式。",
            width: 430, height: 34
        )
        hint.frame.origin = NSPoint(x: 310, y: cy - 6)
        container.addSubview(hint)
        
        return cy + 40
    }
    
    // MARK: - Section 2: Window Configuration
    
    private func setupWindowConfigSection(in container: NSView, y: CGFloat) -> CGFloat {
        var cy = y
        
        let header = makeSection("2. 窗口配置参数")
        header.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(header)
        cy += 30
        
        let desc = makeBody(
            "TFYStatusItemWindowConfiguration 支持自定义窗口与状态栏的间距、动画时长和拖拽检测区域距离。拖动滑块调整后点击「创建/重建」生效。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(desc)
        cy += 28
        
        // Margin slider
        let marginTitle = makeBody("窗口间距", width: 60, height: 18)
        marginTitle.frame.origin = NSPoint(x: 20, y: cy + 4)
        container.addSubview(marginTitle)
        
        marginSlider = NSSlider().chain
            .frame(NSRect(x: 84, y: cy + 2, width: 140, height: 20))
            .minValue(0)
            .maxValue(20)
            .doubleValue(2)
            .build
        marginSlider.target = self
        marginSlider.action = #selector(sliderChanged(_:))
        container.addSubview(marginSlider)
        
        marginLabel = makeBody("2.0 pt", width: 60, height: 18)
        marginLabel.frame.origin = NSPoint(x: 228, y: cy + 4)
        container.addSubview(marginLabel)
        
        // Animation duration slider
        let animTitle = makeBody("动画时长", width: 60, height: 18)
        animTitle.frame.origin = NSPoint(x: 300, y: cy + 4)
        container.addSubview(animTitle)
        
        animDurationSlider = NSSlider().chain
            .frame(NSRect(x: 364, y: cy + 2, width: 140, height: 20))
            .minValue(0.05)
            .maxValue(1.0)
            .doubleValue(0.1)
            .build
        animDurationSlider.target = self
        animDurationSlider.action = #selector(sliderChanged(_:))
        container.addSubview(animDurationSlider)
        
        animDurationLabel = makeBody("0.10 s", width: 60, height: 18)
        animDurationLabel.frame.origin = NSPoint(x: 508, y: cy + 4)
        container.addSubview(animDurationLabel)
        
        // Drag zone slider
        let dragTitle = makeBody("拖拽区域", width: 60, height: 18)
        dragTitle.frame.origin = NSPoint(x: 580, y: cy + 4)
        container.addSubview(dragTitle)
        
        dragZoneSlider = NSSlider().chain
            .frame(NSRect(x: 644, y: cy + 2, width: 80, height: 20))
            .minValue(10)
            .maxValue(100)
            .doubleValue(23)
            .build
        dragZoneSlider.target = self
        dragZoneSlider.action = #selector(sliderChanged(_:))
        container.addSubview(dragZoneSlider)
        
        dragZoneLabel = makeBody("23 pt", width: 50, height: 18)
        dragZoneLabel.frame.origin = NSPoint(x: 728, y: cy + 4)
        container.addSubview(dragZoneLabel)
        
        return cy + 34
    }
    
    // MARK: - Section 3: Actions
    
    private func setupActionsSection(in container: NSView, y: CGFloat) -> CGFloat {
        var cy = y
        
        let header = makeSection("3. 操作按钮")
        header.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(header)
        cy += 30
        
        let desc = makeBody(
            "生命周期管理：创建/重建/移除状态项。窗口控制：显示/隐藏/切换。外观控制：启用/禁用/置灰。运行时可随时调整。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(desc)
        cy += 28
        
        let row1: [(String, Selector)] = [
            ("创建 / 重建", #selector(actionCreate)),
            ("移除状态项", #selector(actionRemove)),
            ("显示窗口", #selector(actionShow)),
            ("隐藏窗口", #selector(actionHide)),
            ("切换窗口", #selector(actionToggle)),
        ]
        
        let row2: [(String, Selector)] = [
            ("切换启用", #selector(actionToggleEnabled)),
            ("切换置灰", #selector(actionToggleDisabled)),
            ("更换图标", #selector(actionChangeIcon)),
            ("更换背景色", #selector(actionChangeTheme)),
            ("获取 Frame", #selector(actionGetFrame)),
        ]
        
        func layoutRow(_ items: [(String, Selector)], atY: CGFloat) {
            var x: CGFloat = 20
            for (title, action) in items {
                let w: CGFloat = max(CGFloat(title.count) * 14 + 16, 100)
                let btn = makeButton(title, frame: NSRect(x: x, y: atY, width: w, height: 30), action: action)
                container.addSubview(btn)
                x += w + 10
            }
        }
        
        layoutRow(row1, atY: cy)
        cy += 40
        layoutRow(row2, atY: cy)
        
        return cy + 44
    }
    
    // MARK: - Section 4: State Panel
    
    private func setupStatePanel(in container: NSView, y: CGFloat) -> CGFloat {
        var cy = y
        
        let header = makeSection("4. 实时状态面板")
        header.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(header)
        cy += 30
        
        let desc = makeBody("展示 TFYStatusItem 当前所有可读属性，点击「刷新状态」或执行任意操作后自动更新。", width: 580, height: 22)
        desc.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(desc)
        
        let refreshBtn = makeButton("刷新状态", frame: NSRect(x: 620, y: cy - 4, width: 90, height: 28), action: #selector(refreshStatePanel))
        container.addSubview(refreshBtn)
        cy += 28
        
        let stateItems: [String] = [
            "presentationMode",
            "enabled",
            "appearsDisabled",
            "isStatusItemWindowVisible",
            "proximityDragDetectionEnabled",
            "proximityDragZoneDistance",
            "isPinned",
            "statusItemFrame",
        ]
        
        let colWidth: CGFloat = 370
        for (index, key) in stateItems.enumerated() {
            let col = index % 2
            let row = index / 2
            let x = CGFloat(20 + col * Int(colWidth))
            let rowY = cy + CGFloat(row) * 24
            
            let keyLabel = makeBody(key + ":", width: 200, height: 18)
            keyLabel.frame.origin = NSPoint(x: x, y: rowY)
            keyLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
            keyLabel.textColor = .labelColor
            container.addSubview(keyLabel)
            
            let valueLabel = makeBody("—", width: 160, height: 18)
            valueLabel.frame.origin = NSPoint(x: x + 200, y: rowY)
            valueLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            valueLabel.textColor = .systemGreen
            container.addSubview(valueLabel)
            
            stateGrid.append((key, valueLabel))
        }
        
        cy += CGFloat((stateItems.count + 1) / 2) * 24 + 8
        refreshStatePanel()
        return cy
    }
    
    // MARK: - Section 5: Notification Events
    
    private func setupNotificationSection(in container: NSView, y: CGFloat) -> CGFloat {
        var cy = y
        
        let header = makeSection("5. 通知事件 (TFYStatusItemNotifications)")
        header.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(header)
        cy += 30
        
        let names: [(String, String)] = [
            ("statusItemWindowWillShow", "窗口即将显示"),
            ("statusItemWindowDidShow", "窗口已显示"),
            ("statusItemWindowWillDismiss", "窗口即将关闭"),
            ("statusItemWindowDidDismiss", "窗口已关闭"),
            ("systemInterfaceThemeChanged", "系统主题切换"),
        ]
        
        let colW: CGFloat = 370
        for (index, (name, desc)) in names.enumerated() {
            let col = index % 2
            let row = index / 2
            let x = CGFloat(20 + col * Int(colW))
            let rowY = cy + CGFloat(row) * 22
            
            let lbl = makeBody("• \(name) — \(desc)", width: 360, height: 18)
            lbl.frame.origin = NSPoint(x: x, y: rowY)
            lbl.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            container.addSubview(lbl)
        }
        
        cy += CGFloat((names.count + 1) / 2) * 22 + 6
        
        let hint = makeBody("上述通知会在日志区实时打印，便于验证事件触发时序。", width: 500, height: 18)
        hint.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(hint)
        cy += 24
        
        return cy
    }
    
    // MARK: - Section 6: Log
    
    private func setupLogSection(in container: NSView, y: CGFloat) -> CGFloat {
        var cy = y
        
        let header = makeSection("6. 运行日志")
        header.frame.origin = NSPoint(x: 20, y: cy)
        container.addSubview(header)
        
        let clearBtn = makeButton("清空", frame: NSRect(x: 700, y: cy - 2, width: 70, height: 26), action: #selector(clearLog))
        container.addSubview(clearBtn)
        cy += 30
        
        let logScroll = NSScrollView().chain
            .frame(NSRect(x: 20, y: cy, width: 750, height: 200))
            .hasVerticalScroller(true)
            .borderType(.bezelBorder)
            .autohidesScrollers(true)
            .build
        container.addSubview(logScroll)
        
        statusTextView = NSTextView().chain
            .frame(NSRect(x: 0, y: 0, width: 750, height: 200))
            .editable(false)
            .font(.monospacedSystemFont(ofSize: 11, weight: .regular))
            .backgroundColor(.textBackgroundColor)
            .textColor(.labelColor)
            .wraps(true)
            .string("")
            .build
        logScroll.chain.documentView(statusTextView)
        
        return cy + 220
    }
    
    // MARK: - Notification Observation
    
    private func observeNotifications() {
        let names: [(Notification.Name, String)] = [
            (.statusItemWindowWillShow, "WindowWillShow"),
            (.statusItemWindowDidShow, "WindowDidShow"),
            (.statusItemWindowWillDismiss, "WindowWillDismiss"),
            (.statusItemWindowDidDismiss, "WindowDidDismiss"),
            (.systemInterfaceThemeChanged, "SystemThemeChanged"),
        ]
        
        for (name, label) in names {
            let token = NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.appendLog("[通知] \(label)")
                self?.refreshStatePanel()
            }
            notificationTokens.append(token)
        }
    }
    
    // MARK: - Build Configuration
    
    private func buildConfiguration() -> TFYStatusItem.StatusItemConfiguration {
        TFYStatusItem.StatusItemConfiguration(
            image: selectedImage(),
            customView: selectedCustomView(),
            viewController: makePopoverContent(),
            windowConfiguration: makeWindowConfig()
        )
    }
    
    private func makeWindowConfig() -> TFYStatusItemWindowConfiguration {
        let config = TFYStatusItemWindowConfiguration.defaultConfiguration()
        config.isPinned = pinnedSwitch.state == .on
        config.toolTip = "TFYSwiftMacOSAppKit StatusItem Demo"
        config.windowToStatusItemMargin = CGFloat(marginSlider.doubleValue)
        config.animationDuration = animDurationSlider.doubleValue
        
        switch transitionPopUp.indexOfSelectedItem {
        case 0: config.setPresentationTransition(.fade)
        case 1: config.setPresentationTransition(.slideAndFade)
        default: config.setPresentationTransition(.none)
        }
        
        config.backgroundColor = selectedThemeColor()
        return config
    }
    
    private func selectedImage() -> NSImage? {
        guard selectedCustomView() == nil else { return nil }
        let symbols = ["star.fill", "bell.fill", "paperplane.fill", "flame.fill", "gearshape.fill", "heart.fill"]
        let idx = iconPopUp.indexOfSelectedItem
        guard idx < symbols.count else { return nil }
        return NSImage(systemSymbolName: symbols[idx], accessibilityDescription: nil)
    }
    
    private func selectedCustomView() -> NSView? {
        guard iconPopUp.indexOfSelectedItem == 6 else { return nil }
        
        let badge = NSView().chain
            .frame(NSRect(x: 0, y: 0, width: 46, height: 22))
            .wantsLayer(true)
            .backgroundColor(.systemOrange)
            .cornerRadius(11)
            .build
        
        let lbl = NSTextField(labelWithString: "TFY").chain
            .font(.systemFont(ofSize: 11, weight: .bold))
            .textColor(.white)
            .alignment(.center)
            .frame(badge.bounds)
            .build
        badge.addSubview(lbl)
        return badge
    }
    
    private func selectedThemeColor() -> NSColor {
        switch themePopUp.indexOfSelectedItem {
        case 1: return NSColor(calibratedWhite: 0.14, alpha: 1)
        case 2: return NSColor(calibratedRed: 0.19, green: 0.38, blue: 0.86, alpha: 1)
        case 3: return NSColor(calibratedRed: 0.94, green: 0.68, blue: 0.16, alpha: 1)
        case 4: return NSColor(calibratedRed: 0.20, green: 0.72, blue: 0.50, alpha: 1)
        case 5: return NSColor(calibratedRed: 0.92, green: 0.40, blue: 0.52, alpha: 1)
        default: return .windowBackgroundColor
        }
    }
    
    private func isDarkTheme() -> Bool {
        [1].contains(themePopUp.indexOfSelectedItem)
    }
    
    private func modeDescription() -> String {
        iconPopUp.indexOfSelectedItem == 6 ? "customView" : "image"
    }
    
    private func makePopoverContent() -> NSViewController {
        let vc = NSViewController()
        let w: CGFloat = 280
        let h: CGFloat = 220
        vc.preferredContentSize = NSSize(width: w, height: h)
        
        let bg = selectedThemeColor()
        let textColor: NSColor = isDarkTheme() ? .white : .labelColor
        let subColor: NSColor = isDarkTheme() ? .white.withAlphaComponent(0.8) : .secondaryLabelColor
        
        let container = NSView().chain
            .frame(NSRect(x: 0, y: 0, width: w, height: h))
            .wantsLayer(true)
            .backgroundColor(bg)
            .build
        vc.view = container
        
        let icon = NSImageView().chain
            .frame(NSRect(x: 20, y: h - 48, width: 28, height: 28))
            .image(NSImage(systemSymbolName: "menubar.arrow.up.rectangle", accessibilityDescription: nil) ?? NSImage())
            .imageScaling(.scaleProportionallyDown)
            .build
        container.addSubview(icon)
        
        let titleLbl = NSTextField(labelWithString: "TFYStatusItem 弹窗").chain
            .font(.boldSystemFont(ofSize: 16))
            .textColor(textColor)
            .frame(NSRect(x: 54, y: h - 44, width: w - 70, height: 22))
            .build
        container.addSubview(titleLbl)
        
        let info = [
            "模式: \(modeDescription())",
            "过渡: \(transitionPopUp.titleOfSelectedItem ?? "—")",
            "主题: \(themePopUp.titleOfSelectedItem ?? "—")",
            "Pinned: \(pinnedSwitch.state == .on ? "是" : "否")",
            "拖拽检测: \(dragSwitch.state == .on ? "开启" : "关闭")",
            "间距: \(String(format: "%.1f", marginSlider.doubleValue)) pt",
            "动画: \(String(format: "%.2f", animDurationSlider.doubleValue)) s",
        ]
        
        let infoLbl = NSTextField(labelWithString: info.joined(separator: "\n")).chain
            .font(.systemFont(ofSize: 12))
            .textColor(subColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .frame(NSRect(x: 20, y: 50, width: w - 40, height: h - 100))
            .build
        container.addSubview(infoLbl)
        
        let closeBtn = NSButton().chain
            .frame(NSRect(x: (w - 100) / 2, y: 14, width: 100, height: 28))
            .title("关闭弹窗")
            .font(.systemFont(ofSize: 12, weight: .medium))
            .bezelStyle(.rounded)
            .addTarget(self, action: #selector(actionHide))
            .build
        container.addSubview(closeBtn)
        
        return vc
    }
    
    // MARK: - State Panel Refresh
    
    @objc private func refreshStatePanel() {
        let mode: String
        switch statusItem.presentationMode {
        case .undefined: mode = "undefined"
        case .image: mode = "image"
        case .customView: mode = "customView"
        }
        
        let frame = statusItem.getStatusItemFrame()
        let frameStr = frame.map { "(\(Int($0.origin.x)), \(Int($0.origin.y)), \(Int($0.width))×\(Int($0.height)))" } ?? "nil"
        let isPinned = statusItem.windowConfiguration?.isPinned ?? false
        
        let values: [String: String] = [
            "presentationMode": mode,
            "enabled": "\(statusItem.enabled)",
            "appearsDisabled": "\(statusItem.appearsDisabled)",
            "isStatusItemWindowVisible": "\(statusItem.isStatusItemWindowVisible)",
            "proximityDragDetectionEnabled": "\(statusItem.proximityDragDetectionEnabled)",
            "proximityDragZoneDistance": "\(Int(statusItem.proximityDragZoneDistance)) pt",
            "isPinned": "\(isPinned)",
            "statusItemFrame": frameStr,
        ]
        
        for (key, label) in stateGrid {
            label.stringValue = values[key] ?? "—"
            if key == "presentationMode" {
                label.textColor = mode == "undefined" ? .systemRed : .systemGreen
            } else if key == "isStatusItemWindowVisible" {
                label.textColor = statusItem.isStatusItemWindowVisible ? .systemBlue : .secondaryLabelColor
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func actionCreate() {
        statusItem.reset()
        let config = buildConfiguration()
        do {
            try statusItem.configure(with: config)
            statusItem.proximityDragDetectionEnabled = dragSwitch.state == .on
            statusItem.proximityDragZoneDistance = CGFloat(dragZoneSlider.doubleValue)
            statusItem.proximityDragDetectionHandler = { [weak self] _, point, status in
                let s = status == .entered ? "进入" : "离开"
                self?.appendLog("[拖拽] \(s) 状态栏区域 (\(Int(point.x)), \(Int(point.y)))")
            }
            appendLog("状态栏项已创建 — 模式: \(modeDescription()), 过渡: \(transitionPopUp.titleOfSelectedItem ?? ""), 主题: \(themePopUp.titleOfSelectedItem ?? "")")
        } catch {
            appendLog("[错误] 创建失败: \(error.localizedDescription)")
        }
        refreshStatePanel()
    }
    
    @objc private func actionRemove() {
        statusItem.reset()
        appendLog("状态栏项已移除")
        refreshStatePanel()
    }
    
    @objc private func actionShow() {
        guard ensureReady() else { return }
        statusItem.showStatusItemWindow()
        appendLog("窗口已显示")
        refreshStatePanel()
    }
    
    @objc private func actionHide() {
        guard ensureReady() else { return }
        statusItem.dismissStatusItemWindow()
        appendLog("窗口已隐藏")
        refreshStatePanel()
    }
    
    @objc private func actionToggle() {
        guard ensureReady() else { return }
        if statusItem.isStatusItemWindowVisible {
            statusItem.dismissStatusItemWindow()
            appendLog("窗口已切换 → 隐藏")
        } else {
            statusItem.showStatusItemWindow()
            appendLog("窗口已切换 → 显示")
        }
        refreshStatePanel()
    }
    
    @objc private func actionToggleEnabled() {
        guard ensureReady() else { return }
        statusItem.enabled.toggle()
        appendLog("enabled → \(statusItem.enabled)")
        refreshStatePanel()
    }
    
    @objc private func actionToggleDisabled() {
        guard ensureReady() else { return }
        statusItem.appearsDisabled.toggle()
        appendLog("appearsDisabled → \(statusItem.appearsDisabled)")
        refreshStatePanel()
    }
    
    @objc private func actionChangeIcon() {
        guard ensureReady() else { return }
        let symbols = ["star.fill", "bolt.fill", "leaf.fill", "cloud.fill", "moon.fill", "sun.max.fill"]
        let random = symbols.randomElement() ?? "star.fill"
        if let img = NSImage(systemSymbolName: random, accessibilityDescription: nil) {
            statusItem.reset()
            let config = TFYStatusItem.StatusItemConfiguration(
                image: img,
                viewController: makePopoverContent(),
                windowConfiguration: makeWindowConfig()
            )
            _ = statusItem.configureSafely(with: config)
            appendLog("图标已更换 → \(random)")
        }
        refreshStatePanel()
    }
    
    @objc private func actionChangeTheme() {
        guard ensureReady() else { return }
        themePopUp.selectItem(at: (themePopUp.indexOfSelectedItem + 1) % themePopUp.numberOfItems)
        actionCreate()
        appendLog("背景主题已轮换 → \(themePopUp.titleOfSelectedItem ?? "")")
    }
    
    @objc private func actionGetFrame() {
        guard ensureReady() else { return }
        if let frame = statusItem.getStatusItemFrame() {
            appendLog("StatusItem Frame: origin(\(Int(frame.origin.x)), \(Int(frame.origin.y))) size(\(Int(frame.width))×\(Int(frame.height)))")
        } else {
            appendLog("StatusItem Frame: nil (未创建)")
        }
    }
    
    @objc private func sliderChanged(_ sender: NSSlider) {
        if sender === marginSlider {
            marginLabel.stringValue = String(format: "%.1f pt", sender.doubleValue)
        } else if sender === animDurationSlider {
            animDurationLabel.stringValue = String(format: "%.2f s", sender.doubleValue)
        } else if sender === dragZoneSlider {
            dragZoneLabel.stringValue = "\(Int(sender.doubleValue)) pt"
            statusItem.proximityDragZoneDistance = CGFloat(sender.doubleValue)
        }
    }
    
    @objc private func clearLog() {
        statusTextView.string = ""
    }
    
    // MARK: - Helpers
    
    private func ensureReady() -> Bool {
        guard statusItem.presentationMode != .undefined else {
            appendLog("[提示] 请先点击「创建/重建」创建状态栏项")
            return false
        }
        return true
    }
    
    private func appendLog(_ message: String) {
        let ts = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let line = "[\(ts)] \(message)\n"
        statusTextView?.string += line
        statusTextView?.scrollToEndOfDocument(nil)
    }
    
    private func makeTitle(_ text: String) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.boldSystemFont(ofSize: 22))
            .textColor(.labelColor)
            .frame(NSRect(x: 0, y: 0, width: 400, height: 28))
            .build
    }
    
    private func makeSection(_ text: String) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.systemFont(ofSize: 15, weight: .semibold))
            .textColor(.labelColor)
            .frame(NSRect(x: 0, y: 0, width: 400, height: 22))
            .build
    }
    
    private func makeBody(_ text: String, width: CGFloat, height: CGFloat) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .frame(NSRect(x: 0, y: 0, width: width, height: height))
            .build
    }
    
    private func makeButton(_ title: String, frame: NSRect, action: Selector) -> NSButton {
        NSButton().chain
            .frame(frame)
            .title(title)
            .font(.systemFont(ofSize: 12, weight: .medium))
            .bezelStyle(.rounded)
            .addTarget(self, action: action)
            .build
    }
}
