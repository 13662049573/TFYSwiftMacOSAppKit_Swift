//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Enums
enum TFYHUDMode {
    case indeterminate    // 不确定进度模式(转圈)
    case determinate      // 确定进度模式(进度条)
    case text            // 纯文本模式
    case customView      // 自定义视图模式
    case loading         // 加载模式
}

public class TFYProgressMacOSHUD: NSView {
    // MARK: - Properties
    private(set) var containerView: NSView
    private(set) var statusLabel: NSTextField
    private(set) var activityIndicator: TFYProgressIndicator
    private(set) var progressView: TFYProgressView
    private(set) var customImageView: NSImageView
    
    var mode: TFYHUDMode = .indeterminate {
        didSet {
            updateForMode()
        }
    }
    
    private let layoutManager: TFYLayoutManager
    private let themeManager: TFYThemeManager
    private let animation: TFYAnimationEnhancer
    private var hideTimer: Timer?
    
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
        addSubview(containerView)
        
        // Activity indicator setup
        containerView.addSubview(activityIndicator)
        
        // Progress view setup
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
        layoutManager.setupConstraints(for: self)
        layoutManager.setupAdaptiveLayout(for: self)
        layoutManager.setupSubviewsConstraints(self)
    }
    
    /// 显示HUD
    public static func showHUD(addedTo view: NSView) -> TFYProgressMacOSHUD {
        let hud = TFYProgressMacOSHUD(frame: view.bounds)
        view.addSubview(hud)
        return hud
    }
    
    /// 隐藏HUD
    public static func hideHUD(for view: NSView) -> Bool {
        if let hud = self.HUD(for: view) {
            hud.hideAnimated(true)
            return true
        }
        return false
    }
    
    /// 获取视图上的HUD
    public static func HUD(for view: NSView) -> TFYProgressMacOSHUD? {
        return view.subviews.first { $0 is TFYProgressMacOSHUD } as? TFYProgressMacOSHUD
    }
    
    /// 获取视图上的所有HUD
    public static func allHUDs(for view: NSView) -> [TFYProgressMacOSHUD] {
        return view.subviews.compactMap { $0 as? TFYProgressMacOSHUD }
    }
    
    // MARK: - 便捷显示方法
    
    /// 显示成功状态
    public static func showSuccess(_ status: String?) {
        showHUDInMainWindow { hud in
            hud.mode = .customView
            hud.customImageView.image = createSuccessImage()
            hud.showStatus(status)
            hud.hideAnimated(true, afterDelay: 2.0)
        }
    }
    
    /// 显示错误状态
    public static func showError(_ status: String?) {
        showHUDInMainWindow { hud in
            hud.mode = .customView
            hud.customImageView.image = createErrorImage()
            hud.showStatus(status)
            hud.hideAnimated(true, afterDelay: 2.0)
        }
    }
    
    /// 显示信息状态
    public static func showInfo(_ status: String?) {
        showHUDInMainWindow { hud in
            hud.mode = .customView
            hud.customImageView.image = createInfoImage()
            hud.showStatus(status)
            hud.hideAnimated(true, afterDelay: 2.0)
        }
    }
    
    /// 显示消息
    public static func showMessage(_ status: String?) {
        showHUDInMainWindow { hud in
            hud.mode = .text
            hud.showStatus(status)
            hud.hideAnimated(true, afterDelay: 2.0)
        }
    }
    
    /// 显示加载状态
    public static func showLoading(_ status: String?) {
        showHUDInMainWindow { hud in
            hud.mode = .indeterminate
            hud.showStatus(status)
        }
    }
    
    /// 显示进度
    public static func showProgress(_ progress: Float, status: String?) {
        showHUDInMainWindow { hud in
            hud.mode = .determinate
            hud.progress = progress
            hud.showStatus(status)
        }
    }
    
    
    // MARK: - 私有辅助方法
    
    /// 在主窗口显示HUD
    private static func showHUDInMainWindow(_ configure: @escaping (TFYProgressMacOSHUD) -> Void) {
        DispatchQueue.main.async {
            guard let window = NSApp.mainWindow,
                  let contentView = window.contentView else { return }
            let hud = showHUD(addedTo: contentView)
            configure(hud)
        }
    }
    
    
    // MARK: - 显示和隐藏方法
    
    /// 显示HUD
    /// - Parameters:
    ///   - animated: 是否使用动画
    public func show(animated: Bool) {
        if graceTime > 0 {
            // 如果设置了延迟显示时间，创建定时器
            graceTimer = Timer.scheduledTimer(withTimeInterval: graceTime, repeats: false) { [weak self] _ in
                self?.showUsingAnimation(animated)
            }
        } else {
            showUsingAnimation(animated)
        }
    }
    
    /// 使用动画显示HUD
    /// - Parameter animated: 是否使用动画
    private func showUsingAnimation(_ animated: Bool) {
        isHidden = false
        
        if animated {
            // 配置动画
            animation.setup(view: self)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = fadeInDuration
                self.animator().alphaValue = 1.0
            }, completionHandler: nil)
        } else {
            // 直接显示
            alphaValue = 1.0
        }
        
        // 如果设置了最小显示时间，创建定时器
        if minShowTime > 0 {
            minShowTimer = Timer.scheduledTimer(withTimeInterval: minShowTime, repeats: false) { [weak self] _ in
                self?.minShowTimer = nil
            }
        }
    }
    
    /// 隐藏HUD
    /// - Parameter animated: 是否使用动画
    public func hideAnimated(_ animated: Bool) {
        hideAnimated(animated, afterDelay: 0)
    }
    
    /// 延迟隐藏HUD
    /// - Parameters:
    ///   - animated: 是否使用动画
    ///   - delay: 延迟时间
    public func hideAnimated(_ animated: Bool, afterDelay delay: TimeInterval) {
        // 创建隐藏动作
        let hideBlock = { [weak self] in
            guard let self = self else { return }
            
            // 检查是否需要等待最小显示时间
            let hideNow = { [weak self] in
                guard let self = self else { return }
                
                if animated {
                    // 使用动画隐藏
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = self.fadeOutDuration
                        self.animator().alphaValue = 0.0
                    }, completionHandler: {
                        self.done()
                    })
                } else {
                    // 直接隐藏
                    self.alphaValue = 0.0
                    self.done()
                }
            }
            
            // 如果最小显示时间定时器存在，等待它完成
            if let minShowTimer = self.minShowTimer {
                DispatchQueue.main.asyncAfter(deadline: .now() + minShowTimer.fireDate.timeIntervalSinceNow) {
                    hideNow()
                }
            } else {
                hideNow()
            }
        }
        
        // 处理延迟隐藏
        if delay > 0 {
            fadeOutTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                hideBlock()
            }
        } else {
            hideBlock()
        }
    }
    
    /// HUD完成显示后的清理工作
    private func done() {
        // 调用完成回调
        completionBlock?()
        // 从父视图移除
        removeFromSuperview()
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
        
        layoutManager.invalidateLayout()
        layoutManager.setupHUDConstraints(self)
    }
    
    // MARK: - Public Static Methods
    static func showHUD(addedTo view: NSView) -> TFYProgressMacOSHUD {
        let hud = TFYProgressMacOSHUD(frame: view.bounds)
        view.addSubview(hud)
        return hud
    }
    
    static func hideHUD(for view: NSView) -> Bool {
        if let hud = allHUDs(for: view).first {
            hud.hide()
            return true
        }
        return false
    }
    
    static func allHUDs(for view: NSView) -> [TFYProgressMacOSHUD] {
        return view.subviews.compactMap { $0 as? TFYProgressMacOSHUD }
    }
    
    // MARK: - Convenience Methods
    static func showSuccess(_ status: String) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .customView
            hud.customImageView.image = createSuccessImage()
            hud.statusLabel.stringValue = status
            hud.show()
            hud.hide(afterDelay: 3.0)
        }
    }
    
    static func showError(_ status: String) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .customView
            hud.customImageView.image = createErrorImage()
            hud.statusLabel.stringValue = status
            hud.show()
            hud.hide(afterDelay: 3.0)
        }
    }
    
    static func showInfo(_ status: String) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .customView
            hud.customImageView.image = createInfoImage()
            hud.statusLabel.stringValue = status
            hud.show()
            hud.hide(afterDelay: 3.0)
        }
    }
    
    static func showMessage(_ status: String) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .text
            hud.statusLabel.stringValue = status
            hud.show()
            hud.hide(afterDelay: 3.0)
        }
    }
    
    static func showLoading(_ status: String) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .loading
            hud.statusLabel.stringValue = status
            hud.show()
        }
    }
    
    static func showProgress(_ progress: Float, status: String?) {
        DispatchQueue.main.async {
            let hud = shared
            hud.mode = .determinate
            hud.progressView.progress = CGFloat(progress)
            hud.statusLabel.stringValue = status ?? ""
            hud.show()
        }
    }
    
    static func hideHUD() {
        DispatchQueue.main.async {
            shared.hide()
        }
    }
    
    static func hideHUD(afterDelay delay: TimeInterval) {
        DispatchQueue.main.async {
            shared.hide(afterDelay: delay)
        }
    }
    
    // MARK: - Private Methods
    private func show() {
        isHidden = false
        animation.setup(with: self)
        animation.applyAnimation(to: self)
    }
    
    private func hide() {
        animation.reset(self)
        hideTimer?.invalidate()
        hideTimer = nil
        isHidden = true
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
