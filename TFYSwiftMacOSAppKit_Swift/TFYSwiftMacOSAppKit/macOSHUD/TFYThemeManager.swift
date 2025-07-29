//
//  TFYThemeManager.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import CoreImage

public enum TFYThemeType {
    case light
    case dark
    case custom
    case system
}

public class TFYThemeManager: NSObject {
    // MARK: - Properties
    private var themes: [String: [String: Any]] = [:]
    private(set) var currentTheme: [String: Any]?
    private weak var currentHUD: TFYProgressMacOSHUD?
    private var currentThemeType: TFYThemeType = .dark
    
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
        
        // Register custom themes
        registerTheme(customBlueTheme, for: "customBlue")
        registerTheme(customGreenTheme, for: "customGreen")
        registerTheme(customPurpleTheme, for: "customPurple")
        registerTheme(customOrangeTheme, for: "customOrange")
        
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
    
    private var customBlueTheme: [String: Any] {
        return [
            "backgroundColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4),
            "containerBackgroundColor": NSColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 0.9),
            "textColor": NSColor.white,
            "progressColor": NSColor.systemBlue,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3),
            "borderColor": NSColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0),
            "cornerRadius": CGFloat(12.0),
            "borderWidth": CGFloat(1.5),
            "shadowRadius": CGFloat(25.0),
            "shadowOpacity": CGFloat(0.5),
            "blurEffect": "dark"
        ]
    }
    
    private var customGreenTheme: [String: Any] {
        return [
            "backgroundColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4),
            "containerBackgroundColor": NSColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 0.9),
            "textColor": NSColor.white,
            "progressColor": NSColor.systemGreen,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3),
            "borderColor": NSColor(red: 0.2, green: 0.7, blue: 0.4, alpha: 1.0),
            "cornerRadius": CGFloat(12.0),
            "borderWidth": CGFloat(1.5),
            "shadowRadius": CGFloat(25.0),
            "shadowOpacity": CGFloat(0.5),
            "blurEffect": "dark"
        ]
    }
    
    private var customPurpleTheme: [String: Any] {
        return [
            "backgroundColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4),
            "containerBackgroundColor": NSColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 0.9),
            "textColor": NSColor.white,
            "progressColor": NSColor.systemPurple,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3),
            "borderColor": NSColor(red: 0.5, green: 0.3, blue: 0.9, alpha: 1.0),
            "cornerRadius": CGFloat(12.0),
            "borderWidth": CGFloat(1.5),
            "shadowRadius": CGFloat(25.0),
            "shadowOpacity": CGFloat(0.5),
            "blurEffect": "dark"
        ]
    }
    
    private var customOrangeTheme: [String: Any] {
        return [
            "backgroundColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4),
            "containerBackgroundColor": NSColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 0.9),
            "textColor": NSColor.white,
            "progressColor": NSColor.systemOrange,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3),
            "borderColor": NSColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0),
            "cornerRadius": CGFloat(12.0),
            "borderWidth": CGFloat(1.5),
            "shadowRadius": CGFloat(25.0),
            "shadowOpacity": CGFloat(0.5),
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
    
    func applyThemeType(_ themeType: TFYThemeType) {
        currentThemeType = themeType
        
        switch themeType {
        case .light:
            applyTheme("light")
        case .dark:
            applyTheme("dark")
        case .custom:
            applyTheme("customBlue")
        case .system:
            let isDark = NSApp.effectiveAppearance.name.rawValue.contains("Dark")
            applyTheme(isDark ? "dark" : "light")
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
    
    // MARK: - Custom Theme Creation
    func createCustomTheme(
        backgroundColor: NSColor,
        containerBackgroundColor: NSColor,
        textColor: NSColor,
        progressColor: NSColor,
        cornerRadius: CGFloat = 10.0,
        borderWidth: CGFloat = 1.0,
        shadowRadius: CGFloat = 20.0,
        shadowOpacity: CGFloat = 0.4
    ) -> [String: Any] {
        return [
            "backgroundColor": backgroundColor,
            "containerBackgroundColor": containerBackgroundColor,
            "textColor": textColor,
            "progressColor": progressColor,
            "successColor": NSColor.systemGreen,
            "errorColor": NSColor.systemRed,
            "shadowColor": NSColor(white: 0, alpha: 0.3),
            "borderColor": containerBackgroundColor.withAlphaComponent(0.8),
            "cornerRadius": cornerRadius,
            "borderWidth": borderWidth,
            "shadowRadius": shadowRadius,
            "shadowOpacity": shadowOpacity,
            "blurEffect": "custom"
        ]
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
        if currentThemeType == .system {
            let themeName = NSApp.effectiveAppearance.name.rawValue.contains("Dark") ? "dark" : "light"
            applyTheme(themeName)
        }
    }
    
    // MARK: - Theme Information
    func getAvailableThemes() -> [String] {
        return Array(themes.keys)
    }
    
    func getCurrentThemeName() -> String? {
        guard let currentTheme = currentTheme else { return nil }
        
        // 比较主题的关键属性而不是整个字典
        for (name, theme) in themes {
            if isThemeEqual(theme, currentTheme) {
                return name
            }
        }
        return nil
    }
    
    private func isThemeEqual(_ theme1: [String: Any], _ theme2: [String: Any]) -> Bool {
        // 比较关键的主题属性
        let keyProperties = ["backgroundColor", "containerBackgroundColor", "textColor", "progressColor", "cornerRadius"]
        
        for key in keyProperties {
            let value1 = theme1[key]
            let value2 = theme2[key]
            
            if let color1 = value1 as? NSColor, let color2 = value2 as? NSColor {
                if !color1.isEqual(color2) {
                    return false
                }
            } else if let number1 = value1 as? CGFloat, let number2 = value2 as? CGFloat {
                if number1 != number2 {
                    return false
                }
            } else if value1 != nil || value2 != nil {
                // 如果一个是nil而另一个不是，则不相等
                return false
            }
        }
        
        return true
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
