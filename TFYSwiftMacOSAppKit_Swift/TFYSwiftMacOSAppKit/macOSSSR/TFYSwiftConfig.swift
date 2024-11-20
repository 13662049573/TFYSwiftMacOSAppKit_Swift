//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 全局设置结构体
struct GlobalSettings: Codable {
    var socksPort: UInt16        // SOCKS5 代理端口
    var httpPort: UInt16         // HTTP 代理端口
    var pacPort: UInt16          // PAC 服务端口
    var localAddress: String     // 本地监听地址
}

/// 服务器配置结构体
struct ServerConfig: Codable {
    var server: String           // 服务器地址
    var serverPort: UInt16       // 服务器端口
    var password: String         // 密码
    var method: CryptoMethod     // 加密方法
    var protocolType: String     // 协议类型
    var protocolParam: String?   // 协议参数
    var obfs: String            // 混淆方式
    var obfsParam: String?      // 混淆参数
    var remarks: String?        // 备注
    var group: String?          // 分组
}

/// 配置类
class TFYSwiftConfig: Codable {
    // MARK: - 类型定义
    
    /// 加密方法枚举
    enum CryptoMethod: String, Codable {
        case aes128CFB = "aes-128-cfb"
        case aes192CFB = "aes-192-cfb"
        case aes256CFB = "aes-256-cfb"
        case chacha20 = "chacha20"
        case salsa20 = "salsa20"
        case rc4MD5 = "rc4-md5"
        case rc4 = "rc4"
        case none = "none"
        
        /// 获取密钥长度
        var keyLength: Int {
            switch self {
            case .aes128CFB:
                return 16
            case .aes192CFB:
                return 24
            case .aes256CFB:
                return 32
            case .chacha20, .salsa20:
                return 32
            case .rc4MD5, .rc4:
                return 16
            case .none:
                return 0
            }
        }
        
        /// 获取 IV 长度
        var ivLength: Int {
            switch self {
            case .aes128CFB, .aes192CFB, .aes256CFB:
                return 16
            case .chacha20, .salsa20:
                return 8
            case .rc4MD5, .rc4:
                return 16
            case .none:
                return 0
            }
        }
    }
    
    // MARK: - 属性
    
    /// 全局设置
    var globalSettings: GlobalSettings
    
    /// 服务器配置列表
    var servers: [ServerConfig]
    
    /// 当前选中的服务器索引
    var selectedServerIndex: Int
    
    /// 订阅 URL 列表
    var subscribeUrls: [String]
    
    /// 绕过列表
    var bypassList: [String]
    
    // MARK: - 计算属性
    
    /// 获取当前选中的服务器配置
    var currentServer: ServerConfig? {
        guard selectedServerIndex >= 0 && selectedServerIndex < servers.count else {
            return nil
        }
        return servers[selectedServerIndex]
    }
    
    /// 当前服务器地址
    var server: String { currentServer?.server ?? "" }
    
    /// 当前服务器端口
    var serverPort: UInt16 { currentServer?.serverPort ?? 0 }
    
    /// 当前服务器密码
    var password: String { currentServer?.password ?? "" }
    
    /// 当前加密方法
    var method: CryptoMethod { currentServer?.method ?? .none }
    
    /// 当前协议类型
    var protocolType: String { currentServer?.protocolType ?? "" }
    
    /// 当前协议参数
    var protocolParam: String? { currentServer?.protocolParam }
    
    /// 当前混淆方式
    var obfs: String { currentServer?.obfs ?? "" }
    
    /// 当前混淆参数
    var obfsParam: String? { currentServer?.obfsParam }
    
    // MARK: - 初始化方法
    
    /// 初始化配置
    /// - Parameters:
    ///   - globalSettings: 全局设置
    ///   - servers: 服务器列表
    ///   - selectedServerIndex: 选中的服务器索引
    ///   - subscribeUrls: 订阅URL列表
    ///   - bypassList: 绕过列表
    init(globalSettings: GlobalSettings = GlobalSettings(socksPort: 1080,
                                                       httpPort: 1087,
                                                       pacPort: 1088,
                                                       localAddress: "127.0.0.1"),
         servers: [ServerConfig] = [],
         selectedServerIndex: Int = -1,
         subscribeUrls: [String] = [],
         bypassList: [String] = []) {
        self.globalSettings = globalSettings
        self.servers = servers
        self.selectedServerIndex = selectedServerIndex
        self.subscribeUrls = subscribeUrls
        self.bypassList = bypassList
    }
    
    // MARK: - 配置文件管理
    
    /// 保存配置到文件
    /// - Throws: 配置保存过程中的错误
    func save() throws {
        // 获取配置文件路径
        guard let configPath = TFYSwiftConfig.getConfigPath() else {
            throw TFYSwiftError.configurationError("无法获取配置文件路径")
        }
        
        // 编码配置数据
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        
        // 写入文件
        try data.write(to: configPath)
        print("配置已保存到: \(configPath.path)")
    }
    
    /// 从文件加载配置
    /// - Returns: 加载的配置对象
    /// - Throws: 配置加载过程中的错误
    static func load() throws -> TFYSwiftConfig {
        // 获取配置文件路径
        guard let configPath = TFYSwiftConfig.getConfigPath() else {
            throw TFYSwiftError.configurationError("无法获取配置文件路径")
        }
        
        // 如果文件不存在，返回默认配置
        if !FileManager.default.fileExists(atPath: configPath.path) {
            print("配置文件不存在，使用默认配置")
            return TFYSwiftConfig()
        }
        
        // 读取并解码配置数据
        let data = try Data(contentsOf: configPath)
        let decoder = JSONDecoder()
        let config = try decoder.decode(TFYSwiftConfig.self, from: data)
        print("已从 \(configPath.path) 加载配置")
        return config
    }
    
    /// 获取配置文件路径
    /// - Returns: 配置文件的 URL
    private static func getConfigPath() -> URL? {
        // 获取应用支持目录
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory,
                                                      in: .userDomainMask).first else {
            print("无法获取应用支持目录")
            return nil
        }
        
        // 创建配置目录路径
        let configDir = appSupport.appendingPathComponent("TFYSwift")
        
        // 创建配置目录
        do {
            try FileManager.default.createDirectory(at: configDir,
                                                  withIntermediateDirectories: true,
                                                  attributes: nil)
            print("配置目录已创建: \(configDir.path)")
        } catch {
            print("创建配置目录失败: \(error.localizedDescription)")
            return nil
        }
        
        // 返回配置文件路径
        return configDir.appendingPathComponent("config.json")
    }
} 
