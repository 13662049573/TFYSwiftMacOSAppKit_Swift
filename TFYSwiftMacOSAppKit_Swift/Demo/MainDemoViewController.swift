//
//  MainDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class MainDemoViewController: NSViewController {
    
    private var tabView: NSTabView!
    private var currentViewController: NSViewController?
    private weak var gradientDemoLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainDemo()
    }
    
    private func setupMainDemo() {
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
            .text("TFYSwiftMacOSAppKit 功能演示")
            .font(.boldSystemFont(ofSize: 24))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 20, width: 400, height: 30))
        
        containerView.addSubview(titleLabel)
        
        // 创建标签视图
        createTabView(in: containerView)
        
        // 创建底部信息区域
        createBottomInfoArea(in: containerView)
    }
    
    private func createTabView(in containerView: NSView) {
        tabView = NSTabView()
        tabView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tabView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
            tabView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tabView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tabView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -100)
        ])
        
        // 创建各个功能模块的标签页
        createOverviewTab()
        createChainDemoTab()
        createUtilsDemoTab()
        createHUDDemoTab()
        createStatusItemDemoTab()
        createAdvancedDemoTab()
    }
    
    private func createOverviewTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "概览"
        
        let overviewViewController = createOverviewViewController()
        tabViewItem.viewController = overviewViewController
        
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createChainDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "链式调用"
        
        let chainDemoViewController = ChainDemoViewController()
        tabViewItem.viewController = chainDemoViewController
        
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createUtilsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "工具类"
        
        let utilsDemoViewController = UtilsDemoViewController()
        tabViewItem.viewController = utilsDemoViewController
        
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createHUDDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "HUD"
        
        let hudDemoViewController = HUDDemoViewController()
        tabViewItem.viewController = hudDemoViewController
        
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createStatusItemDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "状态栏"
        
        let statusItemDemoViewController = StatusItemDemoViewController()
        tabViewItem.viewController = statusItemDemoViewController
        
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createAdvancedDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "高级功能"
        
        let advancedViewController = createAdvancedViewController()
        tabViewItem.viewController = advancedViewController
        
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createOverviewViewController() -> NSViewController {
        let viewController = NSViewController()
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(scrollView)
        
        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = contentView
        
        // 设置约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        // 创建概览内容
        createOverviewContent(in: contentView)
        
        return viewController
    }
    
    private func createOverviewContent(in contentView: NSView) {
        var yOffset: CGFloat = 20
        
        // 库介绍
        let introLabel = NSTextField()
        introLabel.chain
            .text("TFYSwiftMacOSAppKit 是一个专为 macOS 应用开发设计的 Swift 工具库")
            .font(.boldSystemFont(ofSize: 18))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 600, height: 25))
        
        contentView.addSubview(introLabel)
        yOffset += 40
        
        // 功能模块列表
        let features = [
            "🔗 链式调用 - 提供流畅的链式编程体验",
            "🎨 UI组件 - 丰富的UI组件和自定义控件",
            "👆 手势识别 - 完整的手势识别系统",
            "🎭 图层动画 - 强大的CALayer动画支持",
            "🛠️ 工具类 - 网络、缓存、JSON、文件面板、定时器、GCD等",
            "💫 HUD指示器 - 美观的进度和状态指示器",
            "📱 状态栏项 - 完整的状态栏项管理",
            "⚡ 性能优化 - 内存管理和性能监控"
        ]
        
        for (_, feature) in features.enumerated() {
            let featureLabel = NSTextField()
            featureLabel.chain
                .text(feature)
                .font(.systemFont(ofSize: 14))
                .textColor(.labelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .frame(NSRect(x: 20, y: yOffset, width: 600, height: 20))
            
            contentView.addSubview(featureLabel)
            yOffset += 25
        }
        
        yOffset += 15
        
        // 组件与 Demo 对应表
        let mappingTitle = NSTextField()
        mappingTitle.chain
            .text("组件与 Demo 对应（请切换上方标签页查看各功能演示）")
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 600, height: 22))
        contentView.addSubview(mappingTitle)
        yOffset += 28
        
        let mappingItems = [
            "【概览】本页：库介绍与组件一览",
            "【链式调用】Chain 协议、NSView/NSButton/NSTextField/CALayer/CAGradientLayer/CAShapeLayer、NSClick/NSPan/NSRotation 等手势链式 API",
            "【工具类】TFYSwiftUtils(网络/WiFi/加密)、TFYSwiftCacheKit、TFYSwiftJsonUtils、TFYSwiftTimer、TFYSwiftGCD、TFYSwiftOpenPanel(打开/保存文件)",
            "【HUD】TFYProgressMacOSHUD、TFYAnimationEnhancer、TFYThemeManager、TFYProgressView、TFYProgressIndicator：成功/错误/信息/文本/加载/进度/自定义、主题/动画/位置/自动隐藏",
            "【状态栏】TFYStatusItem、TFYStatusItemWindow、TFYStatusItemWindowController：创建/移除/配置/弹窗",
            "【高级功能】CAGradientLayer+Dejal 渐变与动画、扩展能力示例"
        ]
        for item in mappingItems {
            let label = NSTextField()
            label.chain
                .text("• " + item)
                .font(.systemFont(ofSize: 12))
                .textColor(.secondaryLabelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .frame(NSRect(x: 20, y: yOffset, width: 600, height: 18))
            label.cell?.wraps = true
            label.maximumNumberOfLines = 0
            contentView.addSubview(label)
            yOffset += 20
        }
        
        yOffset += 15
        
        // 使用示例
        let exampleLabel = NSTextField()
        exampleLabel.chain
            .text("使用示例:")
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 200, height: 20))
        
        contentView.addSubview(exampleLabel)
        yOffset += 30
        
        // 代码示例
        let codeExamples = [
            "// 链式调用示例",
            "let button = NSButton()",
            "button.chain",
            "    .title(\"点击我\")",
            "    .font(.systemFont(ofSize: 16))",
            "    .textColor(.white)",
            "    .backgroundColor(.systemBlue)",
            "    .frame(NSRect(x: 0, y: 0, width: 100, height: 30))",
            "",
            "// HUD示例",
            "TFYProgressMacOSHUD.showSuccess(\"操作成功!\")",
            "",
            "// 状态栏项示例",
            "let statusItem = TFYStatusItem.shared",
            "try statusItem.configure(with: config)"
        ]
        
        for code in codeExamples {
            let codeLabel = NSTextField()
            codeLabel.chain
                .text(code)
                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                .textColor(.secondaryLabelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .frame(NSRect(x: 20, y: yOffset, width: 600, height: 18))
            
            contentView.addSubview(codeLabel)
            yOffset += 20
        }
        
        // 设置内容视图高度
        contentView.frame.size.height = yOffset + 20
    }
    
    private func createAdvancedViewController() -> NSViewController {
        let viewController = NSViewController()
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(scrollView)
        
        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = contentView
        
        // 设置约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        // 创建高级功能内容
        createAdvancedContent(in: contentView)
        
        return viewController
    }
    
    private func createAdvancedContent(in contentView: NSView) {
        var yOffset: CGFloat = 20
        
        // 高级功能标题
        let titleLabel = NSTextField()
        titleLabel.chain
            .text("高级功能演示")
            .font(.boldSystemFont(ofSize: 18))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 300, height: 25))
        
        contentView.addSubview(titleLabel)
        yOffset += 40
        
        // CAGradientLayer+Dejal 渐变演示
        let gradientTitle = NSTextField()
        gradientTitle.chain
            .text("CAGradientLayer+Dejal 渐变与动画")
            .font(.boldSystemFont(ofSize: 14))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 350, height: 20))
        contentView.addSubview(gradientTitle)
        yOffset += 28
        
        let gradientContainer = NSView()
        gradientContainer.wantsLayer = true
        gradientContainer.frame = NSRect(x: 20, y: yOffset, width: 400, height: 80)
        gradientContainer.layer?.cornerRadius = 8
        gradientContainer.layer?.masksToBounds = true
        if let gradientLayer = CAGradientLayer.rainbowGradient(size: CGSize(width: 400, height: 80)) {
            gradientLayer.frame = gradientContainer.bounds
            gradientContainer.layer?.addSublayer(gradientLayer)
            gradientDemoLayer = gradientLayer
        }
        contentView.addSubview(gradientContainer)
        
        let gradientAnimButton = NSButton()
        gradientAnimButton.chain
            .frame(NSRect(x: 430, y: yOffset + 25, width: 140, height: 30))
            .title("播放颜色渐变动画")
            .font(.systemFont(ofSize: 12))
            .bezelStyle(.rounded)
        gradientAnimButton.target = self
        gradientAnimButton.action = #selector(runGradientAnimation(_:))
        contentView.addSubview(gradientAnimButton)
        yOffset += 100
        
        // 高级功能列表
        let advancedFeatures = [
            "🔧 自定义控件 - 创建自定义UI组件",
            "🎯 性能监控 - 实时监控应用性能",
            "🔒 安全加密 - 数据加密和安全存储",
            "🌐 网络通信 - 高级网络请求和响应处理",
            "📊 数据可视化 - 图表和数据展示",
            "🎨 主题系统 - 动态主题切换",
            "🔔 通知系统 - 本地和远程通知",
            "📱 多窗口管理 - 复杂窗口布局管理"
        ]
        
        for feature in advancedFeatures {
            let featureLabel = NSTextField()
            featureLabel.chain
                .text(feature)
                .font(.systemFont(ofSize: 14))
                .textColor(.labelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .frame(NSRect(x: 20, y: yOffset, width: 600, height: 20))
            
            contentView.addSubview(featureLabel)
            yOffset += 25
        }
        
        yOffset += 20
        
        // 高级示例代码
        let advancedCodeExamples = [
            "// 自定义控件示例",
            "class CustomButton: NSButton {",
            "    override func draw(_ dirtyRect: NSRect) {",
            "        super.draw(dirtyRect)",
            "        // 自定义绘制逻辑",
            "    }",
            "}",
            "",
            "// 性能监控示例",
            "TFYSwiftUtils.monitorPerformance { metrics in",
            "    print(\"CPU使用率: \\(metrics.cpuUsage)\")",
            "    print(\"内存使用: \\(metrics.memoryUsage)\")",
            "}",
            "",
            "// 安全加密示例",
            "let encrypted = TFYSwiftUtils.aesEncrypt(data, key: key)",
            "let decrypted = TFYSwiftUtils.aesDecrypt(encrypted, key: key)"
        ]
        
        for code in advancedCodeExamples {
            let codeLabel = NSTextField()
            codeLabel.chain
                .text(code)
                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                .textColor(.secondaryLabelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .frame(NSRect(x: 20, y: yOffset, width: 600, height: 18))
            
            contentView.addSubview(codeLabel)
            yOffset += 20
        }
        
        // 设置内容视图高度
        contentView.frame.size.height = yOffset + 20
    }
    
    @objc private func runGradientAnimation(_ sender: Any?) {
        guard let layer = gradientDemoLayer else { return }
        let toColors = [
            NSColor.systemPurple,
            NSColor.systemBlue,
            NSColor.systemTeal,
            NSColor.systemGreen,
            NSColor.systemYellow,
            NSColor.systemOrange,
            NSColor.systemRed
        ]
        let anim = layer.colorChangeAnimation(toColors: toColors, duration: 1.0)
        anim.isRemovedOnCompletion = false
        layer.add(anim, forKey: "colorChange")
        layer.colors = toColors.map { $0.cgColor }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak layer] in
            layer?.removeAnimation(forKey: "colorChange")
        }
    }
    
    private func createBottomInfoArea(in containerView: NSView) {
        let infoView = NSView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(infoView)
        
        // 版本信息
        let versionLabel = NSTextField()
        versionLabel.chain
            .text("TFYSwiftMacOSAppKit v1.0.0")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 0, width: 200, height: 20))
        
        infoView.addSubview(versionLabel)
        
        // 版权信息
        let copyrightLabel = NSTextField()
        copyrightLabel.chain
            .text("© 2024 TFYSwift. All rights reserved.")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 250, y: 0, width: 300, height: 20))
        
        infoView.addSubview(copyrightLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            infoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            infoView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
} 
