//
//  MainDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class MainDemoViewController: NSViewController {
    
    private var tabView: NSTabView!
    /// 顶栏大标题（VoiceOver 顺序：标题 → 标签页 → 底栏）
    private var headerTitleField: TFYSwiftLabel!
    private var mainContainerView: NSView!
    private var bottomInfoView: NSView!
    private let releaseVersion = "1.5.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainDemo()
    }
    
    private func setupMainDemo() {
        let containerView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        mainContainerView = containerView
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let titleLabel = TFYSwiftLabel().chain
            .text("TFYSwiftMacOSAppKit 功能演示")
            .font(.boldSystemFont(ofSize: 24))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        headerTitleField = titleLabel
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        createTabView(in: containerView, below: titleLabel)
        createBottomInfoArea(in: containerView)
        applyMainDemoShellAccessibility()
    }

    /// 顶栏标题、标签页与底栏的无障碍名称及子元素顺序（自上而下与视觉一致）。
    private func applyMainDemoShellAccessibility() {
        headerTitleField.setAccessibilityLabel("TFYSwiftMacOSAppKit 功能演示")
        headerTitleField.setAccessibilityRole(.staticText)

        tabView.setAccessibilityLabel("功能模块标签页")
        tabView.setAccessibilityTitle("功能模块")
        tabView.setAccessibilityHelp("切换标签以浏览概览、组件、链式调用、分类扩展、工具、打开/保存面板、HUD、富文本控件与状态栏等演示。")

        bottomInfoView.setAccessibilityLabel("版本与版权")
        bottomInfoView.setAccessibilityTitle("版本与版权")

        mainContainerView.setAccessibilityLabel("TFYSwiftMacOSAppKit 演示主区域")
        mainContainerView.setAccessibilityChildren([headerTitleField!, tabView!, bottomInfoView!])
    }
    
    private func createTabView(in containerView: NSView, below titleLabel: NSView) {
        tabView = NSTabView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        containerView.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tabView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tabView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tabView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -46)
        ])
        
        createOverviewTab()
        createComponentsDemoTab()
        createChainDemoTab()
        createExtensionsDemoTab()
        createUtilsDemoTab()
        createOpenPanelDemoTab()
        createHUDDemoTab()
        createControlDemoTab()
        createStatusItemDemoTab()
    }

    /// 便于 VoiceOver / 调试：子控制器 `title` 与根视图无障碍名称与标签页一致。
    private func configureDemoViewController(_ viewController: NSViewController, tabLabel: String, accessibilitySummary: String) {
        viewController.title = tabLabel
        viewController.view.setAccessibilityLabel("\(tabLabel)：\(accessibilitySummary)")
    }
    
    private func createOverviewTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "概览"
        let overview = createOverviewViewController()
        configureDemoViewController(overview, tabLabel: "概览", accessibilitySummary: "库介绍、功能模块与代码片段")
        tabViewItem.viewController = overview
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createChainDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "链式调用"
        let vc = ChainDemoViewController()
        configureDemoViewController(vc, tabLabel: "链式调用", accessibilitySummary: "Chain、手势、图层与并发链式 API")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createComponentsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "组件控件"
        let vc = ComponentsDemoViewController()
        configureDemoViewController(vc, tabLabel: "组件控件", accessibilitySummary: "TFYSwift 输入、按钮、图片与日志")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createExtensionsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "分类扩展"
        let vc = ExtensionsDemoViewController()
        configureDemoViewController(vc, tabLabel: "分类扩展", accessibilitySummary: "NSView、NSTextField、NSTextView、NSImage 等扩展")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createUtilsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "工具类"
        let vc = UtilsDemoViewController()
        configureDemoViewController(vc, tabLabel: "工具类", accessibilitySummary: "网络、缓存、JSON、定时器、加密与拼接")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }

    private func createOpenPanelDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "打开/保存"
        let vc = OpenPanelDemoViewController()
        configureDemoViewController(vc, tabLabel: "打开/保存", accessibilitySummary: "TFYSwiftOpenPanel 全 API 与沙盒书签")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createHUDDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "HUD"
        let vc = HUDDemoViewController()
        configureDemoViewController(vc, tabLabel: "HUD", accessibilitySummary: "TFYProgressMacOSHUD 与主题、进度控件")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createControlDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "富文本控件"
        let vc = ControlDemoViewController()
        configureDemoViewController(vc, tabLabel: "富文本控件", accessibilitySummary: "NSControl+Dejal 富文本与控件扩展")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createStatusItemDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "状态栏"
        let vc = StatusItemDemoViewController()
        configureDemoViewController(vc, tabLabel: "状态栏", accessibilitySummary: "TFYStatusItem 与状态栏窗口")
        tabViewItem.viewController = vc
        tabView.addTabViewItem(tabViewItem)
    }
    
    // MARK: - Overview ViewController
    
    private func createOverviewViewController() -> NSViewController {
        let vc = NSViewController()
        
        let scrollView = NSScrollView().chain
            .hasVerticalScroller(true)
            .hasHorizontalScroller(false)
            .autohidesScrollers(true)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        vc.view.addSubview(scrollView)
        
        let contentView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scrollView.chain.documentView(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        populateOverviewContent(in: contentView)
        return vc
    }
    
    private func makeLabel(_ text: String, font: NSFont, color: NSColor = .labelColor) -> TFYSwiftLabel {
        TFYSwiftLabel().chain
            .text(text)
            .font(font)
            .textColor(color)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .translatesAutoresizingMaskIntoConstraints(false)
            .wraps(true)
            .maximumNumberOfLines(0)
            .build
    }
    
    private func populateOverviewContent(in contentView: NSView) {
        var constraints: [NSLayoutConstraint] = []
        var lastAnchor = contentView.topAnchor
        let leading = contentView.leadingAnchor
        let trailing = contentView.trailingAnchor
        
        func pin(_ view: NSView, topSpacing: CGFloat = 12, height: CGFloat? = nil) {
            contentView.addSubview(view)
            constraints.append(view.topAnchor.constraint(equalTo: lastAnchor, constant: topSpacing))
            constraints.append(view.leadingAnchor.constraint(equalTo: leading, constant: 20))
            constraints.append(view.trailingAnchor.constraint(equalTo: trailing, constant: -20))
            if let h = height {
                constraints.append(view.heightAnchor.constraint(equalToConstant: h))
            }
            lastAnchor = view.bottomAnchor
        }
        
        // Hero title
        let introLabel = makeLabel(
            "TFYSwiftMacOSAppKit \(releaseVersion)",
            font: .boldSystemFont(ofSize: 20)
        )
        pin(introLabel, topSpacing: 16, height: 26)
        
        // Summary
        let summaryLabel = makeLabel(
            "面向 macOS AppKit 的 Swift 工具库与组件集合。涵盖链式编程、Swift Concurrency、AES-GCM 加密、智能缓存压缩/加密、HUD、状态栏容器、分类扩展与属性观察包装器，适合作为接入前的功能总览与行为验证。提示：本页与各标签页中较长内容均可纵向滚动查看。",
            font: .systemFont(ofSize: 13),
            color: .secondaryLabelColor
        )
        pin(summaryLabel, topSpacing: 6)
        
        // Section header
        let featuresHeader = makeLabel("功能模块", font: .boldSystemFont(ofSize: 15))
        pin(featuresHeader, topSpacing: 18, height: 20)
        
        let features: [String] = [
            "🔗 链式调用 — Chain、asyncAwait / onMainActor、条件执行与调试模式",
            "🔭 属性观察 — @Observable、setIfChanged、projectedValue、Equatable 跳过重复更新",
            "🧩 组件控件 — TFYSwiftTextField / SecureTextField / Button / Label / TextFieldView 等",
            "🎨 图层与动画 — CALayer / CAGradientLayer / CAShapeLayer；CASpringAnimation、AnimationEnhancer",
            "👆 手势 — NSClick / NSPan / NSRotation 等 NSGestureRecognizer 链式配置",
            "🪟 容器 — NSVisualEffectView、NSStackView、NSPopUpButton、NSGridView 等",
            "📐 布局 — TFYLayoutManager 锚点、NSScrollView 文档视图与 Demo 统一 flipped 坐标",
            "🛠️ 工具类 — TFYSwiftUtils（网络 / WiFi / AES-GCM）、TFYSwiftCacheKit、TFYSwiftJsonUtils、TFYStitchImage",
            "📂 打开/保存 — TFYSwiftOpenPanel（async、校验、书签、记忆目录、兼容 API）",
            "⏱️ 调度 — TFYSwiftTimer、TFYSwiftGCD、TFYSwiftAsync、DispatchQueue.once",
            "🗄️ 归档与 Bundle — NSKeyedUnarchiver（超时 + secureCoding）、Bundle（超时 + maxRetries）",
            "🔐 加密 — AES-GCM（CryptoKit）、密钥派生；旧 3DES 已废弃",
            "📦 缓存 — LZFSE 压缩、可选混淆、磁盘读写",
            "💫 HUD — TFYProgressMacOSHUD、TFYThemeManager、TFYProgressView / Indicator",
            "📱 状态栏 — TFYStatusItem、TFYStatusItemWindow、TFYStatusItemWindowController",
            "🧪 分类扩展 — NSView、NSTextField、NSTextView（真占位符）、NSImage、NSColor、NotificationCenter",
            "🔔 通知 — NotificationCenter+Dejal（优先使用 observe，hasObservers 已废弃）"
        ]
        
        for feature in features {
            let lbl = makeLabel(feature, font: .systemFont(ofSize: 13))
            pin(lbl, topSpacing: 4)
        }
        
        // Mapping section
        let mappingHeader = makeLabel("组件与 Demo 对应（切换上方标签页）", font: .boldSystemFont(ofSize: 15))
        pin(mappingHeader, topSpacing: 20, height: 20)
        
        let mappingItems: [String] = [
            "【概览】本页：库介绍与功能一览",
            "【组件控件】TFYSwiftTextField、TFYSwiftSecureTextField、TFYSwiftButton、TFYSwiftLabel、TFYSwiftTextFieldView、图片与二维码处理",
            "【链式调用】Chain 协议全貌、NSView / NSButton / NSTextField / CALayer / CAGradientLayer / CAShapeLayer、NSVisualEffectView、NSStackView、NSPopUpButton、手势 API；新增 asyncAwait / onMainActor 链式调用演示与 @Observable 属性包装器演示",
            "【分类扩展】NSView+Dejal / NSTextField+Dejal / NSTextView+Dejal（真占位符）/ NSImage+Dejal / NotificationCenter+Dejal 交互示例",
            "【工具类】TFYSwiftUtils (网络/WiFi/AES-GCM)、TFYSwiftCacheKit (压缩+加密)、TFYSwiftJsonUtils、TFYSwiftTimer、TFYSwiftGCD、TFYStitchImage；NSKeyedUnarchiver 超时、Bundle maxRetries 示例",
            "【打开/保存】TFYSwiftOpenPanel：单选/多选/目录、类型预设、Result 与校验、记忆目录、saveText/saveData、书签、代理与附件、旧版 openPanel/savePanel API",
            "【HUD】TFYProgressMacOSHUD 全类型 HUD；TFYAnimationEnhancer 弹簧阻尼；TFYThemeManager 主题；TFYLayoutManager 智能锚点；TFYProgressView / TFYProgressIndicator 直接调节",
            "【富文本控件】NSControl+Dejal：富文本/段落/装饰/动画；NSTextField、NSButton、NSSegmentedControl、NSSearchField、NSSlider、NSDatePicker、NSStepper 等扩展与操作日志",
            "【状态栏】TFYStatusItem、TFYStatusItemWindow、TFYStatusItemWindowController：创建/销毁、配置重建、过渡动画、拖拽检测、弹窗展示"
        ]
        
        for item in mappingItems {
            let lbl = makeLabel("• " + item, font: .systemFont(ofSize: 12), color: .secondaryLabelColor)
            pin(lbl, topSpacing: 4)
        }
        
        // Code examples section
        let codeHeader = makeLabel("快速使用示例", font: .boldSystemFont(ofSize: 15))
        pin(codeHeader, topSpacing: 20, height: 20)
        
        let codeSnippets: [String] = [
            "// 链式",
            "NSButton().chain.title(\"点击\").font(.systemFont(ofSize: 16)).backgroundColor(.systemBlue).cornerRadius(8).build",
            "",
            "// 异步链 · 主线程链",
            "label.chain.asyncAwait { v in let d = try? await URLSession.shared.data(from: url).0; await MainActor.run { v.stringValue = \"loaded\" } }",
            "label.chain.onMainActor { $0.stringValue = \"主线程更新\" }",
            "",
            "// @Observable",
            "@Observable var count = 0",
            "$count.setOnChange { print($0) };  $count.setIfChanged(42)  // 同值不触发",
            "",
            "// 加密 · 缓存 · HUD · 真占位符",
            "TFYSwiftUtils.encryptAESGCM(data: plainData, key: key)",
            "cache.set(value, forKey: \"k\", compress: true, encrypt: true)",
            "TFYProgressMacOSHUD.showSuccess(\"操作成功\")",
            "textView.setPlaceholder(\"请输入…\", color: .placeholderTextColor)"
        ]
        
        for code in codeSnippets {
            let lbl = makeLabel(code, font: .monospacedSystemFont(ofSize: 11, weight: .regular), color: .secondaryLabelColor)
            pin(lbl, topSpacing: 2)
        }
        
        // Bottom spacer
        let spacer = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        contentView.addSubview(spacer)
        constraints.append(spacer.topAnchor.constraint(equalTo: lastAnchor, constant: 24))
        constraints.append(spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor))
        constraints.append(spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))
        constraints.append(spacer.heightAnchor.constraint(equalToConstant: 1))
        constraints.append(spacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Bottom Info
    
    private func createBottomInfoArea(in containerView: NSView) {
        let infoView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        bottomInfoView = infoView
        containerView.addSubview(infoView)
        
        let versionLabel = TFYSwiftLabel().chain
            .text("TFYSwiftMacOSAppKit v\(releaseVersion)")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 10, width: 240, height: 20))
            .build
        infoView.addSubview(versionLabel)
        
        let copyrightLabel = TFYSwiftLabel().chain
            .text("Demo Lab · AppKit / CocoaPods / SwiftPM")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 270, y: 10, width: 360, height: 20))
            .build
        infoView.addSubview(copyrightLabel)
        
        NSLayoutConstraint.activate([
            infoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            infoView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

// MARK: - DemoFlippedDocumentView（集中定义，避免独立文件未加入 target 时其它 Demo 找不到类型）

/// `NSScrollView` 文档视图：`y` 向下递增，与 Demo 页自上而下 frame 布局一致。
final class DemoFlippedDocumentView: NSView {
    override var isFlipped: Bool { true }
}
