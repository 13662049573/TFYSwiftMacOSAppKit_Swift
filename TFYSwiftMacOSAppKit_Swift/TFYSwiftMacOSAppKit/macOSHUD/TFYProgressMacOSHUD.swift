//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Enums
public enum TFYHUDMode {
    case indeterminate    // 不确定进度模式(转圈)
    case determinate      // 确定进度模式(进度条)
    case text            // 纯文本模式
    case customView      // 自定义视图模式
    case loading         // 加载模式
}

public enum TFYHUDPosition {
    case center
    case top
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

public class TFYProgressMacOSHUD: NSView {
    // MARK: - Properties
    private(set) var containerView: NSView
    private(set) var statusLabel: NSTextField
    private(set) var activityIndicator: TFYProgressIndicator
    private(set) var progressView: TFYProgressView
    private(set) var customImageView: NSImageView
    
    public var mode: TFYHUDMode = .indeterminate {
        didSet {
            updateForMode()
        }
    }
    
    public var position: TFYHUDPosition = .center {
        didSet {
            updatePosition()
        }
    }
    
    public var autoHide: Bool = true
    public var hideDelay: TimeInterval = 3.0
    public var animationDuration: TimeInterval = 0.3
    
    private let layoutManager: TFYLayoutManager
    private let themeManager: TFYThemeManager
    private let animation: TFYAnimationEnhancer
    private var hideTimer: Timer?
    private var positionConstraints: [NSLayoutConstraint] = []
    private var activeConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Initialization
    override init(frame: NSRect) {
        containerView = NSView(frame: .zero)
        statusLabel = NSTextField(frame: .zero)
        activityIndicator = TFYProgressIndicator(frame: .zero)
        progressView = TFYProgressView(style: .ring)
        customImageView = NSImageView(frame: .zero)
        layoutManager = TFYLayoutManager()
        themeManager = TFYThemeManager()
        animation = TFYAnimationEnhancer()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        containerView = NSView(frame: .zero)
        statusLabel = NSTextField(frame: .zero)
        activityIndicator = TFYProgressIndicator(frame: .zero)
        progressView = TFYProgressView(style: .ring)
        customImageView = NSImageView(frame: .zero)
        layoutManager = TFYLayoutManager()
        themeManager = TFYThemeManager()
        animation = TFYAnimationEnhancer()
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupSubviews()
        setupInitialState()
        setupLayout()
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        // Container view setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Activity indicator setup
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
        
        // Progress view setup
        progressView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(progressView)
        
        // Status label setup
        setupStatusLabel()
        containerView.addSubview(statusLabel)
        
        // Custom image view setup
        setupCustomImageView()
        containerView.addSubview(customImageView)
    }
    
    private func setupStatusLabel() {
        statusLabel.isBezeled = false
        statusLabel.isEditable = false
        statusLabel.drawsBackground = false
        statusLabel.alignment = .center
        statusLabel.textColor = .white
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.cell?.wraps = true
        statusLabel.cell?.isScrollable = false
        statusLabel.maximumNumberOfLines = 0
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.preferredMaxLayoutWidth = 200
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加文字变化监听
        statusLabel.target = self
        statusLabel.action = #selector(statusLabelChanged)
    }
    
    @objc private func statusLabelChanged() {
        updateSizeForText()
    }
    
    private func setupCustomImageView() {
        customImageView.imageScaling = .scaleProportionallyDown
        customImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupInitialState() {
        isHidden = true
        wantsLayer = true
        layer?.masksToBounds = true
        themeManager.setupDefaultTheme()
        themeManager.applyTheme(to: self)
    }
    
    private func setupLayout() {
        layoutManager.setupHUDConstraints(self)
        layoutManager.setupAdaptiveLayout(for: self)
        updatePosition()
    }
    
    // MARK: - Position Management
    private func updatePosition() {
        guard superview != nil else { return }
        
        // 移除现有位置约束
        NSLayoutConstraint.deactivate(positionConstraints)
        positionConstraints.removeAll()
        
        // 添加新的位置约束
        switch position {
        case .center:
            positionConstraints = [
                containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
            
        case .top:
            positionConstraints = [
                containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                containerView.topAnchor.constraint(equalTo: topAnchor, constant: 100)
            ]
            
        case .bottom:
            positionConstraints = [
                containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100)
            ]
            
        case .topLeft:
            positionConstraints = [
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
                containerView.topAnchor.constraint(equalTo: topAnchor, constant: 100)
            ]
            
        case .topRight:
            positionConstraints = [
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
                containerView.topAnchor.constraint(equalTo: topAnchor, constant: 100)
            ]
            
        case .bottomLeft:
            positionConstraints = [
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100)
            ]
            
        case .bottomRight:
            positionConstraints = [
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100)
            ]
        }
        
