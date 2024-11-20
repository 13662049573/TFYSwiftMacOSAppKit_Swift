//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// 代理连接委托协议
protocol TFYSwiftProxyConnectionDelegate: AnyObject {
    /// 连接完成回调
    func connectionDidComplete(_ connection: TFYSwiftProxyConnection)
    /// 连接失败回调
    func connection(_ connection: TFYSwiftProxyConnection, didFailWith error: Error)
}

/// 代理连接类
class TFYSwiftProxyConnection {
    // MARK: - 属性
    
    private let connection: NWConnection          // 本地连接
    private let config: TFYSwiftConfig           // 配置信息
    private weak var delegate: TFYSwiftProxyConnectionDelegate?  // 委托对象
    private var remoteConnection: TFYSwiftConnection?  // 远程连接
    private var crypto: TFYSwiftCrypto?          // 加密工具
    private let queue = DispatchQueue(label: "com.tfyswift.proxyconnection")  // 专用队列
    
    private var buffer = Data()                  // 数据缓冲区
    private var stage: ConnectionStage = .initial // 连接阶段
    
    /// 连接阶段枚举
    enum ConnectionStage {
        case initial        // 初始阶段
        case handshake      // 握手阶段
        case authentication // 认证阶段
        case request        // 请求阶段
        case relay         // 转发阶段
        case completed     // 完成阶段
    }
    
    // MARK: - 初始化方法
    
    init(connection: NWConnection, config: TFYSwiftConfig, delegate: TFYSwiftProxyConnectionDelegate?) {
        self.connection = connection
        self.config = config
        self.delegate = delegate
        
        // 初始化加密工具，使用当前选中服务器的配置
        if let currentServer = config.currentServer {
            self.crypto = TFYSwiftCrypto(password: currentServer.password,
                                        method: currentServer.method)
        }
    }
    
    // MARK: - 公共方法
    
