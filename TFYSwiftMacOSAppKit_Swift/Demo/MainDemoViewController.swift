//
//  MainDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class MainDemoViewController: NSViewController {
    
    private var tabView: NSTabView!
    private let releaseVersion = "1.5.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainDemo()
    }
    
    private func setupMainDemo() {
        let containerView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let titleLabel = NSTextField().chain
            .text("TFYSwiftMacOSAppKit 功能演示")
            .font(.boldSystemFont(ofSize: 24))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        createTabView(in: containerView, below: titleLabel)
        createBottomInfoArea(in: containerView)
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
        createHUDDemoTab()
        createControlDemoTab()
        createStatusItemDemoTab()
    }
    
    private func createOverviewTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "概览"
        tabViewItem.viewController = createOverviewViewController()
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createChainDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "链式调用"
        tabViewItem.viewController = ChainDemoViewController()
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createComponentsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "组件控件"
        tabViewItem.viewController = ComponentsDemoViewController()
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createExtensionsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "分类扩展"
        tabViewItem.viewController = ExtensionsDemoViewController()
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createUtilsDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "工具类"
        tabViewItem.viewController = UtilsDemoViewController()
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createHUDDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "HUD"
        tabViewItem.viewController = HUDDemoViewController()
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createControlDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "富文本控件"
        tabViewItem.viewController = ControlDemoViewController()
        tabView.addTabViewItem(tabViewItem)
    }
    
    private func createStatusItemDemoTab() {
        let tabViewItem = NSTabViewItem()
        tabViewItem.label = "状态栏"
        tabViewItem.viewController = StatusItemDemoViewController()
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
    
    private func makeLabel(_ text: String, font: NSFont, color: NSColor = .labelColor) -> NSTextField {
        NSTextField().chain
            .text(text)
            .font(font)
            .textColor(color)
            .backgroundColor(.clear)
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
            "面向 macOS AppKit 的 Swift 工具库与组件集合。涵盖链式编程、Swift Concurrency、AES-GCM 加密、智能缓存压缩/加密、HUD、状态栏容器、分类扩展与属性观察包装器，适合作为接入前的功能总览与行为验证。",
            font: .systemFont(ofSize: 13),
            color: .secondaryLabelColor
        )
        pin(summaryLabel, topSpacing: 6)
        
        // Section header
        let featuresHeader = makeLabel("功能模块", font: .boldSystemFont(ofSize: 15))
        pin(featuresHeader, topSpacing: 18, height: 20)
        
        let features: [String] = [
            "🔗 链式调用 — 流畅的链式编程，支持 async/await、@MainActor、条件执行与调试模式",
            "⚡️ Swift Concurrency — asyncAwait(_:)、onMainActor(_:) 链式调用封装，Task 驱动",
            "🔄 Swift 并发 - async/await 链式调用与 @MainActor 安全操作",
            "🔭 属性观察器 — @Observable 属性包装器，setIfChanged 防抖更新，projectedValue 投影访问",
            "🎯 属性观察 - Observable 属性包装器支持 Equatable 跳过与 projectedValue",
            "🧩 组件控件 — TFYSwiftTextField / SecureTextField / Button / Label / TextFieldView 等",
            "🎨 图层动画 — CALayer / CAGradientLayer / CAShapeLayer 链式配置；AnimationEnhancer 弹簧阻尼动画",
            "🎪 弹簧动画 - CASpringAnimation 真正使用 springDamping 与 initialSpringVelocity",
            "👆 手势识别 — NSClickGestureRecognizer / NSPanGestureRecognizer / NSRotationGestureRecognizer",
            "🪟 容器效果 — NSVisualEffectView / NSStackView / NSPopUpButton / NSGridView 链式容器",
            "📐 布局管理 — LayoutManager 智能标签锚点定位，NSScrollView 自适应文档视图",
            "🛠️ 工具类 — TFYSwiftUtils (网络/WiFi/AES-GCM 加密)、TFYSwiftCacheKit (压缩+加密)、TFYSwiftJsonUtils",
            "⏱️ 并发调度 — TFYSwiftTimer、TFYSwiftGCD、TFYSwiftAsync、DispatchQueue.once",
            "⏱️ 配置生效 - NSKeyedUnarchiver/Bundle 的 timeout 与 maxRetries 真正应用",
            "🗄️ 归档解析 — NSKeyedUnarchiver (超时 + secureCoding)、Bundle (超时 + maxRetries)",
            "🔐 加密安全 — AES-GCM (CryptoKit) 对称加密，密钥派生，Base64 载荷",
            "🔐 现代加密 - AES-GCM (CryptoKit) 加密/解密，3DES 已标记废弃",
            "📦 缓存增强 - LZFSE 压缩与 XOR 混淆，磁盘缓存读写真正生效",
            "💫 HUD — TFYProgressMacOSHUD 成功/错误/信息/文本/加载/进度；TFYThemeManager 主题切换",
            "📱 状态栏项 — TFYStatusItem / TFYStatusItemWindow / TFYStatusItemWindowController 完整管理",
            "🧪 分类扩展 — NSView / NSTextField / NSTextView (真占位符绘制) / NSImage / NotificationCenter",
            "🖍️ 占位文本 - NSTextView 真实 CATextLayer 占位符绘制",
            "🌈 颜色扩展 - CMYK/Hex/HSB 创建、WCAG 对比度、色温与色彩情感",
            "📦 图片处理 — NSImage lockFocus 迁移至 drawingHandler；TFYStitchImage 图片拼接",
            "🔔 通知中心 — NotificationCenter+Dejal；hasObservers 已废弃（推荐使用 observe(_:) 替代）"
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
            "【工具类】TFYSwiftUtils (网络/WiFi/AES-GCM)、TFYSwiftCacheKit (压缩+加密)、TFYSwiftJsonUtils、TFYSwiftTimer、TFYSwiftGCD、TFYSwiftOpenPanel、TFYStitchImage；NSKeyedUnarchiver 超时、Bundle maxRetries 示例",
            "【HUD】TFYProgressMacOSHUD 全类型 HUD；TFYAnimationEnhancer 弹簧阻尼；TFYThemeManager 主题；TFYLayoutManager 智能锚点；TFYProgressView / TFYProgressIndicator 直接调节",
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
            "// 链式按钮",
            "let button = NSButton().chain",
            "    .title(\"点击我\").font(.systemFont(ofSize: 16))",
            "    .backgroundColor(.systemBlue).cornerRadius(8).build",
            "",
            "// async/await 链式调用",
            "label.chain.asyncAwait { view in",
            "    let data = try? await URLSession.shared.data(from: url).0",
            "    await MainActor.run { view.stringValue = \"loaded\" }",
            "}",
            "",
            "// @MainActor 链式调用",
            "label.chain.onMainActor { lbl in lbl.stringValue = \"主线程更新\" }",
            "",
            "// @Observable 属性包装器",
            "@Observable var count: Int = 0",
            "$count.setOnChange { print(\"new:\", $0) }",
            "$count.setIfChanged(42)  // 仅在值不同时触发",
            "",
            "// AES-GCM 加密 (CryptoKit)",
            "let encrypted = TFYSwiftUtils.encryptAESGCM(data: plainData, key: key)",
            "",
            "// CacheKit 压缩+加密",
            "cache.set(value, forKey: \"k\", compress: true, encrypt: true)",
            "",
            "// HUD",
            "TFYProgressMacOSHUD.showSuccess(\"操作成功!\")",
            "",
            "// NSTextView 真占位符",
            "textView.setPlaceholder(\"请输入内容…\", color: .placeholderTextColor)"
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
        containerView.addSubview(infoView)
        
        let versionLabel = NSTextField().chain
            .text("TFYSwiftMacOSAppKit v\(releaseVersion)")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 10, width: 240, height: 20))
            .build
        infoView.addSubview(versionLabel)
        
        let copyrightLabel = NSTextField().chain
            .text("Demo Lab · AppKit / CocoaPods / SwiftPM")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
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
