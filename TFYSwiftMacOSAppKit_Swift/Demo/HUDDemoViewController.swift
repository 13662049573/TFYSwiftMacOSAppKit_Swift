//
//  HUDDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class HUDDemoViewController: NSViewController {
    
    private var currentHUD: TFYProgressMacOSHUD?
    private var themeManager: TFYThemeManager?
    private var animationEnhancer: TFYAnimationEnhancer?
    
    // UI Elements
    private var themePopUp: NSPopUpButton!
    private var animationPopUp: NSPopUpButton!
    private var positionPopUp: NSPopUpButton!
    private var autoHideSwitch: NSButton!
    private var delayTextField: NSTextField!
    private var durationTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHUDDemo()
    }
    
    private func setupHUDDemo() {
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        view.addSubview(scrollView)
        
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = containerView
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        // 创建标题
        let titleLabel = NSTextField()
        titleLabel.stringValue = "TFYProgressMacOSHUD 功能演示"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = .labelColor
        titleLabel.backgroundColor = .clear
        titleLabel.isBordered = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 20, y: 20, width: 600, height: 40)
        
        containerView.addSubview(titleLabel)
        
        // 创建HUD类型选择区域
        createHUDTypeSection(in: containerView)
        
        // 创建HUD配置区域
        createHUDConfigSection(in: containerView)
        
        // 创建高级功能区域
        createAdvancedSection(in: containerView)
        
        // 创建说明区域
        createInstructionSection(in: containerView)
        
        // 初始化管理器
        themeManager = TFYThemeManager()
        animationEnhancer = TFYAnimationEnhancer()
        
        // 设置文档视图高度以便滚动
        containerView.frame.size.height = 680
    }
    
    private func createHUDTypeSection(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.stringValue = "HUD类型演示"
        sectionLabel.font = .boldSystemFont(ofSize: 18)
        sectionLabel.textColor = .labelColor
        sectionLabel.backgroundColor = .clear
        sectionLabel.isBordered = false
        sectionLabel.isEditable = false
        sectionLabel.isSelectable = false
        sectionLabel.frame = NSRect(x: 20, y: 80, width: 200, height: 25)
        
        containerView.addSubview(sectionLabel)
        
        // 第一行按钮
        let loadingButton = createButton(title: "加载HUD", action: #selector(showLoadingHUD), frame: NSRect(x: 20, y: 120, width: 120, height: 35))
        containerView.addSubview(loadingButton)
        
        let progressButton = createButton(title: "进度HUD", action: #selector(showProgressHUD), frame: NSRect(x: 160, y: 120, width: 120, height: 35))
        containerView.addSubview(progressButton)
        
        let successButton = createButton(title: "成功HUD", action: #selector(showSuccessHUD), frame: NSRect(x: 300, y: 120, width: 120, height: 35))
        containerView.addSubview(successButton)
        
        let errorButton = createButton(title: "错误HUD", action: #selector(showErrorHUD), frame: NSRect(x: 440, y: 120, width: 120, height: 35))
        containerView.addSubview(errorButton)
        
        // 第二行按钮
        let textButton = createButton(title: "文本HUD", action: #selector(showTextHUD), frame: NSRect(x: 20, y: 165, width: 120, height: 35))
        containerView.addSubview(textButton)
        
        let infoButton = createButton(title: "信息HUD", action: #selector(showInfoHUD), frame: NSRect(x: 160, y: 165, width: 120, height: 35))
        containerView.addSubview(infoButton)
        
        let customButton = createButton(title: "自定义HUD", action: #selector(showCustomHUD), frame: NSRect(x: 300, y: 165, width: 120, height: 35))
        containerView.addSubview(customButton)
        
        let hideButton = createButton(title: "隐藏HUD", action: #selector(hideHUD), frame: NSRect(x: 440, y: 165, width: 120, height: 35))
        containerView.addSubview(hideButton)
    }
    
    private func createHUDConfigSection(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.stringValue = "HUD配置选项"
        sectionLabel.font = .boldSystemFont(ofSize: 18)
        sectionLabel.textColor = .labelColor
        sectionLabel.backgroundColor = .clear
        sectionLabel.isBordered = false
        sectionLabel.isEditable = false
        sectionLabel.isSelectable = false
        sectionLabel.frame = NSRect(x: 20, y: 220, width: 200, height: 25)
        
        containerView.addSubview(sectionLabel)
        
        // 主题选择
        let themeLabel = createLabel(text: "主题:", frame: NSRect(x: 20, y: 260, width: 60, height: 20))
        containerView.addSubview(themeLabel)
        
        themePopUp = NSPopUpButton()
        themePopUp.frame = NSRect(x: 90, y: 260, width: 120, height: 20)
        themePopUp.addItems(withTitles: ["深色", "浅色", "蓝色", "绿色", "紫色", "橙色", "系统"])
        themePopUp.selectItem(at: 0)
        themePopUp.target = self
        themePopUp.action = #selector(themeChanged)
        containerView.addSubview(themePopUp)
        
        // 动画选择
        let animationLabel = createLabel(text: "动画:", frame: NSRect(x: 230, y: 260, width: 60, height: 20))
        containerView.addSubview(animationLabel)
        
        animationPopUp = NSPopUpButton()
        animationPopUp.frame = NSRect(x: 300, y: 260, width: 120, height: 20)
        animationPopUp.addItems(withTitles: ["淡入淡出", "缩放", "滑动", "旋转", "弹跳", "弹性", "自定义"])
        animationPopUp.selectItem(at: 0)
        animationPopUp.target = self
        animationPopUp.action = #selector(animationChanged)
        containerView.addSubview(animationPopUp)
        
        // 位置选择
        let positionLabel = createLabel(text: "位置:", frame: NSRect(x: 440, y: 260, width: 60, height: 20))
        containerView.addSubview(positionLabel)
        
        positionPopUp = NSPopUpButton()
        positionPopUp.frame = NSRect(x: 510, y: 260, width: 120, height: 20)
        positionPopUp.addItems(withTitles: ["居中", "顶部", "底部", "左上", "右上", "左下", "右下"])
        positionPopUp.selectItem(at: 0)
        positionPopUp.target = self
        positionPopUp.action = #selector(positionChanged)
        containerView.addSubview(positionPopUp)
        
        // 自动隐藏开关
        let autoHideLabel = createLabel(text: "自动隐藏:", frame: NSRect(x: 20, y: 300, width: 80, height: 20))
        containerView.addSubview(autoHideLabel)
        
        autoHideSwitch = NSButton()
        autoHideSwitch.frame = NSRect(x: 110, y: 300, width: 60, height: 20)
        autoHideSwitch.setButtonType(.switch)
        autoHideSwitch.title = ""
        autoHideSwitch.state = .on
        autoHideSwitch.target = self
        autoHideSwitch.action = #selector(autoHideChanged)
        containerView.addSubview(autoHideSwitch)
        
        // 隐藏延迟
        let delayLabel = createLabel(text: "隐藏延迟(秒):", frame: NSRect(x: 200, y: 300, width: 100, height: 20))
        containerView.addSubview(delayLabel)
        
        delayTextField = NSTextField()
        delayTextField.frame = NSRect(x: 310, y: 300, width: 60, height: 20)
        delayTextField.stringValue = "2.0"
        delayTextField.font = .systemFont(ofSize: 12)
        delayTextField.textColor = .labelColor
        delayTextField.backgroundColor = .controlBackgroundColor
        delayTextField.isBordered = true
        delayTextField.isBezeled = true
        delayTextField.isEditable = true
        delayTextField.isSelectable = true
        containerView.addSubview(delayTextField)
        
        // 动画持续时间
        let durationLabel = createLabel(text: "动画时长(秒):", frame: NSRect(x: 390, y: 300, width: 100, height: 20))
        containerView.addSubview(durationLabel)
        
        durationTextField = NSTextField()
        durationTextField.frame = NSRect(x: 500, y: 300, width: 60, height: 20)
        durationTextField.stringValue = "0.3"
        durationTextField.font = .systemFont(ofSize: 12)
        durationTextField.textColor = .labelColor
        durationTextField.backgroundColor = .controlBackgroundColor
        durationTextField.isBordered = true
        durationTextField.isBezeled = true
        durationTextField.isEditable = true
        durationTextField.isSelectable = true
        containerView.addSubview(durationTextField)
    }
    
    private func createAdvancedSection(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.stringValue = "高级功能演示"
        sectionLabel.font = .boldSystemFont(ofSize: 18)
        sectionLabel.textColor = .labelColor
        sectionLabel.backgroundColor = .clear
        sectionLabel.isBordered = false
        sectionLabel.isEditable = false
        sectionLabel.isSelectable = false
        sectionLabel.frame = NSRect(x: 20, y: 350, width: 200, height: 25)
        
        containerView.addSubview(sectionLabel)
        
        // 高级功能按钮
        let shakeButton = createButton(title: "抖动动画", action: #selector(showShakeAnimation), frame: NSRect(x: 20, y: 390, width: 120, height: 35))
        containerView.addSubview(shakeButton)
        
        let pulseButton = createButton(title: "脉冲动画", action: #selector(showPulseAnimation), frame: NSRect(x: 160, y: 390, width: 120, height: 35))
        containerView.addSubview(pulseButton)
        
        let successAnimButton = createButton(title: "成功动画", action: #selector(showSuccessAnimation), frame: NSRect(x: 300, y: 390, width: 120, height: 35))
        containerView.addSubview(successAnimButton)
        
        let errorAnimButton = createButton(title: "错误动画", action: #selector(showErrorAnimation), frame: NSRect(x: 440, y: 390, width: 120, height: 35))
        containerView.addSubview(errorAnimButton)
        
        // 进度视图样式演示
        let ringProgressButton = createButton(title: "环形进度", action: #selector(showRingProgress), frame: NSRect(x: 20, y: 435, width: 120, height: 35))
        containerView.addSubview(ringProgressButton)
        
        let horizontalProgressButton = createButton(title: "水平进度", action: #selector(showHorizontalProgress), frame: NSRect(x: 160, y: 435, width: 120, height: 35))
        containerView.addSubview(horizontalProgressButton)
        
        let pieProgressButton = createButton(title: "饼图进度", action: #selector(showPieProgress), frame: NSRect(x: 300, y: 435, width: 120, height: 35))
        containerView.addSubview(pieProgressButton)
        
        let percentageProgressButton = createButton(title: "百分比进度", action: #selector(showPercentageProgress), frame: NSRect(x: 440, y: 435, width: 120, height: 35))
        containerView.addSubview(percentageProgressButton)
        
        // 位置演示按钮
        let centerButton = createButton(title: "居中显示", action: #selector(showCenterHUD), frame: NSRect(x: 20, y: 480, width: 120, height: 35))
        containerView.addSubview(centerButton)
        
        let topButton = createButton(title: "顶部显示", action: #selector(showTopHUD), frame: NSRect(x: 160, y: 480, width: 120, height: 35))
        containerView.addSubview(topButton)
        
        let bottomButton = createButton(title: "底部显示", action: #selector(showBottomHUD), frame: NSRect(x: 300, y: 480, width: 120, height: 35))
        containerView.addSubview(bottomButton)
        
        let cornerButton = createButton(title: "角落显示", action: #selector(showCornerHUD), frame: NSRect(x: 440, y: 480, width: 120, height: 35))
        containerView.addSubview(cornerButton)
    }
    
    private func createInstructionSection(in containerView: NSView) {
        let sectionLabel = NSTextField()
        sectionLabel.stringValue = "使用说明"
        sectionLabel.font = .boldSystemFont(ofSize: 18)
        sectionLabel.textColor = .labelColor
        sectionLabel.backgroundColor = .clear
        sectionLabel.isBordered = false
        sectionLabel.isEditable = false
        sectionLabel.isSelectable = false
        sectionLabel.frame = NSRect(x: 20, y: 530, width: 200, height: 25)
        
        containerView.addSubview(sectionLabel)
        
        let instructionLabel = NSTextField()
        instructionLabel.frame = NSRect(x: 20, y: 560, width: 600, height: 110)
        instructionLabel.stringValue = """
        使用说明:
        
        1. HUD类型演示: 点击不同类型的HUD按钮查看效果
           - 加载HUD: 显示旋转的加载指示器
           - 进度HUD: 显示进度条和进度值
           - 成功/错误/信息HUD: 显示相应的图标和消息
           - 文本HUD: 只显示文本消息
           - 自定义HUD: 显示自定义图像
        
        2. 配置选项:
           - 主题: 选择不同的颜色主题
           - 动画: 选择不同的显示/隐藏动画效果
           - 位置: 选择HUD在屏幕上的显示位置
           - 自动隐藏: 控制是否自动隐藏HUD
           - 隐藏延迟: 设置自动隐藏的延迟时间
           - 动画时长: 设置动画的持续时间
        
        3. 高级功能:
           - 抖动动画: 为HUD添加抖动效果
           - 脉冲动画: 为HUD添加脉冲效果
           - 成功/错误动画: 特殊的成功和错误动画
           - 位置演示: 在不同位置显示HUD
        
        4. 编程接口:
           - TFYProgressMacOSHUD.showSuccess("消息")
           - TFYProgressMacOSHUD.showError("消息")
           - TFYProgressMacOSHUD.showLoading("消息")
           - TFYProgressMacOSHUD.showProgress(0.5, status: "进度")
        """
        instructionLabel.font = .systemFont(ofSize: 12)
        instructionLabel.textColor = .secondaryLabelColor
        instructionLabel.backgroundColor = .clear
        instructionLabel.isBordered = false
        instructionLabel.isEditable = false
        instructionLabel.isSelectable = false
        instructionLabel.alignment = .left
        instructionLabel.cell?.wraps = true
        instructionLabel.cell?.isScrollable = false
        instructionLabel.maximumNumberOfLines = 0
        
        containerView.addSubview(instructionLabel)
    }
    
    // MARK: - Helper Methods
    private func createButton(title: String, action: Selector, frame: NSRect) -> NSButton {
        let button = NSButton()
        button.frame = frame
        button.title = title
        button.font = .systemFont(ofSize: 12)
        button.bezelStyle = .rounded
        button.target = self
        button.action = action
        return button
    }
    
    private func createLabel(text: String, frame: NSRect) -> NSTextField {
        let label = NSTextField()
        label.stringValue = text
        label.font = .systemFont(ofSize: 12)
        label.textColor = .labelColor
        label.backgroundColor = .clear
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.frame = frame
        return label
    }
    
    private func getCurrentPosition() -> TFYHUDPosition {
        switch positionPopUp.indexOfSelectedItem {
        case 0: return .center
        case 1: return .top
        case 2: return .bottom
        case 3: return .topLeft
        case 4: return .topRight
        case 5: return .bottomLeft
        case 6: return .bottomRight
        default: return .center
        }
    }
    
    private func getCurrentAnimationType() -> TFYAnimationType {
        switch animationPopUp.indexOfSelectedItem {
        case 0: return .fade
        case 1: return .scale
        case 2: return .slide
        case 3: return .rotate
        case 4: return .bounce
        case 5: return .elastic
        case 6: return .custom
        default: return .fade
        }
    }

    private func getCurrentThemeName() -> String {
        switch themePopUp.indexOfSelectedItem {
        case 0: return "dark"
        case 1: return "light"
        case 2: return "customBlue"
        case 3: return "customGreen"
        case 4: return "customPurple"
        case 5: return "customOrange"
        case 6: return "system"
        default: return "dark"
        }
    }
    
    private func configureCurrentHUD() {
        guard let hud = currentHUD else { return }
        
        // 设置主题
        switch themePopUp.indexOfSelectedItem {
        case 0: hud.setTheme("dark")
        case 1: hud.setTheme("light")
        case 2: hud.setTheme("customBlue")
        case 3: hud.setTheme("customGreen")
        case 4: hud.setTheme("customPurple")
        case 5: hud.setTheme("customOrange")
        case 6: hud.setTheme("system")
        default: break
        }
        
        // 设置动画类型与时长到 HUD 自身的 animation，否则下拉框选择不会生效
        hud.setAnimationType(getCurrentAnimationType())
        if let durationText = durationTextField.stringValue.isEmpty ? nil : durationTextField.stringValue,
           let duration = Double(durationText), duration > 0 {
            hud.setAnimationDuration(duration)
        }
        
        // 设置自动隐藏
        hud.autoHide = autoHideSwitch.state == .on
        
        // 设置隐藏延迟
        if let delayText = delayTextField.stringValue.isEmpty ? nil : delayTextField.stringValue,
           let delay = Double(delayText) {
            hud.hideDelay = delay
        }
    }
    
    // MARK: - HUD Action Methods
    @objc private func showLoadingHUD() {
        hideCurrentHUD()
        
        currentHUD = TFYProgressMacOSHUD.showHUD(addedTo: view)
        currentHUD?.mode = .loading
        currentHUD?.position = getCurrentPosition()
        currentHUD?.statusLabel.stringValue = "正在加载数据..."
        configureCurrentHUD()
        currentHUD?.show()
        
        if let hud = currentHUD, hud.autoHide {
            let delay = hud.hideDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.currentHUD?.hide()
            }
        }
    }
    
    @objc private func showProgressHUD() {
        hideCurrentHUD()

        let hud = TFYProgressMacOSHUD.showHUD(addedTo: view)
        currentHUD = hud
        hud.mode = .determinate
        hud.position = getCurrentPosition()
        hud.statusLabel.stringValue = "下载进度"
        configureCurrentHUD()
        hud.show()

        // 使用 GCD 模拟进度更新，避免 Timer 在 Run Loop 非 Default 模式下不触发
        var progress: Double = 0.0
        func tick() {
            progress += 0.01
            currentHUD?.setProgress(CGFloat(progress))
            if progress >= 1.0 {
                currentHUD?.hide()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: tick)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: tick)
    }
    
    @objc private func showSuccessHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showSuccess("操作成功完成！", position: getCurrentPosition())
    }

    @objc private func showErrorHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showError("操作失败，请重试", position: getCurrentPosition())
    }

    @objc private func showTextHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showMessage("这是一个纯文本的HUD提示信息，可以显示很长的文本内容", position: getCurrentPosition())
    }

    @objc private func showInfoHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showInfo("这是一条信息提示", position: getCurrentPosition())
    }

    @objc private func showCustomHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        let customImage = createCustomImage()
        TFYProgressMacOSHUD.showImage(customImage, status: "自定义动画HUD", position: getCurrentPosition())
    }
    
    @objc private func hideHUD() {
        hideCurrentHUD()
    }
    
    // MARK: - Advanced Animation Methods
    @objc private func showShakeAnimation() {
        hideCurrentHUD()
        
        currentHUD = TFYProgressMacOSHUD.showHUD(addedTo: view)
        currentHUD?.mode = .customView
        currentHUD?.position = getCurrentPosition()
        currentHUD?.statusLabel.stringValue = "抖动动画演示"
        configureCurrentHUD()
        currentHUD?.show()
        
        // 添加抖动动画
        if let animation = animationEnhancer, let hud = currentHUD {
            animation.addShakeAnimation(to: hud.containerView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentHUD?.hide()
        }
    }
    
    @objc private func showPulseAnimation() {
        hideCurrentHUD()
        
        currentHUD = TFYProgressMacOSHUD.showHUD(addedTo: view)
        currentHUD?.mode = .customView
        currentHUD?.position = getCurrentPosition()
        currentHUD?.statusLabel.stringValue = "脉冲动画演示"
        configureCurrentHUD()
        currentHUD?.show()
        
        // 添加脉冲动画
        if let animation = animationEnhancer, let hud = currentHUD {
            animation.addPulseAnimation(to: hud.containerView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.currentHUD?.hide()
        }
    }
    
    @objc private func showSuccessAnimation() {
        hideCurrentHUD()
        
        currentHUD = TFYProgressMacOSHUD.showHUD(addedTo: view)
        currentHUD?.mode = .customView
        currentHUD?.position = getCurrentPosition()
        currentHUD?.statusLabel.stringValue = "成功动画演示"
        configureCurrentHUD()
        currentHUD?.show()
        
        // 添加成功动画
        if let animation = animationEnhancer, let hud = currentHUD {
            animation.addSuccessAnimation(to: hud.containerView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentHUD?.hide()
        }
    }
    
    @objc private func showErrorAnimation() {
        hideCurrentHUD()
        
        currentHUD = TFYProgressMacOSHUD.showHUD(addedTo: view)
        currentHUD?.mode = .customView
        currentHUD?.position = getCurrentPosition()
        currentHUD?.statusLabel.stringValue = "错误动画演示"
        configureCurrentHUD()
        currentHUD?.show()
        
        // 添加错误动画
        if let animation = animationEnhancer, let hud = currentHUD {
            animation.addErrorAnimation(to: hud.containerView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentHUD?.hide()
        }
    }
    
    // MARK: - Progress View Demo Methods
    @objc private func showRingProgress() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showProgressWithStyle(0.7, style: .ring, status: "环形进度演示", position: getCurrentPosition())
    }

    @objc private func showHorizontalProgress() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showProgressWithStyle(0.5, style: .horizontal, status: "水平进度演示", position: getCurrentPosition())
    }

    @objc private func showPieProgress() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showProgressWithStyle(0.9, style: .pie, status: "饼图进度演示", position: getCurrentPosition())
    }

    @objc private func showPercentageProgress() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showProgressWithPercentage(0.8, status: "百分比进度演示", position: getCurrentPosition())
    }
    
    // MARK: - Position Demo Methods
    @objc private func showCenterHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showSuccess("居中显示", position: .center)
    }

    @objc private func showTopHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showInfo("顶部显示", position: .top)
    }

    @objc private func showBottomHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showMessage("底部显示", position: .bottom)
    }

    @objc private func showCornerHUD() {
        hideCurrentHUD()
        applySharedHUDConfig()
        TFYProgressMacOSHUD.showError("角落显示", position: .topRight)
    }
    
    // MARK: - Configuration Action Methods
    @objc private func themeChanged(_ sender: NSPopUpButton) {
        print("主题已更改为: \(sender.titleOfSelectedItem ?? "")")
        if let hud = currentHUD {
            configureCurrentHUD()
        } else {
            TFYProgressMacOSHUD.configureShared(theme: getCurrentThemeName())
        }
    }

    @objc private func animationChanged(_ sender: NSPopUpButton) {
        print("动画已更改为: \(sender.titleOfSelectedItem ?? "")")
        if currentHUD != nil {
            configureCurrentHUD()
        } else {
            TFYProgressMacOSHUD.configureShared(animationType: getCurrentAnimationType(), animationDuration: durationFromTextField())
        }
    }

    @objc private func positionChanged(_ sender: NSPopUpButton) {
        print("位置已更改为: \(sender.titleOfSelectedItem ?? "")")
        let pos = getCurrentPosition()
        if let hud = currentHUD {
            hud.position = pos
        } else {
            TFYProgressMacOSHUD.configureShared(position: pos)
        }
    }

    @objc private func autoHideChanged(_ sender: NSButton) {
        let enabled = sender.state == .on
        print("自动隐藏: \(enabled ? "开启" : "关闭")")
        if let hud = currentHUD {
            hud.autoHide = enabled
        } else {
            let raw = Double(delayTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 2.0
            TFYProgressMacOSHUD.configureShared(autoHide: enabled, hideDelay: raw > 0 ? raw : 2.0)
        }
    }

    private func durationFromTextField() -> TimeInterval {
        let raw = Double(durationTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.3
        return raw > 0 ? raw : 0.3
    }
    
    /// 将当前界面上的配置（主题、动画、位置、自动隐藏、延迟、动画时长）应用到静态方法使用的 shared HUD
    private func applySharedHUDConfig() {
        let raw = Double(delayTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 2.0
        let delay = raw > 0 ? raw : 2.0
        let durationRaw = Double(durationTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.3
        let duration = durationRaw > 0 ? durationRaw : 0.3
        TFYProgressMacOSHUD.configureShared(
            autoHide: autoHideSwitch.state == .on,
            hideDelay: delay,
            theme: getCurrentThemeName(),
            animationType: getCurrentAnimationType(),
            animationDuration: duration,
            position: getCurrentPosition()
        )
    }

    // MARK: - Helper Methods
    private func hideCurrentHUD() {
        currentHUD?.hide()
        currentHUD = nil
        TFYProgressMacOSHUD.hideHUD()
    }
    
    private func createCustomImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 32, height: 32))
        image.lockFocus()
        
        // 创建一个简单的自定义图像
        let rect = NSRect(x: 4, y: 4, width: 24, height: 24)
        let path = NSBezierPath(ovalIn: rect)
        NSColor.systemBlue.setFill()
        path.fill()
        
        // 添加一些装饰
        let innerRect = NSRect(x: 8, y: 8, width: 16, height: 16)
        let innerPath = NSBezierPath(ovalIn: innerRect)
        NSColor.white.setFill()
        innerPath.fill()
        
        image.unlockFocus()
        return image
    }
} 
