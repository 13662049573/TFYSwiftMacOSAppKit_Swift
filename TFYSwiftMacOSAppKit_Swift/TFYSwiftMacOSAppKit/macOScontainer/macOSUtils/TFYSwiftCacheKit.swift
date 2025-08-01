//
//  TFYSwiftCacheKit.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/12/19.
//  用途：缓存管理工具，支持内存缓存、磁盘缓存、图片缓存等功能。
//

import Foundation
import Cocoa

/// 缓存统计信息
public struct TFYCacheStats {
    public var totalHits: Int = 0
    public var totalMisses: Int = 0
    public var memoryHits: Int = 0
    public var diskHits: Int = 0
    public var totalRequests: Int = 0
    
    public var hitRate: Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(totalHits) / Double(totalRequests)
    }
    
    public var memoryHitRate: Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(memoryHits) / Double(totalRequests)
    }
    
    public mutating func recordHit(source: CacheSource) {
        totalHits += 1
        totalRequests += 1
        switch source {
        case .memory:
            memoryHits += 1
        case .disk:
            diskHits += 1
        }
    }
    
    public mutating func recordMiss() {
        totalMisses += 1
        totalRequests += 1
    }
    
    public mutating func reset() {
        totalHits = 0
        totalMisses = 0
        memoryHits = 0
        diskHits = 0
        totalRequests = 0
    }
}

/// 缓存来源
public enum CacheSource {
    case memory
    case disk
}

/// 缓存错误类型
public enum TFYCacheError: Error, LocalizedError {
    case invalidKey
    case dataNotFound
    case saveFailed(Error)
    case loadFailed(Error)
    case invalidData
    case cacheFull
    case unsupportedType
    
    public var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "无效的缓存键"
        case .dataNotFound:
            return "缓存数据未找到"
        case .saveFailed(let error):
            return "保存失败: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "加载失败: \(error.localizedDescription)"
        case .invalidData:
            return "无效的数据"
        case .cacheFull:
            return "缓存已满"
        case .unsupportedType:
            return "不支持的数据类型"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidKey:
            return "缓存键格式不正确"
        case .dataNotFound:
            return "请求的缓存数据不存在"
        case .saveFailed, .loadFailed:
            return "文件系统操作失败"
        case .invalidData:
            return "数据格式损坏或不兼容"
        case .cacheFull:
            return "缓存空间不足"
        case .unsupportedType:
            return "当前平台不支持此数据类型"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidKey:
            return "请使用有效的缓存键（字母、数字、下划线）"
        case .dataNotFound:
            return "请检查缓存键是否正确，或重新缓存数据"
        case .saveFailed, .loadFailed:
            return "请检查磁盘空间和文件权限"
        case .invalidData:
            return "请检查数据格式是否正确"
        case .cacheFull:
            return "请清理部分缓存或增加缓存空间"
        case .unsupportedType:
            return "请使用支持的数据类型"
        }
    }
}

/// 缓存配置
public struct TFYCacheConfig {
    /// 内存缓存大小限制 (MB)
    public var memoryCacheSize: Int = 100
    /// 磁盘缓存大小限制 (MB)
    public var diskCacheSize: Int = 500
    /// 缓存过期时间 (秒)
    public var expirationInterval: TimeInterval = 7 * 24 * 60 * 60 // 7天
    /// 是否启用压缩
    public var enableCompression: Bool = true
    /// 是否启用加密
    public var enableEncryption: Bool = false
    /// 是否启用统计
    public var enableStatistics: Bool = true
    /// 是否启用自动清理
    public var enableAutoClean: Bool = true
    /// 是否启用内存警告监听
    public var enableMemoryWarningListener: Bool = true
    /// 缓存文件扩展名
    public var fileExtension: String = "cache"
    /// 是否启用缓存键哈希
    public var enableKeyHashing: Bool = true
    
    public init() {}
    
