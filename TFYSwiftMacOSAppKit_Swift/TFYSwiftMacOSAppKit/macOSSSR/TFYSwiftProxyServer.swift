//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// 代理服务器类 - 负责管理代理服务和连接
public class TFYSwiftProxyServer {
    
    /// 代理服务器状态枚举
    enum ProxyState {
        case stopped    // 已停止
        case starting   // 启动中
        case running    // 运行中
        case error(Error) // 错误状态
    }
    
    /// 网络监听器
    private var listener: NWListener?
    /// 用于同步操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.proxyserver")
    /// 存储活动连接的字典，键为连接ID，值为代理连接对象
    private var connections: [UUID: TFYSwiftProxyConnection] = [:]
    /// 全局配置对象
    private let config: TFYSwiftConfig
    /// 当前服务器状态
    private var state: ProxyState = .stopped
    /// 配置管理对象
    private let configManager: TFYSwiftConfigManager
    /// 服务器是否在运行
    private var isRunning: Bool = false
    
    /// 初始化代理服务器
    /// - Parameter config: 全局配置对象
    init(config: TFYSwiftConfig, configManager: TFYSwiftConfigManager) {
        self.config = config
        self.configManager = configManager
    }
    
    /// 启动代理服务器
    /// - Parameter completion: 完成回调
    public func start(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            guard !self.isRunning else {
                completion(.success(()))
                return
            }
            
            do {
                // 创建监听器参数
                let parameters = NWParameters.tcp
                
                // 设置本地端点
                let localEndpoint = NWEndpoint.hostPort(
                    host: NWEndpoint.Host(self.config.globalSettings.localAddress),
                    port: NWEndpoint.Port(integerLiteral: UInt16(self.config.globalSettings.socksPort))
                )
                
                // 创建监听器
                self.listener = try NWListener(using: parameters, on: localEndpoint)
                
                // 设置监听器状态处理
                self.listener?.stateUpdateHandler = { [weak self] state in
                    self?.handleListenerState(state)
                }
                
                // 设置新连接处理
                self.listener?.newConnectionHandler = { [weak self] connection in
                    self?.handleNewConnection(connection)
                }
                
                // 启动监听
                self.listener?.start(queue: self.queue)
                self.isRunning = true
                
                logInfo("代理服务器已启动，监听地址: \(self.config.globalSettings.localAddress):\(self.config.globalSettings.socksPort)")
                completion(.success(()))
                
            } catch {
                self.state = .error(error)
                logError("启动代理服务器失败: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    /// 停止代理服务器
    public func stop(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(TFYSwiftError.systemError("实例已被释放")))
                return
            }
            
            guard self.isRunning else {
                completion(.failure(TFYSwiftError.systemError("服务器未在运行")))
                return
            }
            
            self.listener?.cancel()
            self.listener = nil
            self.isRunning = false
            self.state = .stopped
            
            // 断开所有现有连接
            self.connections.values.forEach { $0.disconnect() }
            self.connections.removeAll()
            
            completion(.success(()))
        }
    }
    
    /// 处理监听器状态变化
    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            self.state = .running
            logInfo("监听器就绪")
            
        case .failed(let error):
            self.state = .error(error)
            logError("监听器失败: \(error)")
            
        case .cancelled:
            self.state = .stopped
            logInfo("监听器已停止")
            
        default:
            break
        }
    }
    
    /// 处理新连接
    private func handleNewConnection(_ connection: NWConnection) {
        // 创建连接ID
        let connectionId = UUID()
        
        // 创建代理连接
        let proxyConnection = TFYSwiftProxyConnection(
            connection: connection,
            config: self.config,
            delegate: self
        )
        
        // 存储连接
        connections[connectionId] = proxyConnection
        
        // 开始处理连接
        proxyConnection.start()
        
        logInfo("新连接已建立: \(connectionId)")
    }
    
    /// 移除指定ID的连接
    private func removeConnection(withId id: UUID) {
        queue.async {
            self.connections.removeValue(forKey: id)
        }
    }
    
    /// 获取当前服务器状态
    var currentState: ProxyState {
        return queue.sync { state }
    }
    
    /// 获取当前活动连接数量
    var connectionCount: Int {
        return queue.sync { connections.count }
    }
    
    /// 析构函数 - 确保服务器被正确停止
    deinit {
        stop { _ in }
    }
    
    /// 获取连接统计信息
    public func getConnectionStats() -> ConnectionStats {
        return queue.sync {
            ConnectionStats(
                activeConnections: connections.count,
                totalConnections: totalConnectionCount,
                failedConnections: failedConnectionCount
            )
        }
    }
    
    /// 连接统计信息结构体
    public struct ConnectionStats {
        public let activeConnections: Int
        public let totalConnections: Int
        public let failedConnections: Int
        
        public var description: String {
            return """
            活动连接数: \(activeConnections)
            总连接数: \(totalConnections)
            失败连接数: \(failedConnections)
            """
        }
    }
}

// MARK: - TFYSwiftProxyConnectionDelegate
extension TFYSwiftProxyServer: TFYSwiftProxyConnectionDelegate {
    func connectionDidComplete(_ connection: TFYSwiftProxyConnection) {
        queue.async {
            if let connectionId = self.connections.first(where: { $0.value === connection })?.key {
                self.removeConnection(withId: connectionId)
                logInfo("连接已完成并移除")
            }
        }
    }
    
    func connection(_ connection: TFYSwiftProxyConnection, didFailWith error: Error) {
        queue.async {
            if let connectionId = self.connections.first(where: { $0.value === connection })?.key {
                self.removeConnection(withId: connectionId)
                logError("连接失败并移除: \(error.localizedDescription)")
            }
        }
    }
}
