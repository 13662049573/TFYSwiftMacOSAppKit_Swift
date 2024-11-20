//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 自定义错误类型
enum TFYSwiftError: LocalizedError {
    case configurationError(String)    // 配置错误
    case connectionError(String)       // 连接错误
    case protocolError(String)         // 协议错误
    case authenticationError(String)   // 认证错误
    case encryptionError(String)       // 加密错误
    case decryptionError(String)       // 解密错误
    case networkError(String)          // 网络错误
    case invalidData(String)           // 无效数据
    
    /// 错误描述
    var errorDescription: String? {
        switch self {
        case .configurationError(let message):
            return "配置错误: \(message)"
        case .connectionError(let message):
            return "连接错误: \(message)"
        case .protocolError(let message):
            return "协议错误: \(message)"
        case .authenticationError(let message):
            return "认证错误: \(message)"
        case .encryptionError(let message):
            return "加密错误: \(message)"
        case .decryptionError(let message):
            return "解密错误: \(message)"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .invalidData(let message):
            return "数据错误: \(message)"
        }
    }
} 