    /// 验证配置的有效性
    public func validate() -> [String] {
        var errors: [String] = []
        
        if memoryCacheSize <= 0 {
            errors.append("内存缓存大小必须大于0")
        }
        
        if diskCacheSize <= 0 {
            errors.append("磁盘缓存大小必须大于0")
        }
        
        if expirationInterval <= 0 {
            errors.append("过期时间必须大于0")
        }
        
        if memoryCacheSize > 2000 {
            errors.append("内存缓存大小不建议超过2000MB")
        }
        
        if diskCacheSize > 50000 {
            errors.append("磁盘缓存大小不建议超过50000MB")
        }
        
        return errors
    }
    
    /// 获取默认配置
    public static func `default`() -> TFYCacheConfig {
        return TFYCacheConfig()
    }
    
    /// 获取小内存配置
    public static func smallMemory() -> TFYCacheConfig {
        var config = TFYCacheConfig()
        config.memoryCacheSize = 20
        config.diskCacheSize = 100
        return config
    }
    
    /// 获取大内存配置
    public static func largeMemory() -> TFYCacheConfig {
        var config = TFYCacheConfig()
        config.memoryCacheSize = 500
        config.diskCacheSize = 2000
        return config
    }
    
    /// 获取开发环境配置
    public static func development() -> TFYCacheConfig {
        var config = TFYCacheConfig()
        config.memoryCacheSize = 50
        config.diskCacheSize = 200
        config.expirationInterval = 24 * 60 * 60 // 1天
        config.enableStatistics = true
        return config
    }
    
    /// 获取生产环境配置
    public static func production() -> TFYCacheConfig {
        var config = TFYCacheConfig()
        config.memoryCacheSize = 200
        config.diskCacheSize = 1000
        config.enableStatistics = false
        return config
    }
}

/// 缓存项
public struct TFYCacheItem<T> {
    public let key: String
    public let value: T
    public let timestamp: Date
    public let size: Int
    public let expirationInterval: TimeInterval
    public let metadata: [String: Any]
    
    public init(key: String, value: T, size: Int = 0, expirationInterval: TimeInterval? = nil, metadata: [String: Any] = [:]) {
        self.key = key
        self.value = value
        self.timestamp = Date()
        self.size = size
        self.expirationInterval = expirationInterval ?? TFYSwiftCacheKit.shared.config.expirationInterval
        self.metadata = metadata
    }
    
    public var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > expirationInterval
    }
    
    public var age: TimeInterval {
        return Date().timeIntervalSince(timestamp)
    }
}

/// 缓存管理工具类
public class TFYSwiftCacheKit: NSObject {
    
    // MARK: - 单例
    public static let shared = TFYSwiftCacheKit()
    
    // MARK: - 属性
    public private(set) var config = TFYCacheConfig()
    
    /// 内存缓存
    private let memoryCache = NSCache<NSString, AnyObject>()
    
    /// 磁盘缓存目录
    private let diskCachePath: String
    
    /// 缓存队列
    private let cacheQueue = DispatchQueue(label: "com.tfy.cache", qos: .utility)
    
    /// 内存缓存队列（确保线程安全）
    private let memoryCacheQueue = DispatchQueue(label: "com.tfy.memory.cache", qos: .userInitiated)
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    /// 缓存统计
    private var cacheStats = TFYCacheStats()
    
    /// 统计信息更新队列（确保线程安全）
    private let statsQueue = DispatchQueue(label: "com.tfy.cache.stats", qos: .utility)
    
    /// 缓存键哈希映射
    private var keyHashMapping: [String: String] = [:]
    
    /// 缓存键映射队列
    private let keyMappingQueue = DispatchQueue(label: "com.tfy.cache.keys", qos: .utility)
    
    // MARK: - 初始化
    private override init() {
        guard let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("TFYSwiftCacheKit: 无法获取缓存目录")
        }
        diskCachePath = (cacheDir as NSString).appendingPathComponent("TFYCache")
        
        super.init()
        