        NSLayoutConstraint.activate(positionConstraints)
    }
    
    /// 动态更新HUD大小
    public func updateSizeForText() {
        // 检查是否有文字内容
        let hasText = !statusLabel.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // 移除现有的容器大小约束
        containerView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        // 根据是否有文字设置新的约束
        if hasText {
            // 有文字时使用自适应大小
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
                containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
            statusLabel.isHidden = false
        } else {
            // 无文字时使用固定大小
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalToConstant: 200),
                containerView.heightAnchor.constraint(equalToConstant: 120)
            ])
            statusLabel.isHidden = true
        }
        
        // 强制布局更新
        needsLayout = true
        layout()
    }
    
    /// 确保HUD大小稳定
    public func ensureStableSize() {
        // 确保容器视图有固定大小
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 检查是否有文字内容
        let hasText = !statusLabel.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // 移除可能冲突的约束
        containerView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        // 根据是否有文字设置约束
        if hasText {
            // 有文字时使用自适应大小
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
                containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
        } else {
            // 无文字时使用固定大小
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalToConstant: 200),
                containerView.heightAnchor.constraint(equalToConstant: 120)
            ])
        }
        
        // 强制布局更新
        needsLayout = true
        layout()
    }
    
    /// 显示HUD
    public static func showHUD(addedTo view: NSView) -> TFYProgressMacOSHUD {
        let hud = TFYProgressMacOSHUD(frame: view.bounds)
        hud.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hud)
        
        // 设置约束
        NSLayoutConstraint.activate([
            hud.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hud.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hud.topAnchor.constraint(equalTo: view.topAnchor),
            hud.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 确保布局正确设置
        hud.layoutManager.setupHUDConstraints(hud)
        hud.layoutManager.setupAdaptiveLayout(for: hud)
        
        // 确保HUD可见
        hud.isHidden = false
        
        return hud
    }
    
    /// 获取视图上的HUD
    public static func HUD(for view: NSView) -> TFYProgressMacOSHUD? {
        return view.subviews.first { $0 is TFYProgressMacOSHUD } as? TFYProgressMacOSHUD
    }
    
    /// 获取视图上的所有HUD
    public static func allHUDs(for view: NSView) -> [TFYProgressMacOSHUD] {
        return view.subviews.compactMap { $0 as? TFYProgressMacOSHUD }
    }
    
    /// 在主窗口显示HUD
    private static func showHUDInMainWindow(_ configure: @escaping (TFYProgressMacOSHUD) -> Void) {
        DispatchQueue.main.async {
            guard let window = NSApp.mainWindow,
                  let contentView = window.contentView else { return }
            let hud = showHUD(addedTo: contentView)
            configure(hud)
        }
    }
    
    private func updateForMode() {
        switch mode {
        case .indeterminate:
            activityIndicator.isHidden = false
            progressView.isHidden = true
            customImageView.isHidden = true
            activityIndicator.startAnimation()
            
        case .determinate:
            activityIndicator.isHidden = true
            progressView.isHidden = false
            customImageView.isHidden = true
            activityIndicator.stopAnimation()
            
        case .text:
            activityIndicator.isHidden = true
            progressView.isHidden = true
            customImageView.isHidden = true
            activityIndicator.stopAnimation()
            
        case .customView:
            activityIndicator.isHidden = true
            progressView.isHidden = true
            customImageView.isHidden = false
            activityIndicator.stopAnimation()
            
        case .loading:
            activityIndicator.isHidden = false
            progressView.isHidden = true
            customImageView.isHidden = true
            activityIndicator.startAnimation()
        }
        
        // 只在首次设置时更新布局，避免重复设置约束
        if activeConstraints.isEmpty {
            DispatchQueue.main.async {
                self.layoutManager.setupHUDConstraints(self)
                self.layoutManager.setupAdaptiveLayout(for: self)
                
                // 强制布局更新
                self.needsLayout = true
                self.layout()
            }
        }
    }
    
    // MARK: - Convenience Methods
    public static func showSuccess(_ status: String, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .customView
            hud.position = position
            hud.customImageView.image = createSuccessImage()
            hud.statusLabel.stringValue = status
            hud.updateSizeForText() // 更新大小
            hud.show()
            if hud.autoHide {
                hud.hide(afterDelay: hud.hideDelay)
            }
        }
    }
    
    public static func showError(_ status: String, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .customView
            hud.position = position
            hud.customImageView.image = createErrorImage()
            hud.statusLabel.stringValue = status
            hud.statusLabel.textColor = .systemRed
            hud.updateSizeForText() // 更新大小
            hud.show()
            if hud.autoHide {
                hud.hide(afterDelay: hud.hideDelay)
            }
        }
    }
    
    public static func showInfo(_ status: String, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .customView
            hud.position = position
            hud.customImageView.image = createInfoImage()
            hud.statusLabel.stringValue = status
            hud.updateSizeForText() // 更新大小
            hud.show()
            if hud.autoHide {
                hud.hide(afterDelay: hud.hideDelay)
            }
        }
    }
    
    public static func showMessage(_ status: String, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .text
            hud.position = position
            hud.statusLabel.stringValue = status
            hud.updateSizeForText() // 更新大小
            hud.show()
            if hud.autoHide {
                hud.hide(afterDelay: hud.hideDelay)
            }
        }
    }
    
    public static func showLoading(_ status: String, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .loading
            hud.position = position
            hud.statusLabel.stringValue = status
            hud.updateSizeForText() // 更新大小
            hud.show()
        }
    }
    
    public static func showProgress(_ progress: Float, status: String?, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .determinate
            hud.position = position
            hud.progressView.progress = CGFloat(progress)
            hud.statusLabel.stringValue = status ?? ""
            hud.updateSizeForText() // 更新大小
            hud.show()
        }
    }
    
    public static func showImage(_ image: NSImage, status: String?, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .customView
            hud.position = position
            hud.customImageView.image = image
            hud.statusLabel.stringValue = status ?? ""
            hud.updateSizeForText() // 更新大小
            hud.show()
        }
    }
    
    /// 设置进度值
    public func setProgress(_ progress: CGFloat) {
        progressView.progress = progress
    }
    
    /// 设置进度视图样式
    public func setProgressViewStyle(_ style: TFYProgressViewStyle) {
        progressView.style = style
    }
    
    /// 设置进度视图大小
    public func setProgressViewSize(_ size: TFYProgressViewSize) {
        progressView.size = size
    }
    
    /// 设置进度视图颜色
    public func setProgressViewColors(progress: NSColor, track: NSColor) {
        progressView.progressColor = progress
        progressView.trackColor = track
    }
    
    /// 设置进度指示器样式
    public func setActivityIndicatorStyle(_ style: TFYProgressIndicatorStyle) {
        activityIndicator.setStyle(style)
    }
    
    /// 设置进度指示器大小
    public func setActivityIndicatorSize(_ size: TFYProgressIndicatorSize) {
        activityIndicator.setSize(size)
    }
    
    /// 设置进度指示器颜色
    public func setActivityIndicatorColor(_ color: NSColor) {
        activityIndicator.setColor(color)
    }
    
    /// 配置进度指示器
    public func configureActivityIndicator(style: TFYProgressIndicatorStyle, size: TFYProgressIndicatorSize, color: NSColor? = nil) {
        activityIndicator.configure(style: style, size: size, color: color)
    }
    
    /// 配置进度视图
    public func configureProgressView(style: TFYProgressViewStyle, size: TFYProgressViewSize, progressColor: NSColor, trackColor: NSColor) {
        progressView.configure(style: style, size: size, progressColor: progressColor, trackColor: trackColor)
    }
    
    /// 显示百分比
    public func showProgressPercentage(_ show: Bool) {
        progressView.showPercentage = show
    }
    
    /// 设置主题
    public func setTheme(_ themeName: String) {
        themeManager.applyTheme(themeName)
    }
    
    /// 设置动画持续时间
    public func setAnimationDuration(_ duration: TimeInterval) {
        animationDuration = duration
        animation.configure(duration: CGFloat(duration), springDamping: 0.7, initialSpringVelocity: 0.5, animationCurve: .easeInOut)
    }
    
    /// 设置动画类型
    public func setAnimationType(_ type: TFYAnimationType) {
        animation.setAnimationType(type)
    }
    
    /// 显示带进度的HUD
    public static func showProgressHUD(_ progress: CGFloat, status: String?, style: TFYProgressViewStyle = .ring, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .determinate
            hud.position = position
            hud.progressView.style = style
            hud.progressView.progress = progress
            hud.statusLabel.stringValue = status ?? ""
            hud.updateSizeForText() // 更新大小
            hud.show()
        }
    }
    
    /// 显示带百分比的进度HUD
    public static func showProgressWithPercentage(_ progress: CGFloat, status: String?, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .determinate
            hud.position = position
            hud.progressView.showPercentage = true
            hud.progressView.progress = progress
            hud.statusLabel.stringValue = status ?? ""
            hud.updateSizeForText() // 更新大小
            hud.show()
        }
    }
    
    /// 显示不同样式的进度HUD
    public static func showProgressWithStyle(_ progress: CGFloat, style: TFYProgressViewStyle, status: String?, position: TFYHUDPosition = .center) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .determinate
            hud.position = position
            hud.progressView.style = style
            hud.progressView.progress = progress
            hud.statusLabel.stringValue = status ?? ""
            hud.updateSizeForText() // 更新大小
            hud.show()
        }
    }
    
    public static func hideHUD() {
        DispatchQueue.main.async {
            shared.hide()
        }
    }
    
    public static func hideHUD(afterDelay delay: TimeInterval) {
        DispatchQueue.main.async {
            shared.hide(afterDelay: delay)
        }
    }
    
    // MARK: - Private Methods
    public func show() {
        // 确保HUD在最上层
        if let superview = superview {
            superview.addSubview(self, positioned: .above, relativeTo: nil)
        }
        
        // 确保HUD大小稳定
        ensureStableSize()
        
        // 设置可见并应用动画
        isHidden = false
        animation.setup(with: self)
        
        // 应用动画
        DispatchQueue.main.async {
            self.animation.applyAnimation(to: self)
        }
    }
    
    public func hide() {
        animation.reset(self)
        hideTimer?.invalidate()
        hideTimer = nil
        
        // 延迟隐藏，让动画完成
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.isHidden = true
        }
    }
    
    private func hide(afterDelay delay: TimeInterval) {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.hide()
        }
    }
    
    // MARK: - Singleton
    private static var shared: TFYProgressMacOSHUD = {
        guard let window = NSApplication.shared.mainWindow,
              let contentView = window.contentView else {
            fatalError("No main window found")
        }

        contentView.wantsLayer = true
        let hud = TFYProgressMacOSHUD(frame: contentView.bounds)
        hud.autoresizingMask = [.width, .height]
        contentView.addSubview(hud)
        
        hud.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hud.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hud.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hud.topAnchor.constraint(equalTo: contentView.topAnchor),
            hud.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        hud.isHidden = true
        return hud
    }()
}

