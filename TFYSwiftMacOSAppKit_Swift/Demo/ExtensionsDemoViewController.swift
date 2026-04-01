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
    private var notificationStatusLabel: NSTextField!
    private var logTextView: NSTextView!
    private var notificationToken: NSObjectProtocol?
    private var notificationCount = 0
    
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
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        view.addSubview(scrollView)
        
        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = contentView
        
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
        
        let subtitleLabel = makeBodyLabel("这里专门演示 NSView / NSControl / NSTextField / NotificationCenter 相关扩展能力，适合验证交互细节和辅助 API 的成熟度。", width: 780, height: 34)
        subtitleLabel.frame.origin = NSPoint(x: 20, y: yOffset)
        contentView.addSubview(subtitleLabel)
        yOffset += 56
        
        yOffset = setupViewExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupControlExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupTextFieldExtensionSection(in: contentView, yOffset: yOffset)
        yOffset = setupNotificationSection(in: contentView, yOffset: yOffset)
        yOffset = setupLogSection(in: contentView, yOffset: yOffset)
        
        contentView.frame.size.height = yOffset + 24
    }
    
    private func setupViewExtensionSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("NSView + Dejal")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 34
        
        previewBox = NSView(frame: NSRect(x: 20, y: currentOffset, width: 220, height: 120))
        previewBox.setBackgroundColor(.systemTeal)
        previewBox.setCornerRadius(18)
        previewBox.setBorder(color: .white.withAlphaComponent(0.28), width: 1)
        previewBox.setShadow(color: .black, offset: CGSize(width: 0, height: 8), radius: 16, opacity: 0.2)
        _ = previewBox.addClickGesture { [weak self] _ in
            self?.appendLog("NSView 点击手势已触发")
        }
        _ = previewBox.addLongPressGesture({ [weak self] _ in
            self?.appendLog("NSView 长按手势已触发")
        }, duration: 0.35)
        contentView.addSubview(previewBox)
        
        let badgeLabel = NSTextField(labelWithString: "拖动、动画、阴影、圆角、点击/长按")
        badgeLabel.font = .systemFont(ofSize: 11, weight: .medium)
        badgeLabel.textColor = .white
        badgeLabel.alignment = .center
        badgeLabel.frame = NSRect(x: 16, y: 46, width: 188, height: 18)
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
        
        styledField = NSTextField(labelWithString: "NSControl 富文本增强演示")
        styledField.frame = NSRect(x: 20, y: currentOffset, width: 320, height: 24)
        styledField.font = .systemFont(ofSize: 16, weight: .medium)
        styledField.textColor = .labelColor
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
        
        plainTextField = NSTextField(frame: NSRect(x: 20, y: currentOffset, width: 280, height: 34))
        plainTextField.placeholderString = "普通 NSTextField 也可直接增强"
        plainTextField.placeholderStringColor = .systemBlue
        plainTextField.setMaxLength(10)
        plainTextField.addFocusEffect()
        plainTextField.setTextChangeHandler { [weak self] text in
            self?.appendLog("普通文本框输入变化: \(text)")
        }
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
    
    private func setupLogSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("扩展能力日志")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30
        
        let clearButton = makeActionButton(title: "清空日志", frame: NSRect(x: 690, y: currentOffset - 4, width: 90, height: 28), action: #selector(clearLog))
        contentView.addSubview(clearButton)
        
        logTextView = NSTextView(frame: NSRect(x: 20, y: currentOffset, width: 760, height: 150))
        logTextView.isEditable = false
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.backgroundColor = .textBackgroundColor
        logTextView.textColor = .labelColor
        logTextView.string = "等待扩展操作...\n"
        contentView.addSubview(logTextView)
        
        appendLog("扩展页已加载，可以测试动画、富文本、通知桥接与普通文本框增强能力")
        return currentOffset + 168
    }
    
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
    
    private func appendLog(_ message: String) {
        let current = logTextView?.string ?? ""
        logTextView?.string = current + "• " + message + "\n"
        logTextView?.scrollToEndOfDocument(nil)
    }
    
    private func makeTitleLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .labelColor
        label.frame = NSRect(x: 0, y: 0, width: 360, height: 28)
        return label
    }
    
    private func makeSectionLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .labelColor
        label.frame = NSRect(x: 0, y: 0, width: 320, height: 22)
        return label
    }
    
    private func makeBodyLabel(_ text: String, width: CGFloat, height: CGFloat) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabelColor
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 0
        label.frame = NSRect(x: 0, y: 0, width: width, height: height)
        return label
    }
    
    private func makeActionButton(title: String, frame: NSRect, action: Selector) -> NSButton {
        let button = NSButton(frame: frame)
        button.title = title
        button.font = .systemFont(ofSize: 12, weight: .medium)
        button.bezelStyle = .rounded
        button.target = self
        button.action = action
        return button
    }
    
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
    
    @objc private func clearLog() {
        logTextView.string = ""
    }
}
