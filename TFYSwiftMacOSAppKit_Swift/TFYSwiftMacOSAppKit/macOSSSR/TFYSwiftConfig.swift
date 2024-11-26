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
    /// 服务器唯一标识符
    let id: String
    /// 服务器地址
    var serverHost: String
    /// 服务器端口
    var serverPort: UInt16
    /// 密码
    var password: String
    /// 加密方法
    var method: String
    /// 协议类型
    var protocolType: String
    /// 协议参数
    var protocolParam: String?
    /// 混淆方式
    var obfs: String
    /// 混淆参数
    var obfsParam: String?
    /// 备注名称
    var remarks: String?
    /// 分组名称
    var group: String?
    /// 延迟（毫秒）
    var latency: Int?
    /// 上次连接时间
    var lastConnectedTime: Date?
    /// 总上传流量
    var totalUploadTraffic: UInt64
    /// 总下载流量
    var totalDownloadTraffic: UInt64
    
    enum CodingKeys: String, CodingKey {
        case id
        case serverHost
        case serverPort
        case password
        case method
        case protocolType = "protocol"
        case protocolParam = "protocol_param"
        case obfs
        case obfsParam = "obfs_param"
        case remarks
        case group
        case latency
        case lastConnectedTime
        case totalUploadTraffic
        case totalDownloadTraffic
    }
    
    init(id: String = UUID().uuidString,
         serverHost: String,
         serverPort: UInt16,
         password: String,
         method: String,
         protocolType: String,
         protocolParam: String? = nil,
         obfs: String,
         obfsParam: String? = nil,
         remarks: String? = nil,
         group: String? = nil) {
        self.id = id
        self.serverHost = serverHost
        self.serverPort = serverPort
        self.password = password
        self.method = method
        self.protocolType = protocolType
        self.protocolParam = protocolParam
        self.obfs = obfs
        self.obfsParam = obfsParam
        self.remarks = remarks
        self.group = group
        self.latency = nil
        self.lastConnectedTime = nil
        self.totalUploadTraffic = 0
        self.totalDownloadTraffic = 0
    }
    
    /// 创建加密器实例
    func createCrypto() throws -> TFYSwiftCrypto {
        return try TFYSwiftCrypto(password: password, method: method)
    }
    
    /// 验证配置是否有效
    func isValid() -> Bool {
        // 验证服务器地址不为空
        guard !serverHost.isEmpty else { return false }
        
        // 验证端口号在有效范围内 (1-65535)
        guard serverPort > 0 && serverPort <= UInt16.max else { return false }
        
        // 验证加密方法是否支持
        guard let _ = TFYSwiftCrypto.CryptoMethod(rawValue: method.lowercased()) else {
            return false
        }
        
        // 验证密码不为空
        guard !password.isEmpty else { return false }
        
        // 验证协议类型不为空
        guard !protocolType.isEmpty else { return false }
        
        // 验证混淆方式不为空
        guard !obfs.isEmpty else { return false }
        
        return true
    }
    
    /// 获取显示名称
    var displayName: String {
        if let remarks = remarks, !remarks.isEmpty {
            return remarks
        }
        return "\(serverHost):\(serverPort)"
    }
    
    /// 创建一个基本的服务器配置
    static func createBasicConfig(
        serverHost: String,
        port: UInt16,
        password: String,
        method: String = "aes-256-cfb"
    ) -> ServerConfig {
        return ServerConfig(
            serverHost: serverHost,
            serverPort: port,
            password: password,
            method: method,
            protocolType: "origin",
            obfs: "plain"
        )
    }
    
    /// 加密敏感数据
    mutating func encryptSensitiveData() throws {
        guard let crypto = try? createCrypto() else {
            throw TFYSwiftError.encryptionError("无法创建加密器")
        }
        
        // 加密密码
        if !password.isEmpty {
            let passwordData = password.data(using: .utf8) ?? Data()
            let encryptedPassword = try crypto.encrypt(passwordData)
            password = encryptedPassword.base64EncodedString()
        }
        
        // 加密协议参数（如果存在）
        if let param = protocolParam, !param.isEmpty {
            let paramData = param.data(using: .utf8) ?? Data()
            let encryptedParam = try crypto.encrypt(paramData)
            protocolParam = encryptedParam.base64EncodedString()
        }
        
        // 加密混淆参数（如果存在）
        if let param = obfsParam, !param.isEmpty {
            let paramData = param.data(using: .utf8) ?? Data()
            let encryptedParam = try crypto.encrypt(paramData)
            obfsParam = encryptedParam.base64EncodedString()
        }
    }
    
    /// 解密敏感数据
    mutating func decryptSensitiveData() throws {
        guard let crypto = try? createCrypto() else {
            throw TFYSwiftError.decryptionError("无法创建解密器")
        }
        
        // 解密密码
        if !password.isEmpty {
            guard let passwordData = Data(base64Encoded: password) else {
                throw TFYSwiftError.decryptionError("密码格式无效")
            }
            let decryptedPassword = try crypto.decrypt(passwordData)
            guard let passwordString = String(data: decryptedPassword, encoding: .utf8) else {
                throw TFYSwiftError.decryptionError("密码解密失败")
            }
            password = passwordString
        }
        
        // 解密协议参数（如果存在）
        if let param = protocolParam, !param.isEmpty {
            guard let paramData = Data(base64Encoded: param) else {
                throw TFYSwiftError.decryptionError("协议参数格式无效")
            }
            let decryptedParam = try crypto.decrypt(paramData)
            guard let paramString = String(data: decryptedParam, encoding: .utf8) else {
                throw TFYSwiftError.decryptionError("协议参数解密失败")
            }
            protocolParam = paramString
        }
        
        // 解密混淆参数（如果存在）
        if let param = obfsParam, !param.isEmpty {
            guard let paramData = Data(base64Encoded: param) else {
                throw TFYSwiftError.decryptionError("混淆参数格式无效")
            }
            let decryptedParam = try crypto.decrypt(paramData)
            guard let paramString = String(data: decryptedParam, encoding: .utf8) else {
                throw TFYSwiftError.decryptionError("混淆参数解密失败")
            }
            obfsParam = paramString
        }
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

// 补充配置管理功能

extension TFYSwiftConfig {
    /// 全局设置
    public struct GlobalSettings: Codable {
        /// 本地监听地址
        var localAddress: String
        /// SOCKS5 端口
        var socksPort: UInt16
        /// HTTP 代理端口
        var httpPort: UInt16
        /// PAC 端口
        var pacPort: UInt16
        /// 是否启用 UDP 转发
        var enableUDP: Bool
        /// 是否启用 IPv6
        var enableIPv6: Bool
        /// 日志级别
        var logLevel: LogLevel
        /// 是否开机启动
        var launchAtLogin: Bool
        /// 是否显示网速
        var showSpeedInDock: Bool
        
        public init(
            localAddress: String = "127.0.0.1",
            socksPort: UInt16 = 1080,
            httpPort: UInt16 = 1087,
            pacPort: UInt16 = 1088,
            enableUDP: Bool = true,
            enableIPv6: Bool = false,
            logLevel: LogLevel = .info,
            launchAtLogin: Bool = false,
            showSpeedInDock: Bool = true
        ) {
            self.localAddress = localAddress
            self.socksPort = socksPort
            self.httpPort = httpPort
            self.pacPort = pacPort
            self.enableUDP = enableUDP
            self.enableIPv6 = enableIPv6
            self.logLevel = logLevel
            self.launchAtLogin = launchAtLogin
            self.showSpeedInDock = showSpeedInDock
        }
    }
    
    /// 日志级别
    public enum LogLevel: String, Codable {
        case debug
        case info
        case warning
        case error
    }
    
    /// 服务器组
    public struct ServerGroup: Codable {
        var name: String
        var servers: [ServerConfig]
        
        public init(name: String, servers: [ServerConfig] = []) {
            self.name = name
            self.servers = servers
        }
    }
    
    /// 添加服务器配置
    /// - Parameters:
    ///   - server: 服务器配置
    ///   - groupName: 组名称
    public func addServer(_ server: ServerConfig, to groupName: String) {
        if var group = serverGroups.first(where: { $0.name == groupName }) {
            group.servers.append(server)
            if let index = serverGroups.firstIndex(where: { $0.name == groupName }) {
                serverGroups[index] = group
            }
        } else {
            let newGroup = ServerGroup(name: groupName, servers: [server])
            serverGroups.append(newGroup)
        }
        saveConfig()
    }
    
    /// 移除服务器配置
    /// - Parameters:
    ///   - id: 服务器ID
    ///   - groupName: 组名称
    public func removeServer(id: String, from groupName: String) {
        if var group = serverGroups.first(where: { $0.name == groupName }) {
            group.servers.removeAll(where: { $0.id == id })
            if let index = serverGroups.firstIndex(where: { $0.name == groupName }) {
                serverGroups[index] = group
            }
        }
        saveConfig()
    }
    
    /// 更新服务器配置
    /// - Parameter server: 服务器配置
    public func updateServer(_ server: ServerConfig) {
        for (groupIndex, var group) in serverGroups.enumerated() {
            if let serverIndex = group.servers.firstIndex(where: { $0.id == server.id }) {
                group.servers[serverIndex] = server
                serverGroups[groupIndex] = group
                break
            }
        }
        saveConfig()
    }
    
    /// 更新全局设置
    /// - Parameter settings: 全局设置
    public func updateGlobalSettings(_ settings: GlobalSettings) {
        globalSettings = settings
        saveConfig()
    }
    
    /// 导出配置
    /// - Parameter url: 导出路径
    public func exportConfig(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: url)
    }
    
    /// 导入配置
    /// - Parameter url: 配置文件路径
    public func importConfig(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let config = try JSONDecoder().decode(TFYSwiftConfig.self, from: data)
        self.globalSettings = config.globalSettings
        self.serverGroups = config.serverGroups
        saveConfig()
    }
    
    /// 保存配置
    private func saveConfig() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            try data.write(to: configURL)
        } catch {
            print("保存配置失败: \(error)")
        }
    }
} 

