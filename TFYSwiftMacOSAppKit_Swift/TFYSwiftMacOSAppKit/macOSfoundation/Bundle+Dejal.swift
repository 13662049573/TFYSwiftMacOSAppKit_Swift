//
//  Bundle+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

// Bundle+YYAdd.swift

import AppKit
import Foundation

// MARK: - Bundle 错误类型
public enum BundleError: LocalizedError {
    case resourceNotFound(String)
    case invalidResourceName(String)
    case invalidScale(CGFloat)
    case invalidDirectory(String)
    case fileSystemError(String)
    case unsupportedResourceType(String)
    case resourceCorrupted(String)
    case memoryError(String)
    case timeoutError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .resourceNotFound(let name):
            return "Bundle错误: 找不到资源 '\(name)'"
        case .invalidResourceName(let name):
            return "Bundle错误: 无效的资源名称 '\(name)'"
        case .invalidScale(let scale):
            return "Bundle错误: 无效的缩放倍数 \(scale)"
        case .invalidDirectory(let path):
            return "Bundle错误: 无效的目录路径 '\(path)'"
        case .fileSystemError(let message):
            return "Bundle错误: 文件系统错误 - \(message)"
        case .unsupportedResourceType(let type):
            return "Bundle错误: 不支持的资源类型 '\(type)'"
        case .resourceCorrupted(let name):
            return "Bundle错误: 资源已损坏 '\(name)'"
        case .memoryError(let message):
            return "Bundle错误: 内存错误 - \(message)"
        case .timeoutError(let message):
            return "Bundle错误: 超时错误 - \(message)"
        case .unknownError(let message):
            return "Bundle错误: 未知错误 - \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .resourceNotFound:
            return "指定的资源文件不存在于Bundle中"
        case .invalidResourceName:
            return "资源名称格式不正确或包含非法字符"
        case .invalidScale:
            return "缩放倍数必须是正数且合理范围"
        case .invalidDirectory:
            return "目录路径不存在或无法访问"
        case .fileSystemError:
            return "文件系统操作失败"
        case .unsupportedResourceType:
            return "当前不支持此类型的资源"
        case .resourceCorrupted:
            return "资源文件已损坏或格式不正确"
        case .memoryError:
            return "内存不足或内存分配失败"
        case .timeoutError:
            return "操作超时"
        case .unknownError:
            return "发生了未预期的错误"
        }
    }
}

// MARK: - Bundle 配置结构
public struct BundleConfiguration: Sendable {
    public let allowFallback: Bool
    public let validateResource: Bool
    public let timeout: TimeInterval
    public let maxRetries: Int
    public let logErrors: Bool
    
    public init(allowFallback: Bool = true,
                validateResource: Bool = true,
                timeout: TimeInterval = 30.0,
                maxRetries: Int = 3,
                logErrors: Bool = true) {
        self.allowFallback = allowFallback
        self.validateResource = validateResource
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.logErrors = logErrors
    }
    
