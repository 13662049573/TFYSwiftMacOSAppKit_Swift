//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 全局设置结构体 - 用于存储应用程序的全局配置参数
public struct GlobalSettings: Codable {
    var socksPort: UInt16        // SOCKS5 代理端口，用于 SOCKS5 协议
    var httpPort: UInt16         // HTTP 代理端口，用于 HTTP 协议代理
    var pacPort: UInt16          // PAC 服务端口，用于自动代理配置服务
    var localAddress: String     // 本地监听地址，通常为 127.0.0.1
    var localPort: UInt16        // 本地监听端口，用于本地代理服务
    var enableUDP: Bool          // 是否启用 UDP 转发功能
    var enableIPv6: Bool         // 是否启用 IPv6 支持
    var enableSystemProxy: Bool   // 是否启用系统全局代理
    
    /// 初始化方法 - 设置默认值
    init(socksPort: UInt16 = 1080,      // SOCKS5 默认端口 1080
         httpPort: UInt16 = 1087,       // HTTP 默认端口 1087
         pacPort: UInt16 = 1088,        // PAC 默认端口 1088
         localAddress: String = "127.0.0.1",  // 默认本地地址
         localPort: UInt16 = 1089,      // 本地默认端口 1089
         enableUDP: Bool = false,        // 默认不启用 UDP
         enableIPv6: Bool = false,       // 默认不启用 IPv6
         enableSystemProxy: Bool = false) {  // 默认不启用系统代理
        self.socksPort = socksPort
        self.httpPort = httpPort
        self.pacPort = pacPort
        self.localAddress = localAddress
        self.localPort = localPort
        self.enableUDP = enableUDP
        self.enableIPv6 = enableIPv6
        self.enableSystemProxy = enableSystemProxy
    }
}

/// 服务器配置结构体 - 用于存储单个代理服务器的配置信息
public struct ServerConfig: Codable {
    var server: String           // 服务器地址
    var serverPort: UInt16       // 服务器端口
    var method: String           // 加密方法（如 aes-256-cfb 等）
    var password: String         // 连接密码
    var protocolType: String     // 协议类型（如 origin、auth_sha1_v4 等）
    var protocolParam: String?   // 协议参数（可选）
    var obfs: String            // 混淆方式（如 plain、http_simple 等）
    var obfsParam: String?      // 混淆参数（可选）
    var remarks: String?        // 服务器备注名称（可选）
    var group: String?          // 服务器分组（可选）
    
    /// 完整的初始化方法
    init(server: String,
         serverPort: UInt16,
         method: String,
         password: String,
         protocolType: String,
         protocolParam: String?,
         obfs: String,
         obfsParam: String?,
         remarks: String?,
         group: String?) {
        self.server = server
        self.serverPort = serverPort
        self.method = method
        self.password = password
        self.protocolType = protocolType
        self.protocolParam = protocolParam
        self.obfs = obfs
        self.obfsParam = obfsParam
        self.remarks = remarks
        self.group = group
    }
    
    /// 用于 JSON 编解码的键名映射
    enum CodingKeys: String, CodingKey {
        case server
        case serverPort = "server_port"  // JSON 中使用下划线格式
        case method
        case password
        case protocolType = "protocol"   // 避免与 Swift 关键字冲突
        case protocolParam = "protocol_param"
        case obfs
        case obfsParam = "obfs_param"
        case remarks
        case group
    }
    
    /// 解码初始化器
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        server = try container.decode(String.self, forKey: .server)
        serverPort = try container.decode(UInt16.self, forKey: .serverPort)
        method = try container.decode(String.self, forKey: .method)
        password = try container.decode(String.self, forKey: .password)
        
        protocolType = try container.decode(String.self, forKey: .protocolType)
        protocolParam = try container.decodeIfPresent(String.self, forKey: .protocolParam)
        obfs = try container.decode(String.self, forKey: .obfs)
        obfsParam = try container.decodeIfPresent(String.self, forKey: .obfsParam)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        group = try container.decodeIfPresent(String.self, forKey: .group)
    }
    
    /// 编码方法
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(server, forKey: .server)
        try container.encode(serverPort, forKey: .serverPort)
        try container.encode(method, forKey: .method)
        try container.encode(password, forKey: .password)
        try container.encode(protocolType, forKey: .protocolType)
        try container.encodeIfPresent(protocolParam, forKey: .protocolParam)
        try container.encode(obfs, forKey: .obfs)
        try container.encodeIfPresent(obfsParam, forKey: .obfsParam)
        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(group, forKey: .group)
    }
}

/// 主配置类 - 管理整个应用的配置信息
public class TFYSwiftConfig: Codable {
    var globalSettings: GlobalSettings       // 全局设置
    var serverConfigs: [ServerConfig]       // 服务器配置列表
    var selectedServer: Int                 // 当前选中的服务器索引
    
    /// 获取当前选中的服务器配置
    var currentServer: ServerConfig? {
        guard selectedServer >= 0 && selectedServer < serverConfigs.count else {
            return nil  // 当索引无效时返回 nil
        }
        return serverConfigs[selectedServer]
    }
    
    /// 默认初始化方法
    init() {
        self.globalSettings = GlobalSettings()  // 使用默认全局设置
        self.serverConfigs = []                // 空服务器列表
        self.selectedServer = -1               // 未选中任何服务器
    }
    
    /// 保存配置到文件
    func save() throws {
        let fileManager = FileManager.default
        // 获取应用支持目录路径
        let appSupport = try fileManager.url(for: .applicationSupportDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
        // 配置文件完整路径
        let configPath = appSupport.appendingPathComponent("TFYSwift/config.json")
        
        // 确保目录存在
        try fileManager.createDirectory(at: configPath.deletingLastPathComponent(),
                                      withIntermediateDirectories: true)
        
        // 编码并保存配置
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted  // 美化 JSON 输出
        let data = try encoder.encode(self)
        try data.write(to: configPath)
    }
    
    /// 从文件加载配置
    static func load() throws -> TFYSwiftConfig {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(for: .applicationSupportDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
        let configPath = appSupport.appendingPathComponent("TFYSwift/config.json")
        
        // 如果配置文件存在则加载，否则返回默认配置
        if fileManager.fileExists(atPath: configPath.path) {
            let data = try Data(contentsOf: configPath)
            return try JSONDecoder().decode(TFYSwiftConfig.self, from: data)
        }
        
        return TFYSwiftConfig()
    }
    
    /// 验证配置是否有效
    func validate() -> Bool {
        // 验证服务器选择是否有效
        guard selectedServer >= -1 && selectedServer < serverConfigs.count else {
            return false
        }
        
        // 验证端口号是否在有效范围内（0-65535）
        guard globalSettings.socksPort > 0 && globalSettings.socksPort < 65535,
              globalSettings.httpPort > 0 && globalSettings.httpPort < 65535,
              globalSettings.pacPort > 0 && globalSettings.pacPort < 65535,
              globalSettings.localPort > 0 && globalSettings.localPort < 65535 else {
            return false
        }
        
        return true
    }
} 

