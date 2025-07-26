//
//  TFYStatusItemContainerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//


import Foundation

// MARK: - Notification Names
public extension Notification.Name {
    static let statusItemThemeChanged = Notification.Name("AppleInterfaceThemeChangedNotification")
    static let statusItemWindowWillShow = Notification.Name("TFYStatusItemWindowWillShowNotification")
    static let statusItemWindowDidShow = Notification.Name("TFYStatusItemWindowDidShowNotification")
    static let statusItemWindowWillDismiss = Notification.Name("TFYStatusItemWindowWillDismissNotification")
    static let statusItemWindowDidDismiss = Notification.Name("TFYStatusItemWindowDidDismissNotification")
    static let systemInterfaceThemeChanged = Notification.Name("TFYSystemInterfaceThemeChangedNotification")
} 
