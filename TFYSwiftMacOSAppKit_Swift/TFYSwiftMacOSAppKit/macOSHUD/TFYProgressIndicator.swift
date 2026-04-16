//
//  TFYProgressIndicator.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import CoreImage

public enum TFYProgressIndicatorStyle {
    case spinning
    case determinate
    case indeterminate
}

public enum TFYProgressIndicatorSize {
    case small
    case regular
    case large
    case custom(CGFloat)
}

public class TFYProgressIndicator: NSView {
    // MARK: - Properties
    public private(set) var progressIndicator: NSProgressIndicator
    private var style: TFYProgressIndicatorStyle = .spinning
    private var size: TFYProgressIndicatorSize = .regular
    private var isAnimating: Bool = false
    
    public var tintColor: NSColor? {
        didSet {
            if let color = tintColor {
                setColor(color)
            }
        }
    }
    
    public var progress: Double = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    public var isIndeterminate: Bool = true {
        didSet {
            updateIndeterminateState()
        }
    }
    
    // MARK: - Initialization
    public override init(frame: NSRect) {
        progressIndicator = NSProgressIndicator(frame: .zero)
        super.init(frame: frame)
        setupProgressIndicator()
    }
    
    public required init?(coder: NSCoder) {
        progressIndicator = NSProgressIndicator(frame: .zero)
        super.init(coder: coder)
        setupProgressIndicator()
    }
    
    // MARK: - Setup
    private func setupProgressIndicator() {
        // Configure progress indicator
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .regular
        progressIndicator.wantsLayer = true
        progressIndicator.isIndeterminate = true
        
        addSubview(progressIndicator)
        
        // Setup constraints
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressIndicator.widthAnchor.constraint(equalToConstant: 30),
            progressIndicator.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Public Methods
    public func setStyle(_ style: TFYProgressIndicatorStyle) {
        self.style = style
        
        switch style {
        case .spinning:
            progressIndicator.style = .spinning
            progressIndicator.isIndeterminate = true
        case .determinate:
            progressIndicator.style = .bar
            progressIndicator.isIndeterminate = false
        case .indeterminate:
            progressIndicator.style = .bar
            progressIndicator.isIndeterminate = true
        }
    }
    
    public func setSize(_ size: TFYProgressIndicatorSize) {
        self.size = size
        
        let sizeValue: CGFloat
        let controlSize: NSControl.ControlSize
        
        switch size {
        case .small:
            sizeValue = 20
            controlSize = .small
        case .regular:
            sizeValue = 30
            controlSize = .regular
        case .large:
            sizeValue = 40
            controlSize = .large
        case .custom(let customSize):
            sizeValue = customSize
            controlSize = .regular
        }
        
        progressIndicator.controlSize = controlSize
        
        // Update constraints
        progressIndicator.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        NSLayoutConstraint.activate([
            progressIndicator.widthAnchor.constraint(equalToConstant: sizeValue),
            progressIndicator.heightAnchor.constraint(equalToConstant: sizeValue)
        ])
    }
    
    public func setColor(_ color: NSColor) {
        // Primary: clear any existing filters, apply appearance tinting
        progressIndicator.contentFilters = []
        progressIndicator.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Use appearance-based tinting as the simpler, more reliable approach
        if let brightness = color.usingColorSpace(.sRGB)?.brightnessComponent {
            progressIndicator.appearance = brightness > 0.5 ?
                NSAppearance(named: .aqua) :
                NSAppearance(named: .darkAqua)
        }
        
        // Fallback: CIColorMonochrome filter for precise color matching
        if let colorFilter = CIFilter(name: "CIColorMonochrome") {
            colorFilter.setDefaults()
            colorFilter.setValue(CIColor(color: color), forKey: "inputColor")
            colorFilter.setValue(1.0, forKey: "inputIntensity")
            progressIndicator.contentFilters = [colorFilter]
        }
        
        if style == .determinate {
            progressIndicator.layer?.borderColor = color.cgColor
            progressIndicator.layer?.borderWidth = 1.0
        }
    }
    
    public func setProgress(_ progress: Double, animated: Bool = true) {
        self.progress = max(0.0, min(1.0, progress))
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                progressIndicator.doubleValue = self.progress
            })
        } else {
            progressIndicator.doubleValue = self.progress
        }
    }
    
    public func startAnimation() {
        guard !isAnimating else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.progressIndicator.startAnimation(nil)
            self?.isAnimating = true
        }
    }
    
    public func stopAnimation() {
        guard isAnimating else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.progressIndicator.stopAnimation(nil)
            self?.isAnimating = false
        }
    }
    
    public func reset() {
        stopAnimation()
        setProgress(0.0, animated: false)
    }
    
    // MARK: - Private Methods
    private func updateProgress() {
        if style == .determinate {
            progressIndicator.doubleValue = progress
        }
    }
    
    private func updateIndeterminateState() {
        progressIndicator.isIndeterminate = isIndeterminate
    }
    
    // MARK: - Convenience Methods
    public func configure(style: TFYProgressIndicatorStyle, size: TFYProgressIndicatorSize, color: NSColor? = nil) {
        setStyle(style)
        setSize(size)
        if let color = color {
            setColor(color)
        }
    }
    
    public func showProgress(_ progress: Double, animated: Bool = true) {
        setStyle(.determinate)
        setProgress(progress, animated: animated)
    }
    
    public func showSpinning() {
        setStyle(.spinning)
        startAnimation()
    }
    
    public func showIndeterminate() {
        setStyle(.indeterminate)
        startAnimation()
    }
}

// MARK: - NSColor Extension
private extension NSColor {
    var brightnessComponent: CGFloat {
        guard let rgbColor = usingColorSpace(.sRGB) else { return 0 }
        var brightness: CGFloat = 0
        rgbColor.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }
}
