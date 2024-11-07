//
//  TFYStatusItemWindowConfiguration.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public enum TFYPresentationTransition: Int {
    case none = 0
    case fade
    case slideAndFade
}

let TFYDefaultArrowHeight: CGFloat = 11.0
let TFYDefaultArrowWidth: CGFloat = 42.0
let TFYDefaultCornerRadius: CGFloat = 5.0

public class TFYStatusItemWindowConfiguration: NSObject {
    
    static func defaultConfiguration() -> TFYStatusItemWindowConfiguration {
        return TFYStatusItemWindowConfiguration()
    }

    // 状态项窗口
    public var windowToStatusItemMargin: CGFloat = 2.0
    public var animationDuration: TimeInterval = 0.21
    public var backgroundColor: NSColor?
    public var presentationTransition: TFYPresentationTransition = .fade
    public var toolTip: String?
    public var isPinned: Bool = false

    public override init() {
        super.init()
        backgroundColor = NSColor.windowBackgroundColor
    }

    func setPresentationTransition(_ presentationTransition: TFYPresentationTransition) {
        if self.presentationTransition != presentationTransition {
            self.presentationTransition = presentationTransition
            if self.presentationTransition == .none {
                animationDuration = 0
            }
        }
    }
}
