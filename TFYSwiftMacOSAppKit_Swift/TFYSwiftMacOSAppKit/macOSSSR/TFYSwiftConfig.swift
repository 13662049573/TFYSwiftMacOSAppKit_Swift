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
    public struct ServerConfig: Codable {
        var host: String
        var port: UInt16
        var password: String
        var method: CryptoMethod
        var `protocol`: ProtocolType
        var obfs: ObfsType
        var obfsParam: String?
        var protocolParam: String?
        
        public init(host: String, port: UInt16, password: String,
                   method: CryptoMethod = .aes256CFB,
                   protocol: ProtocolType = .origin,
                   obfs: ObfsType = .plain) {
            self.host = host
            self.port = port
            self.password = password
            self.method = method
            self.protocol = `protocol`
            self.obfs = obfs
        }
    }
    
    // 加密方法
    public enum CryptoMethod: String, Codable {
        case aes256CFB = "aes-256-cfb"
        case aes128CFB = "aes-128-cfb"
        case chacha20 = "chacha20"
        case rc4MD5 = "rc4-md5"
    }
    
    // 协议类型
    public enum ProtocolType: String, Codable {
        case origin = "origin"
        case auth_aes128_md5 = "auth_aes128_md5"
        case auth_aes128_sha1 = "auth_aes128_sha1"
    }
    
    // 混淆类型
    public enum ObfsType: String, Codable {
        case plain = "plain"
        case http_simple = "http_simple"
        case tls1_2_ticket_auth = "tls1.2_ticket_auth"
    }
    
    var servers: [ServerConfig]
    var selectedServer: Int
    var localPort: UInt16
    var timeout: TimeInterval
    
    public init() {
        self.servers = []
        self.selectedServer = 0
        self.localPort = 1080
        self.timeout = 60
    }
} 
