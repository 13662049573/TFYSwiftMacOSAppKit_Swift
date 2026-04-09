//
//  ComponentsDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by Codex on 2026/4/2.
//

import Cocoa

final class ComponentsDemoViewController: NSViewController {
    
    private var logTextView: NSTextView!
    private var inputStateLabel: NSTextField!
    private var imageInfoLabel: NSTextField!
    private var customInput: TFYSwiftTextField!
    private var customSecureInput: TFYSwiftSecureTextField!
    private var textActionLabel: TFYSwiftLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDemo()
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
        
        let titleLabel = makeTitleLabel("组件控件演示")
        titleLabel.frame.origin = NSPoint(x: 20, y: yOffset)
        contentView.addSubview(titleLabel)
        yOffset += 38
        
        let subtitleLabel = makeBodyLabel("这一页集中展示库内自定义控件、文本输入增强、图片处理与二维码能力，适合作为接入时的第一轮视觉验证。", width: 780, height: 34)
        subtitleLabel.frame.origin = NSPoint(x: 20, y: yOffset)
        contentView.addSubview(subtitleLabel)
        yOffset += 56
        
        yOffset = setupCustomControlsSection(in: contentView, yOffset: yOffset)
        yOffset = setupInputEnhancementSection(in: contentView, yOffset: yOffset)
        yOffset = setupImageSection(in: contentView, yOffset: yOffset)
        yOffset = setupLogSection(in: contentView, yOffset: yOffset)
        
