//
//  TFYStatusItemContainerView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 状态栏项错误类型
public enum TFYStatusItemError: Error {
    case alreadyInitialized
    case invalidContentSize
    case configurationMissing
    case invalidImage
    case invalidView
    
    var localizedDescription: String {
        switch self {
        case .alreadyInitialized:
            return "状态栏项已经初始化"
        case .invalidContentSize:
            return "内容视图大小无效"
        case .configurationMissing:
            return "配置信息缺失"
        case .invalidImage:
            return "图片无效"
        case .invalidView:
            return "视图无效"
        }
    }
} 
