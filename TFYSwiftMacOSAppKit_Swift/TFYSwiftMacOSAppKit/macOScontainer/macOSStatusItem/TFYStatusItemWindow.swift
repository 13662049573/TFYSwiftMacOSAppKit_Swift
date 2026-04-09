//
//  TFYStatusItemWindow.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYStatusItemWindow: NSPanel {
    
    // MARK: - Properties
    
    private var configuration: TFYStatusItemWindowConfiguration?
    private var userContentView: NSView?
    private var backgroundView: TFYStatusItemWindowBackgroundView?
    
    // MARK: - Initialization
    
    public class func statusItemWindowWithConfiguration(
        configuration: TFYStatusItemWindowConfiguration
    ) -> TFYStatusItemWindow {
        return TFYStatusItemWindow(
            contentRect: .zero,
            styleMask: .nonactivatingPanel,
            backing: .buffered,
            defer: true,
            configuration: configuration
        )
    }
    
    public init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool,
        configuration: TFYStatusItemWindowConfiguration
    ) {
        self.configuration = configuration
        super.init(contentRect: contentRect, styleMask: styleMask, backing: backing, defer: flag)
        setupWindow()
    }
    
    // MARK: - Setup
    
    private func setupWindow() {
        isOpaque = false
        hasShadow = true
        level = .statusBar
        backgroundColor = .clear
        collectionBehavior = [.canJoinAllSpaces, .ignoresCycle]
        
        if #available(macOS 12.0, *) {
            appearance = NSAppearance.currentDrawing()
        } else {
            appearance = NSAppearance.current
        }
    }
    
    // MARK: - Overrides
    
    public override var canBecomeKey: Bool { true }
    
    public override var contentView: NSView? {
        get { userContentView }
        set { setupContentView(newValue) }
    }
    
    public override func frameRect(forContentRect contentRect: NSRect) -> NSRect {
        return NSRect(
            x: contentRect.minX,
            y: contentRect.minY,
            width: contentRect.width,
            height: contentRect.height + TFYDefaultConstants.arrowHeight
        )
    }
    
    // MARK: - Private Methods
    
    private func setupContentView(_ contentView: NSView?) {
        guard let contentView = contentView,
              userContentView !== contentView else { return }
        
        let contentBounds = NSRect(origin: .zero, size: contentView.bounds.size)
        let windowBounds = frameRect(forContentRect: contentBounds)
        setupBackgroundViewIfNeeded(with: windowBounds)
        backgroundView?.frame = windowBounds
        
        if let oldContentView = userContentView {
            oldContentView.removeFromSuperview()
        }
        
        userContentView = contentView
        configureUserContentView(contentView, bounds: windowBounds)
        backgroundView?.addSubview(contentView)
    }
    
    private func setupBackgroundViewIfNeeded(with bounds: NSRect) {
        guard let configuration = configuration else { return }

        if backgroundView == nil {
            backgroundView = TFYStatusItemWindowBackgroundView(
                frame: bounds,
                windowConfiguration: configuration
            )
            if let backgroundView {
                configureBackgroundView(backgroundView, bounds: bounds)
                super.contentView = backgroundView
            }
            return
        }

        backgroundView?.windowConfiguration = configuration
        if let backgroundView {
            configureBackgroundView(backgroundView, bounds: bounds)
        }
    }
    
    private func configureView(_ view: NSView, bounds: NSRect) {
        view.wantsLayer = true
        view.layer?.frame = bounds
        view.layer?.cornerRadius = TFYDefaultConstants.cornerRadius
        view.layer?.masksToBounds = true
        view.layer?.edgeAntialiasingMask = [
            .layerLeftEdge,
            .layerRightEdge,
            .layerBottomEdge,
            .layerTopEdge
        ]
    }
    
    private func configureBackgroundView(_ view: NSView, bounds: NSRect) {
        view.frame = bounds
        configureView(view, bounds: bounds)
    }
    
    private func configureUserContentView(_ view: NSView, bounds: NSRect) {
        view.frame = contentRect(forFrameRect: bounds)
        view.autoresizingMask = [.width, .height]
        configureView(view, bounds: bounds)
    }
}
