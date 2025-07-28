//
//  NSKeyedUnarchiver+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 解档错误类型
public enum UnarchiverError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidData(String)
    case unsupportedClass(String)
    case corruptedData(String)
    case securityError(String)
    case timeoutError(TimeInterval)
    case memoryError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "文件未找到: \(path)"
        case .invalidData(let reason):
            return "无效的数据: \(reason)"
        case .unsupportedClass(let className):
            return "不支持的类类型: \(className)"
        case .corruptedData(let reason):
            return "数据已损坏: \(reason)"
        case .securityError(let reason):
            return "安全错误: \(reason)"
        case .timeoutError(let timeout):
            return "解档超时: \(timeout)秒"
        case .memoryError(let reason):
            return "内存错误: \(reason)"
        case .unknownError(let reason):
            return "未知错误: \(reason)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .fileNotFound:
            return "指定的文件路径不存在或无法访问"
        case .invalidData:
            return "数据格式不正确或为空"
        case .unsupportedClass:
            return "尝试解档的类不在允许的类列表中"
        case .corruptedData:
            return "归档数据已损坏或格式不正确"
        case .securityError:
            return "安全策略阻止了解档操作"
        case .timeoutError:
            return "解档操作超过了指定的时间限制"
        case .memoryError:
            return "内存不足或内存分配失败"
        case .unknownError:
            return "发生了未预期的错误"
        }
    }
}

/// 解档配置结构体
public struct UnarchiverConfiguration {
    public let allowedClasses: [AnyClass]
    public let requiresSecureCoding: Bool
    public let timeout: TimeInterval
    
    public init(allowedClasses: [AnyClass] = [NSObject.self],
                requiresSecureCoding: Bool = true,
                timeout: TimeInterval = 30.0) {
        self.allowedClasses = allowedClasses
        self.requiresSecureCoding = requiresSecureCoding
        self.timeout = timeout
    }
}

/// NSKeyedUnarchiver 的扩展，提供异步解档功能
public extension NSKeyedUnarchiver {
    
    // MARK: - 基础异步解档
    
    /// 从数据中异步解档对象
    /// - Parameters:
    ///   - data: 需要解档的数据
    ///   - configuration: 解档配置，可选
    /// - Returns: 包含解档对象和错误信息的元组
    ///   - object: 解档后的对象，如果失败则为 nil
    ///   - error: 解档过程中的错误信息，如果成功则为 nil
    @available(macOS 12.0, *)
    static func unarchiveObject(withData data: Data, configuration: UnarchiverConfiguration? = nil) async -> (object: Any?, error: Error?) {
        do {
            let object = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Any?, Error>) in
                do {
                    let config = configuration ?? UnarchiverConfiguration()
                    let object = try NSKeyedUnarchiver.unarchivedObject(ofClasses: config.allowedClasses, from: data)
                        continuation.resume(returning: object)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            return (object, nil)
        } catch {
            return (nil, error)
        }
    }
    
    /// 从文件路径异步解档对象
    /// - Parameters:
    ///   - path: 归档文件的路径
    ///   - configuration: 解档配置，可选
    /// - Returns: 包含解档对象和错误信息的元组
    ///   - object: 解档后的对象，如果失败则为 nil
    ///   - error: 解档过程中的错误信息，如果成功则为 nil
    @available(macOS 12.0, *)
    static func unarchiveObject(withFile path: String, configuration: UnarchiverConfiguration? = nil) async -> (object: Any?, error: Error?) {
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: path) else {
            return (nil, UnarchiverError.fileNotFound(path))
        }
        
        // 读取文件内容
        guard let data = FileManager.default.contents(atPath: path) else {
            return (nil, UnarchiverError.invalidData("无法读取文件内容: \(path)"))
        }
        