        contentView.frame.size.height = yOffset + 24
    }
    
    private func setupCustomControlsSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("自定义控件")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30
        
        let actionButton = TFYSwiftButton().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 180, height: 40))
            .title("TFYSwiftButton 悬浮按钮")
            .font(.systemFont(ofSize: 13, weight: .semibold))
            .titleTextColor(.white)
            .backgroundColor(.systemBlue)
            .hoverBackgroundColor(.systemIndigo)
            .cornerRadius(12)
            .addTarget(self, action: #selector(handlePrimaryComponentAction))
            .build
        contentView.addSubview(actionButton)
        
        let infoLabel = makeBodyLabel("按钮支持 hover 背景色、内边距、文本颜色控制；可直接用于工具栏样式或业务操作按钮。", width: 420, height: 38)
        infoLabel.frame.origin = NSPoint(x: 220, y: currentOffset + 2)
        contentView.addSubview(infoLabel)
        currentOffset += 60
        
        textActionLabel = TFYSwiftLabel().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 320, height: 28))
            .text("TFYSwiftLabel：点击我写入下方日志")
            .font(.systemFont(ofSize: 13, weight: .medium))
            .textColor(.systemPurple)
            .mouseDownBlock { [weak self] _ in
                self?.appendLog("TFYSwiftLabel 点击事件已触发")
            }
            .build
        contentView.addSubview(textActionLabel)
        
        let componentBadge = NSTextField(labelWithString: "控件均来自 macOScontainer/macOSUtils").chain
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .frame(NSRect(x: 360, y: currentOffset + 4, width: 320, height: 20))
            .build
        contentView.addSubview(componentBadge)
        
        return currentOffset + 52
    }
    
    private func setupInputEnhancementSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("文本输入增强")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 30
        
        customInput = TFYSwiftTextField().chain
            .frame(NSRect(x: 20, y: currentOffset, width: 280, height: 38))
            .placeholderString("请输入至少 4 个字符，最大 12 个")
            .placeholderColor(.systemOrange)
            .backgroundColor(.textBackgroundColor)
            .textColor(.labelColor)
            .bordered(true)
            .wantsLayer(true)
            .cornerRadius(10)
            .focusRingType(.none)
            .maxLength(12)
            .focusEffect(true)
            .validationHandler { text in
                text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4
            }
            .textChangeHandler { [weak self] text in
                self?.updateInputState(text)
            }
            .build
        contentView.addSubview(customInput)
        
        customSecureInput = TFYSwiftSecureTextField().chain
            .frame(NSRect(x: 320, y: currentOffset, width: 220, height: 38))
            .placeholderString("TFYSwiftSecureTextField")
            .textColor(.systemRed)
            .bordered(true)
            .focusRingType(.none)
            .build
        contentView.addSubview(customSecureInput)
        
        let readonlyButton = makeActionButton(title: "切换只读", frame: NSRect(x: 560, y: currentOffset, width: 100, height: 32), action: #selector(toggleReadOnly))
        contentView.addSubview(readonlyButton)
        
        let copyButton = makeActionButton(title: "复制文本", frame: NSRect(x: 670, y: currentOffset, width: 90, height: 32), action: #selector(copyInputText))
        contentView.addSubview(copyButton)
        
        currentOffset += 48
        
        let pasteButton = makeActionButton(title: "粘贴文本", frame: NSRect(x: 20, y: currentOffset, width: 90, height: 32), action: #selector(pasteInputText))
        contentView.addSubview(pasteButton)
        
        let cursorButton = makeActionButton(title: "光标置尾", frame: NSRect(x: 120, y: currentOffset, width: 90, height: 32), action: #selector(moveCursorToEnd))
        contentView.addSubview(cursorButton)
        
        inputStateLabel = makeBodyLabel("输入状态：等待输入", width: 560, height: 22)
        inputStateLabel.frame.origin = NSPoint(x: 230, y: currentOffset + 6)
        contentView.addSubview(inputStateLabel)
        
        return currentOffset + 52
    }
    
    private func setupImageSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("图像处理与二维码")
        sectionLabel.frame.origin = NSPoint(x: 20, y: currentOffset)
        contentView.addSubview(sectionLabel)
        currentOffset += 34
        
        let baseImage = (NSImage(systemSymbolName: "swift", accessibilityDescription: nil) ?? NSImage.image(withColor: .systemBlue))
            .resized(to: NSSize(width: 72, height: 72))
        
        let tintedImage = baseImage
            .tintedImage(withColor: .systemPink)
            .roundedImage(cornerRadius: 16)
        
        let rotatedImage = baseImage
            .rotated(by: .pi / 8)
            .addBorder(width: 4, color: .systemTeal)
        
        let qrImage = NSImage.generateColoredQRCode(
            from: "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift",
            size: CGSize(width: 110, height: 110),
            rgbColor: CIColor(color: .black) ?? CIColor(red: 0, green: 0, blue: 0),
            backgroundColor: CIColor(color: .white) ?? CIColor(red: 1, green: 1, blue: 1)
        )
        
        let previews = [
            ("原图", baseImage, NSRect(x: 20, y: currentOffset, width: 120, height: 128)),
            ("染色圆角", tintedImage, NSRect(x: 155, y: currentOffset, width: 120, height: 128)),
            ("旋转边框", rotatedImage, NSRect(x: 290, y: currentOffset, width: 120, height: 128)),
            ("二维码", qrImage ?? NSImage.gradientImage(colors: [.systemGray, .systemBlue], size: NSSize(width: 110, height: 110)), NSRect(x: 425, y: currentOffset, width: 140, height: 128))
        ]
        
        for (title, image, frame) in previews {
            let imageView = NSImageView().chain
                .frame(frame)
                .imageScaling(.scaleProportionallyUpOrDown)
                .image(image)
                .wantsLayer(true)
                .backgroundColor(.windowBackgroundColor)
                .cornerRadius(16)
                .borderWidth(1)
                .borderColor(.separatorColor)
                .build
            contentView.addSubview(imageView)
            
            let caption = NSTextField(labelWithString: title).chain
                .font(.systemFont(ofSize: 12, weight: .medium))
                .alignment(.center)
                .frame(NSRect(x: frame.minX, y: frame.maxY + 4, width: frame.width, height: 18))
                .build
            contentView.addSubview(caption)
        }
        
        let saveButton = makeActionButton(title: "保存处理图像到临时目录", frame: NSRect(x: 590, y: currentOffset + 38, width: 190, height: 34), action: #selector(saveProcessedImage))
        contentView.addSubview(saveButton)
        
        imageInfoLabel = makeBodyLabel("", width: 190, height: 58)
        imageInfoLabel.frame.origin = NSPoint(x: 590, y: currentOffset + 78)
        contentView.addSubview(imageInfoLabel)
        
        let infoImage = tintedImage
        let averageColor = infoImage.averageColor()?.usingColorSpace(.deviceRGB)
        let red = Int((averageColor?.redComponent ?? 0) * 255)
        let green = Int((averageColor?.greenComponent ?? 0) * 255)
        let blue = Int((averageColor?.blueComponent ?? 0) * 255)
        let fileSize = infoImage.fileSize(format: .png) ?? 0
        imageInfoLabel.stringValue = "平均色: (\(red), \(green), \(blue))\nPNG 大小: \(fileSize) bytes"
        
        return currentOffset + 152
    }
    
    private func setupLogSection(in contentView: NSView, yOffset: CGFloat) -> CGFloat {
        var currentOffset = yOffset
        
        let sectionLabel = makeSectionLabel("组件交互日志")
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
            .string("等待组件交互...\n")
            .build
        contentView.addSubview(logTextView)
        
        appendLog("组件页已加载，可直接测试文本输入、图片处理与控件交互")
        return currentOffset + 168
    }
    
    private func updateInputState(_ text: String) {
        let isValid = customInput.validateText()
        let state = isValid ? "有效" : "需至少 4 个字符"
        inputStateLabel.stringValue = "输入状态：\(state) · 当前长度 \(text.count)/12"
    }
    
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
            .frame(NSRect(x: 0, y: 0, width: 320, height: 22))
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
    
    @objc private func handlePrimaryComponentAction() {
        appendLog("TFYSwiftButton 点击成功")
    }
    
    @objc private func toggleReadOnly() {
        let nextReadOnly = customInput.isEditable
        customInput.chain.readOnly(nextReadOnly)
        appendLog(nextReadOnly ? "自定义文本框已切换为只读" : "自定义文本框已恢复可编辑")
    }
    
    @objc private func copyInputText() {
        customInput.copyText()
        appendLog("已复制当前输入文本到剪贴板")
    }
    
    @objc private func pasteInputText() {
        customInput.pasteText()
        updateInputState(customInput.stringValue)
        appendLog("已从剪贴板粘贴文本")
    }
    
    @objc private func moveCursorToEnd() {
        let position = customInput.stringValue.count
        customInput.chain.cursorPosition(position)
        appendLog("光标已移动到文本末尾")
    }
    
    @objc private func saveProcessedImage() {
        let image = (NSImage(systemSymbolName: "swift", accessibilityDescription: nil) ?? NSImage.image(withColor: .systemBlue))
            .resized(to: NSSize(width: 120, height: 120))
            .tintedImage(withColor: .systemPurple)
            .roundedImage(cornerRadius: 24)
        
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("TFYSwiftMacOSAppKit_component_demo.png")
        
        do {
            try image.save(to: destination, format: .png)
            appendLog("处理图像已保存到: \(destination.path)")
        } catch {
            appendLog("处理图像保存失败: \(error.localizedDescription)")
        }
    }
    
    @objc private func clearLog() {
        logTextView.string = ""
    }
}
