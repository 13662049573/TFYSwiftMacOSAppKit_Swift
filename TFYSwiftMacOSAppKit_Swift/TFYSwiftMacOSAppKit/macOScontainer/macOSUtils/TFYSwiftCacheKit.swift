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
    /// 是否启用磁盘数据 XOR 混淆（非加密，仅防明文落盘）
    public var enableObfuscation: Bool = false
    /// 兼容旧名；实际为 XOR 混淆，非安全加密
    @available(*, deprecated, renamed: "enableObfuscation", message: "XOR obfuscation is not encryption")
    public var enableEncryption: Bool {
        get { enableObfuscation }
        set { enableObfuscation = newValue }
    }
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
        self.expirationInterval = expirationInterval ?? TFYSwiftCacheKit.shared.getCurrentConfig().expirationInterval
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
    
    /// 内存缓存 (NSCache 自带线程安全)
    private let memoryCache = NSCache<NSString, AnyObject>()

    /// 磁盘缓存目录
    private let diskCachePath: String

    /// 缓存队列
    private let cacheQueue = DispatchQueue(label: "com.tfy.cache", qos: .utility)
    private static let cacheQueueKey = DispatchSpecificKey<UInt8>()
    private static let cacheQueueContext: UInt8 = 1

    /// 文件管理器
    private let fileManager = FileManager.default

    /// 缓存统计
    private var cacheStats = TFYCacheStats()

    /// 上次执行磁盘过期扫描的时间戳
    private var lastExpirationScanTime: TimeInterval = 0
    /// 磁盘过期扫描最小间隔 (秒)，避免每次读取都触发全盘扫描
    private let expirationScanMinInterval: TimeInterval = 60
    private let expirationScanLock = NSLock()
    
    /// 统计信息更新队列（确保线程安全）
    private let statsQueue = DispatchQueue(label: "com.tfy.cache.stats", qos: .utility)
    
    /// 配置读写锁（config 可被任意线程读取，updateConfig 写入）
    private let configLock = NSLock()
    
    /// 缓存键哈希映射
    private var keyHashMapping: [String: String] = [:]
    
    /// 缓存键映射队列
    private let keyMappingQueue = DispatchQueue(label: "com.tfy.cache.keys", qos: .utility)
    
    /// 在 cacheQueue 上同步执行，避免同队列 re-entrant sync 死锁
    private func syncOnCacheQueue<T>(_ work: () -> T) -> T {
        if DispatchQueue.getSpecific(key: Self.cacheQueueKey) != nil {
            return work()
        }
        return cacheQueue.sync(execute: work)
    }
    
    private func currentConfig() -> TFYCacheConfig {
        configLock.lock()
        defer { configLock.unlock() }
        return config
    }
    
    private func debugLog(_ message: String) {
        #if DEBUG
        print("TFYSwiftCacheKit: \(message)")
        #endif
    }
    
    // MARK: - 初始化
    private override init() {
        let baseDirectoryURL: URL
        if let cachesDirectoryURL = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) {
            baseDirectoryURL = cachesDirectoryURL
        } else {
            baseDirectoryURL = FileManager.default.temporaryDirectory
        }
        diskCachePath = baseDirectoryURL.appendingPathComponent("TFYCache", isDirectory: true).path
        
        super.init()
        cacheQueue.setSpecific(key: Self.cacheQueueKey, value: Self.cacheQueueContext)
        
        setupMemoryCache()
        setupDiskCache()
        setupNotifications()
        scheduleAutoCleanIfNeeded()
    }
    
    // MARK: - 设置
    private func setupMemoryCache() {
        let cfg = currentConfig()
        memoryCache.totalCostLimit = cfg.memoryCacheSize * 1024 * 1024
        memoryCache.countLimit = 200
        memoryCache.delegate = self
    }
    
    private func setupDiskCache() {
        do {
            try ensureDiskCacheDirectoryExists()
        } catch {
            debugLog("创建缓存目录失败: \(error.localizedDescription)")
        }
    }
    
    private func setupNotifications() {
        // macOS 没有内存警告通知，使用系统资源监控
        if currentConfig().enableMemoryWarningListener {
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
    
    private func scheduleAutoCleanIfNeeded() {
        guard currentConfig().enableAutoClean else { return }
        cacheQueue.async { [weak self] in
            self?.cleanExpiredCacheIfNeeded(force: true)
            self?.cleanDiskIfNeeded()
        }
    }
    
    @objc private func handleSystemPressure() {
        debugLog("系统唤醒，检查缓存状态")
        cacheQueue.async { [weak self] in
            self?.cleanExpiredCacheIfNeeded(force: true)
        }
    }
    
    @objc private func handleAppStateChange() {
        debugLog("应用状态变化，优化缓存")
        if NSApplication.shared.isActive {
            preloadFrequentlyUsedCache()
        } else {
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
            debugLog("配置验证失败: \(errors.joined(separator: ", "))")
            return false
        }
        
        configLock.lock()
        config = newConfig
        configLock.unlock()
        setupMemoryCache()
        setupDiskCache()
        scheduleAutoCleanIfNeeded()
        return true
    }
    
    /// 获取当前配置
    public func getCurrentConfig() -> TFYCacheConfig {
        return currentConfig()
    }
    
    // MARK: - 内存缓存
    
    /// 设置内存缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键
    public func setMemoryCache<T>(_ value: T, forKey key: String) {
        guard validateCacheKey(key) else {
            debugLog("无效的缓存键: \(key)")
            return
        }

        let nsKey = key as NSString
        let cost = approximateCost(of: value)
        if cost > 0 {
            memoryCache.setObject(value as AnyObject, forKey: nsKey, cost: cost)
        } else {
            memoryCache.setObject(value as AnyObject, forKey: nsKey)
        }
    }

    /// 获取内存缓存
    /// - Parameter key: 缓存键
    /// - Returns: 缓存值
    public func getMemoryCache<T>(forKey key: String) -> T? {
        let nsKey = key as NSString
        return memoryCache.object(forKey: nsKey) as? T
    }

    /// 移除内存缓存
    /// - Parameter key: 缓存键
    public func removeMemoryCache(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
    }

    /// 清空内存缓存
    public func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }

    /// 估算任意值的内存开销，用于 NSCache 成本限制
    private func approximateCost<T>(of value: T) -> Int {
        if let data = value as? Data {
            return data.count
        }
        if let image = value as? NSImage {
            let s = image.size
            return max(1, Int(s.width * s.height * 4))
        }
        if let string = value as? String {
            return string.utf8.count
        }
        if let array = value as? [Any] {
            return array.count * 16
        }
        return 0
    }
    
    // MARK: - 磁盘缓存
    
    /// 设置磁盘缓存
    /// - Parameters:
    ///   - data: 缓存数据
    ///   - key: 缓存键
    ///   - completion: 完成回调（主线程）
    public func setDiskCache(_ data: Data, forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        guard validateCacheKey(key) else {
            dispatchToMain {
                completion(.failure(.invalidKey))
            }
            return
        }
        
        cacheQueue.async {
            let result = self.writeDiskCacheSync(data, forKey: key)
            self.dispatchResult(result, completion: completion)
        }
    }
    
    /// 获取磁盘缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调（主线程）
    public func getDiskCache(forKey key: String, completion: @escaping (Result<Data, TFYCacheError>) -> Void) {
        guard validateCacheKey(key) else {
            dispatchToMain {
                completion(.failure(.invalidKey))
            }
            return
        }
        
        cacheQueue.async {
            let result = self.readDiskCacheSync(forKey: key)
            self.dispatchResult(result, completion: completion)
        }
    }
    
    /// 移除磁盘缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func removeDiskCache(forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        guard validateCacheKey(key) else {
            dispatchToMain {
                completion(.failure(.invalidKey))
            }
            return
        }
        
        cacheQueue.async {
            let filePath = self.diskCachePath(forKey: key)
            
            do {
                if self.fileManager.fileExists(atPath: filePath) {
                    try self.fileManager.removeItem(atPath: filePath)
                }
                self.dispatchToMain {
                    completion(.success(()))
                }
            } catch {
                self.dispatchToMain {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    /// 清空磁盘缓存
    /// - Parameter completion: 完成回调
    public func clearDiskCache(completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                try self.ensureDiskCacheDirectoryExists()
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    try self.fileManager.removeItem(atPath: filePath)
                }
                self.keyMappingQueue.async {
                    self.keyHashMapping.removeAll()
                }
                self.dispatchToMain {
                    completion(.success(()))
                }
            } catch {
                self.dispatchToMain {
                    completion(.failure(.saveFailed(error)))
                }
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
            removeMemoryCache(forKey: key)
            dispatchToMain {
                completion(.failure(.saveFailed(error)))
            }
        }
    }
    
    /// 获取缓存（自动清理过期，主线程回调）
    public func getCache<T: Codable>(_ type: T.Type, forKey key: String, completion: @escaping (Result<T, TFYCacheError>) -> Void) {
        // 先尝试从内存缓存获取
        if let memoryValue: T = getMemoryCache(forKey: key) {
            recordHitIfEnabled(source: .memory)
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
                    self.recordHitIfEnabled(source: .disk)
                    self.dispatchToMain { completion(.success(value)) }
                } catch {
                    self.recordMissIfEnabled()
                    self.dispatchToMain { completion(.failure(.loadFailed(error))) }
                }
            case .failure(let error):
                self.recordMissIfEnabled()
                self.dispatchToMain { completion(.failure(error)) }
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
                self.removeMemoryCache(forKey: key)
                self.dispatchToMain { completion(.failure(.invalidData)) }
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
            dispatchToMain { completion(.success(image)) }
            return
        }
        
        // 从磁盘缓存获取
        getDiskCache(forKey: key) { result in
            switch result {
            case .success(let data):
                if let image = NSImage(data: data) {
                    // 设置到内存缓存
                    self.setMemoryCache(image, forKey: key)
                    self.dispatchToMain { completion(.success(image)) }
                } else {
                    self.dispatchToMain { completion(.failure(.invalidData)) }
                }
            case .failure(let error):
                self.dispatchToMain { completion(.failure(error)) }
            }
        }
    }
    
    // MARK: - 缓存管理
    
    /// 获取缓存大小
    /// - Parameter completion: 完成回调
    public func getCacheSize(completion: @escaping (Result<Int, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                try self.ensureDiskCacheDirectoryExists()
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                var totalSize = 0
                
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                    if let size = attributes[.size] as? Int {
                        totalSize += size
                    }
                }
                
                self.dispatchToMain {
                    completion(.success(totalSize))
                }
            } catch {
                self.dispatchToMain {
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
                try self.ensureDiskCacheDirectoryExists()
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                let expirationDate = Date().addingTimeInterval(-self.currentConfig().expirationInterval)
                
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                    
                    if let modificationDate = attributes[.modificationDate] as? Date,
                       modificationDate < expirationDate {
                        try self.fileManager.removeItem(atPath: filePath)
                        self.pruneKeyHashMapping(forHashedFileName: file)
                    }
                }
                
                self.dispatchToMain {
                    completion(.success(()))
                }
            } catch {
                self.dispatchToMain {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    private func recordHitIfEnabled(source: CacheSource) {
        guard currentConfig().enableStatistics else { return }
        statsQueue.async {
            self.cacheStats.recordHit(source: source)
        }
    }
    
    private func recordMissIfEnabled() {
        guard currentConfig().enableStatistics else { return }
        statsQueue.async {
            self.cacheStats.recordMiss()
        }
    }
    
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
        if !currentConfig().enableKeyHashing {
            return sanitizeCacheKey(key)
        }
        
        return keyMappingQueue.sync {
            if let hashedKey = keyHashMapping[key] {
                return hashedKey
            }
            
            let hashedKey = fileSystemSafeHash(for: key)
            keyHashMapping[key] = hashedKey
            return hashedKey
        }
    }
    
    private func pruneKeyHashMapping(forHashedFileName fileName: String) {
        let hashedKey = (fileName as NSString).deletingPathExtension
        keyMappingQueue.async {
            self.keyHashMapping = self.keyHashMapping.filter { $0.value != hashedKey }
        }
    }
    
    private func fileSystemSafeHash(for key: String) -> String {
        guard let data = key.data(using: .utf8) else {
            return sanitizeCacheKey(key)
        }
        
        return data.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private func diskCachePath(forKey key: String) -> String {
        let hashedKey = hashCacheKey(key)
        let fileName = "\(hashedKey).\(currentConfig().fileExtension)"
        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }
    
    private func ensureDiskCacheDirectoryExists() throws {
        guard !diskCachePath.isEmpty else {
            throw TFYCacheError.invalidData
        }
        
        if !fileManager.fileExists(atPath: diskCachePath) {
            try fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func writeDiskCacheSync(_ data: Data, forKey key: String) -> Result<Void, TFYCacheError> {
        do {
            try ensureDiskCacheDirectoryExists()
            cleanDiskIfNeeded()
            let cfg = currentConfig()
            let filePath = diskCachePath(forKey: key)
            var dataToWrite = data
            if cfg.enableCompression {
                if let compressed = try? (dataToWrite as NSData).compressed(using: .lzfse) as Data {
                    dataToWrite = compressed
                }
            }
            if cfg.enableObfuscation {
                dataToWrite = xorObfuscate(dataToWrite)
            }
            try dataToWrite.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            return .success(())
        } catch let cacheError as TFYCacheError {
            return .failure(cacheError)
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    private func readDiskCacheSync(forKey key: String) -> Result<Data, TFYCacheError> {
        let cfg = currentConfig()
        if cfg.enableAutoClean {
            cleanExpiredCacheIfNeeded(force: false)
        }
        let filePath = diskCachePath(forKey: key)
        
        guard fileManager.fileExists(atPath: filePath) else {
            return .failure(.dataNotFound)
        }
        
        do {
            var data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            if cfg.enableObfuscation {
                data = xorObfuscate(data)
            }
            if cfg.enableCompression {
                if let decompressed = try? (data as NSData).decompressed(using: .lzfse) as Data {
                    data = decompressed
                }
            }
            return .success(data)
        } catch {
            return .failure(.loadFailed(error))
        }
    }
    
    private func xorObfuscate(_ data: Data) -> Data {
        let key: [UInt8] = [0x54, 0x46, 0x59, 0x43, 0x61, 0x63, 0x68, 0x65] // "TFYCache"
        var result = [UInt8](data)
        for i in result.indices {
            result[i] ^= key[i % key.count]
        }
        return Data(result)
    }
    
    private func dispatchToMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    private func dispatchResult<T>(_ result: Result<T, TFYCacheError>, completion: @escaping (Result<T, TFYCacheError>) -> Void) {
        dispatchToMain {
            completion(result)
        }
    }
    
    /// 自动清理过期缓存（仅内部调用，非主线程）
    /// - Parameter force: true 时忽略间隔限制，否则按 `expirationScanMinInterval` 节流
    private func cleanExpiredCacheIfNeeded(force: Bool = false) {
        expirationScanLock.lock()
        let now = Date().timeIntervalSince1970
        if !force, now - lastExpirationScanTime < expirationScanMinInterval {
            expirationScanLock.unlock()
            return
        }
        lastExpirationScanTime = now
        expirationScanLock.unlock()

        do {
            let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
            let expirationDate = Date().addingTimeInterval(-self.currentConfig().expirationInterval)
            for file in contents {
                let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                if let modificationDate = attributes[.modificationDate] as? Date,
                   modificationDate < expirationDate {
                    try? self.fileManager.removeItem(atPath: filePath)
                    self.pruneKeyHashMapping(forHashedFileName: file)
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
            var fileInfos: [(path: String, date: Date, size: Int, name: String)] = []
            var totalSize = 0
            for file in contents {
                let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                let size = attributes[.size] as? Int ?? 0
                let date = attributes[.modificationDate] as? Date ?? Date.distantPast
                fileInfos.append((filePath, date, size, file))
                totalSize += size
            }
            let maxSize = self.currentConfig().diskCacheSize * 1024 * 1024
            if totalSize > maxSize {
                // 按最早时间排序，依次删除
                let sorted = fileInfos.sorted { $0.date < $1.date }
                var sizeToFree = totalSize - maxSize
                for info in sorted {
                    try? self.fileManager.removeItem(atPath: info.path)
                    pruneKeyHashMapping(forHashedFileName: info.name)
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
        debugLog("Memory cache item evicted")
    }
}

// MARK: - 缓存统计扩展
public extension TFYSwiftCacheKit {
    /// 获取缓存统计信息
    var statistics: TFYCacheStats {
        var stats = TFYCacheStats()
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
        var stats = TFYCacheStats()
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
        guard validateCacheKey(key) else {
            return .failure(.invalidKey)
        }
        
        setMemoryCache(value, forKey: key)
        
        do {
            let data = try JSONEncoder().encode(value)
            let result = syncOnCacheQueue {
                writeDiskCacheSync(data, forKey: key)
            }
            if case .failure = result {
                removeMemoryCache(forKey: key)
            }
            return result
        } catch {
            removeMemoryCache(forKey: key)
            return .failure(.saveFailed(error))
        }
    }
    
    /// 同步获取缓存（避免死锁）
    func getCacheSync<T: Codable>(_ type: T.Type, forKey key: String) -> Result<T, TFYCacheError> {
        guard validateCacheKey(key) else {
            return .failure(.invalidKey)
        }
        
        if let memoryValue: T = getMemoryCache(forKey: key) {
            recordHitIfEnabled(source: .memory)
            return .success(memoryValue)
        }
        
        let diskResult: Result<Data, TFYCacheError> = syncOnCacheQueue {
            readDiskCacheSync(forKey: key)
        }
        
        switch diskResult {
        case .success(let data):
            do {
                let value = try JSONDecoder().decode(type, from: data)
                setMemoryCache(value, forKey: key)
                recordHitIfEnabled(source: .disk)
                return .success(value)
            } catch {
                recordMissIfEnabled()
                return .failure(.loadFailed(error))
            }
        case .failure(let error):
            recordMissIfEnabled()
            return .failure(error)
        }
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
                completion(.failure(errors.first ?? .invalidData))
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
                completion(.failure(errors.first ?? .invalidData))
            }
        }
    }
}
