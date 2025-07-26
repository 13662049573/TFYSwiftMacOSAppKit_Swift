//
//  TFYSwiftButton.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Padding Structure
public struct Padding {
    let vertical: CGFloat
    let horizontal: CGFloat
    
    init(vertical: CGFloat = 0, horizontal: CGFloat = 0) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
}

// MARK: - Custom Button
public class TFYSwiftButton: NSButton {
    
    // MARK: - Properties
    private var originalBackgroundColor: NSColor = .clear {
        didSet {
            updateBackgroundColor(originalBackgroundColor)
        }
    }
    
    @IBInspectable public var verticalImageInset: CGFloat = 0 {
        didSet { needsDisplay = true }
    }
    
    @IBInspectable public var horizontalImageInset: CGFloat = 0 {
        didSet { needsDisplay = true }
    }
    
    @IBInspectable public var hoverBackgroundColor: NSColor = .black
    
    // MARK: - Computed Properties
    private var currentPadding: Padding {
        Padding(vertical: verticalImageInset, horizontal: horizontalImageInset)
    }
    
    public var titleTextColor: NSColor {
        get {
            attributedTitle.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor ?? .labelColor
        }
        set {
            let attrTitle = NSMutableAttributedString(attributedString: attributedTitle)
            attrTitle.addAttribute(.foregroundColor, value: newValue, range: NSRange(location: 0, length: title.count))
            self.attributedTitle = attrTitle
        }
    }
    
    public var backgroundColor: NSColor {
        get { originalBackgroundColor }
        set { originalBackgroundColor = newValue }
    }
    
    // MARK: - Initialization
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Setup
    private func setupButton() {
        isBordered = false
        bezelStyle = .texturedSquare
        wantsLayer = true
        
        setupTrackingArea()
    }
    
    private func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: bounds,
                                        options: options,
                                        owner: self,
                                        userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    // MARK: - Drawing
    public override func draw(_ dirtyRect: NSRect) {
        let originalBounds = bounds
        defer { bounds = originalBounds }
        
        bounds = originalBounds.insetBy(dx: currentPadding.horizontal,
                                      dy: currentPadding.vertical)
        
        super.draw(dirtyRect)
    }
    
    public override var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.width += currentPadding.horizontal * 2
        size.height += currentPadding.vertical * 2
        return size
    }
    
    // MARK: - Mouse Events
    public override func mouseEntered(with event: NSEvent) {
        updateBackgroundColor(hoverBackgroundColor)
    }
    
    public override func mouseExited(with event: NSEvent) {
        updateBackgroundColor(originalBackgroundColor)
    }
    
    // MARK: - Helper Methods
    private func updateBackgroundColor(_ color: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }
}

// MARK: - Custom Button Cell
public class TFYSwiftButtonCell: NSButtonCell {
    
    // MARK: - Properties
    @IBInspectable public var imagePaddingLeft: CGFloat = 0 {
        didSet { controlView?.needsDisplay = true }
    }
    
    @IBInspectable public var imagePaddingTop: CGFloat = 0 {
        didSet { controlView?.needsDisplay = true }
    }
    
    @IBInspectable public var textPaddingLeft: CGFloat = 0 {
        didSet { controlView?.needsDisplay = true }
    }
    
    @IBInspectable public var textPaddingTop: CGFloat = 0 {
        didSet { controlView?.needsDisplay = true }
    }
    
    // MARK: - Drawing Methods
    public override func drawImage(_ image: NSImage,
                                 withFrame frame: NSRect,
                                 in controlView: NSView) {
        let padding = Padding(vertical: imagePaddingTop,
                            horizontal: imagePaddingLeft)
        let newFrame = NSRect(x: frame.minX + padding.horizontal,
                            y: frame.minY + padding.vertical,
                            width: frame.width,
                            height: frame.height)
        super.drawImage(image, withFrame: newFrame, in: controlView)
    }
    
    public override func drawTitle(_ title: NSAttributedString,
                                 withFrame frame: NSRect,
                                 in controlView: NSView) -> NSRect {
        let padding = Padding(vertical: textPaddingTop,
                            horizontal: textPaddingLeft)
        let newFrame = NSRect(x: frame.minX + padding.horizontal,
                            y: frame.minY + padding.vertical,
                            width: frame.width,
                            height: frame.height)
        return super.drawTitle(title, withFrame: newFrame, in: controlView)
    }
}
