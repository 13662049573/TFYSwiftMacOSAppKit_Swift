//
//  Bundle+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

// Bundle+YYAdd.swift

import AppKit

// MARK: - Bundle 扩展
public extension Bundle {
    
    /// 屏幕缩放倍数的最佳搜索顺序
    /// 对于 macOS，我们使用主屏幕的缩放因子
    static var preferredScales: [CGFloat] {
        struct Static {
            static let scales: [CGFloat] = {
                let screenScale = NSScreen.main?.backingScaleFactor ?? 1.0
                if screenScale <= 1 {
                    return [1, 2]
                } else {
                    return [2, 1]
                }
            }()
        }
        return Static.scales
    }
    
    /**
     获取带有屏幕缩放倍数的资源路径
     
     - Parameters:
        - name: 资源名称
        - ext: 资源扩展名
        - bundlePath: bundle目录路径
     - Returns: 资源的完整路径
     */
    static func path(forScaledResource name: String,
                    ofType ext: String?,
                    inDirectory bundlePath: String) -> String? {
        guard !name.isEmpty else { return nil }
        if name.hasSuffix("/") {
            return path(forResource: name, ofType: ext, inDirectory: bundlePath)
        }
        
        // 按优先级尝试不同的缩放倍数
        for scale in preferredScales {
            let scaledName: String
            if let ext = ext, !ext.isEmpty {
                scaledName = name.appendingNameScale(scale)
            } else {
                scaledName = name.appendingPathScale(scale)
            }
            
            if let path = path(forResource: scaledName,
                             ofType: ext,
                             inDirectory: bundlePath) {
                return path
            }
        }
        
        return nil
    }
    
    /**
     获取带有屏幕缩放倍数的资源路径
     
     - Parameters:
        - name: 资源名称
        - ext: 资源扩展名
     */
    func path(forScaledResource name: String,
             ofType ext: String?) -> String? {
        guard !name.isEmpty else { return nil }
        if name.hasSuffix("/") {
            return path(forResource: name, ofType: ext)
        }
        
        for scale in Bundle.preferredScales {
            let scaledName: String
            if let ext = ext, !ext.isEmpty {
                scaledName = name.appendingNameScale(scale)
            } else {
                scaledName = name.appendingPathScale(scale)
            }
            
            if let path = path(forResource: scaledName, ofType: ext) {
                return path
            }
        }
        
        return nil
    }
    
    /**
     获取带有屏幕缩放倍数的资源路径
     
     - Parameters:
        - name: 资源名称
        - ext: 资源扩展名
        - subpath: bundle子目录路径
     */
    func path(forScaledResource name: String,
             ofType ext: String?,
             inDirectory subpath: String?) -> String? {
        guard !name.isEmpty else { return nil }
        if name.hasSuffix("/") {
            return path(forResource: name, ofType: ext)
        }
        
        for scale in Bundle.preferredScales {
            let scaledName: String
            if let ext = ext, !ext.isEmpty {
                scaledName = name.appendingNameScale(scale)
            } else {
                scaledName = name.appendingPathScale(scale)
            }
            
            if let path = path(forResource: scaledName,
                             ofType: ext,
                             inDirectory: subpath) {
                return path
            }
        }
        
        return nil
    }
}
