//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 自定义错误类型枚举
/// 实现 LocalizedError 协议以提供本地化的错误描述
public enum TFYSwiftError: LocalizedError {
    /// 配置相关错误，如配置文件格式错误、参数无效等
    case configurationError(String)    
    
    /// 网络连接相关错误，如连接超时、连接断开等
    case connectionError(String)       
    
    /// 协议相关错误，如协议版本不匹配、数据格式错误等
    case protocolError(String)         
    
    /// 身份验证相关错误，如密码错误、token失效等
    case authenticationError(String)   
    
    /// 加密过程中的错误，如密钥无效、加密失败等
    case encryptionError(String)       
    
    /// 解密过程中的错误，如密钥不匹配、数据损坏等
    case decryptionError(String)       
    
    /// 网络通信错误，如DNS解析失败、网络不可用等
    case networkError(String)          
    
    /// 数据格式错误，如JSON解析失败、数据校验失败等
    case invalidData(String)           
    
    /// 系统级错误，如权限不足、资源不足等
    case systemError(String)           
    
    /// 错误的详细描述
    /// 实现 LocalizedError 协议的 errorDescription 属性
    public var errorDescription: String? {
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
            return "无效数据: \(message)"
        case .systemError(let message):
            return "系统错误: \(message)"
        }
    }
    
    /// 错误恢复建议
    /// 为每种错误类型提供具体的解决方案建议
    public var recoverySuggestion: String? {
        switch self {
        case .configurationError:
            return "请检查配置参数是否正确"
        case .connectionError:
            return "请检查网络连接和服务器状态"
        case .protocolError:
            return "请确保客户端和服务器版本兼容"
        case .authenticationError:
            return "请验证用户名和密码是否正确"
        case .encryptionError:
            return "请检查加密参数和密钥设置"
        case .decryptionError:
            return "请确保加密方法和密钥匹配"
        case .networkError:
            return "请检查网络连接并重试"
        case .invalidData:
            return "请确保数据完整性并重试"
        case .systemError:
            return "请检查系统设置和权限"
        }
    }
} 

