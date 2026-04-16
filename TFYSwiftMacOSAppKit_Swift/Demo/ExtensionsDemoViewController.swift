//
//  ExtensionsDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by Codex on 2026/4/2.
//

import Cocoa

final class ExtensionsDemoViewController: NSViewController {
    
    private var previewBox: NSView!
    private var previewInfoLabel: NSTextField!
    private var styledField: NSTextField!
    private var plainTextField: NSTextField!
    private var richTextView: NSTextView!
    private var textViewStatsLabel: NSTextField!
    private var notificationStatusLabel: NSTextField!
    private var logTextView: NSTextView!
    private var notificationToken: NSObjectProtocol?
    private var notificationCount = 0
    private var isTextViewReadOnly = false
    private var placeholderTextView: NSTextView!
    private var gradientLayerView: NSView!
    private var gradientLayer: CAGradientLayer?
    private var gradientDirectionIndex: Int = 0

    deinit {
        if let notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDemo()
        setupNotificationObserver()
    }
    
    private func setupDemo() {
        let scrollView = NSScrollView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .hasVerticalScroller(true)
            .autohidesScrollers(true)
            .build
        view.addSubview(scrollView)
        
        let contentView = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scrollView.chain.documentView(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        var yOffset: CGFloat = 20
        
        let titleLabel = makeTitleLabel("分类扩展演示")
        titleLabel.frame.origin = NSPoint(x: 20, y: yOffset)
        contentView.addSubview(titleLabel)
        yOffset += 38
        
        let subtitleLabel = makeBodyLabel("这里专门演示 NSView / NSControl / NSTextField / NSTextView / NotificationCenter 相关扩展能力，适合验证交互细节和辅助 API 的成熟度。", width: 780, height: 34)
        subtitleLabel.frame.origin = NSPoint(x: 20, y: yOffset)
        contentView.addSubview(subtitleLabel)
        yOffset += 56
        
        yOffset = setupViewExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupControlExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupTextFieldExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupTextViewExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupNotificationSection(in: contentView, yOffset: yOffset)
        yOffset = setupTextViewPlaceholderSection(in: contentView, yOffset: yOffset)
        yOffset = setupColorExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupGradientLayerSection(in: contentView, yOffset: yOffset)
        yOffset = setupImageExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupLogSection(in: contentView, yOffset: yOffset)
        
        contentView.frame.size.height = yOffset + 24
    }
    
    // MARK: - Existing Sections
    
    private func setupViewExtensionSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("NSView + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 34
        
        previewBox = NSView().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 220, height: 120))
            .backgroundColor(.systemTeal)
            .cornerRadius(18)
            .borderWidth(1)
            .borderColor(.white.withAlphaComponent(0.28))
            .build
        previewBox.setShadow(color: .black, offset: CGSize(width: 0, height: 8), radius: 16, opacity: 0.2)
        _ = previewBox.addClickGesture { [weak self] _ in
            self?.appendLog("NSView 点击手势已触发")
        }
        _ = previewBox.addLongPressGesture({ [weak self] _ in
            self?.appendLog("NSView 长按手势已触发")
        }, duration: 0.35)
        contentView.addSubview(previewBox)
        
        let badgeLabel = NSTextField(labelWithString: "拖动、动画、阴影、圆角、点击/长按").chain
            .font(.systemFont(ofSize: 11, weight: .medium))
            .textColor(.white)
            .alignment(.center)
            .frame(NSRect(x: 16, y: 46, width: 188, height: 18))
            .build
        previewBox.addSubview(badgeLabel)
        
        previewInfoLabel = makeBodyLabel("viewController(): \(previewBox.viewController() === self ? "已命中当前控制器" : "未命中")", width: 520, height: 22)
        previewInfoLabel.frame.origin = NSPoint(x: 260, y: currentOffset + 2)
        contentView.addSubview(previewInfoLabel)
        
