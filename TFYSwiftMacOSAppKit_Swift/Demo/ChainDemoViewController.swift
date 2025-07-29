//
//  ChainDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class ChainDemoViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChainDemo()
    }
    
    private func setupChainDemo() {
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
            .text("链式调用高级演示")
            .font(.boldSystemFont(ofSize: 20))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 20, width: 300, height: 30))
        
        containerView.addSubview(titleLabel)
        
        // 创建按钮示例
        createButtonExamples(in: containerView)
        
        // 创建文本框示例
        createTextFieldExamples(in: containerView)
        
        // 创建图层示例
        createLayerExamples(in: containerView)
        
        // 创建手势示例
        createGestureExamples(in: containerView)
    }
    
    private func createButtonExamples(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.chain
            .text("按钮链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 70, width: 200, height: 20))
        
        containerView.addSubview(sectionLabel)
        
        // 基础按钮
        let basicButton = NSButton()
        basicButton.chain
            .frame(NSRect(x: 20, y: 100, width: 120, height: 30))
            .addTarget(self, action: #selector(basicButtonAction))
            .title("基础按钮")
            .font(.systemFont(ofSize: 14))
            .textColor(.white)
            .backgroundColor(.systemBlue)
            .bordered(false)
            .bezelStyle(.rounded)
        
        containerView.addSubview(basicButton)
        
        // 图标按钮
        let iconButton = NSButton()
        iconButton.chain
            .frame(NSRect(x: 160, y: 100, width: 120, height: 30))
            .title("图标按钮")
            .image(NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)!)
            .imagePosition(.imageLeft)
            .imageScaling(.scaleProportionallyDown)
            .font(.systemFont(ofSize: 14))
            .addTarget(self, action: #selector(iconButtonAction))
        
        containerView.addSubview(iconButton)
        
        // 开关按钮
        let switchButton = NSButton()
        switchButton.chain
            .frame(NSRect(x: 300, y: 100, width: 120, height: 30))
            .setButtonType(.switch)
            .title("开关")
            .state(.on)
            .addTarget(self, action: #selector(switchButtonAction))
        
        containerView.addSubview(switchButton)
    }
    
    private func createTextFieldExamples(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.chain
            .text("文本框链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 150, width: 200, height: 20))
        
        containerView.addSubview(sectionLabel)
        
        // 基础文本框
        let basicTextField = NSTextField()
        basicTextField.chain
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
        
        containerView.addSubview(basicTextField)
        
        // 密码文本框
        let secureTextField = NSSecureTextField()
        secureTextField.chain
            .frame(NSRect(x: 240, y: 180, width: 200, height: 30))
            .placeholder("请输入密码")
            .font(.systemFont(ofSize: 14))
            .textColor(.labelColor)
            .backgroundColor(.controlBackgroundColor)
            .bordered(true)
            .bezeled(true)
            .editable(true)
            .selectable(true)
        
        containerView.addSubview(secureTextField)
        
        // 搜索框
        let searchField = NSSearchField()
        searchField.chain
            .frame(NSRect(x: 460, y: 180, width: 200, height: 30))
            .placeholder("搜索...")
            .font(.systemFont(ofSize: 14))
            .addTarget(self, action: #selector(searchFieldAction))

        containerView.addSubview(searchField)
    }
    
    private func createLayerExamples(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.chain
            .text("图层链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 230, width: 200, height: 20))
        
        containerView.addSubview(sectionLabel)
        
        // 基础图层视图
        let layerView = NSView()
        layerView.chain
            .frame(NSRect(x: 20, y: 260, width: 150, height: 100))
            .wantsLayer(true)
            .layer(CALayer())
        
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
        
        // 渐变图层视图
        let gradientView = NSView()
        gradientView.chain
            .frame(NSRect(x: 190, y: 260, width: 150, height: 100))
            .wantsLayer(true)
        
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
        
        // 形状图层视图
        let shapeView = NSView()
        shapeView.chain
            .frame(NSRect(x: 360, y: 260, width: 150, height: 100))
            .wantsLayer(true)
        
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
        } else {
            // Fallback on earlier versions
        }
        
        shapeView.layer = shapeLayer
        containerView.addSubview(shapeView)
    }
    
    private func createGestureExamples(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.chain
            .text("手势识别链式调用示例")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 380, width: 200, height: 20))
        
        containerView.addSubview(sectionLabel)
        
        // 点击手势视图
        let clickView = NSView()
        clickView.chain
            .frame(NSRect(x: 20, y: 410, width: 120, height: 80))
            .backgroundColor(.systemBlue)
            .wantsLayer(true)
            .layer(CALayer())
        
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
        
        // 拖拽手势视图
        let panView = NSView()
        panView.chain
            .frame(NSRect(x: 160, y: 410, width: 120, height: 80))
            .backgroundColor(.systemGreen)
            .wantsLayer(true)
            .layer(CALayer())
        
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
        
        // 旋转手势视图
        let rotationView = NSView()
        rotationView.chain
            .frame(NSRect(x: 300, y: 410, width: 120, height: 80))
            .backgroundColor(.systemOrange)
            .wantsLayer(true)
            .layer(CALayer())
        
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
        
        // 说明标签
        let instructionLabel = NSTextField()
        instructionLabel.chain
            .frame(NSRect(x: 20, y: 500, width: 400, height: 40))
            .text("点击蓝色区域、拖拽绿色区域、旋转橙色区域来测试手势识别")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .alignment(.center)
        
        containerView.addSubview(instructionLabel)
    }
    
    // MARK: - Action Methods
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
        let rotation = sender.rotation
        print("旋转手势 - 角度: \(rotation)")
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
