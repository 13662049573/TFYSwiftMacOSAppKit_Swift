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
    /// 自动隐藏延迟（秒），默认 2 秒
    public var hideDelay: TimeInterval = 2.0
    public var animationDuration: TimeInterval = 0.3
    
    private let layoutManager: TFYLayoutManager
    private let themeManager: TFYThemeManager
    private let animation: TFYAnimationEnhancer
    /// 使用 GCD 而非 Timer，避免 macOS 下 Run Loop 处于 EventTracking 模式时定时器不触发导致不自动消失
    private var hideWorkItem: DispatchWorkItem?
    private var positionConstraints: [NSLayoutConstraint] = []
    
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
    
    /// 动态更新 HUD 大小（统一通过 layoutManager 重设约束，避免与位置约束冲突）
    public func updateSizeForText() {
        let hasText = !statusLabel.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        statusLabel.isHidden = !hasText
        layoutManager.invalidateLayout()
        layoutManager.setupHUDConstraints(self)
        layoutManager.setupAdaptiveLayout(for: self)
        updatePosition()
        needsLayout = true
        layout()
    }
    
    /// 确保 HUD 大小稳定（复用 updateSizeForText 的逻辑）
    public func ensureStableSize() {
        updateSizeForText()
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
        
        // 模式变化时重新设置布局约束，保证各模式下的尺寸与位置正确
        DispatchQueue.main.async {
            self.layoutManager.setupHUDConstraints(self)
            self.layoutManager.setupAdaptiveLayout(for: self)
            self.updatePosition()
            self.needsLayout = true
            self.layout()
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
            hud.updateSizeForText() // 更新大小
            hud.show()
            hud.statusLabel.textColor = .systemRed
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
            if hud.autoHide {
                hud.hide(afterDelay: hud.hideDelay)
            }
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
    
    /// 设置主题（支持 "system" 表示跟随系统深浅色）；设置后立即应用到当前 HUD 的布局与颜色
    public func setTheme(_ themeName: String) {
        if themeName == "system" {
            themeManager.applyThemeType(.system)
        } else {
            themeManager.applyTheme(themeName)
        }
        themeManager.applyTheme(to: self)
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
    
    /// 在调用 showSuccess/showError 等静态方法前调用，使配置选项（主题、动画、自动隐藏等）生效
    public static func configureShared(
        autoHide: Bool? = nil,
        hideDelay: TimeInterval? = nil,
        theme: String? = nil,
        animationType: TFYAnimationType? = nil,
        animationDuration: TimeInterval? = nil,
        position: TFYHUDPosition? = nil
    ) {
        if let v = autoHide { shared.autoHide = v }
        if let v = hideDelay { shared.hideDelay = v }
        if let v = theme { shared.setTheme(v) }
        if let v = animationType { shared.setAnimationType(v) }
        if let v = animationDuration { shared.setAnimationDuration(v) }
        if let v = position { shared.position = v }
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
        // Singleton 可能尚未加入窗口（无 mainWindow 时延迟加入）
        if superview == nil,
           let window = NSApp.mainWindow,
           let contentView = window.contentView {
            contentView.wantsLayer = true
            frame = contentView.bounds
            autoresizingMask = [.width, .height]
            contentView.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                topAnchor.constraint(equalTo: contentView.topAnchor),
                bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

        // 确保HUD在最上层
        if let superview = superview {
            superview.addSubview(self, positioned: .above, relativeTo: nil)
        }

        // 有 superview 时应用位置约束（commonInit 时可能还没有 superview）
        updatePosition()

        // 每次显示时重新应用主题，保证文案颜色正确（如 showError 后的 showSuccess）
        themeManager.applyTheme(to: self)

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
        hideWorkItem?.cancel()
        hideWorkItem = nil

        // 延迟隐藏，让动画完成
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.isHidden = true
        }
    }

    private func hide(afterDelay delay: TimeInterval) {
        hideWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    deinit {
        hideWorkItem?.cancel()
        hideWorkItem = nil
    }

    // MARK: - Singleton
    private static var shared: TFYProgressMacOSHUD = {
        let hud = TFYProgressMacOSHUD(frame: .zero)
        hud.isHidden = true

        if let window = NSApplication.shared.mainWindow,
           let contentView = window.contentView {
            contentView.wantsLayer = true
            hud.frame = contentView.bounds
            hud.autoresizingMask = [.width, .height]
            contentView.addSubview(hud)
            hud.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hud.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hud.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hud.topAnchor.constraint(equalTo: contentView.topAnchor),
                hud.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

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
