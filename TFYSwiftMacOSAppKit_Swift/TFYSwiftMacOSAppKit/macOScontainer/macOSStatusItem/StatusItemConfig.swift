//
//  StatusItemConfig.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 状态项过渡类型枚举
public enum StatusItemTransition: Int {
    case none = 0
    case fade = 1
    case slideAndFade = 2
}

// 定义常量
public let TFY_DEFAULT_ARROW_HEIGHT: CGFloat = 11.0
public let TFY_DEFAULT_ARROW_WIDTH: CGFloat = 42.0
public let TFY_DEFAULT_CORNER_RADIUS: CGFloat = 5

// 状态项配置类
public class StatusItemConfig: NSObject {

    // 静态属性存储单例实例
    public static let defaultConfig = StatusItemConfig()

    // 私有初始化方法防止外部实例化
    public override init() {
        super.init()
        presentationTransition = .fade
        windowToStatusItemMargin = TFY_DEFAULT_STATUS_ITEM_MARGIN
        animationDuration = TFY_DEFAULT_ANIMATION_DURATION
        toolTip = ""
        backgroundColor = .windowBackgroundColor
        pinned = false
    }

    // 私有常量
    private let TFY_DEFAULT_STATUS_ITEM_MARGIN: CGFloat = 2.0
    private let TFY_DEFAULT_ANIMATION_DURATION: TimeInterval = 0.21

    // 属性
    public var windowToStatusItemMargin: CGFloat?
    public var animationDuration: TimeInterval?
    public var backgroundColor: NSColor?
    public var toolTip: String?
    public var pinned: Bool?
    public var presentationTransition: StatusItemTransition? {
        didSet {
            guard let present = presentationTransition else { return }
            if present == .none {
                animationDuration = 0.0
            } else {
                animationDuration = TFY_DEFAULT_ANIMATION_DURATION
            }
        }
    }
}
