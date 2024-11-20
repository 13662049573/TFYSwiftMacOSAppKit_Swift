//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

public struct TFYSwiftConfig: Codable {
    // 基础配置
    public struct ServerConfig: Codable, Equatable {
        var host: String
        var port: UInt16
        var password: String
        var method: CryptoMethod
        var `protocol`: ProtocolType
        var obfs: ObfsType
        var obfsParam: String?
        var protocolParam: String?
        var remarks: String?
        var timeout: TimeInterval
        var udpEnabled: Bool
        
        public init(host: String, 
                   port: UInt16, 
                   password: String,
                   method: CryptoMethod = .aes256CFB,
                   protocol: ProtocolType = .origin,
                   obfs: ObfsType = .plain,
                   remarks: String? = nil,
                   timeout: TimeInterval = 60,
                   udpEnabled: Bool = false) {
            self.host = host
            self.port = port
            self.password = password
            self.method = method
            self.protocol = `protocol`
            self.obfs = obfs
            self.remarks = remarks
            self.timeout = timeout
            self.udpEnabled = udpEnabled
        }
    }
    
    // 加密方法扩展
    public enum CryptoMethod: String, Codable, CaseIterable {
        case aes256CFB = "aes-256-cfb"
        case aes128CFB = "aes-128-cfb"
        case chacha20 = "chacha20"
        case rc4MD5 = "rc4-md5"
        case salsa20 = "salsa20"
        case chacha20IETF = "chacha20-ietf"
        
        var keySize: Int {
            switch self {
            case .aes256CFB: return 32
            case .aes128CFB: return 16
            case .chacha20, .chacha20IETF: return 32
            case .rc4MD5: return 16
            case .salsa20: return 32
            }
        }
        
        var ivSize: Int {
            switch self {
            case .aes256CFB, .aes128CFB: return 16
            case .chacha20: return 8
            case .chacha20IETF: return 12
            case .rc4MD5: return 16
            case .salsa20: return 8
            }
        }
    }
    
    // 协议类型扩展
    public enum ProtocolType: String, Codable, CaseIterable {
        case origin = "origin"
        case auth_aes128_md5 = "auth_aes128_md5"
        case auth_aes128_sha1 = "auth_aes128_sha1"
        case auth_chain_a = "auth_chain_a"
        case auth_chain_b = "auth_chain_b"
    }
    
    // 混淆类型扩展
    public enum ObfsType: String, Codable, CaseIterable {
        case plain = "plain"
        case http_simple = "http_simple"
        case tls1_2_ticket_auth = "tls1.2_ticket_auth"
        case random_head = "random_head"
    }
    
    // 全局设置
    struct GlobalSettings: Codable {
        var localPort: UInt16
        var pacPort: UInt16
        var socksPort: UInt16
        var httpPort: UInt16
        var enableUDP: Bool
        var enableIPv6: Bool
        var dnsServer: String
        var routeMode: RouteMode
        
        init() {
            self.localPort = 1080
            self.pacPort = 1090
            self.socksPort = 1080
            self.httpPort = 1087
            self.enableUDP = false
            self.enableIPv6 = false
            self.dnsServer = "8.8.8.8"
            self.routeMode = .global
        }
    }
    
    enum RouteMode: String, Codable {
        case global = "global"
        case bypass = "bypass"
        case forward = "forward"
    }
    
    var servers: [ServerConfig]
    var selectedServer: Int
    var globalSettings: GlobalSettings
    var subscribeUrls: [String]
    var bypassList: [String]
    var forwardList: [String]
    
    public init() {
        self.servers = []
        self.selectedServer = 0
        self.globalSettings = GlobalSettings()
        self.subscribeUrls = []
        self.bypassList = []
        self.forwardList = []
    }
    
    // 配置文件操作
    func save() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        let configPath = try getConfigPath()
        try data.write(to: configPath)
    }
    
    static func load() throws -> TFYSwiftConfig {
        let configPath = try getConfigPath()
        if let data = try? Data(contentsOf: configPath) {
            return try JSONDecoder().decode(TFYSwiftConfig.self, from: data)
        }
        return TFYSwiftConfig()
    }
    
    private static func getConfigPath() throws -> URL {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(for: .applicationSupportDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
        let configDir = appSupport.appendingPathComponent("TFYSwift")
        if !fileManager.fileExists(atPath: configDir.path) {
            try fileManager.createDirectory(at: configDir,
                                         withIntermediateDirectories: true)
        }
        return configDir.appendingPathComponent("config.json")
    }
} 
