//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

enum TFYSwiftError: Error {
    case configurationError(String)
    case connectionError(String)
    case cryptoError(String)
    case protocolError(String)
    case systemError(String)
    
    var localizedDescription: String {
        switch self {
        case .configurationError(let msg):
            return "Configuration Error: \(msg)"
        case .connectionError(let msg):
            return "Connection Error: \(msg)"
        case .cryptoError(let msg):
            return "Crypto Error: \(msg)"
        case .protocolError(let msg):
            return "Protocol Error: \(msg)"
        case .systemError(let msg):
            return "System Error: \(msg)"
        }
    }
} 
