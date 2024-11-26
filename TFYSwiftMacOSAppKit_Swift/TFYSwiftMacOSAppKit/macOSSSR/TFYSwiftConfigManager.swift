//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// SSR配置管理器类 - 负责管理和持久化配置信息
public class TFYSwiftConfigManager {
    // MARK: - 属性
    /// 用于同步配置操作的串行队列，确保线程安全
    private let queue = DispatchQueue(label: "com.tfyswift.configmanager")
    
    /// 配置文件的存储路径
    private let configPath: URL
    
    /// 当前的配置对象
    private var config: TFYSwiftConfig
    
    /// 获取当前配置
    public var currentConfig: TFYSwiftConfig {
        return queue.sync { config }
    }
    
    // MARK: - 初始化
    /// 初始化配置管理器
    /// 会尝试从磁盘加载配置，如果不存在则创建默认配置
    /// - Throws: 文件操作或JSON解码错误
    public init() {
        let fileManager = FileManager.default
        // 获取应用支持目录路径
        let appSupport = try? fileManager.url(for: .applicationSupportDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
        // 设置配置文件完整路径
        configPath = appSupport?.appendingPathComponent("TFYSwift/config.json") ?? URL(fileURLWithPath: "")
        
        // 尝试加载现有配置，如果不存在则创建新配置
        if let data = try? Data(contentsOf: configPath),
           let loadedConfig = try? JSONDecoder().decode(TFYSwiftConfig.self, from: data) {
            config = loadedConfig
        } else {
            config = TFYSwiftConfig()
            try? self.saveConfig()
        }
        
        // 确保配置目录存在
        try? fileManager.createDirectory(at: configPath.deletingLastPathComponent(),
                                     withIntermediateDirectories: true)
    }
    
    /// 加载配置
    public func loadConfig(completion: @escaping (Result<TFYSwiftConfig, Error>) -> Void) {
        queue.async {
            do {
                let data = try Data(contentsOf: self.configPath)
                let loadedConfig = try JSONDecoder().decode(TFYSwiftConfig.self, from: data)
                self.config = loadedConfig
                completion(.success(loadedConfig))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 公共方法
    /// 获取当前配置
    /// - Returns: 当前的配置对象副本
    func getConfig() -> TFYSwiftConfig {
        return queue.sync { config }
    }
    
    /// 更新配置并保存到磁盘
    /// - Parameter newConfig: 新的配置对象
    /// - Throws: 保存失败时抛出错误
    func updateConfig(_ newConfig: TFYSwiftConfig) throws {
        try queue.sync {
            config = newConfig
            try saveConfig()
        }
    }
    
    /// 将配置保存到磁盘
    /// - Throws: 编码或文件写入错误
    private func saveConfig() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted  // 使JSON更易读
        let data = try encoder.encode(config)
        try data.write(to: configPath, options: .atomicWrite)  // 原子写入确保数据完整性
    }
    
    /// 重置配置到默认状态
    /// - Throws: 保存失败时抛出错误
    func resetConfig() throws {
        try queue.sync {
            config = TFYSwiftConfig()
            try saveConfig()
        }
    }
    
    // MARK: - 配置验证
    /// 验证当前配置是否有效
    /// - Returns: 配置有效返回true，否则返回false
    func validateConfig() -> Bool {
        return config.validate()
    }
    
    /// 更新选中的服务器
    /// - Parameter index: 服务器索引
    /// - Throws: 如果索引无效则抛出错误
    public func updateSelectedServer(_ index: Int) throws {
        try queue.sync {
            // 验证索引是否有效
            guard index >= 0 && index < config.serverConfigs.count else {
                throw TFYSwiftError.configurationError("无效的服务器索引: \(index)")
            }
            
            // 更新选中的服务器索引
            config.selectedServer = index
            
            // 保存配置
            try saveConfig()
        }
    }
    
    /// 获取当前选中的服务器配置
    public func getCurrentServer() -> ServerConfig? {
        return queue.sync {
            guard config.selectedServer >= 0 && config.selectedServer < config.serverConfigs.count else {
                return nil
            }
            return config.serverConfigs[config.selectedServer]
        }
    }
    
    /// 更新服务器配置
    /// - Parameters:
    ///   - serverConfig: 新的服务器配置
    ///   - completion: 完成回调
    public func updateServerConfig(_ serverConfig: ServerConfig, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            self.config.servers[serverConfig.id] = serverConfig
            self.config.currentServerId = serverConfig.id
            
            do {
                try self.saveConfig()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// 更新多个服务器配置
    /// - Parameters:
    ///   - configs: 服务器配置数组
    ///   - completion: 完成回调
    public func updateServerConfigs(_ configs: [ServerConfig], completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            // 更新服务器列表
            for serverConfig in configs {
                self.config.servers[serverConfig.id] = serverConfig
            }
            
            // 如果没有当前服务器，设置第一个为当前服务器
            if self.config.currentServerId == nil && !configs.isEmpty {
                self.config.currentServerId = configs[0].id
            }
            
            do {
                try self.saveConfig()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - 错误处理
extension TFYSwiftConfigManager {
    /// 配置管理器可能遇到的错误类型
    enum ConfigError: LocalizedError {
        case invalidConfigData    // 配置数据无效
        case saveFailed          // 保存配置失败
        case loadFailed          // 加载配置失败
        
        /// 错误描述信息
        var errorDescription: String? {
            switch self {
            case .invalidConfigData:
                return "配置数据无效"
            case .saveFailed:
                return "配置保存失败"
            case .loadFailed:
                return "配置加载失败"
            }
        }
    }
} 
