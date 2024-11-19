//
//  TFYProgressView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Progress View Style
public enum TFYProgressViewStyle {
    case ring
    case horizontal
}

public class TFYProgressView: NSView {
    
    // MARK: - Properties
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    private var lastProgress: CGFloat = 0
    private var completionBlock: (() -> Void)?
    private var animationTimer: Timer?
    
    // MARK: - Public Properties
    public var progress: CGFloat = 0 {
        didSet {
            setProgress(progress, animated: animated)
        }
    }
    
    public var style: TFYProgressViewStyle = .ring {
        didSet {
            updatePaths()
        }
    }
    
    public var progressColor: NSColor = .systemBlue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    public var trackColor: NSColor = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    public var lineWidth: CGFloat = 3 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            updatePaths()
        }
    }
    
    public var animated: Bool = true
    public var animationDuration: TimeInterval = 0.3
    public var timingFunction: CAMediaTimingFunction = .init(name: .easeInEaseOut)
    
    // MARK: - Initialization
    public init(style: TFYProgressViewStyle) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        wantsLayer = true
        
        // Setup track layer
        trackLayer.fillColor = NSColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        layer?.addSublayer(trackLayer)
        
        // Setup progress layer
        progressLayer.fillColor = NSColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0.0
        layer?.addSublayer(progressLayer)
        
        updatePaths()
    }
    
    // MARK: - Layout
    public override func layout() {
        super.layout()
        updatePaths()
    }
    
    private func updatePaths() {
        let bounds = self.bounds
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth
        
        switch style {
        case .ring:
            let circlePath = NSBezierPath(ovalIn: NSRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            trackLayer.path = circlePath.cgPath
            progressLayer.path = circlePath.cgPath
            
        case .horizontal:
            let path = NSBezierPath()
            path.move(to: NSPoint(x: bounds.minX, y: bounds.midY))
            path.line(to: NSPoint(x: bounds.maxX, y: bounds.midY))
            trackLayer.path = path.cgPath
            progressLayer.path = path.cgPath
        }
    }
    
    // MARK: - Progress Control
    public func setProgress(_ progress: CGFloat, animated: Bool) {
        setProgress(progress, animated: animated, completion: nil)
    }
    
    public func setProgress(_ progress: CGFloat, animated: Bool, completion: (() -> Void)?) {
        let progress = min(1.0, max(0.0, progress))
        
        if self.progress == progress {
            completion?()
            return
        }
        
        lastProgress = self.progress
        self.progress = progress
        self.completionBlock = completion
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = lastProgress
            animation.toValue = progress
            animation.duration = animationDuration
            animation.timingFunction = timingFunction
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            
            let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
            colorAnimation.fromValue = progressColor.cgColor
            colorAnimation.toValue = progressColor.cgColor
            colorAnimation.duration = animationDuration
            
            progressLayer.add(animation, forKey: "progressAnimation")
            progressLayer.add(colorAnimation, forKey: "colorAnimation")
            
            animationTimer?.invalidate()
            animationTimer = Timer.scheduledTimer(withTimeInterval: animationDuration,
                                                repeats: false) { [weak self] _ in
                self?.animationDidComplete()
            }
        } else {
            progressLayer.strokeEnd = progress
            completion?()
        }
    }
    
    private func animationDidComplete() {
        completionBlock?()
        completionBlock = nil
    }
    
    // MARK: - Cleanup
    deinit {
        animationTimer?.invalidate()
    }
}

// MARK: - NSBezierPath Extension
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [NSPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            case .cubicCurveTo:
                break
            case .quadraticCurveTo:
                break
            @unknown default:
                break
            }
        }
        return path
    }
}
