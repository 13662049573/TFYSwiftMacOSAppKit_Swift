//
//  ChainDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

final class ChainDemoViewController: NSViewController {

    private var materialPreviewView: NSVisualEffectView!
    private var containerStatusLabel: TFYSwiftLabel!
    private var asyncStatusLabel: TFYSwiftLabel!
    private var observableValueLabel: TFYSwiftLabel!

    // Library's Observable<Value> property wrapper used as a plain stored variable
    private var observableDemo = Observable<Int>(wrappedValue: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChainDemo()
        setupObservableCallback()
    }

    // Register onChange callback after the label is created
    private func setupObservableCallback() {
        observableDemo.setOnChange { [weak self] newValue in
            DispatchQueue.main.async {
                self?.observableValueLabel?.stringValue = "当前值: \(newValue)  ✅ onChange 已触发"
            }
        }
    }

    // MARK: - Root Setup

    private func setupChainDemo() {
        // Wrap everything in a scroll view so all demo sections are reachable
        let scrollView = NSScrollView().chain
            .hasVerticalScroller(true)
            .hasHorizontalScroller(false)
            .autohidesScrollers(true)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // FlippedScrollContent uses isFlipped=true so y:0 is the TOP — the same y values
        // the original frame-based code used are now read top-down, which is natural for scrolling.
        let contentView = DemoFlippedDocumentView(frame: NSRect(x: 0, y: 0, width: 780, height: 1220))
        scrollView.documentView = contentView

        // Title
        let titleLabel = TFYSwiftLabel().chain
            .text("链式调用高级演示")
            .font(.boldSystemFont(ofSize: 20))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 20, width: 300, height: 30))
            .build
        contentView.addSubview(titleLabel)

        createButtonExamples(in: contentView)
        createTextFieldExamples(in: contentView)
        createLayerExamples(in: contentView)
        createGestureExamples(in: contentView)
        createContainerExamples(in: contentView)
        createConcurrencyExamples(in: contentView)
        createObservableExamples(in: contentView)
    }

    // MARK: - Existing Sections (unchanged)

    private func createButtonExamples(in containerView: NSView) {
        let sectionLabel = TFYSwiftLabel().chain
            .text("按钮链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 70, width: 200, height: 20))
            .build
        containerView.addSubview(sectionLabel)

        let basicButton = NSButton().chain
            .frame(NSRect(x: 20, y: 100, width: 120, height: 30))
            .addTarget(self, action: #selector(basicButtonAction))
            .title("基础按钮")
            .font(.systemFont(ofSize: 14))
            .textColor(.white)
            .backgroundColor(.systemBlue)
            .bordered(false)
            .bezelStyle(.rounded)
            .build
        containerView.addSubview(basicButton)

        let iconButton = NSButton().chain
            .frame(NSRect(x: 160, y: 100, width: 120, height: 30))
            .title("图标按钮")
            .image(NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)!)
            .imagePosition(.imageLeft)
            .imageScaling(.scaleProportionallyDown)
            .font(.systemFont(ofSize: 14))
            .addTarget(self, action: #selector(iconButtonAction))
            .build
        containerView.addSubview(iconButton)

        let switchButton = NSButton().chain
            .frame(NSRect(x: 300, y: 100, width: 120, height: 30))
            .setButtonType(.switch)
            .title("开关")
            .state(.on)
            .addTarget(self, action: #selector(switchButtonAction))
            .build
        containerView.addSubview(switchButton)
    }

    private func createTextFieldExamples(in containerView: NSView) {
        let sectionLabel = TFYSwiftLabel().chain
            .text("文本框链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 150, width: 200, height: 20))
            .build
        containerView.addSubview(sectionLabel)

        let basicTextField = NSTextField().chain
            .frame(NSRect(x: 20, y: 180, width: 200, height: 30))
            .placeholder("请输入文本")
            .font(.systemFont(ofSize: 14))
            .textColor(.labelColor)
            .backgroundColor(.controlBackgroundColor)
            .bordered(true)
            .bezeled(true)
            .editable(true)
            .selectable(true)
            .delegate(self)
            .build
        containerView.addSubview(basicTextField)

        let secureTextField = NSSecureTextField().chain
            .frame(NSRect(x: 240, y: 180, width: 200, height: 30))
            .placeholder("请输入密码")
            .font(.systemFont(ofSize: 14))
            .textColor(.labelColor)
            .backgroundColor(.controlBackgroundColor)
            .bordered(true)
            .bezeled(true)
            .editable(true)
            .selectable(true)
            .build
        containerView.addSubview(secureTextField)

        let searchField = NSSearchField().chain
            .frame(NSRect(x: 460, y: 180, width: 200, height: 30))
            .placeholder("搜索...")
            .font(.systemFont(ofSize: 14))
            .addTarget(self, action: #selector(searchFieldAction))
            .build
        containerView.addSubview(searchField)
    }

    private func createLayerExamples(in containerView: NSView) {
        let sectionLabel = TFYSwiftLabel().chain
            .text("图层链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 230, width: 200, height: 20))
            .build
        containerView.addSubview(sectionLabel)

        let layerView = NSView().chain
            .frame(NSRect(x: 20, y: 260, width: 150, height: 100))
            .wantsLayer(true)
            .layer(CALayer())
            .build
        layerView.layer?.chain
            .backgroundColor(NSColor.systemGreen.cgColor)
            .cornerRadius(10)
            .borderWidth(2)
            .borderColor(NSColor.systemBlue.cgColor)
            .shadowColor(NSColor.black.cgColor)
            .shadowOffset(CGSize(width: 2, height: 2))
            .shadowOpacity(0.5)
            .shadowRadius(4)
        containerView.addSubview(layerView)

        let gradientView = NSView().chain
            .frame(NSRect(x: 190, y: 260, width: 150, height: 100))
            .wantsLayer(true)
            .build
        let gradientLayer = CAGradientLayer()
        gradientLayer.chain
            .frame(gradientView.bounds)
            .colors([NSColor.systemRed.cgColor, NSColor.systemYellow.cgColor, NSColor.systemGreen.cgColor])
            .locations([0.0, 0.5, 1.0])
            .startPoint(CGPoint(x: 0, y: 0))
            .endPoint(CGPoint(x: 1, y: 1))
            .cornerRadius(10)
        gradientView.layer = gradientLayer
        containerView.addSubview(gradientView)

        let shapeView = NSView().chain
            .frame(NSRect(x: 360, y: 260, width: 150, height: 100))
            .wantsLayer(true)
            .build
        let shapeLayer = CAShapeLayer()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 75, y: 10))
        path.line(to: NSPoint(x: 140, y: 90))
        path.line(to: NSPoint(x: 10, y: 90))
        path.close()
        if #available(macOS 14.0, *) {
            shapeLayer.chain
                .path(path.cgPath)
                .fillColor(NSColor.systemOrange.cgColor)
                .strokeColor(NSColor.systemBlue.cgColor)
                .lineWidth(3)
        }
        shapeView.layer = shapeLayer
        containerView.addSubview(shapeView)
    }

    private func createGestureExamples(in containerView: NSView) {
        let sectionLabel = TFYSwiftLabel().chain
            .text("手势识别链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 380, width: 200, height: 20))
            .build
        containerView.addSubview(sectionLabel)

        let clickView = NSView().chain
            .frame(NSRect(x: 20, y: 410, width: 120, height: 80))
            .backgroundColor(.systemBlue)
            .wantsLayer(true)
            .layer(CALayer())
            .build
        clickView.layer?.chain
            .cornerRadius(8)
            .borderWidth(1)
            .borderColor(NSColor.systemGray.cgColor)

        let clickGesture = NSClickGestureRecognizer()
        clickGesture.chain
            .target(self)
            .action(#selector(handleClickGesture))
            .numberOfClicksRequired(1)
            .numberOfTouchesRequired(1)
        clickView.addGestureRecognizer(clickGesture)
        containerView.addSubview(clickView)

        let panView = NSView().chain
            .frame(NSRect(x: 160, y: 410, width: 120, height: 80))
            .backgroundColor(.systemGreen)
            .wantsLayer(true)
            .layer(CALayer())
            .build
        panView.layer?.chain
            .cornerRadius(8)
            .borderWidth(1)
            .borderColor(NSColor.systemGray.cgColor)

        let panGesture = NSPanGestureRecognizer()
        panGesture.chain
            .target(self)
            .action(#selector(handlePanGesture))
        panView.addGestureRecognizer(panGesture)
        containerView.addSubview(panView)

        let rotationView = NSView().chain
            .frame(NSRect(x: 300, y: 410, width: 120, height: 80))
            .backgroundColor(.systemOrange)
            .wantsLayer(true)
            .layer(CALayer())
            .build
        rotationView.layer?.chain
            .cornerRadius(8)
            .borderWidth(1)
            .borderColor(NSColor.systemGray.cgColor)

        let rotationGesture = NSRotationGestureRecognizer()
        rotationGesture.chain
            .target(self)
            .action(#selector(handleRotationGesture))
        rotationView.addGestureRecognizer(rotationGesture)
        containerView.addSubview(rotationView)

        let instructionLabel = TFYSwiftLabel().chain
            .frame(NSRect(x: 20, y: 500, width: 400, height: 40))
            .text("点击蓝色区域、拖拽绿色区域、旋转橙色区域来测试手势识别")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .alignment(.center)
            .build
        containerView.addSubview(instructionLabel)
    }

    private func createContainerExamples(in containerView: NSView) {
        let sectionLabel = TFYSwiftLabel().chain
            .text("容器与视觉效果链式调用")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 560, width: 240, height: 20))
            .build
        containerView.addSubview(sectionLabel)

        materialPreviewView = NSVisualEffectView().chain
            .frame(NSRect(x: 20, y: 590, width: 260, height: 120))
            .material(.sidebar)
            .blendingMode(.withinWindow)
            .state(.active)
            .wantsLayer(true)
            .cornerRadius(16)
            .build
        containerView.addSubview(materialPreviewView)

        let previewTitleLabel = TFYSwiftLabel().chain
            .text("NSVisualEffectView")
            .font(.systemFont(ofSize: 15, weight: .semibold))
            .textColor(.labelColor)
            .drawsBackground(false)
            .frame(NSRect(x: 18, y: 18, width: 180, height: 20))
            .build
        materialPreviewView.addSubview(previewTitleLabel)

        let previewSubtitleLabel = TFYSwiftLabel().chain
            .text("通过链式配置快速切换 material / state / blendingMode")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .wraps(true)
            .maximumNumberOfLines(0)
            .drawsBackground(false)
            .frame(NSRect(x: 18, y: 46, width: 220, height: 38))
            .build
        materialPreviewView.addSubview(previewSubtitleLabel)

        let materialPopup = NSPopUpButton().chain
            .frame(NSRect(x: 300, y: 598, width: 150, height: 28))
            .addItems(["Sidebar", "Popover", "Header"])
            .selectItem(0)
            .addTarget(self, action: #selector(handleMaterialSelectionChange))
            .build
        containerView.addSubview(materialPopup)

        let stackView = NSStackView().chain
            .frame(NSRect(x: 300, y: 646, width: 360, height: 56))
            .orientation(.horizontal)
            .distribution(.fillEqually)
            .alignment(.centerY)
            .spacing(10)
            .edgeInsets(NSEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
            .build
        stackView.chain
            .addArrangedSubview(makeBadgeView(title: "StackView", color: .systemBlue))
            .addArrangedSubview(makeBadgeView(title: "VisualEffect", color: .systemPurple))
            .addArrangedSubview(makeBadgeView(title: "PopUpButton", color: .systemGreen))
        containerView.addSubview(stackView)

        containerStatusLabel = TFYSwiftLabel().chain
            .frame(NSRect(x: 300, y: 636, width: 360, height: 18))
            .text("当前材质：Sidebar")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .build
        containerView.addSubview(containerStatusLabel)
    }

    private func makeBadgeView(title: String, color: NSColor) -> NSView {
        let badgeView = NSView().chain
            .frame(NSRect(x: 0, y: 0, width: 108, height: 36))
            .wantsLayer(true)
            .backgroundColor(color.withAlphaComponent(0.14))
            .cornerRadius(12)
            .borderWidth(1)
            .borderColor(color.withAlphaComponent(0.25))
            .build

        let badgeLabel = TFYSwiftLabel().chain
            .text(title)
            .font(.systemFont(ofSize: 12, weight: .medium))
            .textColor(color)
            .alignment(.center)
            .drawsBackground(false)
            .frame(NSRect(x: 8, y: 8, width: 92, height: 18))
            .build
        badgeView.addSubview(badgeLabel)
        return badgeView
    }

    // MARK: - New: Swift Concurrency Section

    private func createConcurrencyExamples(in containerView: NSView) {
        let sectionLabel = TFYSwiftLabel().chain
            .text("Swift Concurrency 链式调用")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 760, width: 280, height: 20))
            .build
        containerView.addSubview(sectionLabel)

        asyncStatusLabel = TFYSwiftLabel().chain
            .text("点击下方按钮查看 asyncAwait / onMainActor 链式调用结果")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.controlBackgroundColor)
            .bordered(true)
            .bezeled(true)
            .editable(false)
            .selectable(false)
            .wraps(true)
            .maximumNumberOfLines(3)
            .frame(NSRect(x: 20, y: 790, width: 640, height: 48))
            .build
        containerView.addSubview(asyncStatusLabel)

        let asyncAwaitButton = NSButton().chain
            .frame(NSRect(x: 20, y: 848, width: 190, height: 30))
            .title("asyncAwait { } 演示")
            .font(.systemFont(ofSize: 13))
            .bezelStyle(.rounded)
            .addTarget(self, action: #selector(triggerAsyncAwait))
            .build
        containerView.addSubview(asyncAwaitButton)

        let mainActorButton = NSButton().chain
            .frame(NSRect(x: 228, y: 848, width: 190, height: 30))
            .title("onMainActor { } 演示")
            .font(.systemFont(ofSize: 13))
            .bezelStyle(.rounded)
            .addTarget(self, action: #selector(triggerMainActor))
            .build
        containerView.addSubview(mainActorButton)

        let descLabel = TFYSwiftLabel().chain
            .frame(NSRect(x: 20, y: 890, width: 640, height: 48))
            .text("asyncAwait(_:) 通过 Task { await op(base) } 封装 async 闭包，返回 Chain<Base> 可继续链式；onMainActor(_:) 通过 Task { @MainActor in op(base) } 保证在主线程执行 UI 更新，两者均为 @available(macOS 10.15, *)。")
            .font(.systemFont(ofSize: 11))
            .textColor(.tertiaryLabelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .wraps(true)
            .maximumNumberOfLines(0)
            .build
        containerView.addSubview(descLabel)
    }

    // MARK: - New: Observable Section

    private func createObservableExamples(in containerView: NSView) {
        let sectionLabel = TFYSwiftLabel().chain
            .text("Observable 属性包装器")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 960, width: 260, height: 20))
            .build
        containerView.addSubview(sectionLabel)

        observableValueLabel = TFYSwiftLabel().chain
            .text("当前值: 0  (等待操作…)")
            .font(.monospacedSystemFont(ofSize: 13, weight: .regular))
            .textColor(.labelColor)
            .backgroundColor(.controlBackgroundColor)
            .bordered(true)
            .bezeled(true)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 990, width: 400, height: 30))
            .build
        containerView.addSubview(observableValueLabel)

        let incrementButton = NSButton().chain
            .frame(NSRect(x: 20, y: 1030, width: 160, height: 30))
            .title("值 +1 (触发 onChange)")
            .font(.systemFont(ofSize: 12))
            .bezelStyle(.rounded)
            .addTarget(self, action: #selector(incrementObservable))
            .build
        containerView.addSubview(incrementButton)

        let setIfChangedButton = NSButton().chain
            .frame(NSRect(x: 196, y: 1030, width: 180, height: 30))
            .title("setIfChanged(相同值) — 不触发")
            .font(.systemFont(ofSize: 12))
            .bezelStyle(.rounded)
            .addTarget(self, action: #selector(setIfChangedSameValue))
            .build
        containerView.addSubview(setIfChangedButton)

        let resetButton = NSButton().chain
            .frame(NSRect(x: 392, y: 1030, width: 80, height: 30))
            .title("重置为 0")
            .font(.systemFont(ofSize: 12))
            .bezelStyle(.rounded)
            .addTarget(self, action: #selector(resetObservable))
            .build
        containerView.addSubview(resetButton)

        let descLabel = TFYSwiftLabel().chain
            .frame(NSRect(x: 20, y: 1072, width: 640, height: 64))
            .text("Observable<Value> 是库内置属性包装器：setOnChange(_:) 注册变化回调；setIfChanged(_:) 仅当新值与当前值不同时才赋值并触发回调（防抖）；projectedValue 返回 Observable<Value> 自身，可继续链式调用。\n通过 _observableDemo 或直接变量名访问包装器实例，调用 mutating 方法需要 var 存储属性。")
            .font(.systemFont(ofSize: 11))
            .textColor(.tertiaryLabelColor)
            .drawsBackground(false)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .wraps(true)
            .maximumNumberOfLines(0)
            .build
        containerView.addSubview(descLabel)
    }

    // MARK: - Action Methods (existing)

    @objc private func basicButtonAction() {
        let alert = NSAlert()
        alert.messageText = "基础按钮"
        alert.informativeText = "这是一个基础按钮的链式调用示例"
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }

    @objc private func iconButtonAction() {
        let alert = NSAlert()
        alert.messageText = "图标按钮"
        alert.informativeText = "这是一个带图标的按钮示例"
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }

    @objc private func switchButtonAction(_ sender: NSButton) {
        let state = sender.state == .on ? "开启" : "关闭"
        print("开关状态: \(state)")
    }

    @objc private func searchFieldAction(_ sender: NSSearchField) {
        print("搜索内容: \(sender.stringValue)")
    }

    @objc private func handleMaterialSelectionChange(_ sender: NSPopUpButton) {
        let material: NSVisualEffectView.Material
        let title: String
        switch sender.indexOfSelectedItem {
        case 1:  material = .popover;    title = "Popover"
        case 2:  material = .headerView; title = "Header"
        default: material = .sidebar;    title = "Sidebar"
        }
        materialPreviewView.material = material
        containerStatusLabel.stringValue = "当前材质：\(title) · 由 NSPopUpButton 链式配置切换"
    }

    @objc private func handleClickGesture(_ sender: NSClickGestureRecognizer) {
        let alert = NSAlert()
        alert.messageText = "点击手势"
        alert.informativeText = "检测到点击手势"
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }

    @objc private func handlePanGesture(_ sender: NSPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        print("拖拽手势 - 位移: \(translation)")
    }

    @objc private func handleRotationGesture(_ sender: NSRotationGestureRecognizer) {
        print("旋转手势 - 角度: \(sender.rotation)")
    }

    // MARK: - Action Methods (concurrency)

    @objc private func triggerAsyncAwait() {
        asyncStatusLabel.stringValue = "⏳ asyncAwait 已触发，模拟 0.8s 异步操作中…"
        asyncStatusLabel.chain.asyncAwait { label in
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run {
                label.stringValue = "✅ asyncAwait 完成：async 闭包在 Task 内执行，await MainActor.run 回到主线程更新 UI"
            }
        }
    }

    @objc private func triggerMainActor() {
        asyncStatusLabel.chain.onMainActor { label in
            label.stringValue = "✅ onMainActor 已执行：Task @MainActor 确保在主线程运行 (\(Date().formatted(.dateTime.hour().minute().second())))"
        }
    }

    // MARK: - Action Methods (Observable)

    @objc private func incrementObservable() {
        observableDemo.wrappedValue += 1
    }

    @objc private func setIfChangedSameValue() {
        let current = observableDemo.wrappedValue
        // setIfChanged with the SAME value — onChange must NOT fire
        observableDemo.setIfChanged(current)
        observableValueLabel.stringValue = "当前值: \(current)  ⚠️ setIfChanged(\(current)) → 值相同，onChange 未触发"
    }

    @objc private func resetObservable() {
        observableDemo.wrappedValue = 0
    }
}

// MARK: - NSTextFieldDelegate
extension ChainDemoViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            print("文本框内容变化: \(textField.stringValue)")
        }
    }
}
