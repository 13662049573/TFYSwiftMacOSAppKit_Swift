//
//  TFYThemeManager.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import CoreImage

public class TFYThemeManager: NSObject {
    // MARK: - Properties
    private var themes: [String: [String: Any]] = [:]
    private(set) var currentTheme: [String: Any]?
    private weak var currentHUD: TFYProgressMacOSHUD?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupDefaultTheme()
    }
    
    // MARK: - Theme Setup
    func setupDefaultTheme() {
        // Register default light theme
        registerTheme(defaultLightTheme, for: "light")
        
        // Register default dark theme
        registerTheme(defaultDarkTheme, for: "dark")
        
        // Set initial theme
        applyTheme("dark")
    }
    
    private var defaultLightTheme: [String: Any] {
        return [
            "backgroundColor": NSColor(white: 0.0, alpha: 0.35),
            "containerBackgroundColor": NSColor(white: 0.95, alpha: 1.0),
            "textColor": NSColor.black,
            "progressColor": NSColor.systemBlue,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(white: 0, alpha: 0.1),
            "borderColor": NSColor(white: 0.8, alpha: 1.0),
            "cornerRadius": CGFloat(10.0),
            "borderWidth": CGFloat(1.0),
            "shadowRadius": CGFloat(20.0),
            "shadowOpacity": CGFloat(0.4),
            "blurEffect": "light"
        ]
    }
    
    private var defaultDarkTheme: [String: Any] {
        return [
            "backgroundColor": NSColor(white: 0.0, alpha: 0.35),
            "containerBackgroundColor": NSColor(white: 0.2, alpha: 1.0),
            "textColor": NSColor.white,
            "progressColor": NSColor.systemBlue,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(white: 0, alpha: 0.3),
            "borderColor": NSColor(white: 0.3, alpha: 1.0),
            "cornerRadius": CGFloat(10.0),
            "borderWidth": CGFloat(1.0),
            "shadowRadius": CGFloat(20.0),
            "shadowOpacity": CGFloat(0.4),
            "blurEffect": "dark"
        ]
    }
    
    // MARK: - Theme Management
    func registerTheme(_ theme: [String: Any], for name: String) {
        themes[name] = theme
    }
    
    func theme(for name: String) -> [String: Any]? {
        return themes[name]
    }
    
    func applyTheme(_ themeName: String) {
        guard let theme = theme(for: themeName) else { return }
        currentTheme = theme
        if let hud = currentHUD {
            applyTheme(to: hud)
        }
    }
    
    func applyTheme(to hud: TFYProgressMacOSHUD) {
        guard let theme = currentTheme else { return }
        
        currentHUD = hud
        
        // Configure main view
        hud.wantsLayer = true
        if let backgroundColor = theme["backgroundColor"] as? NSColor {
            hud.layer?.backgroundColor = backgroundColor.cgColor
        }
        
        // Configure container view
        hud.containerView.wantsLayer = true
        if let containerBackgroundColor = theme["containerBackgroundColor"] as? NSColor {
            hud.containerView.layer?.backgroundColor = containerBackgroundColor.cgColor
        }
        
        // Apply corner radius
        if let cornerRadius = theme["cornerRadius"] as? CGFloat {
            hud.containerView.layer?.cornerRadius = cornerRadius
        }
        
        // Apply border
        if let borderWidth = theme["borderWidth"] as? CGFloat {
            hud.containerView.layer?.borderWidth = borderWidth
        }
        
        if let borderColor = theme["borderColor"] as? NSColor {
            hud.containerView.layer?.borderColor = borderColor.cgColor
        }
        
        // Configure shadow
        if let shadowColor = theme["shadowColor"] as? NSColor {
            hud.containerView.layer?.shadowColor = shadowColor.cgColor
        }
        
        if let shadowRadius = theme["shadowRadius"] as? CGFloat {
            hud.containerView.layer?.shadowRadius = shadowRadius
        }
        
        if let shadowOpacity = theme["shadowOpacity"] as? Float {
            hud.containerView.layer?.shadowOpacity = shadowOpacity
        }
        
        hud.containerView.layer?.shadowOffset = NSSize(width: 0, height: -3)
        
        // Configure text color
        if let textColor = theme["textColor"] as? NSColor {
            hud.statusLabel.textColor = textColor
        }
        
        // Configure progress indicator color
        if let progressColor = theme["progressColor"] as? NSColor {
            hud.progressView.progressColor = progressColor
            hud.activityIndicator.setColor(progressColor)
        }
    }
    
    // MARK: - System Theme Observation
    func observeSystemThemeChanges() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleSystemThemeChange),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }
    
    @objc private func handleSystemThemeChange(_ notification: Notification) {
        let themeName = NSApp.effectiveAppearance.name.rawValue.contains("Dark") ? "dark" : "light"
        applyTheme(themeName)
    }
    
    // MARK: - Cleanup
    func cleanup() {
        DistributedNotificationCenter.default().removeObserver(self)
        themes.removeAll()
        currentTheme = nil
        currentHUD = nil
    }
    
    deinit {
        cleanup()
    }
}