    /// 启动连接
    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state)
        }
        
        connection.start(queue: queue)
    }
    
    /// 停止连接
    func stop() {
        connection.cancel()
        remoteConnection?.disconnect()
    }
    
    // MARK: - 私有方法
    
    /// 处理连接状态变化
    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            startReading()
        case .failed(let error):
            delegate?.connection(self, didFailWith: error)
        case .cancelled:
            delegate?.connectionDidComplete(self)
        default:
            break
        }
    }
    
    /// 开始读取数据
    private func startReading() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.connection(self, didFailWith: error)
                return
            }
            
            if let data = content {
                self.handleReceivedData(data)
            }
            
            if !isComplete {
                self.startReading()
            }
        }
    }
    
    /// 处理接收到的数据
    private func handleReceivedData(_ data: Data) {
        buffer.append(data)
        
        switch stage {
        case .initial:
            handleInitialStage()
        case .handshake:
            handleHandshakeStage()
        case .authentication:
            handleAuthenticationStage()
        case .request:
            handleRequestStage()
        case .relay:
            handleRelayStage()
        case .completed:
            break
        }
    }
    
    /// 处理初始阶段
    private func handleInitialStage() {
        guard buffer.count >= 1 else { return }
        
        let version = buffer[0]
        if version == 0x05 { // SOCKS5
            stage = .handshake
            handleHandshakeStage()
        } else {
            delegate?.connection(self, didFailWith: TFYSwiftError.protocolError("不支持的协议版本"))
        }
    }
    
    /// 处理握手阶段
    private func handleHandshakeStage() {
        // 确保有足够的数据
        guard buffer.count >= 2 else { return }
        
        let methodCount = Int(buffer[1])
        guard buffer.count >= 2 + methodCount else { return }
        
        // 检查是否支持无认证方法
        let methods = buffer[2..<(2 + methodCount)]
        if methods.contains(0x00) {
            // 发送握手响应
            let response = Data([0x05, 0x00])
            connection.send(content: response, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    self?.delegate?.connection(self!, didFailWith: error)
                    return
                }
                self?.stage = .request
                self?.buffer.removeFirst(2 + methodCount)
            })
        } else {
            // 不支持的认证方法
            let response = Data([0x05, 0xFF])
            connection.send(content: response, completion: .contentProcessed { [weak self] error in
                guard let self = self else { return }
                self.delegate?.connection(self, didFailWith: TFYSwiftError.authenticationError("不支持的认证方法"))
            })
        }
    }
    
    /// 处理认证阶段
    private func handleAuthenticationStage() {
        // 当前实现不需要认证
        stage = .request
    }
    
    /// 处理请求阶段
    private func handleRequestStage() {
        // 确保有足够的数据进行请求解析
        guard buffer.count >= 4 else { return }
        
        let version = buffer[0]
        let command = buffer[1]
        let addressType = buffer[3]
        
        var headerLength = 4
        var host: String?
        var port: UInt16 = 0
        
        // 解析地址
        switch addressType {
        case 0x01: // IPv4
            guard buffer.count >= 10 else { return }
            let ipData = buffer[4...7]
            host = ipData.map { String($0) }.joined(separator: ".")
            port = UInt16(buffer[8]) << 8 | UInt16(buffer[9])
            headerLength = 10
            
        case 0x03: // 域名
            guard buffer.count >= 5 else { return }
            let domainLength = Int(buffer[4])
            guard buffer.count >= 5 + domainLength + 2 else { return }
            host = String(data: buffer[5..<(5 + domainLength)], encoding: .utf8)
            port = UInt16(buffer[5 + domainLength]) << 8 | UInt16(buffer[5 + domainLength + 1])
            headerLength = 5 + domainLength + 2
            
        case 0x04: // IPv6
            guard buffer.count >= 22 else { return }
            let ipData = buffer[4...19]
            host = ipData.map { String(format: "%02x", $0) }.joined(separator: ":")
            port = UInt16(buffer[20]) << 8 | UInt16(buffer[21])
            headerLength = 22
            
        default:
            delegate?.connection(self, didFailWith: TFYSwiftError.protocolError("不支持的地址类型"))
            return
        }
        
        guard let finalHost = host else {
            delegate?.connection(self, didFailWith: TFYSwiftError.protocolError("无效的目标地址"))
            return
        }
        
        // 创建远程连接
        createRemoteConnection(host: finalHost, port: port) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                // 发送成功响应
                let response = Data([0x05, 0x00, 0x00, 0x01]) + Data(repeating: 0, count: 6)
                self.connection.send(content: response, completion: .contentProcessed { error in
                    if let error = error {
                        self.delegate?.connection(self, didFailWith: error)
                        return
                    }
                    self.stage = .relay
                    self.buffer.removeFirst(headerLength)
                    if !self.buffer.isEmpty {
                        self.handleRelayStage()
                    }
                })
            } else {
                // 发送失败响应
                let response = Data([0x05, 0x04, 0x00, 0x01]) + Data(repeating: 0, count: 6)
                self.connection.send(content: response, completion: .contentProcessed { _ in
                    self.delegate?.connection(self, didFailWith: TFYSwiftError.connectionError("无法连接到目标服务器"))
                })
            }
        }
    }
    
    /// 处理转发阶段
    private func handleRelayStage() {
        guard !buffer.isEmpty else { return }
        
        // 加密数据
        guard let crypto = crypto else {
            delegate?.connection(self, didFailWith: TFYSwiftError.encryptionError("加密工具未初始化"))
            return
        }
        
        do {
            // 尝试加密数据
            let encryptedData = try crypto.encrypt(buffer)
            
            // 发送到远程服务器
            remoteConnection?.send(data: encryptedData) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.delegate?.connection(self, didFailWith: error)
                    return
                }
                self.buffer.removeAll()
            }
        } catch {
            // 处理加密错误
            delegate?.connection(self, didFailWith: TFYSwiftError.encryptionError("加密失败: \(error.localizedDescription)"))
        }
    }
    
    /// 处理远程数据
    private func handleRemoteData(_ data: Data) {
        guard let crypto = crypto else {
            delegate?.connection(self, didFailWith: TFYSwiftError.decryptionError("解密工具未初始化"))
            return
        }
        
        do {
            // 尝试解密数据
            let decryptedData = try crypto.decrypt(data)
            
            // 发送到本地连接
            connection.send(content: decryptedData, completion: .contentProcessed { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.delegate?.connection(self, didFailWith: error)
                }
            })
        } catch {
            // 处理解密错误
            delegate?.connection(self, didFailWith: TFYSwiftError.decryptionError("解密失败: \(error.localizedDescription)"))
        }
    }
    
    /// 创建远程连接
    private func createRemoteConnection(host: String, port: UInt16, completion: @escaping (Bool) -> Void) {
        remoteConnection = TFYSwiftConnection(host: config.server,
                                            port: config.serverPort,
                                            password: config.password,
                                            method: config.method)
        
        remoteConnection?.connect { [weak self] error in
            if let error = error {
                self?.delegate?.connection(self!, didFailWith: error)
                completion(false)
                return
            }
            
            completion(true)
        }
        
        // 设置远程连接的数据回调
        remoteConnection?.onData = { [weak self] data in
            guard let self = self else { return }
            self.handleRemoteData(data)
        }
    }
} 
