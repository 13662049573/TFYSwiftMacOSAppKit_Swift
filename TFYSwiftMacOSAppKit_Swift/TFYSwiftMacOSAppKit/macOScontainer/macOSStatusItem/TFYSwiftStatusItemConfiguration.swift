//
//  TFYSwiftStatusItemConfiguration.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public enum TTFYSwiftTransition : Int {
    case TFYSwiftTransitionNone = 0
    case TFYSwiftTransitionFade = 1
    case TFYSwiftTransitionSlideAndFade = 2
}

public let TFYDefaultArrowHeight:CGFloat = 11.0
public let TFYDefaultArrowWidth:CGFloat = 42.0
public let TFYDefaultCornerRadius:CGFloat = 5

public class TFYSwiftStatusItemConfiguration: NSObject {
    
    private let TFYDefaultStatusItemMargin:CGFloat = 2.0
    private let TFYDefaultAnimationDuration:TimeInterval = 0.21
    
    // 静态属性存储单例实例
    static let defaultConfiguration = TFYSwiftStatusItemConfiguration()
    // 私有初始化方法防止外部实例化
    public override init() {
        super.init()
        self.presentationTransition = .TFYSwiftTransitionFade
        self.windowToStatusItemMargin = TFYDefaultStatusItemMargin
        self.animationDuration = TFYDefaultAnimationDuration
        self.toolTip = ""
        self.backgroundColor = .windowBackgroundColor
        self.pinned = false
    }
    
    var windowToStatusItemMargin:CGFloat?
    var animationDuration:TimeInterval?
    var backgroundColor:NSColor?
    var toolTip:String?
    var pinned:Bool?
    var presentationTransition:TTFYSwiftTransition? {
        didSet {
            if let present = presentationTransition {
                if present == .TFYSwiftTransitionNone {
                    self.animationDuration = 0.0
                } else {
                    self.animationDuration = TFYDefaultAnimationDuration
                }
            }
        }
    }
}