// MARK: - Helper Methods for Creating Images
extension TFYProgressMacOSHUD {
    
    static func createSuccessImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 32, height: 32))
        image.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .high
        NSGraphicsContext.current?.shouldAntialias = true
        
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 8, y: 16))
        path.line(to: NSPoint(x: 14, y: 12))
        path.line(to: NSPoint(x: 24, y: 22))
        
        path.lineWidth = 2.5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        NSColor.systemGreen.setStroke()
        path.stroke()
        
        image.unlockFocus()
        image.isTemplate = false
        image.cacheMode = .never
        
        return image
    }
    
    static func createErrorImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 32, height: 32))
        image.lockFocus()
        
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 8, y: 8))
        path.line(to: NSPoint(x: 24, y: 24))
        path.move(to: NSPoint(x: 24, y: 8))
        path.line(to: NSPoint(x: 8, y: 24))
        
        NSColor.systemRed.set()
        path.lineWidth = 2
        path.stroke()
        
        image.unlockFocus()
        return image
    }
    
    static func createInfoImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 32, height: 32))
        image.lockFocus()
        
        let circlePath = NSBezierPath(ovalIn: NSRect(x: 14, y: 20, width: 4, height: 4))
        let linePath = NSBezierPath()
        linePath.move(to: NSPoint(x: 16, y: 8))
        linePath.line(to: NSPoint(x: 16, y: 16))
        
        NSColor.systemBlue.set()
        circlePath.fill()
        linePath.lineWidth = 2
        linePath.stroke()
        
        image.unlockFocus()
        return image
    }
}
