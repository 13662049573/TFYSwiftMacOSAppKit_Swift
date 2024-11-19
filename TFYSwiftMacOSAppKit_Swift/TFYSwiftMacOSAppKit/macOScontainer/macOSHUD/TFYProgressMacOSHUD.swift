//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

/// HUD 显示模式
public enum TFYHUDMode {
    case indeterminate  // 不确定进度（转圈）
    case determinate    // 确定进度（进度条）
    case text          // 纯文本
    case customView    // 自定义视图
    case loading       // 加载中
}

/// macOS HUD 进度指示器
public class TFYProgressMacOSHUD: NSView {
    
    // MARK: - 内部视图属性
    
    /// 容器视图
    private(set) var containerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        return view
    }()
    
    /// 状态文本标签
    private(set) var statusLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.alignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.cell?.wraps = true
        label.cell?.isScrollable = false
        label.maximumNumberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    /// 活动指示器（转圈动画）
    private(set) var activityIndicator = TFYProgressIndicator()
    
    /// 进度视图（进度条）
    private(set) var progressView = TFYProgressView(style: .ring)
    
    /// 自定义图片视图
    private(set) var customImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyDown
        return imageView
    }()
    
    // MARK: - 管理器属性
    
    /// 布局管理器
    private let layoutManager = TFYLayoutManager()
    
    /// 主题管理器
    private let themeManager = TFYThemeManager()
    
    /// 动画管理器
    private let animation = TFYAnimationEnhancer()
    
    /// 手势处理器
    private let gestureHandler = TFYGestureHandler()
    
    // MARK: - 定时器属性
    
    /// 隐藏定时器
    private var hideTimer: Timer?
    
    /// 最小显示时间定时器
    private var minShowTimer: Timer?
    
    /// 延迟显示定时器
    private var graceTimer: Timer?
    
    /// 淡出动画定时器
    private var fadeOutTimer: Timer?
    
    // MARK: - 配置属性
    
    /// 显示模式
    public var mode: TFYHUDMode = .indeterminate {
        didSet {
            updateForMode()
        }
    }
    
    /// 进度值 (0.0 - 1.0)
    public var progress: Float = 0 {
        didSet {
            progressView.progress = CGFloat(progress)
        }
    }
    
    /// 边距
    public var margin: CGFloat = 20
    
    /// 最小尺寸
    public var minSize: CGSize = CGSize(width: 100, height: 100)
    
    /// 最大尺寸
    public var maxSize: CGSize = CGSize(width: 300, height: 300)
    
    /// 最小显示时间
    public var minShowTime: TimeInterval = 0.5
    
    /// 延迟显示时间
    public var graceTime: TimeInterval = 0.0
    
    /// 淡入动画时长
    public var fadeInDuration: TimeInterval = 0.3
    
    /// 淡出动画时长
    public var fadeOutDuration: TimeInterval = 0.3
    
    /// 完成回调
    public var completionBlock: (() -> Void)?
    
    // MARK: - 初始化方法
    
    public override init(frame: NSRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    /// 通用初始化方法
    private func commonInit() {
        setupViews()
        setupConstraints()
        setupInitialState()
        setupGestureRecognizers()
    }
    
    // MARK: - 设置方法
    
    /// 设置视图层级
    private func setupViews() {
        wantsLayer = true
        
        // 添加子视图
        addSubview(containerView)
        containerView.addSubview(statusLabel)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        containerView.addSubview(customImageView)
        
        // 初始隐藏所有视图
        [statusLabel, activityIndicator, progressView, customImageView].forEach {
            $0.isHidden = true
        }
    }
    
    /// 设置约束
    private func setupConstraints() {
        // 禁用自动约束转换
        [containerView, statusLabel, activityIndicator, progressView, customImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 使用布局管理器设置约束
        layoutManager.setupHUDConstraints(self)
    }
    
    /// 设置初始状态
    private func setupInitialState() {
        isHidden = true
        alphaValue = 0.0
        themeManager.applyTheme(to: self)
    }
    
    /// 设置手势识别
    private func setupGestureRecognizers() {
        gestureHandler.delegate = self
        gestureHandler.setupGestures(for: self)
    }
    
    // MARK: - 静态便捷方法
    
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
    
    // MARK: - 模式更新
    
    /// 根据当前模式更新视图显示状态
    private func updateForMode() {
        // 状态标签始终可见
        statusLabel.isHidden = false
        
        switch mode {
        case .indeterminate:
            // 显示旋转加载指示器
            activityIndicator.isHidden = false
            progressView.isHidden = true
            customImageView.isHidden = true
            activityIndicator.startAnimation()
            
        case .determinate:
            // 显示进度条
            activityIndicator.isHidden = true
            progressView.isHidden = false
            customImageView.isHidden = true
            activityIndicator.stopAnimation()
            
        case .text:
            // 仅显示文本
            activityIndicator.isHidden = true
            progressView.isHidden = true
            customImageView.isHidden = true
            activityIndicator.stopAnimation()
            
        case .customView:
            // 显示自定义图片
            activityIndicator.isHidden = true
            progressView.isHidden = true
            customImageView.isHidden = false
            activityIndicator.stopAnimation()
            
        case .loading:
            // 显示加载动画
            activityIndicator.isHidden = false
            progressView.isHidden = true
            customImageView.isHidden = true
            activityIndicator.startAnimation()
        }
        
        // 更新布局
        layoutManager.setupHUDConstraints(self)
    }
    
    /// 显示状态文本
    /// - Parameter status: 状态文本
    private func showStatus(_ status: String?) {
        statusLabel.stringValue = status ?? ""
        statusLabel.isHidden = status?.isEmpty ?? true
        layoutManager.setupHUDConstraints(self)
        show(animated: true)
    }
    
    // MARK: - 图片生成方法
    
    /// 创建成功图标
    private static func createSuccessImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 32, height: 32))
        image.lockFocus()
        
        // 绘制对勾
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 8, y: 16))
        path.line(to: NSPoint(x: 14, y: 22))
        path.line(to: NSPoint(x: 24, y: 12))
        
        NSColor.systemGreen.setStroke()
        path.lineWidth = 2.5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
        
        image.unlockFocus()
        return image
    }
    
    /// 创建错误图标
    private static func createErrorImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 32, height: 32))
        image.lockFocus()
        
        // 绘制叉号
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 8, y: 8))
        path.line(to: NSPoint(x: 24, y: 24))
        path.move(to: NSPoint(x: 24, y: 8))
        path.line(to: NSPoint(x: 8, y: 24))
        
        NSColor.systemRed.setStroke()
        path.lineWidth = 2
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
        
        image.unlockFocus()
        return image
    }
    
    /// 创建信息图标
    private static func createInfoImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 32, height: 32))
        image.lockFocus()
        
        // 绘制圆点
        let dotPath = NSBezierPath(ovalIn: NSRect(x: 14, y: 20, width: 4, height: 4))
        NSColor.systemBlue.setFill()
        dotPath.fill()
        
        // 绘制竖线
        let linePath = NSBezierPath()
        linePath.move(to: NSPoint(x: 16, y: 8))
        linePath.line(to: NSPoint(x: 16, y: 16))
        
        NSColor.systemBlue.setStroke()
        linePath.lineWidth = 2
        linePath.lineCapStyle = .round
        linePath.stroke()
        
        image.unlockFocus()
        return image
    }
    
    // MARK: - 清理方法
    
    deinit {
        // 清理所有定时器
        [hideTimer, minShowTimer, graceTimer, fadeOutTimer].forEach { $0?.invalidate() }
        // 清理手势识别器
        gestureHandler.cleanup()
    }
}

// MARK: - 手势处理代理实现
extension TFYProgressMacOSHUD: TFYGestureHandlerDelegate {
    /// 处理点击手势
    public func gestureHandler(_ handler: TFYGestureHandler, didRecognizeTapGesture gesture: NSGestureRecognizer) {
        hideAnimated(true)
    }
    
    /// 处理滑动手势
    public func gestureHandler(_ handler: TFYGestureHandler, didRecognizeSwipeGesture gesture: NSGestureRecognizer) {
        hideAnimated(true)
    }
}