        // 调用数据解档方法
        return await unarchiveObject(withData: data, configuration: configuration)
    }
    
    /// 从URL异步解档对象
    /// - Parameters:
    ///   - url: 归档文件的URL
    ///   - configuration: 解档配置，可选
    /// - Returns: 包含解档对象和错误信息的元组
    ///   - object: 解档后的对象，如果失败则为 nil
    ///   - error: 解档过程中的错误信息，如果成功则为 nil
    @available(macOS 12.0, *)
    static func unarchiveObject(withURL url: URL, configuration: UnarchiverConfiguration? = nil) async -> (object: Any?, error: Error?) {
        do {
            let data = try Data(contentsOf: url)
            return await unarchiveObject(withData: data, configuration: configuration)
        } catch {
            return (nil, UnarchiverError.invalidData("无法读取URL数据: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - 类型安全解档
    
    /// 从数据中异步解档指定类型的对象（类型安全版本）
    /// - Parameters:
    ///   - type: 要解档的对象类型
    ///   - data: 需要解档的数据
    ///   - configuration: 解档配置，可选
    /// - Returns: 包含解档对象和错误信息的元组
    ///   - object: 解档后的指定类型对象，如果失败则为 nil
    ///   - error: 解档过程中的错误信息，如果成功则为 nil
    /// - Note: 泛型类型 T 必须同时遵循 NSObject 和 NSSecureCoding 协议
    @available(macOS 12.0, *)
    static func unarchiveObject<T>(
        ofClass type: T.Type,
        from data: Data,
        configuration: UnarchiverConfiguration? = nil
    ) async -> (object: T?, error: Error?) where T: NSObject & NSSecureCoding {
        do {
            let object = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T?, Error>) in
                do {
                    let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: type, from: data)
                    continuation.resume(returning: object)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            return (object, nil)
        } catch {
            return (nil, error)
        }
    }
    
    /// 从文件路径异步解档指定类型的对象
    /// - Parameters:
    ///   - type: 要解档的对象类型
    ///   - path: 归档文件的路径
    ///   - configuration: 解档配置，可选
    /// - Returns: 包含解档对象和错误信息的元组
    @available(macOS 12.0, *)
    static func unarchiveObject<T>(
        ofClass type: T.Type,
        fromFile path: String,
        configuration: UnarchiverConfiguration? = nil
    ) async -> (object: T?, error: Error?) where T: NSObject & NSSecureCoding {
        guard let data = FileManager.default.contents(atPath: path) else {
            return (nil, UnarchiverError.fileNotFound(path))
        }
        return await unarchiveObject(ofClass: type, from: data, configuration: configuration)
    }
    
    /// 从URL异步解档指定类型的对象
    /// - Parameters:
    ///   - type: 要解档的对象类型
    ///   - url: 归档文件的URL
    ///   - configuration: 解档配置，可选
    /// - Returns: 包含解档对象和错误信息的元组
    @available(macOS 12.0, *)
    static func unarchiveObject<T>(
        ofClass type: T.Type,
        fromURL url: URL,
        configuration: UnarchiverConfiguration? = nil
    ) async -> (object: T?, error: Error?) where T: NSObject & NSSecureCoding {
        do {
            let data = try Data(contentsOf: url)
            return await unarchiveObject(ofClass: type, from: data, configuration: configuration)
        } catch {
            return (nil, UnarchiverError.invalidData("无法读取URL数据: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - 批量解档
    
    /// 批量异步解档多个文件
    /// - Parameters:
    ///   - paths: 文件路径数组
    ///   - configuration: 解档配置，可选
    /// - Returns: 解档结果数组
    @available(macOS 12.0, *)
    static func unarchiveObjects(fromFiles paths: [String], configuration: UnarchiverConfiguration? = nil) async -> [(path: String, object: Any?, error: Error?)] {
        var results: [(path: String, object: Any?, error: Error?)] = []
        
        await withTaskGroup(of: (String, Any?, Error?).self) { group in
            for path in paths {
                group.addTask {
                    let result = await unarchiveObject(withFile: path, configuration: configuration)
                    return (path, result.object, result.error)
                }
            }
            
            for await result in group {
                results.append(result)
            }
        }
        
        return results
    }
    
    /// 批量异步解档指定类型的对象
    /// - Parameters:
    ///   - type: 要解档的对象类型
    ///   - paths: 文件路径数组
    ///   - configuration: 解档配置，可选
    /// - Returns: 解档结果数组
    @available(macOS 12.0, *)
    static func unarchiveObjects<T>(
        ofClass type: T.Type,
        fromFiles paths: [String],
        configuration: UnarchiverConfiguration? = nil
    ) async -> [(path: String, object: T?, error: Error?)] where T: NSObject & NSSecureCoding {
        var results: [(path: String, object: T?, error: Error?)] = []
        
        await withTaskGroup(of: (String, T?, Error?).self) { group in
            for path in paths {
                group.addTask {
                    let result = await unarchiveObject(ofClass: type, fromFile: path, configuration: configuration)
                    return (path, result.object, result.error)
                }
            }
            
            for await result in group {
                results.append(result)
            }
        }
        
        return results
    }
    
    // MARK: - 便利方法
    
    /// 安全解档（返回可选值）
    /// - Parameters:
    ///   - data: 需要解档的数据
    ///   - configuration: 解档配置，可选
    /// - Returns: 解档后的对象，如果失败则返回nil
    @available(macOS 12.0, *)
    static func safeUnarchiveObject(withData data: Data, configuration: UnarchiverConfiguration? = nil) async -> Any? {
        let result = await unarchiveObject(withData: data, configuration: configuration)
        return result.object
    }
    
    /// 安全解档指定类型（返回可选值）
    /// - Parameters:
    ///   - type: 要解档的对象类型
    ///   - data: 需要解档的数据
    ///   - configuration: 解档配置，可选
    /// - Returns: 解档后的指定类型对象，如果失败则返回nil
    @available(macOS 12.0, *)
    static func safeUnarchiveObject<T>(
        ofClass type: T.Type,
        from data: Data,
        configuration: UnarchiverConfiguration? = nil
    ) async -> T? where T: NSObject & NSSecureCoding {
        let result = await unarchiveObject(ofClass: type, from: data, configuration: configuration)
        return result.object
    }
    
    /// 解档并转换错误
    /// - Parameters:
    ///   - data: 需要解档的数据
    ///   - configuration: 解档配置，可选
    /// - Returns: 解档后的对象
    /// - Throws: UnarchiverError 如果解档失败
    @available(macOS 12.0, *)
    static func unarchiveObjectThrowing(withData data: Data, configuration: UnarchiverConfiguration? = nil) async throws -> Any {
        let result = await unarchiveObject(withData: data, configuration: configuration)
        if let error = result.error {
            throw error
        }
        guard let object = result.object else {
            throw UnarchiverError.invalidData("解档结果为空")
        }
        return object
    }
    
    /// 解档指定类型并转换错误
    /// - Parameters:
    ///   - type: 要解档的对象类型
    ///   - data: 需要解档的数据
    ///   - configuration: 解档配置，可选
    /// - Returns: 解档后的指定类型对象
    /// - Throws: UnarchiverError 如果解档失败
    @available(macOS 12.0, *)
    static func unarchiveObjectThrowing<T>(
        ofClass type: T.Type,
        from data: Data,
        configuration: UnarchiverConfiguration? = nil
    ) async throws -> T where T: NSObject & NSSecureCoding {
        let result = await unarchiveObject(ofClass: type, from: data, configuration: configuration)
        if let error = result.error {
            throw error
        }
        guard let object = result.object else {
            throw UnarchiverError.invalidData("解档结果为空")
        }
        return object
    }
    
    // MARK: - 配置预设
    
    /// 创建允许所有类的配置
    /// - Returns: 解档配置
    static func permissiveConfiguration() -> UnarchiverConfiguration {
        return UnarchiverConfiguration(allowedClasses: [NSObject.self], requiresSecureCoding: false)
    }
    
    /// 创建严格的安全配置
    /// - Parameter allowedClasses: 允许的类数组
    /// - Returns: 解档配置
    static func secureConfiguration(allowedClasses: [AnyClass]) -> UnarchiverConfiguration {
        return UnarchiverConfiguration(allowedClasses: allowedClasses, requiresSecureCoding: true)
    }
    
    /// 创建自定义超时配置
    /// - Parameters:
    ///   - timeout: 超时时间
    ///   - allowedClasses: 允许的类数组
    /// - Returns: 解档配置
    static func timeoutConfiguration(timeout: TimeInterval, allowedClasses: [AnyClass] = [NSObject.self]) -> UnarchiverConfiguration {
        return UnarchiverConfiguration(allowedClasses: allowedClasses, requiresSecureCoding: true, timeout: timeout)
    }
    
    // MARK: - 高级解档功能
    
    /// 带重试的解档
    /// - Parameters:
    ///   - data: 需要解档的数据
    ///   - maxRetries: 最大重试次数
    ///   - retryDelay: 重试延迟（秒）
    ///   - configuration: 解档配置
    /// - Returns: 解档结果
    @available(macOS 12.0, *)
    static func unarchiveObjectWithRetry(
        withData data: Data,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1.0,
        configuration: UnarchiverConfiguration? = nil
    ) async -> (object: Any?, error: Error?) {
        for attempt in 1...maxRetries {
            let result = await unarchiveObject(withData: data, configuration: configuration)
            if result.object != nil {
                return result
            }
            
            if attempt < maxRetries {
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            }
        }
        
        return (nil, UnarchiverError.unknownError("解档失败，已重试 \(maxRetries) 次"))
    }
    
    /// 带进度监控的解档
    /// - Parameters:
    ///   - data: 需要解档的数据
    ///   - configuration: 解档配置
    ///   - progressHandler: 进度回调
    /// - Returns: 解档结果
    @available(macOS 12.0, *)
    static func unarchiveObjectWithProgress(
        withData data: Data,
        configuration: UnarchiverConfiguration? = nil,
        progressHandler: @escaping (Double) -> Void
    ) async -> (object: Any?, error: Error?) {
        progressHandler(0.0)
        
        let result = await unarchiveObject(withData: data, configuration: configuration)
        
        progressHandler(1.0)
        return result
    }
    
    /// 验证归档数据的完整性
    /// - Parameter data: 要验证的数据
    /// - Returns: 验证结果
    static func validateArchiveData(_ data: Data) -> (isValid: Bool, error: Error?) {
        guard !data.isEmpty else {
            return (false, UnarchiverError.invalidData("数据为空"))
        }
        
        // 检查数据大小
        let maxSize = 100 * 1024 * 1024 // 100MB
        guard data.count <= maxSize else {
            return (false, UnarchiverError.memoryError("数据过大: \(data.count) bytes"))
        }
        
        // 尝试解析数据头部
        do {
            let _ = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: data)
            return (true, nil)
        } catch {
            return (false, UnarchiverError.corruptedData("数据格式验证失败: \(error.localizedDescription)"))
        }
    }
    
    /// 获取归档数据的元信息
    /// - Parameter data: 归档数据
    /// - Returns: 元信息字典
    static func getArchiveMetadata(_ data: Data) -> [String: Any] {
        var metadata: [String: Any] = [:]
        
        metadata["size"] = data.count
        metadata["sizeInMB"] = Double(data.count) / (1024 * 1024)
        
        if let object = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: data) {
            metadata["rootClass"] = NSStringFromClass(type(of: object) as! AnyClass)
            metadata["isValid"] = true
        } else {
            metadata["isValid"] = false
        }
        
        return metadata
    }
    
    /// 批量验证归档文件
    /// - Parameter paths: 文件路径数组
    /// - Returns: 验证结果数组
    static func validateArchiveFiles(_ paths: [String]) async -> [(path: String, isValid: Bool, error: Error?)] {
        var results: [(path: String, isValid: Bool, error: Error?)] = []
        
        await withTaskGroup(of: (String, Bool, Error?).self) { group in
            for path in paths {
                group.addTask {
                    guard let data = FileManager.default.contents(atPath: path) else {
                        return (path, false, UnarchiverError.fileNotFound(path))
                    }
                    
                    let validation = validateArchiveData(data)
                    return (path, validation.isValid, validation.error)
                }
            }
            
            for await result in group {
                results.append(result)
            }
        }
        
        return results
    }
}

// MARK: - 使用示例和最佳实践

/*
 
 // MARK: - 基础使用示例
 
 // 1. 从数据解档
 let data = // 获取归档数据
 let result = await NSKeyedUnarchiver.unarchiveObject(withData: data)
 if let object = result.object {
     print("解档成功: \(object)")
 } else if let error = result.error {
     print("解档失败: \(error)")
 }
 
 // 2. 从文件解档
 let filePath = "/path/to/archived/file"
 let fileResult = await NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
 
 // 3. 类型安全解档
 let userResult = await NSKeyedUnarchiver.unarchiveObject(
     ofClass: User.self,
     from: data
 )
 if let user = userResult.object {
     print("用户: \(user.name)")
 }
 
 // MARK: - 配置使用
 
 // 4. 使用自定义配置
 let config = UnarchiverConfiguration(
     allowedClasses: [User.self, NSArray.self, NSDictionary.self],
     requiresSecureCoding: true,
     timeout: 60.0
 )
 let configuredResult = await NSKeyedUnarchiver.unarchiveObject(
     withData: data,
     configuration: config
 )
 
 // 5. 使用预设配置
 let permissiveConfig = NSKeyedUnarchiver.permissiveConfiguration()
 let secureConfig = NSKeyedUnarchiver.secureConfiguration(allowedClasses: [User.self])
 let timeoutConfig = NSKeyedUnarchiver.timeoutConfiguration(timeout: 30.0)
 
 // MARK: - 批量解档
 
 // 6. 批量解档多个文件
 let filePaths = ["/path1", "/path2", "/path3"]
 let batchResults = await NSKeyedUnarchiver.unarchiveObjects(fromFiles: filePaths)
 
 for result in batchResults {
     if let object = result.object {
         print("文件 \(result.path) 解档成功")
     } else if let error = result.error {
         print("文件 \(result.path) 解档失败: \(error)")
     }
 }
 
 // 7. 批量解档指定类型
 let userResults = await NSKeyedUnarchiver.unarchiveObjects(
     ofClass: User.self,
     fromFiles: filePaths
 )
 
 // MARK: - 便利方法使用
 
 // 8. 安全解档（忽略错误）
 let safeObject = await NSKeyedUnarchiver.safeUnarchiveObject(withData: data)
 let safeUser = await NSKeyedUnarchiver.safeUnarchiveObject(ofClass: User.self, from: data)
 
 // 9. 抛出错误版本
 do {
     let object = try await NSKeyedUnarchiver.unarchiveObjectThrowing(withData: data)
     let user = try await NSKeyedUnarchiver.unarchiveObjectThrowing(ofClass: User.self, from: data)
 } catch UnarchiverError.fileNotFound {
     print("文件未找到")
 } catch UnarchiverError.corruptedData {
     print("数据已损坏")
 } catch {
     print("其他错误: \(error)")
 }
 
 // MARK: - 高级用法
 
 // 10. 自定义错误处理
 func unarchiveUserSafely(from data: Data) async -> User? {
     let result = await NSKeyedUnarchiver.unarchiveObject(ofClass: User.self, from: data)
     
     switch result {
     case (let user?, nil):
         return user
     case (nil, let error?):
         print("解档失败: \(error)")
         return nil
     default:
         return nil
     }
 }
 
 // 11. 带重试的解档
 func unarchiveWithRetry<T: NSObject & NSSecureCoding>(
     ofClass type: T.Type,
     from data: Data,
     maxRetries: Int = 3
 ) async -> T? {
     for attempt in 1...maxRetries {
         let result = await NSKeyedUnarchiver.unarchiveObject(ofClass: type, from: data)
         if let object = result.object {
             return object
         }
         
         if attempt < maxRetries {
             try? await Task.sleep(nanoseconds: UInt64(attempt * 1_000_000_000)) // 1秒延迟
         }
     }
     return nil
 }
 
 // 12. 性能优化 - 缓存解档结果
 class UnarchiverCache {
     private static var cache: [String: Any] = [:]
     
     static func cachedUnarchive<T: NSObject & NSSecureCoding>(
         ofClass type: T.Type,
         from data: Data,
         key: String
     ) async -> T? {
         if let cached = cache[key] as? T {
             return cached
         }
         
         let result = await NSKeyedUnarchiver.unarchiveObject(ofClass: type, from: data)
         if let object = result.object {
             cache[key] = object
             return object
         }
         
         return nil
     }
     
     static func clearCache() {
         cache.removeAll()
     }
 }
 
 // 13. 监控解档性能
 func unarchiveWithPerformanceMonitoring<T: NSObject & NSSecureCoding>(
     ofClass type: T.Type,
     from data: Data
 ) async -> (object: T?, duration: TimeInterval) {
     let startTime = CFAbsoluteTimeGetCurrent()
     let result = await NSKeyedUnarchiver.unarchiveObject(ofClass: type, from: data)
     let duration = CFAbsoluteTimeGetCurrent() - startTime
     
     return (result.object, duration)
 }
 
 // MARK: - 最佳实践
 
 // 14. 错误处理最佳实践
 func handleUnarchiveError(_ error: Error) {
     if let unarchiverError = error as? UnarchiverError {
         switch unarchiverError {
         case .fileNotFound:
             // 处理文件未找到
             break
         case .corruptedData:
             // 处理数据损坏
             break
         case .securityError:
             // 处理安全错误
             break
         default:
             // 处理其他错误
             break
         }
     } else {
         // 处理其他类型的错误
         print("未知错误: \(error)")
     }
 }
 
 // 15. 配置最佳实践
 extension UnarchiverConfiguration {
     static let userData = UnarchiverConfiguration(
         allowedClasses: [User.self, NSArray.self, NSDictionary.self, NSString.self, NSNumber.self],
         requiresSecureCoding: true,
         timeout: 30.0
     )
     
     static let settingsData = UnarchiverConfiguration(
         allowedClasses: [NSDictionary.self, NSString.self, NSNumber.self, NSArray.self],
         requiresSecureCoding: true,
         timeout: 10.0
     )
 }
 
 */
