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
enum TFYProgressViewStyle {
    case ring, horizontal
}

// Main class definition
class TFYProgressView: NSView {
    // Properties
    var progress: CGFloat = 0.0 {
        didSet {
            if progress != oldValue {
                setProgress(progress, animated: animated)
            }
        }
    }
    var style: TFYProgressViewStyle = .ring {
        didSet {
            setStyle(style, animated: animated)
        }
    }
    var progressColor: NSColor = .systemBlue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    var trackColor: NSColor = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    var lineWidth: CGFloat = 2.0 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            updatePaths()
        }
    }
    var animated: Bool = true
    var animationDuration: TimeInterval = 0.3
    var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(controlPoints: 0.42, 0.0, 0.58, 1.0)

    // Private layers for rendering
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var lastProgress: CGFloat = 0.0
    private var completionBlock: (() -> Void)?

    // Initialization
    init(style: TFYProgressViewStyle) {
        super.init(frame: .zero)
        self.style = style
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    // Common setup
    private func commonInit() {
        wantsLayer = true
        setupLayers()
        updatePaths()
    }

    // Setup layers
    private func setupLayers() {
        trackLayer.fillColor = NSColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        layer?.addSublayer(trackLayer)

        progressLayer.fillColor = NSColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0.0
        layer?.addSublayer(progressLayer)
    }

    // Layout and path updates
    override func layout() {
        super.layout()
        updatePaths()
    }

    private func updatePaths() {
        let bounds = self.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth
        switch style {
        case .ring:
            let circlePath = CGPath(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2), transform: nil)
            trackLayer.path = circlePath
            progressLayer.path = circlePath
        case .horizontal:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
            trackLayer.path = path
            progressLayer.path = path
        }
    }

    // Progress setting with animation
    func setProgress(_ progress: CGFloat, animated: Bool, completion: (() -> Void)? = nil) {
        let clampedProgress = min(max(progress, 0.0), 1.0)
        lastProgress = self.progress
        self.progress = clampedProgress
        completionBlock = completion
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = lastProgress
            animation.toValue = progress
            animation.duration = animationDuration
            animation.timingFunction = timingFunction
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            
            progressLayer.add(animation, forKey: "progressAnimation")
            
            // Timer to handle completion
            Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
                self.animationDidComplete()
            }
        } else {
            progressLayer.strokeEnd = progress
            completion?()
        }
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

    // Cleanup
    deinit {
        completionBlock = nil
    }
}
