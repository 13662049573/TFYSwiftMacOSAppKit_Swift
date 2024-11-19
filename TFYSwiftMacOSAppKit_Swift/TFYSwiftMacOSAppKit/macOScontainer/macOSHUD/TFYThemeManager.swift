//
//  TFYThemeManager.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import CoreImage

public class TFYThemeManager {
    
    // MARK: - Properties
    private var themes: [String: [String: Any]] = [:]
    private(set) var currentTheme: [String: Any] = [:]
    private weak var currentHUD: TFYProgressMacOSHUD?
    
    // MARK: - Initialization
    public init() {
        setupDefaultTheme()
    }
    
    // MARK: - Theme Setup
    public func setupDefaultTheme() {
        registerTheme(defaultLightTheme(), forName: "light")
        registerTheme(defaultDarkTheme(), forName: "dark")
        applyTheme("light")
    }
    
    private func defaultLightTheme() -> [String: Any] {
        return [
            "backgroundColor": NSColor(white: 0.0, alpha: 0.35),
            "containerBackgroundColor": NSColor(white: 0.95, alpha: 1.0),
            "textColor": NSColor.black,
            "progressColor": NSColor.systemBlue,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(white: 0, alpha: 0.1),
            "borderColor": NSColor(white: 0.8, alpha: 1.0),
            "cornerRadius": 10.0,
            "borderWidth": 1.0,
            "shadowRadius": 20.0,
            "shadowOpacity": 0.2,
            "blurEffect": "light"
        ]
    }
    
    private func defaultDarkTheme() -> [String: Any] {
        return [
            "backgroundColor": NSColor(white: 0.0, alpha: 0.35),
            "containerBackgroundColor": NSColor(white: 0.2, alpha: 1.0),
            "textColor": NSColor.white,
            "progressColor": NSColor.systemBlue,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(white: 0, alpha: 0.3),
            "borderColor": NSColor(white: 0.3, alpha: 1.0),
            "cornerRadius": 10.0,
            "borderWidth": 1.0,
            "shadowRadius": 20.0,
            "shadowOpacity": 0.4,
            "blurEffect": "dark"
        ]
    }
    
    // MARK: - Theme Management
    public func registerTheme(_ theme: [String: Any], forName name: String) {
        themes[name] = theme
    }
    
    public func theme(forName name: String) -> [String: Any]? {
        return themes[name]
    }
    
    public func applyTheme(_ themeName: String) {
        guard let theme = theme(forName: themeName) else { return }
        currentTheme = theme
        if let hud = currentHUD {
            applyTheme(to: hud)
        }
    }
    
    public func applyTheme(to hud: TFYProgressMacOSHUD) {
        guard !currentTheme.isEmpty else { return }
        
        currentHUD = hud
        
        // Configure main view
        hud.wantsLayer = true
        if let backgroundColor = currentTheme["backgroundColor"] as? NSColor {
            hud.layer?.backgroundColor = backgroundColor.cgColor
        }
        
        // Configure container view
        hud.containerView.wantsLayer = true
        if let containerBackgroundColor = currentTheme["containerBackgroundColor"] as? NSColor {
            hud.containerView.layer?.backgroundColor = containerBackgroundColor.cgColor
        }
        
        // Apply corner radius
        if let cornerRadius = currentTheme["cornerRadius"] as? CGFloat {
            hud.containerView.layer?.cornerRadius = cornerRadius
        }
        
        // Apply border
        if let borderWidth = currentTheme["borderWidth"] as? CGFloat {
            hud.containerView.layer?.borderWidth = borderWidth
        }
        
        if let borderColor = currentTheme["borderColor"] as? NSColor {
            hud.containerView.layer?.borderColor = borderColor.cgColor
        }
        
        // Apply shadow
        if let shadowColor = currentTheme["shadowColor"] as? NSColor {
            hud.containerView.layer?.shadowColor = shadowColor.cgColor
        }
        
        if let shadowRadius = currentTheme["shadowRadius"] as? CGFloat {
            hud.containerView.layer?.shadowRadius = shadowRadius
        }
        
        if let shadowOpacity = currentTheme["shadowOpacity"] as? Float {
            hud.containerView.layer?.shadowOpacity = shadowOpacity
        }
        
        hud.containerView.layer?.shadowOffset = NSSize(width: 0, height: -3)
        
        // Configure text color
        if let textColor = currentTheme["textColor"] as? NSColor {
            hud.statusLabel.textColor = textColor
        }
        
        // Configure progress indicators
        if let progressColor = currentTheme["progressColor"] as? NSColor {
            hud.progressView.progressColor = progressColor
            hud.activityIndicator.color = progressColor
        }
    }
    
    // MARK: - Spinner Color Update
    public func updateSpinnerColor(_ color: NSColor, for hud: TFYProgressMacOSHUD) {
        guard let rgbColor = color.usingColorSpace(.sRGB) else {
            hud.activityIndicator.appearance = NSAppearance(named: .aqua)
            return
        }
        
        var brightness: CGFloat = 0
        rgbColor.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        
        hud.activityIndicator.appearance = NSAppearance(named: brightness > 0.5 ? .aqua : .darkAqua)
    }
    
    // MARK: - System Theme Observation
    public func observeSystemThemeChanges() {
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
    public func cleanup() {
        DistributedNotificationCenter.default().removeObserver(self)
        themes.removeAll()
        currentTheme.removeAll()
        currentHUD = nil
    }
    
    deinit {
        cleanup()
    }
}