        setupMemoryCache()
        setupDiskCache()
        setupNotifications()
    }
    
    // MARK: - 设置
    private func setupMemoryCache() {
        memoryCache.totalCostLimit = config.memoryCacheSize * 1024 * 1024
        memoryCache.countLimit = 200
        memoryCache.delegate = self
    }
    
    private func setupDiskCache() {
        if !fileManager.fileExists(atPath: diskCachePath) {
            do {
                try fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("TFYSwiftCacheKit: 创建缓存目录失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupNotifications() {
        // macOS 没有内存警告通知，使用系统资源监控
        if config.enableMemoryWarningListener {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleSystemPressure),
                name: NSWorkspace.didWakeNotification,
                object: nil
            )
            
            // 监听应用激活/失活
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAppStateChange),
                name: NSApplication.didBecomeActiveNotification,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAppStateChange),
                name: NSApplication.didResignActiveNotification,
                object: nil
            )
        }
    }
    
    @objc private func handleSystemPressure() {
        print("TFYSwiftCacheKit: 系统唤醒，检查缓存状态")
        cleanExpiredCacheIfNeeded()
    }
    
    @objc private func handleAppStateChange() {
        print("TFYSwiftCacheKit: 应用状态变化，优化缓存")
        if NSApplication.shared.isActive {
            // 应用激活时，可以预加载一些缓存
            preloadFrequentlyUsedCache()
        } else {
            // 应用失活时，清理一些内存缓存
            cleanMemoryCacheIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 配置管理
    
    /// 更新缓存配置
    /// - Parameter newConfig: 新的配置
    /// - Returns: 配置验证结果
    @discardableResult
    public func updateConfig(_ newConfig: TFYCacheConfig) -> Bool {
        let errors = newConfig.validate()
        guard errors.isEmpty else {
            print("TFYSwiftCacheKit: 配置验证失败: \(errors.joined(separator: ", "))")
            return false
        }
        
        config = newConfig
        setupMemoryCache()
        return true
    }
    
    /// 获取当前配置
    public func getCurrentConfig() -> TFYCacheConfig {
        return config
    }
    
    // MARK: - 内存缓存
    
    /// 设置内存缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键
    public func setMemoryCache<T>(_ value: T, forKey key: String) {
        guard validateCacheKey(key) else {
            print("TFYSwiftCacheKit: 无效的缓存键: \(key)")
            return
        }
        
        memoryCacheQueue.async {
            let nsKey = key as NSString
            self.memoryCache.setObject(value as AnyObject, forKey: nsKey)
        }
    }
    
    /// 获取内存缓存
    /// - Parameter key: 缓存键
    /// - Returns: 缓存值
    public func getMemoryCache<T>(forKey key: String) -> T? {
        var result: T?
        memoryCacheQueue.sync {
            let nsKey = key as NSString
            result = self.memoryCache.object(forKey: nsKey) as? T
        }
        return result
    }
    
    /// 移除内存缓存
    /// - Parameter key: 缓存键
    public func removeMemoryCache(forKey key: String) {
        memoryCacheQueue.async {
            let nsKey = key as NSString
            self.memoryCache.removeObject(forKey: nsKey)
        }
    }
    
    /// 清空内存缓存
    public func clearMemoryCache() {
        memoryCacheQueue.async {
            self.memoryCache.removeAllObjects()
        }
    }
    
    // MARK: - 磁盘缓存
    
    /// 设置磁盘缓存
    /// - Parameters:
    ///   - data: 缓存数据
    ///   - key: 缓存键
    ///   - completion: 完成回调（主线程）
    public func setDiskCache(_ data: Data, forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            self.cleanDiskIfNeeded()
            do {
                let filePath = self.diskCachePath(forKey: key)
                try data.write(to: URL(fileURLWithPath: filePath))
                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.saveFailed(error))) }
            }
        }
    }
    
    /// 获取磁盘缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调（主线程）
    public func getDiskCache(forKey key: String, completion: @escaping (Result<Data, TFYCacheError>) -> Void) {
        cacheQueue.async {
            self.cleanExpiredCacheIfNeeded()
            let filePath = self.diskCachePath(forKey: key)
            
            guard self.fileManager.fileExists(atPath: filePath) else {
                DispatchQueue.main.async { completion(.failure(.dataNotFound)) }
                return
            }
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                DispatchQueue.main.async { completion(.success(data)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.loadFailed(error))) }
            }
        }
    }
    
    /// 移除磁盘缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func removeDiskCache(forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            let filePath = self.diskCachePath(forKey: key)
            
            do {
                if self.fileManager.fileExists(atPath: filePath) {
                    try self.fileManager.removeItem(atPath: filePath)
                }
                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.saveFailed(error))) }
            }
        }
    }
    
    /// 清空磁盘缓存
    /// - Parameter completion: 完成回调
    public func clearDiskCache(completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    try self.fileManager.removeItem(atPath: filePath)
                }
                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.saveFailed(error))) }
            }
        }
    }
    
    // MARK: - 通用缓存
    
    /// 设置缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func setCache<T: Codable>(_ value: T, forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        // 设置内存缓存
        setMemoryCache(value, forKey: key)
        
        // 设置磁盘缓存
        do {
            let data = try JSONEncoder().encode(value)
            setDiskCache(data, forKey: key, completion: completion)
        } catch {
            completion(.failure(.saveFailed(error)))
        }
    }
    
    /// 获取缓存（自动清理过期，主线程回调）
    public func getCache<T: Codable>(_ type: T.Type, forKey key: String, completion: @escaping (Result<T, TFYCacheError>) -> Void) {
        // 先尝试从内存缓存获取
        if let memoryValue: T = getMemoryCache(forKey: key) {
            statsQueue.async {
                self.cacheStats.recordHit(source: .memory)
            }
            DispatchQueue.main.async { completion(.success(memoryValue)) }
            return
        }
        // 从磁盘缓存获取
        getDiskCache(forKey: key) { result in
            switch result {
            case .success(let data):
                do {
                    let value = try JSONDecoder().decode(type, from: data)
                    // 设置到内存缓存
                    self.setMemoryCache(value, forKey: key)
                    self.statsQueue.async {
                        self.cacheStats.recordHit(source: .disk)
                    }
                    completion(.success(value))
                } catch {
                    self.statsQueue.async {
                        self.cacheStats.recordMiss()
                    }
                    completion(.failure(.loadFailed(error)))
                }
            case .failure(let error):
                self.statsQueue.async {
                    self.cacheStats.recordMiss()
                }
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 图片缓存 (macOS适配)
    
    /// 缓存图片
    /// - Parameters:
    ///   - image: 图片
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func cacheImage(_ image: NSImage, forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        // 设置内存缓存
        setMemoryCache(image, forKey: key)
        
        // 设置磁盘缓存
        cacheQueue.async {
            guard let tiffData = image.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData),
                  let data = bitmapRep.representation(using: .jpeg, properties: [:]) else {
                DispatchQueue.main.async { completion(.failure(.invalidData)) }
                return
            }
            
            self.setDiskCache(data, forKey: key, completion: completion)
        }
    }
    
    /// 获取缓存图片
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func getCachedImage(forKey key: String, completion: @escaping (Result<NSImage, TFYCacheError>) -> Void) {
        // 先尝试从内存缓存获取
        if let image: NSImage = getMemoryCache(forKey: key) {
            completion(.success(image))
            return
        }
        
        // 从磁盘缓存获取
        getDiskCache(forKey: key) { result in
            switch result {
            case .success(let data):
                if let image = NSImage(data: data) {
                    // 设置到内存缓存
                    self.setMemoryCache(image, forKey: key)
                    completion(.success(image))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 缓存管理
    
    /// 获取缓存大小
    /// - Parameter completion: 完成回调
    public func getCacheSize(completion: @escaping (Result<Int, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                var totalSize = 0
                
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                    if let size = attributes[.size] as? Int {
                        totalSize += size
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.success(totalSize))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.loadFailed(error)))
                }
            }
        }
    }
    
    /// 清理过期缓存
    /// - Parameter completion: 完成回调
    public func cleanExpiredCache(completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                let expirationDate = Date().addingTimeInterval(-self.config.expirationInterval)
                
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                    
                    if let modificationDate = attributes[.modificationDate] as? Date,
                       modificationDate < expirationDate {
                        try self.fileManager.removeItem(atPath: filePath)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 验证缓存键的有效性
    private func validateCacheKey(_ key: String) -> Bool {
        guard !key.isEmpty else { return false }
        guard key.count <= 255 else { return false }
        // 检查是否包含危险字符
        let dangerousCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        guard key.rangeOfCharacter(from: dangerousCharacters) == nil else { return false }
        return true
    }
    
    /// 安全的缓存键处理
    private func sanitizeCacheKey(_ key: String) -> String {
        // 移除或替换危险字符
        var sanitized = key
        let dangerousCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        sanitized = sanitized.components(separatedBy: dangerousCharacters).joined(separator: "_")
        // 限制长度
        if sanitized.count > 255 {
            sanitized = String(sanitized.prefix(255))
        }
        // 确保不为空
        if sanitized.isEmpty {
            sanitized = "default_key"
        }
        return sanitized
    }
    
    /// 生成缓存键哈希
    private func hashCacheKey(_ key: String) -> String {
        if !config.enableKeyHashing {
            return sanitizeCacheKey(key)
        }
        
        return keyMappingQueue.sync {
            if let hashedKey = keyHashMapping[key] {
                return hashedKey
            }
            
            let hashedKey = key.data(using: .utf8)?.base64EncodedString() ?? sanitizeCacheKey(key)
            keyHashMapping[key] = hashedKey
            return hashedKey
        }
    }
    
    private func diskCachePath(forKey key: String) -> String {
        let hashedKey = hashCacheKey(key)
        let fileName = "\(hashedKey).\(config.fileExtension)"
        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }
    
    /// 自动清理过期缓存（仅内部调用，非主线程）
    private func cleanExpiredCacheIfNeeded() {
        do {
            let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
            let expirationDate = Date().addingTimeInterval(-self.config.expirationInterval)
            for file in contents {
                let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                if let modificationDate = attributes[.modificationDate] as? Date,
                   modificationDate < expirationDate {
                    try? self.fileManager.removeItem(atPath: filePath)
                }
            }
        } catch {
            // 忽略清理错误
        }
    }
    
    /// 检查磁盘缓存大小，超限时自动清理最早的缓存文件
    private func cleanDiskIfNeeded() {
        do {
            let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
            var fileInfos: [(path: String, date: Date, size: Int)] = []
            var totalSize = 0
            for file in contents {
                let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                let size = attributes[.size] as? Int ?? 0
                let date = attributes[.modificationDate] as? Date ?? Date.distantPast
                fileInfos.append((filePath, date, size))
                totalSize += size
            }
            let maxSize = self.config.diskCacheSize * 1024 * 1024
            if totalSize > maxSize {
                // 按最早时间排序，依次删除
                let sorted = fileInfos.sorted { $0.date < $1.date }
                var sizeToFree = totalSize - maxSize
                for info in sorted {
                    try? self.fileManager.removeItem(atPath: info.path)
                    sizeToFree -= info.size
                    if sizeToFree <= 0 { break }
                }
            }
        } catch {
            // 忽略清理错误
        }
    }
    
    /// 预加载常用缓存
    private func preloadFrequentlyUsedCache() {
        // 这里可以实现预加载逻辑
        // 例如预加载用户偏好设置、应用配置等
    }
    
    /// 清理内存缓存（如果需要）
    private func cleanMemoryCacheIfNeeded() {
        // 当应用失活时，可以清理一些不重要的内存缓存
        // 这里可以实现智能清理逻辑
    }
}

// MARK: - NSCacheDelegate
extension TFYSwiftCacheKit: NSCacheDelegate {
    public func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        // 当内存缓存被清理时记录日志
        print("TFYSwiftCacheKit: Memory cache item evicted")
    }
}

// MARK: - 缓存统计扩展
public extension TFYSwiftCacheKit {
    /// 获取缓存统计信息
    var statistics: TFYCacheStats {
        var stats: TFYCacheStats!
        statsQueue.sync {
            stats = cacheStats
        }
        return stats
    }
    
    /// 重置缓存统计
    func resetStatistics() {
        statsQueue.async {
            self.cacheStats.reset()
        }
    }
    
    /// 获取缓存统计报告
    func getCacheReport() -> String {
        var stats: TFYCacheStats!
        statsQueue.sync {
            stats = cacheStats
        }
        return """
        缓存统计报告:
        - 总请求数: \(stats.totalRequests)
        - 命中次数: \(stats.totalHits)
        - 未命中次数: \(stats.totalMisses)
        - 命中率: \(String(format: "%.2f%%", stats.hitRate * 100))
        - 内存命中次数: \(stats.memoryHits)
        - 磁盘命中次数: \(stats.diskHits)
        - 内存命中率: \(String(format: "%.2f%%", stats.memoryHitRate * 100))
        """
    }
}

// MARK: - 便利扩展
public extension TFYSwiftCacheKit {
    /// 同步设置缓存（避免死锁）
    func setCacheSync<T: Codable>(_ value: T, forKey key: String) -> Result<Void, TFYCacheError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Void, TFYCacheError>!
        
        // 始终在后台队列执行，避免死锁
        DispatchQueue.global(qos: .userInitiated).async {
            self.setCache(value, forKey: key) { res in
                result = res
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return result
    }
    
    /// 同步获取缓存（避免死锁）
    func getCacheSync<T: Codable>(_ type: T.Type, forKey key: String) -> Result<T, TFYCacheError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<T, TFYCacheError>!
        
        // 始终在后台队列执行，避免死锁
        DispatchQueue.global(qos: .userInitiated).async {
            self.getCache(type, forKey: key) { res in
                result = res
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return result
    }
    
    /// 异步设置缓存（推荐使用）
    func setCacheAsync<T: Codable>(_ value: T, forKey key: String) async -> Result<Void, TFYCacheError> {
        return await withCheckedContinuation { continuation in
            setCache(value, forKey: key) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// 异步获取缓存（推荐使用）
    func getCacheAsync<T: Codable>(_ type: T.Type, forKey key: String) async -> Result<T, TFYCacheError> {
        return await withCheckedContinuation { continuation in
            getCache(type, forKey: key) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// 批量设置缓存
    func setCacheBatch<T: Codable>(_ items: [(key: String, value: T)], completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        let group = DispatchGroup()
        var errors: [TFYCacheError] = []
        let errorQueue = DispatchQueue(label: "com.tfy.cache.batch.errors")
        
        for item in items {
            group.enter()
            setCache(item.value, forKey: item.key) { result in
                errorQueue.async {
                    if case .failure(let error) = result {
                        errors.append(error)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(errors.first!))
            }
        }
    }
    
    /// 批量获取缓存
    func getCacheBatch<T: Codable>(_ type: T.Type, keys: [String], completion: @escaping (Result<[T], TFYCacheError>) -> Void) {
        let group = DispatchGroup()
        var results: [T] = []
        var errors: [TFYCacheError] = []
        let resultQueue = DispatchQueue(label: "com.tfy.cache.batch.results")
        
        for key in keys {
            group.enter()
            getCache(type, forKey: key) { result in
                resultQueue.async {
                    switch result {
                    case .success(let value):
                        results.append(value)
                    case .failure(let error):
                        errors.append(error)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(results))
            } else {
                completion(.failure(errors.first!))
            }
        }
    }
}

// MARK: - 缓存工具用法示例
/*
// 1. 基础缓存操作
TFYSwiftCacheKit.shared.setCache("Hello, Cache!", forKey: "stringKey") { result in
    switch result {
    case .success:
        print("字符串缓存成功")
    case .failure(let error):
        print("缓存失败: \(error.localizedDescription)")
    }
}

TFYSwiftCacheKit.shared.getCache(String.self, forKey: "stringKey") { result in
    switch result {
    case .success(let value):
        print("获取到字符串缓存: \(value)")
    case .failure(let error):
        print("获取失败: \(error.localizedDescription)")
    }
}

// 2. 缓存自定义模型
struct User: Codable {
    let id: Int
    let name: String
}
let user = User(id: 1, name: "张三")
TFYSwiftCacheKit.shared.setCache(user, forKey: "userKey") { result in
    if case .success = result {
        print("模型缓存成功")
    }
}
TFYSwiftCacheKit.shared.getCache(User.self, forKey: "userKey") { result in
    if case .success(let user) = result {
        print("获取到模型: \(user)")
    }
}

// 3. 缓存图片 (macOS)
if let image = NSImage(named: "AppIcon") {
    TFYSwiftCacheKit.shared.cacheImage(image, forKey: "icon") { result in
        if case .success = result {
            print("图片缓存成功")
        }
    }
    TFYSwiftCacheKit.shared.getCachedImage(forKey: "icon") { result in
        if case .success(let img) = result {
            print("获取到图片，尺寸: \(img.size)")
        }
    }
}

// 4. 同步缓存用法（已修复死锁问题）
let syncResult = TFYSwiftCacheKit.shared.setCacheSync(user, forKey: "userSyncKey")
if case .success = syncResult {
    print("同步缓存成功")
}
let syncGet = TFYSwiftCacheKit.shared.getCacheSync(User.self, forKey: "userSyncKey")
if case .success(let user) = syncGet {
    print("同步获取到模型: \(user)")
}

// 5. 缓存统计功能
print(TFYSwiftCacheKit.shared.getCacheReport())
let stats = TFYSwiftCacheKit.shared.statistics
print("缓存命中率: \(String(format: "%.2f%%", stats.hitRate * 100))")

// 6. 配置管理
var newConfig = TFYCacheConfig.smallMemory()
newConfig.expirationInterval = 24 * 60 * 60 // 1天
if TFYSwiftCacheKit.shared.updateConfig(newConfig) {
    print("配置更新成功")
}

// 7. 缓存键验证
TFYSwiftCacheKit.shared.setCache("test", forKey: "invalid/key") // 会被拒绝
TFYSwiftCacheKit.shared.setCache("test", forKey: "validKey") // 正常缓存

// 8. 清理与管理
TFYSwiftCacheKit.shared.clearMemoryCache()
TFYSwiftCacheKit.shared.clearDiskCache { _ in print("磁盘缓存已清空") }
TFYSwiftCacheKit.shared.cleanExpiredCache { _ in print("过期缓存已清理") }
TFYSwiftCacheKit.shared.getCacheSize { result in
    if case .success(let size) = result {
        print("当前缓存大小: \(size) 字节")
    }
}

// 9. 重置统计
TFYSwiftCacheKit.shared.resetStatistics()

// 10. 批量操作
let users = [User(id: 1, name: "张三"), User(id: 2, name: "李四")]
let items = users.enumerated().map { (key: "user_\($0)", value: $1) }
TFYSwiftCacheKit.shared.setCacheBatch(items) { result in
    if case .success = result {
        print("批量缓存成功")
    }
}

TFYSwiftCacheKit.shared.getCacheBatch(User.self, keys: ["user_0", "user_1"]) { result in
    if case .success(let users) = result {
        print("批量获取成功: \(users)")
    }
}
*/ 