        let viewButtons = [
            ("淡出", #selector(fadeOutPreview), 260),
            ("淡入", #selector(fadeInPreview), 350),
            ("抖动", #selector(shakePreview), 440),
            ("脉冲", #selector(pulsePreview), 530),
            ("弹跳", #selector(bouncePreview), 620)
        ]
        
        for (title, action, x) in viewButtons {
            let button = makeActionButton(title: title, frame: NSRect(x: CGFloat(x), y: currentOffset + 34, width: 76, height: 30), action: action)
            contentView.addSubview(button)
        }
        
        let restyleButton = makeActionButton(title: "重设样式", frame: NSRect(x: 260, y: currentOffset + 74, width: 110, height: 30), action: #selector(restylePreview))
        contentView.addSubview(restyleButton)
        
        let geometryLabel = makeBodyLabel("尺寸: \(Int(previewBox.macos_width)) x \(Int(previewBox.macos_height)) · 深度: \(previewBox.depth)", width: 360, height: 22)
        geometryLabel.frame.origin = NSPoint(x: 390, y: currentOffset + 78)
        contentView.addSubview(geometryLabel)
        
        return currentOffset + 150
    }
    
    private func setupControlExtensionSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("NSControl + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 34
        
        styledField = NSTextField(labelWithString: "NSControl 富文本增强演示").chain
            .frame(NSRect(x: 20, y: currentOffset, width: 320, height: 24))
            .font(.systemFont(ofSize: 16, weight: .medium))
            .textColor(.labelColor)
            .build
        contentView.addSubview(styledField)
        
        let styleButton = makeActionButton(title: "应用富文本样式", frame: NSRect(x: 360, y: currentOffset - 4, width: 110, height: 30), action: #selector(applyStyledControlText))
        contentView.addSubview(styleButton)
        
        let iconButton = makeActionButton(title: "插入前置图标", frame: NSRect(x: 484, y: currentOffset - 4, width: 110, height: 30), action: #selector(applyLeadingImages))
        contentView.addSubview(iconButton)
        
        let roundedButton = makeActionButton(title: "圆角边框", frame: NSRect(x: 608, y: currentOffset - 4, width: 90, height: 30), action: #selector(applyRoundedBorder))
        contentView.addSubview(roundedButton)
        
        let tipLabel = makeBodyLabel("可以直接对 NSControl 子类做字距、颜色、下划线、阴影、占位文本、圆角边框等富文本与外观处理。", width: 760, height: 22)
        tipLabel.frame.origin = NSPoint(x: 20, y: currentOffset + 34)
        contentView.addSubview(tipLabel)
        
        return currentOffset + 74
    }
    
    private func setupTextFieldExtensionSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("NSTextField + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 34
        
        plainTextField = NSTextField().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 280, height: 34))
            .placeholder("普通 NSTextField 也可直接增强")
            .placeholderStringColor(.systemBlue)
            //.maxLength(10)
            .focusEffect(true)
            .textChangeHandler { [weak self] text in
                self?.appendLog("普通文本框输入变化: \(text)")
            }
            .build
        _ = plainTextField.addGestureLongPress({ [weak self] _ in
            self?.appendLog("NSTextField 长按手势已触发")
        }, for: 0.35)
        contentView.addSubview(plainTextField)
        
        let copyButton = makeActionButton(title: "复制", frame: NSRect(x: 320, y: currentOffset + 2, width: 70, height: 30), action: #selector(copyPlainText))
        contentView.addSubview(copyButton)
        
        let pasteButton = makeActionButton(title: "粘贴", frame: NSRect(x: 402, y: currentOffset + 2, width: 70, height: 30), action: #selector(pastePlainText))
        contentView.addSubview(pasteButton)
        
        let validateButton = makeActionButton(title: "判空检测", frame: NSRect(x: 484, y: currentOffset + 2, width: 90, height: 30), action: #selector(validatePlainText))
        contentView.addSubview(validateButton)
        
        let fontFitButton = makeActionButton(title: "自动换行适配", frame: NSRect(x: 588, y: currentOffset + 2, width: 110, height: 30), action: #selector(fitPlainText))
        contentView.addSubview(fontFitButton)
        
        let helperLabel = makeBodyLabel("这里演示的是扩展方法，不依赖自定义子类，适合直接加在现有表单页。", width: 760, height: 22)
        helperLabel.frame.origin = NSPoint(x: 20, y: currentOffset + 40)
        contentView.addSubview(helperLabel)
        
        return currentOffset + 74
    }

    private func setupTextViewExtensionSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset

        let sectionLabel = makeSectionLabel("NSTextView + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 34

        let scrollView = NSScrollView().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 380, height: 120))
            .hasVerticalScroller(true)
            .borderType(.bezelBorder)
            .autohidesScrollers(true)
            .build
        contentView.addSubview(scrollView)

        richTextView = NSTextView().chain
            .frame(NSRect(x: 0, y: 0, width: 380, height: 120))
            .font(.systemFont(ofSize: 13))
            .wraps(true)
            .lineSpacing(3)
            .string("点击 HUD 或 缓存 这两个关键词，观察 NSTextView 的点击扩展回调。你也可以直接编辑文本，然后查看统计信息。")
            .clickableTexts([
                "HUD": "Progress HUD",
                "缓存": "CacheKit"
            ]) { [weak self] key, value, _ in
                self?.appendLog("NSTextView 点击关键词: \(key) -> \(value as? String ?? "无附加值")")
            }
            .textChangeHandler { [weak self] _ in
                self?.refreshTextViewStats()
            }
            .selectionChangeHandler { [weak self] range in
                self?.refreshTextViewStats(selectionRange: range)
            }
            .build
        scrollView.chain.documentView(richTextView)

        let loadButton = makeActionButton(title: "加载示例文本", frame: NSRect(x: 424, y: currentOffset + 6, width: 110, height: 30), action: #selector(loadTextViewTemplate))
        contentView.addSubview(loadButton)

        let replaceButton = makeActionButton(title: "替换关键词", frame: NSRect(x: 548, y: currentOffset + 6, width: 90, height: 30), action: #selector(replaceTextViewKeywords))
        contentView.addSubview(replaceButton)

        let statsButton = makeActionButton(title: "输出统计", frame: NSRect(x: 650, y: currentOffset + 6, width: 90, height: 30), action: #selector(reportTextViewStatistics))
        contentView.addSubview(statsButton)

        let readOnlyButton = makeActionButton(title: "切换只读", frame: NSRect(x: 424, y: currentOffset + 44, width: 110, height: 30), action: #selector(toggleTextViewReadOnly))
        contentView.addSubview(readOnlyButton)

        let bottomButton = makeActionButton(title: "滚动到底部", frame: NSRect(x: 548, y: currentOffset + 44, width: 90, height: 30), action: #selector(scrollTextViewToBottom))
        contentView.addSubview(bottomButton)

        let appendButton = makeActionButton(title: "追加文本", frame: NSRect(x: 650, y: currentOffset + 44, width: 90, height: 30), action: #selector(appendTextViewSnippet))
        contentView.addSubview(appendButton)

        let helperLabel = makeBodyLabel("这部分演示点击关键词、文本统计、查找替换、滚动定位和只读切换，都是直接作用在原生 NSTextView 上。", width: 340, height: 38)
        helperLabel.frame.origin = NSPoint(x: 424, y: currentOffset + 82)
        contentView.addSubview(helperLabel)

        textViewStatsLabel = makeBodyLabel("", width: 760, height: 22)
        textViewStatsLabel.frame.origin = NSPoint(x: 20, y: currentOffset + 128)
        contentView.addSubview(textViewStatsLabel)
        refreshTextViewStats()

        return currentOffset + 160
    }
    
    private func setupNotificationSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("NotificationCenter + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 34
        
        let postBackgroundButton = makeActionButton(title: "后台线程发通知", frame: NSRect(x: 20, y: currentOffset, width: 120, height: 32), action: #selector(postBackgroundNotification))
        contentView.addSubview(postBackgroundButton)
        
        let postMainButton = makeActionButton(title: "主线程发通知", frame: NSRect(x: 154, y: currentOffset, width: 120, height: 32), action: #selector(postMainNotification))
        contentView.addSubview(postMainButton)
        
        notificationStatusLabel = makeBodyLabel("最近通知：暂无", width: 480, height: 22)
        notificationStatusLabel.frame.origin = NSPoint(x: 300, y: currentOffset + 6)
        contentView.addSubview(notificationStatusLabel)
        
        return currentOffset + 52
    }
    
    // MARK: - New Sections
    
    private func setupTextViewPlaceholderSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset

        let sectionLabel = makeSectionLabel("NSTextView Placeholder (CATextLayer)")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30

        let descLabel = makeBodyLabel("setPlaceholder 通过 CATextLayer 在视图 layer 上绘制占位文本，清空内容后占位符自动显现。", width: 760, height: 22)
        descLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(descLabel)
        currentOffset += 28

        let placeholderScrollView = NSScrollView().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 380, height: 100))
            .hasVerticalScroller(true)
            .borderType(.bezelBorder)
            .autohidesScrollers(true)
            .build
        contentView.addSubview(placeholderScrollView)

        placeholderTextView = NSTextView().chain
            .frame(NSRect(x: 0, y: 0, width: 380, height: 100))
            .font(.systemFont(ofSize: 13))
            .wraps(true)
            .string("在此输入文字后点击「清空」可见占位符效果")
            .build
        placeholderTextView.setPlaceholder("这里输入文本...（由 CATextLayer 渲染）")
        placeholderScrollView.chain.documentView(placeholderTextView)

        let clearPlaceholderButton = makeActionButton(
            title: "清空文本",
            frame: NSRect(x: 420, y: currentOffset + 10, width: 90, height: 32),
            action: #selector(clearPlaceholderText)
        )
        contentView.addSubview(clearPlaceholderButton)

        let fillPlaceholderButton = makeActionButton(
            title: "填充文本",
            frame: NSRect(x: 420, y: currentOffset + 52, width: 90, height: 32),
            action: #selector(fillPlaceholderText)
        )
        contentView.addSubview(fillPlaceholderButton)

        let hintLabel = makeBodyLabel("清空后可看到 CATextLayer 绘制的占位文本；填充后占位文本自动隐藏。", width: 310, height: 38)
        hintLabel.frame.origin = NSPoint(x: 524, y: currentOffset + 26)
        contentView.addSubview(hintLabel)

        return currentOffset + 120
    }

    private func setupColorExtensionSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset

        let sectionLabel = makeSectionLabel("NSColor + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30

        let descLabel = makeBodyLabel("展示 Hex 初始化、CMYK 初始化、互补色、反色、WCAG 对比度、颜色温度与情感等扩展能力。", width: 760, height: 22)
        descLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(descLabel)
        currentOffset += 28

        let hexColor = NSColor(safeHexString: "#FF5733") ?? .systemOrange
        let cmykColor = (try? NSColor(c: 0, m: 80, y: 100, k: 0)) ?? .systemRed
        let baseColor = NSColor(hex: 0x4A90E2)
        let complementaryColor = baseColor.complementary
        let invertedColor = baseColor.inverted
        let blendedColor = hexColor.blended(with: baseColor, ratio: 0.5)

        let colorBoxItems: [(String, NSColor)] = [
            ("Hex #FF5733", hexColor),
            ("CMYK(0,80,100,0)", cmykColor),
            ("Base #4A90E2", baseColor),
            ("互补色", complementaryColor),
            ("反色", invertedColor),
            ("混合50%", blendedColor)
        ]

        let boxSize: CGFloat = 112
        let boxHeight: CGFloat = 52
        for (index, (label, color)) in colorBoxItems.enumerated() {
            let x = CGFloat(20 + index * Int(boxSize + 8))
            let colorBox = NSView().chain
                .frame(NSRect(x: x, y: currentOffset, width: boxSize, height: boxHeight))
                .backgroundColor(color)
                .cornerRadius(10)
                .borderWidth(1)
                .borderColor(.separatorColor)
                .build
            contentView.addSubview(colorBox)

            let hexStr = color.usingColorSpace(.sRGB)?.hexString ?? "n/a"
            let boxLabel = NSTextField(labelWithString: "\(label)\n\(hexStr)").chain
                .font(.systemFont(ofSize: 10))
                .textColor(color.bestContrastColor())
                .alignment(.center)
                .lineBreakMode(.byWordWrapping)
                .wraps(true)
                .maximumNumberOfLines(0)
                .frame(NSRect(x: 4, y: 6, width: boxSize - 8, height: boxHeight - 12))
                .build
            colorBox.addSubview(boxLabel)
        }
        currentOffset += boxHeight + 10

        let contrastRatio = hexColor.contrastRatio(with: .white)
        let wcagAA = hexColor.meetsWCAGContrast(with: .white, level: .AA)
        let temp = baseColor.temperature
        let emotion = baseColor.emotion
        let tempStr: String
        switch temp {
        case .warm: tempStr = "暖色"
        case .cool: tempStr = "冷色"
        case .neutral: tempStr = "中性色"
        }
        let emotionStr: String
        switch emotion {
        case .warm: emotionStr = "温暖"
        case .cool: emotionStr = "冷静"
        case .fresh: emotionStr = "清新"
        case .passionate: emotionStr = "热情"
        case .calm: emotionStr = "平和"
        case .energetic: emotionStr = "活力"
        case .mysterious: emotionStr = "神秘"
        }

        let infoLabel = makeBodyLabel(
            "#FF5733 vs 白色对比度: \(String(format: "%.2f", contrastRatio)) · WCAG AA: \(wcagAA ? "✓通过" : "✗不达标") · #4A90E2 温度: \(tempStr) · 情感: \(emotionStr)",
            width: 760, height: 22
        )
        infoLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(infoLabel)
        currentOffset += 30

        return currentOffset
    }

    private func setupGradientLayerSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset

        let sectionLabel = makeSectionLabel("CAGradientLayer Chain API")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30

        let descLabel = makeBodyLabel("通过 CAGradientLayer Chain API 配置渐变方向、颜色与动画过渡；点击按钮切换预设渐变样式。", width: 760, height: 22)
        descLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(descLabel)
        currentOffset += 28

        gradientLayerView = NSView().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 300, height: 100))
            .wantsLayer(true)
            .cornerRadius(12)
            .borderWidth(1)
            .borderColor(.separatorColor)
            .build
        contentView.addSubview(gradientLayerView)

        let initialLayer = CAGradientLayer()
        initialLayer.chain
            .frame(CGRect(x: 0, y: 0, width: 300, height: 100))
            .colors([NSColor.systemBlue.cgColor, NSColor.systemTeal.cgColor])
            .startPoint(CGPoint(x: 0, y: 0.5))
            .endPoint(CGPoint(x: 1, y: 0.5))
            .cornerRadius(12)
        gradientLayerView.layer?.addSublayer(initialLayer)
        gradientLayer = initialLayer

        let gradientButtons: [(String, Selector, CGFloat)] = [
            ("水平渐变", #selector(applyHorizontalGradient), 340),
            ("垂直渐变", #selector(applyVerticalGradient), 442),
            ("彩虹渐变", #selector(applyRainbowGradient), 544),
            ("日落渐变", #selector(applySunsetGradient), 646)
        ]
        for (title, action, x) in gradientButtons {
            let btn = makeActionButton(title: title, frame: NSRect(x: x, y: currentOffset + 10, width: 90, height: 30), action: action)
            contentView.addSubview(btn)
        }

        let animateButton = makeActionButton(title: "动画切换", frame: NSRect(x: 340, y: currentOffset + 56, width: 90, height: 30), action: #selector(animateGradientTransition))
        contentView.addSubview(animateButton)

        return currentOffset + 120
    }

    private func setupImageExtensionSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset

        let sectionLabel = makeSectionLabel("NSImage + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30

        let descLabel = makeBodyLabel("展示 resized、roundedImage、circularImage、addBorder、rotated、tintedImage 等 NSImage 扩展处理。", width: 760, height: 22)
        descLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(descLabel)
        currentOffset += 28

        let baseImg = (NSImage(systemSymbolName: "swift", accessibilityDescription: nil) ??
                       NSImage.image(withColor: .systemBlue))
            .resized(to: NSSize(width: 72, height: 72))

        let imageItems: [(String, NSImage)] = [
            ("原图", baseImg),
            ("圆角", baseImg.roundedImage(cornerRadius: 18)),
            ("圆形", baseImg.circularImage()),
            ("加边框", baseImg.addBorder(width: 4, color: .systemPurple)),
            ("旋转45°", baseImg.rotated(by: .pi / 4)),
            ("染色", baseImg.tintedImage(withColor: .systemPink))
        ]

        let itemWidth: CGFloat = 110
        for (index, (caption, image)) in imageItems.enumerated() {
            let x = CGFloat(20 + index * Int(itemWidth + 8))
            let imageView = NSImageView().chain
                .frame(NSRect(x: x, y: currentOffset, width: itemWidth, height: itemWidth))
                .image(image)
                .imageScaling(.scaleProportionallyUpOrDown)
                .wantsLayer(true)
                .backgroundColor(.windowBackgroundColor)
                .cornerRadius(12)
                .borderWidth(1)
                .borderColor(.separatorColor)
                .build
            contentView.addSubview(imageView)

            let captionLabel = NSTextField(labelWithString: caption).chain
                .font(.systemFont(ofSize: 11, weight: .medium))
                .alignment(.center)
                .frame(NSRect(x: x, y: currentOffset + itemWidth + 4, width: itemWidth, height: 18))
                .build
            contentView.addSubview(captionLabel)
        }
        currentOffset += itemWidth + 28

        let avgColor = baseImg.roundedImage(cornerRadius: 18).averageColor()?.usingColorSpace(.deviceRGB)
        let r = Int((avgColor?.redComponent ?? 0) * 255)
        let g = Int((avgColor?.greenComponent ?? 0) * 255)
        let b = Int((avgColor?.blueComponent ?? 0) * 255)
        let fileSize = baseImg.fileSize(format: .png) ?? 0

        let imageInfoLabel = makeBodyLabel(
            "圆角图平均色: RGB(\(r), \(g), \(b)) · PNG 大小: \(fileSize) bytes",
            width: 760, height: 22
        )
        imageInfoLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(imageInfoLabel)
        currentOffset += 28

        return currentOffset
    }

    private func setupLogSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("扩展能力日志")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30
        
        let clearButton = makeActionButton(title: "清空日志", frame: NSRect(x: 690, y: currentOffset - 4, width: 90, height: 28), action: #selector(clearLog))
        contentView.addSubview(clearButton)
        
        logTextView = NSTextView().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 760, height: 150))
            .editable(false)
            .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .backgroundColor(.textBackgroundColor)
            .textColor(.labelColor)
            .string("等待扩展操作...\n")
            .build
        contentView.addSubview(logTextView)
        
        appendLog("扩展页已加载，可以测试动画、富文本、NSTextView 增强、通知桥接与普通文本框增强能力")
        return currentOffset + 168
    }
    
    // MARK: - Notification Observer
    
    private func setupNotificationObserver() {
        notificationToken = NotificationCenter.default.addObserver(
            forName: .exampleNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.notificationCount += 1
            let payload = notification.userInfo?["payload"] as? String ?? "无附带数据"
            self.notificationStatusLabel.stringValue = "最近通知：第 \(self.notificationCount) 次 · \(payload)"
            self.appendLog("收到通知 exampleNotification，payload: \(payload)")
        }
    }
    
    // MARK: - Helpers
    
    private func appendLog(_ message: String) {
        let current = logTextView?.string ?? ""
        logTextView?.string = current + "• " + message + "\n"
        logTextView?.scrollToEndOfDocument(nil)
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
            .frame(NSRect(x: 0, y: 0, width: 400, height: 22))
            .build
    }
    
    private func makeBodyLabel(_ text: String, width: CGFloat, height: CGFloat) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .maximumNumberOfLines(0)
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
    
    // MARK: - NSView Actions
    
    @objc private func fadeOutPreview() {
        previewBox.fadeOut()
        appendLog("执行 NSView 淡出动画")
    }
    
    @objc private func fadeInPreview() {
        previewBox.fadeIn()
        appendLog("执行 NSView 淡入动画")
    }
    
    @objc private func shakePreview() {
        previewBox.shake()
        appendLog("执行 NSView 抖动动画")
    }
    
    @objc private func pulsePreview() {
        previewBox.pulse()
        appendLog("执行 NSView 脉冲动画")
    }
    
    @objc private func bouncePreview() {
        previewBox.bounce()
        appendLog("执行 NSView 弹跳动画")
    }
    
    @objc private func restylePreview() {
        previewBox.setBackgroundColor(.systemMint)
        previewBox.setCornerRadius(24)
        previewBox.setBorder(color: .systemBlue, width: 2)
        previewInfoLabel.stringValue = "viewController(): \(previewBox.viewController() === self ? "已命中当前控制器" : "未命中") · 样式已刷新"
        appendLog("已重设 NSView 边框、背景和圆角")
    }
    
    // MARK: - NSControl Actions
    
    @objc private func applyStyledControlText() {
        styledField.setAttributedText("NSControl 富文本增强演示", font: .systemFont(ofSize: 16, weight: .semibold), color: .systemBlue, alignment: .left)
        styledField.changeSpace(with: 4)
        styledField.changeUnderlineStyle(with: NSNumber(value: NSUnderlineStyle.single.rawValue))
        styledField.changeUnderlineColor(with: .systemPink)
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.shadowColor = NSColor.systemBlue.withAlphaComponent(0.35)
        styledField.changeShadow(with: shadow)
        appendLog("已应用 NSControl 富文本样式")
    }
    
    @objc private func applyLeadingImages() {
        guard let image = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: nil) else { return }
        styledField.changeText(text: "前置图标文本演示", frontImages: [image], imageSpan: 6)
        appendLog("已为 NSControl 文本插入前置图标")
    }
    
    @objc private func applyRoundedBorder() {
        styledField.setRoundedBorder(cornerRadius: 10, borderWidth: 1, borderColor: .systemBlue)
        styledField.setShadow(shadowColor: .systemBlue, shadowOffset: CGSize(width: 0, height: 3), shadowRadius: 6, shadowOpacity: 0.18)
        appendLog("已对 NSControl 应用圆角边框和阴影")
    }
    
    // MARK: - NSTextField Actions
    
    @objc private func copyPlainText() {
        plainTextField.copyText()
        appendLog("已复制普通文本框内容")
    }
    
    @objc private func pastePlainText() {
        plainTextField.pasteText()
        appendLog("已粘贴到普通文本框")
    }
    
    @objc private func validatePlainText() {
        appendLog(plainTextField.isEmpty ? "普通文本框当前为空" : "普通文本框当前有内容")
    }
    
    @objc private func fitPlainText() {
        plainTextField.fitFontSize(maxSize: NSSize(width: 280, height: 80))
        appendLog("已执行文本适配与换行")
    }

    // MARK: - NSTextView Actions

    private func refreshTextViewStats(selectionRange: NSRange? = nil) {
        let stats = richTextView?.textStatistics ?? (characters: 0, words: 0, lines: 0, paragraphs: 0)
        let selection = selectionRange ?? richTextView?.selectedRange() ?? NSRange(location: 0, length: 0)
        let modeText = isTextViewReadOnly ? "只读" : "可编辑"
        textViewStatsLabel?.stringValue = "NSTextView 统计：字符 \(stats.characters) · 单词 \(stats.words) · 行 \(stats.lines) · 段落 \(stats.paragraphs) · 选区 \(selection.length) · 模式 \(modeText)"
    }

    @objc private func loadTextViewTemplate() {
        richTextView.string = """
        TFYSwiftMacOSAppKit 的扩展层不仅覆盖 NSTextField，也补到了 NSTextView。
        点击 HUD 或 缓存 关键词，可以验证 click callback。

        当前这一页还演示了查找替换、统计、滚动定位和只读切换。
        """
        richTextView.chain.clickableTexts([
            "HUD": "Progress HUD",
            "缓存": "CacheKit"
        ]) { [weak self] key, value, _ in
            self?.appendLog("NSTextView 点击关键词: \(key) -> \(value as? String ?? "无附加值")")
        }
        refreshTextViewStats()
        appendLog("已载入 NSTextView 示例文本")
    }

    @objc private func replaceTextViewKeywords() {
        let replacedCount = richTextView.replaceAllText("HUD", with: "Progress HUD")
        refreshTextViewStats()
        appendLog("NSTextView 已替换关键词 \(replacedCount) 处")
    }

    @objc private func reportTextViewStatistics() {
        let stats = richTextView.textStatistics
        appendLog("NSTextView 统计 -> 字符 \(stats.characters)，单词 \(stats.words)，行 \(stats.lines)，段落 \(stats.paragraphs)")
    }

    @objc private func toggleTextViewReadOnly() {
        isTextViewReadOnly.toggle()
        richTextView.chain.readOnly(isTextViewReadOnly)
        refreshTextViewStats()
        appendLog(isTextViewReadOnly ? "NSTextView 已切换为只读" : "NSTextView 已恢复可编辑")
    }

    @objc private func scrollTextViewToBottom() {
        richTextView.scrollToBottom()
        appendLog("NSTextView 已滚动到底部")
    }

    @objc private func appendTextViewSnippet() {
        richTextView.setSelectedRange(NSRange(location: richTextView.string.count, length: 0))
        richTextView.insertText("\n追加片段：这里可以继续测试滚动、统计和选择回调。")
        refreshTextViewStats()
        appendLog("已向 NSTextView 追加一段文本")
    }
    
    // MARK: - Notification Actions
    
    @objc private func postBackgroundNotification() {
        NotificationCenter.default.postNotificationOnBackgroundThread(
            name: .exampleNotification,
            object: self,
            userInfo: ["payload": "来自后台线程"]
        )
        appendLog("已请求在后台线程发送通知")
    }
    
    @objc private func postMainNotification() {
        NotificationCenter.default.postNotificationOnMainThread(
            name: .exampleNotification,
            object: self,
            userInfo: ["payload": "来自主线程"]
        )
        appendLog("已请求在主线程发送通知")
    }

    // MARK: - Placeholder TextVIew Actions

    @objc private func clearPlaceholderText() {
        placeholderTextView.string = ""
        appendLog("NSTextView 文本已清空，CATextLayer 占位符应显示")
    }

    @objc private func fillPlaceholderText() {
        placeholderTextView.string = "已填充示例文字，占位符自动隐藏。"
        appendLog("NSTextView 已填充文本，占位符自动隐藏")
    }

    // MARK: - Gradient Layer Actions

    @objc private func applyHorizontalGradient() {
        applyGradientPreset(colors: [.systemBlue, .systemTeal], start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5))
        appendLog("CAGradientLayer 已切换为水平渐变")
    }

    @objc private func applyVerticalGradient() {
        applyGradientPreset(colors: [.systemIndigo, .systemPurple], start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1))
        appendLog("CAGradientLayer 已切换为垂直渐变")
    }

    @objc private func applyRainbowGradient() {
        let rainbowColors: [NSColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple]
        applyGradientPreset(colors: rainbowColors, start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5))
        appendLog("CAGradientLayer 已切换为彩虹渐变")
    }

    @objc private func applySunsetGradient() {
        applyGradientPreset(colors: [.systemOrange, .systemPink, .systemPurple], start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 1))
        appendLog("CAGradientLayer 已切换为日落渐变")
    }

    @objc private func animateGradientTransition() {
        gradientDirectionIndex = (gradientDirectionIndex + 1) % 4
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.6)
        switch gradientDirectionIndex {
        case 0: applyGradientPreset(colors: [.systemBlue, .systemTeal], start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5))
        case 1: applyGradientPreset(colors: [.systemIndigo, .systemPurple], start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1))
        case 2: applyGradientPreset(colors: [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple], start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5))
        default: applyGradientPreset(colors: [.systemOrange, .systemPink, .systemPurple], start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 1))
        }
        CATransaction.commit()
        appendLog("CAGradientLayer 动画过渡到下一个预设")
    }

    private func applyGradientPreset(colors: [NSColor], start: CGPoint, end: CGPoint) {
        guard let layer = gradientLayer else { return }
        layer.chain
            .colors(colors.map { $0.cgColor })
            .startPoint(start)
            .endPoint(end)
    }

    // MARK: - Log Action
    
    @objc private func clearLog() {
        logTextView.string = ""
    }
}
