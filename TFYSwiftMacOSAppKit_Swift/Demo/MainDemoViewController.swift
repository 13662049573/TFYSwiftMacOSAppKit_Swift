//
//  MainDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class MainDemoViewController: NSViewController {
    
    private var tabView: NSTabView!
    private let releaseVersion = "1.4.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainDemo()
    }
    
    private func setupMainDemo() {
        // 创建主容器视图
        let containerView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        view.addSubview(containerView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 创建标题
        let titleLabel = NSTextField().chain
            .text("TFYSwiftMacOSAppKit 功能演示")
            .font(.boldSystemFont(ofSize: 24))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 20, width: 400, height: 30))
            .build
        containerView.addSubview(titleLabel)
        
        // 创建标签视图
        createTabView(in: containerView)
        
        // 创建底部信息区域
        createBottomInfoArea(in: containerView)
    }
    
    private func createTabView(in containerView: NSView) {
        tabView = NSTabView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
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
        createComponentsDemoTab()
        createChainDemoTab()
        createExtensionsDemoTab()
        createUtilsDemoTab()
        createHUDDemoTab()
        createStatusItemDemoTab()
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
    
    private func createComponentsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "组件控件"
        
        let viewController = ComponentsDemoViewController()
        tabViewItem.viewController = viewController
        
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createExtensionsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "分类扩展"
        
        let viewController = ExtensionsDemoViewController()
        tabViewItem.viewController = viewController
        
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
    
    private func createOverviewViewController() -> NSViewController {
        let viewController = NSViewController()
        let scrollView = NSScrollView().chain
            .hasVerticalScroller(true)
            .hasHorizontalScroller(false)
            .autohidesScrollers(true)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        viewController.view.addSubview(scrollView)
        
        let contentView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scrollView.chain.documentView(contentView)
        
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
        let introLabel = NSTextField().chain
            .text("TFYSwiftMacOSAppKit 是一个面向 macOS AppKit 场景的 Swift 工具库与组件集合")
            .font(.boldSystemFont(ofSize: 18))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 600, height: 25))
            .build
        contentView.addSubview(introLabel)
        yOffset += 40
        
        let summaryLabel = NSTextField().chain
            .text("这个 Demo App 现在覆盖链式编程、自定义控件、密码容器、分类扩展、工具类、HUD、直接进度视图与状态栏容器，并为工具与图像能力补充了可视化预览，适合作为接入前的功能总览与行为验证。")
            .font(.systemFont(ofSize: 13))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 720, height: 36))
            .wraps(true)
            .build
        summaryLabel.maximumNumberOfLines = 0
        contentView.addSubview(summaryLabel)
        yOffset += 52
        
        // 功能模块列表
        let features = [
            "🔗 链式调用 - 提供流畅的链式编程体验",
            "🧩 组件控件 - TFYSwiftTextField / SecureTextField / Button / Label / TextFieldView 等自定义控件",
            "🎨 UI组件 - 丰富的UI组件和自定义控件",
            "👆 手势识别 - 完整的手势识别系统",
            "🎭 图层动画 - 强大的CALayer动画支持",
            "🪟 容器效果 - NSVisualEffectView / NSStackView / NSPopUpButton 链式容器示例",
            "🛠️ 工具类 - 网络、缓存、JSON、文件面板、定时器、GCD、Async、Once、图片拼接与实时预览",
            "💫 HUD指示器 - 美观的进度和状态指示器",
            "📱 状态栏项 - 完整的状态栏项管理",
            "🧪 分类扩展 - NSView / NSTextField / NSControl / NSImage / NotificationCenter 等增强能力"
        ]
        
        for (_, feature) in features.enumerated() {
            let featureLabel = NSTextField().chain
                .text(feature)
                .font(.systemFont(ofSize: 14))
                .textColor(.labelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .frame(NSRect(x: 20, y: yOffset, width: 600, height: 20))
                .build
            contentView.addSubview(featureLabel)
            yOffset += 25
        }
        
        yOffset += 15
        
        // 组件与 Demo 对应表
        let mappingTitle = NSTextField().chain
            .text("组件与 Demo 对应（请切换上方标签页查看各功能演示）")
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 600, height: 22))
            .build
        contentView.addSubview(mappingTitle)
        yOffset += 28
        
        let mappingItems = [
            "【概览】本页：库介绍与组件一览",
            "【组件控件】TFYSwiftTextField、TFYSwiftSecureTextField、TFYSwiftButton、TFYSwiftLabel、TFYSwiftTextFieldView、图片与二维码处理能力",
            "【链式调用】Chain 协议、NSView/NSButton/NSTextField/CALayer/CAGradientLayer/CAShapeLayer、NSVisualEffectView、NSStackView、NSPopUpButton、NSClick/NSPan/NSRotation 等链式 API",
            "【分类扩展】NSView+Dejal / NSTextField+Dejal / NSTextView+Dejal / NSControl+Dejal / NSImage+Dejal / NotificationCenter+Dejal 的交互式示例",
            "【工具类】TFYSwiftUtils(网络/WiFi/加密)、TFYSwiftCacheKit、TFYSwiftJsonUtils、TFYSwiftTimer、TFYSwiftGCD、TFYSwiftAsync、DispatchQueue.once、TFYSwiftOpenPanel(打开/保存文件)、TFYStitchImage(图片拼接) 与实时预览",
            "【HUD】TFYProgressMacOSHUD、TFYAnimationEnhancer、TFYThemeManager、TFYProgressView、TFYProgressIndicator：成功/错误/信息/文本/加载/进度/自定义、主题/动画/位置/自动隐藏、直接进度视图调节",
            "【状态栏】TFYStatusItem、TFYStatusItemWindow、TFYStatusItemWindowController：创建/销毁、配置重建、过渡动画、拖拽检测、弹窗展示"
        ]
        for item in mappingItems {
            let label = NSTextField().chain
                .text("• " + item)
                .font(.systemFont(ofSize: 12))
                .textColor(.secondaryLabelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .frame(NSRect(x: 20, y: yOffset, width: 600, height: 18))
                .wraps(true)
                .build
            label.maximumNumberOfLines = 0
            contentView.addSubview(label)
            yOffset += 20
        }
        
        yOffset += 15
        
        // 使用示例
        let exampleLabel = NSTextField().chain
            .text("使用示例:")
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: yOffset, width: 200, height: 20))
            .build
        contentView.addSubview(exampleLabel)
        yOffset += 30
        
        // 代码示例
        let codeExamples = [
            "// 链式调用示例",
            "let button = NSButton().chain",
            "    .title(\"点击我\")",
            "    .font(.systemFont(ofSize: 16))",
            "    .textColor(.white)",
            "    .backgroundColor(.systemBlue)",
            "    .frame(NSRect(x: 0, y: 0, width: 100, height: 30))",
            "    .build",
            "",
            "// 容器与自定义文本框示例",
            "let cardView = NSView().chain",
            "    .wantsLayer(true)",
            "    .backgroundColor(NSColor.windowBackgroundColor)",
            "    .cornerRadius(18)",
            "    .translatesAutoresizingMaskIntoConstraints(false)",
            "    .build",
            "",
            "let textField = TFYSwiftTextField().chain",
            "    .placeholderString(\"请输入内容\")",
            "    .placeholderColor(.systemOrange)",
            "    .maxLength(12)",
            "    .focusEffect(true)",
            "    .textChangeHandler { text in print(text) }",
            "    .frame(NSRect(x: 20, y: 20, width: 220, height: 36))",
            "    .build",
            "",
            "// NSTextView 扩展示例",
            "let textView = NSTextView().chain",
            "    .wraps(true)",
            "    .lineSpacing(3)",
            "    .clickableTexts([\"HUD\": \"Progress HUD\"]) { key, value, _ in",
            "        print(key, value)",
            "    }",
            "    .build",
            "",
            "// HUD示例",
            "TFYProgressMacOSHUD.showSuccess(\"操作成功!\")",
            "",
            "// 状态栏项示例",
            "let statusItem = TFYStatusItem.shared",
            "try statusItem.configure(with: config)"
        ]
        
        for code in codeExamples {
            let codeLabel = NSTextField().chain
                .text(code)
                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                .textColor(.secondaryLabelColor)
                .backgroundColor(.clear)
                .bordered(false)
                .editable(false)
                .selectable(false)
                .wraps(true)
                .maximumNumberOfLines(0)
                .frame(NSRect(x: 20, y: yOffset, width: 680, height: 18))
                .build
            contentView.addSubview(codeLabel)
            yOffset += 20
        }
        
        // 设置内容视图高度
        contentView.frame.size.height = yOffset + 20
    }
    
    private func createBottomInfoArea(in containerView: NSView) {
        let infoView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        containerView.addSubview(infoView)
        
        // 版本信息
        let versionLabel = NSTextField().chain
            .text("TFYSwiftMacOSAppKit v\(releaseVersion)")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 0, width: 200, height: 20))
            .build
        infoView.addSubview(versionLabel)
        
        // 版权信息
        let copyrightLabel = NSTextField().chain
            .text("Demo Lab · AppKit / CocoaPods / SwiftPM")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 250, y: 0, width: 360, height: 20))
            .build
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
