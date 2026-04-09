//
//  TFYProgressView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

// Define the style of the progress view
public enum TFYProgressViewStyle {
    case ring
    case horizontal
    case circular
    case pie
}

public enum TFYProgressViewSize {
    case small
    case regular
    case large
    case custom(CGFloat)
}

// Main class definition
public class TFYProgressView: NSView {
    // Properties
    public var progress: CGFloat = 0.0 {
        didSet {
            if progress != oldValue, !isInsideSetProgress {
                isInsideSetProgress = true
                setProgress(progress, animated: animated)
                isInsideSetProgress = false
            }
        }
    }

    /// 防止 didSet 与 setProgress 相互递归
    private var isInsideSetProgress: Bool = false
    
    public var style: TFYProgressViewStyle = .ring {
        didSet {
            setStyle(style, animated: animated)
        }
    }
    
    public var size: TFYProgressViewSize = .regular {
        didSet {
            updateSize()
        }
    }
    
    public var progressColor: NSColor = .systemBlue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
            updateColors()
        }
    }
    
    public var trackColor: NSColor = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
            updateColors()
        }
    }
    
    public var backgroundColor: NSColor = .clear {
        didSet {
            layer?.backgroundColor = backgroundColor.cgColor
        }
    }
    
    public var lineWidth: CGFloat = 2.0 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            updatePaths()
        }
    }
    
    public var animated: Bool = true
    public var animationDuration: TimeInterval = 0.3
    public var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(controlPoints: 0.42, 0.0, 0.58, 1.0)
    
    public var showPercentage: Bool = false {
        didSet {
            updatePercentageLabel()
        }
    }
    
    public var percentageFont: NSFont = .systemFont(ofSize: 12) {
        didSet {
            percentageLabel.font = percentageFont
        }
    }
    
    public var percentageColor: NSColor = .labelColor {
        didSet {
            percentageLabel.textColor = percentageColor
        }
    }

    // Private layers for rendering
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var pieLayer = CAShapeLayer()
    private var lastProgress: CGFloat = 0.0
    private var completionBlock: (() -> Void)?
    private var percentageLabel = NSTextField()
    private var sizeValue: CGFloat = 40.0

    // Initialization
    public init(style: TFYProgressViewStyle) {
        super.init(frame: .zero)
        self.style = style
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    // Common setup
    private func commonInit() {
        wantsLayer = true
        setupLayers()
        setupPercentageLabel()
        updateColors()
        updateSize()
        updatePaths()
        updatePercentageLabel()
    }

    // Setup layers
    private func setupLayers() {
        trackLayer.fillColor = NSColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer?.addSublayer(trackLayer)

        progressLayer.fillColor = NSColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = .round
        layer?.addSublayer(progressLayer)
        
        pieLayer.fillColor = progressColor.cgColor
        pieLayer.strokeColor = NSColor.clear.cgColor
        layer?.addSublayer(pieLayer)
    }
    
    private func setupPercentageLabel() {
        percentageLabel.isEditable = false
        percentageLabel.isSelectable = false
        percentageLabel.isBordered = false
        percentageLabel.drawsBackground = false
        percentageLabel.alignment = .center
        percentageLabel.font = percentageFont
        percentageLabel.textColor = percentageColor
        percentageLabel.stringValue = ""
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(percentageLabel)
        
        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // Layout and path updates
    public override func layout() {
        super.layout()
        updatePaths()
        updatePercentageLabel()
    }

    public override var intrinsicContentSize: NSSize {
        NSSize(width: sizeValue, height: sizeValue)
    }
    
    private func updateSize() {
        switch size {
        case .small:
            sizeValue = 30.0
        case .regular:
            sizeValue = 40.0
        case .large:
            sizeValue = 50.0
        case .custom(let customSize):
            sizeValue = customSize
        }

        invalidateIntrinsicContentSize()
        if translatesAutoresizingMaskIntoConstraints {
            setFrameSize(NSSize(width: sizeValue, height: sizeValue))
        }
        needsLayout = true
    }

    private func updatePaths() {
        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = max(0, min(bounds.width, bounds.height) / 2 - lineWidth)
        
        progressLayer.isHidden = style == .pie
        pieLayer.isHidden = style != .pie
        
        switch style {
        case .ring:
            let circlePath = CGPath(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2), transform: nil)
            trackLayer.path = circlePath
            progressLayer.path = circlePath
            pieLayer.path = nil
            
        case .horizontal:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: bounds.minX + lineWidth/2, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.maxX - lineWidth/2, y: bounds.midY))
            trackLayer.path = path
            progressLayer.path = path
            pieLayer.path = nil
            
        case .circular:
            let circlePath = CGPath(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2), transform: nil)
            trackLayer.path = circlePath
            progressLayer.path = circlePath
            pieLayer.path = nil
            
        case .pie:
            let circlePath = CGPath(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2), transform: nil)
            trackLayer.path = circlePath
            progressLayer.path = nil
            updatePiePath()
        }

        progressLayer.strokeEnd = progress
    }
    
    private func updatePiePath() {
        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = max(0, min(bounds.width, bounds.height) / 2 - lineWidth)
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (2 * CGFloat.pi * progress)
        
        let path = CGMutablePath()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        pieLayer.path = path
    }
    
    private func updateColors() {
        progressLayer.strokeColor = progressColor.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        pieLayer.fillColor = progressColor.cgColor
    }
    
    private func updatePercentageLabel() {
        if showPercentage {
            percentageLabel.stringValue = "\(Int(progress * 100))%"
            percentageLabel.isHidden = false
        } else {
            percentageLabel.isHidden = true
        }
    }

    // Progress setting with animation
    public func setProgress(_ progress: CGFloat, animated: Bool, completion: (() -> Void)? = nil) {
        let clampedProgress = min(max(progress, 0.0), 1.0)
        lastProgress = self.progress
        isInsideSetProgress = true
        self.progress = clampedProgress
        isInsideSetProgress = false
        completionBlock = completion

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = lastProgress
            animation.toValue = clampedProgress
            animation.duration = animationDuration
            animation.timingFunction = timingFunction
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            
            progressLayer.add(animation, forKey: "progressAnimation")
            progressLayer.strokeEnd = clampedProgress

            if style == .pie {
                let pieAnimation = CABasicAnimation(keyPath: "path")
                pieAnimation.duration = animationDuration
                pieAnimation.timingFunction = timingFunction
                pieLayer.add(pieAnimation, forKey: "pieAnimation")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
                self?.animationDidComplete()
            }
        } else {
            progressLayer.strokeEnd = clampedProgress
            if style == .pie {
                updatePiePath()
            }
            completion?()
        }
        
        updatePercentageLabel()
    }

    // Handle animation completion
    private func animationDidComplete() {
        completionBlock?()
        completionBlock = nil
    }

    // Style setting with animation
    private func setStyle(_ style: TFYProgressViewStyle, animated: Bool) {
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = animationDuration
                context.timingFunction = timingFunction
                updatePaths()
            })
        } else {
            updatePaths()
        }
    }
    
    // MARK: - Convenience Methods
    public func configure(style: TFYProgressViewStyle, size: TFYProgressViewSize, progressColor: NSColor, trackColor: NSColor) {
        self.style = style
        self.size = size
        self.progressColor = progressColor
        self.trackColor = trackColor
    }
    
    public func showProgress(_ progress: CGFloat, animated: Bool = true) {
        setProgress(progress, animated: animated)
    }
    
    public func reset() {
        setProgress(0.0, animated: false)
    }
    
    public func animateToProgress(_ progress: CGFloat, duration: TimeInterval? = nil) {
        let animDuration = duration ?? animationDuration
        let originalDuration = animationDuration
        animationDuration = animDuration
        setProgress(progress, animated: true)
        animationDuration = originalDuration
    }

    // Cleanup
    deinit {
        completionBlock = nil
    }
}
