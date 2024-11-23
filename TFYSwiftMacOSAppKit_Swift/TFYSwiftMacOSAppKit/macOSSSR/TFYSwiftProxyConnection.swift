//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// 代理连接委托协议 - 用于处理连接状态回调
protocol TFYSwiftProxyConnectionDelegate: AnyObject {
    /// 连接完成回调
    func connectionDidComplete(_ connection: TFYSwiftProxyConnection)
    /// 连接失败回调
    func connection(_ connection: TFYSwiftProxyConnection, didFailWith error: Error)
}

/// 代理连接类 - 负责管理代理服务器的网络连接
public class TFYSwiftProxyConnection {
    // MARK: - 属性
    
    /// 本地客户端连接
    private let connection: NWConnection
    
    /// 远程目标服务器连接
    private var remoteConnection: TFYSwiftConnection?
    
    /// 代理配置信息
    private let config: TFYSwiftConfig
    
    /// 代理连接委托对象
    private weak var delegate: TFYSwiftProxyConnectionDelegate?
    
    /// 数据加密解密工具
    private var crypto: TFYSwiftCrypto?
    
    /// 数据临时缓冲区
    private var buffer = Data()
    
    /// 当前连接状态
    private var state: ConnectionState = .initial {
        didSet {
            updateConnectionState(state)
        }
    }
    
    /// 操作队列，用于同步连接操作
    private let queue = DispatchQueue(label: "com.tfyswift.connection")
    
    /// 连接状态监控相关属性
    private var connectionMonitor: Timer?
    private var lastActivityTime: Date = Date()
    private let connectionTimeout: TimeInterval = 300 // 5分钟超时
    
    // MARK: - 枚举
    
    /// 连接状态枚举
    private enum ConnectionState {
        case initial        // 初始状态
        case handshake     // 握手阶段
        case request       // 请求阶段
        case connecting    // 连接中
        case connected     // 已连接
        case relay         // 数据转发状态
        case error(Error)  // 错误状态
        case cancelled     // 已取消
    }
    
    // MARK: - 初始化方法
    
    /// 初始化代理连接
    /// - Parameters:
    ///   - connection: 网络连接对象
    ///   - config: 代理配置信息
    ///   - delegate: 代理连接委托
    init(connection: NWConnection, config: TFYSwiftConfig, delegate: TFYSwiftProxyConnectionDelegate?) {
        self.connection = connection
        self.config = config
        self.delegate = delegate
        
        // 初始化加密工具
        if let currentServer = config.currentServer {
            do {
                self.crypto = try TFYSwiftCrypto(password: currentServer.password,
                                               method: currentServer.method)
            } catch {
                logError("初始化加密工具失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 公共方法
    
    /// 启动代理连接
    func start() {
        state = .handshake
        startConnectionMonitor()
        
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state)
        }
        
        connection.start(queue: queue)
    }
    
    /// 取消代理连接
    func cancel() {
        state = .cancelled
        
        // 取消本地连接
        connection.cancel()
        
        // 取消远程连接
        remoteConnection?.disconnect()
        remoteConnection = nil
        
        // 清理缓冲区
        buffer.removeAll()
        
        // 通知委托
        delegate?.connectionDidComplete(self)
        
        print("代理连接已取消")
    }
    
    /// 断开连接
    func disconnect() {
        cancel()  // 复用取消连接的逻辑
    }
    
    // MARK: - 私有方法
    
    /// 设置连接配置
    private func setupConnection() {
        // 设置状态处理器
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .ready:
                self.handleConnectionReady()
            case .failed(let error):
                self.handleConnectionError(error)
            case .cancelled:
                self.handleConnectionCancelled()
            default:
                break
            }
        }
        
        // 开始接收数据
        receiveData()
    }
    
    /// 处理连接就绪状态
    private func handleConnectionReady() {
        state = .handshake
        print("连接就绪，开始握手")
        handleHandshakeStage()
    }
    
    /// 处理连接错误
    private func handleConnectionError(_ error: Error) {
        state = .error(error)
        print("连接错误: \(error.localizedDescription)")
        delegate?.connection(self, didFailWith: error)
    }
    
    /// 处理连接取消
    private func handleConnectionCancelled() {
        if case .cancelled = state {
            print("连接已被取消")
            cancel()
        }
    }
    
