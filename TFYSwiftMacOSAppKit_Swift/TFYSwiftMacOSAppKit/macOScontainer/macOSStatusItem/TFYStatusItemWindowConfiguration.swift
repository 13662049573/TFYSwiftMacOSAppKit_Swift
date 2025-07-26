//
//  TFYStatusItemWindowConfiguration.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

/// 呈现过渡类型
public enum TFYPresentationTransition: Int {
    case none = 0
    case fade
    case slideAndFade
}

/// 默认常量
public struct TFYDefaultConstants {
    public static let arrowHeight: CGFloat = 11.0
    public static let arrowWidth: CGFloat = 42.0
    public static let cornerRadius: CGFloat = 5.0
    public static let animationDuration: TimeInterval = 0.25
    public static let windowMargin: CGFloat = 2.0
}

@objcMembers
public class TFYStatusItemWindowConfiguration: NSObject {
    
    // MARK: - Properties
    
    public var windowToStatusItemMargin: CGFloat = TFYDefaultConstants.windowMargin
    public var animationDuration: TimeInterval = TFYDefaultConstants.animationDuration
    public var backgroundColor: NSColor
    public var presentationTransition: TFYPresentationTransition = .fade
    public var toolTip: String?
    dynamic public var isPinned: Bool = false
    
    // MARK: - Initialization
    
    public override init() {
        self.backgroundColor = NSColor.windowBackgroundColor
        super.init()
    }
    
    // MARK: - Public Methods
    
    public static func defaultConfiguration() -> TFYStatusItemWindowConfiguration {
        return TFYStatusItemWindowConfiguration()
    }
    
    public func setPresentationTransition(_ transition: TFYPresentationTransition) {
        presentationTransition = transition
        if transition == .none {
            animationDuration = 0
        }
    }
}
