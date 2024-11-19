//
//  TFYProgressIndicator.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import CoreImage

public class TFYProgressIndicator: NSView {
    
    // MARK: - Properties
    public private(set) var progressIndicator: NSProgressIndicator
    public var color: NSColor? {
        didSet {
            updateColor()
        }
    }
    
    // MARK: - Initialization
    override init(frame: NSRect) {
        progressIndicator = NSProgressIndicator(frame: .zero)
        super.init(frame: frame)
        setupProgressIndicator()
    }
    
    required init?(coder: NSCoder) {
        progressIndicator = NSProgressIndicator(frame: .zero)
        super.init(coder: coder)
        setupProgressIndicator()
    }
    
    private func setupProgressIndicator() {
        // Configure progress indicator
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .regular
        progressIndicator.wantsLayer = true
        
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
    
    // MARK: - Color Management
    private func updateColor() {
        guard let color = color else { return }
        
        // Method 1: Using Core Image filter
        let colorFilter = CIFilter(name: "CIColorMonochrome")
        colorFilter?.setDefaults()
        colorFilter?.setValue(CIColor(color: color), forKey: "inputColor")
        colorFilter?.setValue(1.0, forKey: "inputIntensity")
        progressIndicator.contentFilters = [colorFilter].compactMap { $0 }
        
        // Method 2: Set layer properties
        progressIndicator.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Method 3: Set appearance based on brightness
        var brightness: CGFloat = 0
        color.usingColorSpace(.sRGB)?.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        progressIndicator.appearance = NSAppearance(named: brightness > 0.5 ? .aqua : .darkAqua)
    }
    
    // MARK: - Animation Control
    public func startAnimation() {
        DispatchQueue.main.async { [weak self] in
            self?.progressIndicator.startAnimation(nil)
        }
    }
    
    public func stopAnimation() {
        DispatchQueue.main.async { [weak self] in
            self?.progressIndicator.stopAnimation(nil)
        }
    }
}