    /// 接收据
    private func receiveData() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleConnectionError(error)
                return
            }
            
            if let data = content {
                print("接收到 \(data.count) 字节数据")
                self.handleReceivedData(data)
            }
            
            if isComplete {
                self.cancel()
            } else {
                self.receiveData()
            }
        }
    }
    
    /// 处理接收到的数据
    private func handleReceivedData(_ data: Data) {
        buffer.append(data)
        
        switch state {
        case .handshake:
            handleHandshakeStage()
        case .connected:
            handleRelayStage()
        default:
            break
        }
    }
    
    /// 处理握手阶段
    private func handleHandshakeStage() {
        // 确保有足够的数据
        guard buffer.count >= 2 else { return }
        
        let methodCount = Int(buffer[1])
        guard buffer.count >= 2 + methodCount else { return }
        
        // 查是否支持无认证方法
        let methods = buffer[2..<(2 + methodCount)]
        if methods.contains(0x00) {
            // 发送握手响应
            let response = Data([0x05, 0x00])
            connection.send(content: response, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    self?.delegate?.connection(self!, didFailWith: error)
                    return
                }
                self?.state = .request
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
        state = .request
    }
    
    /// 处理请求阶段
    private func handleRequestStage() {
        // 确保有足够的数据进行请求解析
        guard buffer.count >= 4 else { return }
        
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
                    self.state = .relay
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
        
        // 密数据
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
        remoteConnection = TFYSwiftConnection(
            host: host,
            port: port
        )
        
        remoteConnection?.onData = { [weak self] data in
            guard let self = self else { return }
            self.handleRemoteData(data)
        }
        
        remoteConnection?.connect { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.connection(self, didFailWith: error)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // 添加连接监控
    private func startConnectionMonitor() {
        connectionMonitor = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkConnectionTimeout()
        }
    }
    
    private func checkConnectionTimeout() {
        if case .connected = state {
            let inactiveTime = Date().timeIntervalSince(lastActivityTime)
            if inactiveTime > connectionTimeout {
                logWarning("Connection timed out after \(Int(inactiveTime))s of inactivity")
                cancel()
            }
        }
    }
    
    // 改进数据处理
    private func handleData(_ data: Data) {
        lastActivityTime = Date()
        
        switch state {
        case .handshake:
            handleHandshakeStage()
        case .connecting:
            handleRequestStage()
        case .connected:
            handleRelayStage()
        case .request:
            handleRequestStage()
        case .relay:
            handleRelayStage()
        case .error(_):
            logError("Connection in error state")
        case .cancelled:
            logInfo("Connection cancelled")
        case .initial:
            logError("Received data in initial state")
        }
    }
    
    private func updateConnectionState(_ state: ConnectionState) {
        switch state {
        case .initial:
            logInfo("Connection initialized")
        case .handshake:
            logInfo("Connection handshaking")
        case .request:
            logInfo("Processing connection request")
        case .connecting:
            logInfo("Connection connecting")
        case .connected:
            logInfo("Connection established")
        case .relay:
            logInfo("Relaying data")
        case .error(let error):
            logError("Connection error: \(error.localizedDescription)")
            delegate?.connection(self, didFailWith: error)
        case .cancelled:
            logInfo("Connection cancelled")
            delegate?.connectionDidComplete(self)
        }
    }
    
    private func startRelay() {
        // 开始从客户端接收数据
        receiveFromClient()
        // 开始从目标服务器接收数据
        receiveFromTarget()
    }
    
    private func receiveFromClient() {
        if case .relay = state {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.handleConnectionError(error)
                    return
                }
                
                if let data = content {
                    self.handleClientData(data)
                }
                
                if !isComplete, case .relay = self.state {
                    self.receiveFromClient()
                }
            }
        }
    }
    
    private func receiveFromTarget() {
        if case .relay = state, let remoteConnection = self.remoteConnection {
            remoteConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, context, isComplete, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.handleConnectionError(error)
                    return
                }
                
                if let data = content {
                    self.handleTargetData(data)
                }
                
                if !isComplete, case .relay = self.state {
                    self.receiveFromTarget()
                }
            }
        }
    }
    
    private func handleClientData(_ data: Data) {
        guard let remoteConnection = self.remoteConnection else { return }
        
        // 如果需要，这里可以添加加密处理
        if let crypto = self.crypto {
            do {
                let encryptedData = try crypto.encrypt(data)
                remoteConnection.send(data: encryptedData) { [weak self] error in
                    if let error = error {
                        self?.handleConnectionError(error)
                    }
                }
            } catch {
                handleConnectionError(error)
            }
        } else {
            remoteConnection.send(data: data) { [weak self] error in
                if let error = error {
                    self?.handleConnectionError(error)
                }
            }
        }
    }
    
    private func handleTargetData(_ data: Data) {
        // 如果需要，这里可以添加解密处理
        if let crypto = self.crypto {
            do {
                let decryptedData = try crypto.decrypt(data)
                connection.send(content: decryptedData, completion: .contentProcessed { [weak self] error in
                    if let error = error {
                        self?.handleConnectionError(error)
                    }
                })
            } catch {
                handleConnectionError(error)
            }
        } else {
            connection.send(content: data, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    self?.handleConnectionError(error)
                }
            })
        }
    }
    
    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            setupConnection()
        case .failed(let error):
            handleConnectionError(error)
        case .cancelled:
            cancel()
        default:
            break
        }
    }
}