    public static let `default` = BundleConfiguration()
    public static let strict = BundleConfiguration(allowFallback: false, validateResource: true)
    public static let relaxed = BundleConfiguration(allowFallback: true, validateResource: false)
}

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
    
    /// 支持的资源类型
    static let supportedResourceTypes = [
        "png", "jpg", "jpeg", "gif", "bmp", "tiff", "tga",
        "mp3", "wav", "aac", "m4a", "ogg",
        "mp4", "mov", "avi", "mkv", "wmv",
        "json", "plist", "xml", "txt", "html", "css", "js",
        "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx"
    ]
    
    /// 验证资源名称是否有效
    static func isValidResourceName(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        
        // 检查是否包含非法字符
        let illegalCharacters = CharacterSet(charactersIn: "<>:\"/\\|?*")
        if name.rangeOfCharacter(from: illegalCharacters) != nil {
            return false
        }
        
        // 检查是否以点开头或结尾
        if name.hasPrefix(".") || name.hasSuffix(".") {
            return false
        }
        
        return true
    }
    
    /// 验证缩放倍数是否有效
    static func isValidScale(_ scale: CGFloat) -> Bool {
        return scale > 0 && scale <= 10.0 // 合理的缩放范围
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

// MARK: - 高级Bundle功能
public extension Bundle {
    
    /// 获取资源路径（带错误处理）
    func pathForResource(_ name: String,
                        ofType ext: String?,
                        inDirectory subpath: String? = nil,
                        configuration: BundleConfiguration = .default) throws -> String {
        
        guard Bundle.isValidResourceName(name) else {
            throw BundleError.invalidResourceName(name)
        }
        
        // 尝试获取缩放资源
        if let path = path(forScaledResource: name, ofType: ext, inDirectory: subpath) {
            if configuration.validateResource {
                try validateResource(at: path)
            }
            return path
        }
        
        // 尝试获取普通资源
        if let path = path(forResource: name, ofType: ext, inDirectory: subpath) {
            if configuration.validateResource {
                try validateResource(at: path)
            }
            return path
        }
        
        // 如果允许回退，尝试不同的扩展名
        if configuration.allowFallback {
            for fallbackExt in ["png", "jpg", "jpeg", "gif"] {
                if let path = path(forResource: name, ofType: fallbackExt, inDirectory: subpath) {
                    if configuration.validateResource {
                        try validateResource(at: path)
                    }
                    return path
                }
            }
        }
        
        throw BundleError.resourceNotFound(name)
    }
    
    /// 获取资源数据（带错误处理）
    func dataForResource(_ name: String,
                        ofType ext: String?,
                        inDirectory subpath: String? = nil,
                        configuration: BundleConfiguration = .default) throws -> Data {
        
        let path = try pathForResource(name, ofType: ext, inDirectory: subpath, configuration: configuration)
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            if configuration.validateResource {
                try validateData(data, forResource: name)
            }
            
            return data
        } catch {
            throw BundleError.fileSystemError("无法读取资源数据: \(error.localizedDescription)")
        }
    }
    
    /// 获取资源URL（带错误处理）
    func urlForResource(_ name: String,
                       ofType ext: String?,
                       inDirectory subpath: String? = nil,
                       configuration: BundleConfiguration = .default) throws -> URL {
        
        let path = try pathForResource(name, ofType: ext, inDirectory: subpath, configuration: configuration)
        return URL(fileURLWithPath: path)
    }
    
    /// 批量获取资源路径
    func pathsForResources(withNames names: [String],
                          ofType ext: String?,
                          inDirectory subpath: String? = nil,
                          configuration: BundleConfiguration = .default) throws -> [String: String] {
        
        var results: [String: String] = [:]
        var errors: [String: Error] = [:]
        
        for name in names {
            do {
                let path = try pathForResource(name, ofType: ext, inDirectory: subpath, configuration: configuration)
                results[name] = path
            } catch {
                errors[name] = error
                if configuration.logErrors {
                    print("Bundle错误: 无法获取资源 '\(name)': \(error.localizedDescription)")
                }
            }
        }
        
        if !errors.isEmpty && !configuration.allowFallback {
            throw BundleError.resourceNotFound("批量获取资源失败: \(errors.keys.joined(separator: ", "))")
        }
        
        return results
    }
    
    /// 异步获取资源路径
    func pathForResourceAsync(_ name: String,
                             ofType ext: String?,
                             inDirectory subpath: String? = nil,
                             configuration: BundleConfiguration = .default) async throws -> String {
        
        return try await withCheckedThrowingContinuation { continuation in
            let config = configuration // 创建本地副本以避免Sendable问题
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let path = try self.pathForResource(name, ofType: ext, inDirectory: subpath, configuration: config)
                    continuation.resume(returning: path)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 获取资源信息
    func resourceInfo(for name: String,
                     ofType ext: String?,
                     inDirectory subpath: String? = nil) throws -> ResourceInfo {
        
        let path = try pathForResource(name, ofType: ext, inDirectory: subpath)
        let url = URL(fileURLWithPath: path)
        
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        let creationDate = attributes[.creationDate] as? Date
        let modificationDate = attributes[.modificationDate] as? Date
        
        return ResourceInfo(
            name: name,
            path: path,
            url: url,
            fileSize: fileSize,
            creationDate: creationDate,
            modificationDate: modificationDate,
            extension: ext,
            subpath: subpath
        )
    }
    
    /// 验证资源文件
    private func validateResource(at path: String) throws {
        _ = URL(fileURLWithPath: path) // 创建URL但不使用，仅用于验证路径格式
        
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: path) else {
            throw BundleError.resourceNotFound(path)
        }
        
        // 检查文件大小
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        if fileSize == 0 {
            throw BundleError.resourceCorrupted("文件大小为0")
        }
        
        // 检查文件是否可读
        guard FileManager.default.isReadableFile(atPath: path) else {
            throw BundleError.fileSystemError("文件不可读")
        }
    }
    
    /// 验证数据
    private func validateData(_ data: Data, forResource name: String) throws {
        guard !data.isEmpty else {
            throw BundleError.resourceCorrupted("数据为空")
        }
        
        // 检查数据大小限制（100MB）
        if data.count > 100 * 1024 * 1024 {
            throw BundleError.memoryError("数据过大: \(data.count) bytes")
        }
    }
}

// MARK: - 资源信息结构
public struct ResourceInfo {
    public let name: String
    public let path: String
    public let url: URL
    public let fileSize: Int64
    public let creationDate: Date?
    public let modificationDate: Date?
    public let `extension`: String?
    public let subpath: String?
    
    public var fileSizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    public var isImage: Bool {
        guard let ext = `extension`?.lowercased() else { return false }
        return ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "tga"].contains(ext)
    }
    
    public var isAudio: Bool {
        guard let ext = `extension`?.lowercased() else { return false }
        return ["mp3", "wav", "aac", "m4a", "ogg"].contains(ext)
    }
    
    public var isVideo: Bool {
        guard let ext = `extension`?.lowercased() else { return false }
        return ["mp4", "mov", "avi", "mkv", "wmv"].contains(ext)
    }
    
    public var isDocument: Bool {
        guard let ext = `extension`?.lowercased() else { return false }
        return ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx"].contains(ext)
    }
}

// MARK: - Bundle管理器
public class BundleManager {
    public static let shared = BundleManager()
    
    private var cache: [String: String] = [:]
    private let cacheQueue = DispatchQueue(label: "com.tfy.bundle.cache", attributes: .concurrent)
    
    private init() {}
    
    /// 获取资源路径（带缓存）
    public func pathForResource(_ name: String,
                               ofType ext: String?,
                               inDirectory subpath: String? = nil,
                               bundle: Bundle = .main,
                               configuration: BundleConfiguration = .default) throws -> String {
        
        let cacheKey = "\(name)_\(ext ?? "")_\(subpath ?? "")"
        
        return try cacheQueue.sync {
            if let cachedPath = cache[cacheKey] {
                return cachedPath
            }
            
            let path = try bundle.pathForResource(name, ofType: ext, inDirectory: subpath, configuration: configuration)
            cache[cacheKey] = path
            return path
        }
    }
    
    /// 清除缓存
    public func clearCache() {
        cacheQueue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
    
    /// 获取缓存统计信息
    public func cacheStatistics() -> (count: Int, totalSize: Int) {
        return cacheQueue.sync {
            let count = cache.count
            let totalSize = cache.values.joined().count
            return (count, totalSize)
        }
    }
}
