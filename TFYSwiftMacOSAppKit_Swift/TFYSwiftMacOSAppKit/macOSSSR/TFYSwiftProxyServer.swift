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
    
    /// 初始化代理服务器
    /// - Parameter config: 全局配置对象
    init(config: TFYSwiftConfig) {
        self.config = config
    }
    
    /// 启动代理服务器
    /// - Throws: 启动失败时抛出错误
    func start() throws {
        if case .stopped = state {
            state = .starting
            
            let port = NWEndpoint.Port(integerLiteral: config.globalSettings.socksPort)
            let parameters = NWParameters.tcp
            
            // 创建网络监听器
            listener = try NWListener(using: parameters, on: port)
            
            // 设置状态更新处理器
            listener?.stateUpdateHandler = { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .ready:
                    self.state = .running
                    logInfo("代理服务器已启动，端口: \(self.config.globalSettings.socksPort)")
                case .failed(let error):
                    self.state = .error(error)
                    logError("代理服务器启动失败: \(error)")
                case .cancelled:
                    self.state = .stopped
                    logInfo("代理服务器已停止")
                default:
                    break
                }
            }
            
            // 设置新连接处理器
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            
            // 在指定队列上启动监听器
            listener?.start(queue: queue)
        }
    }
    
    /// 停止代理服务器
    func stop() {
        listener?.cancel()
        listener = nil
        
        queue.async {
            // 断开所有活动连接
            for connection in self.connections.values {
                connection.disconnect()
            }
            self.connections.removeAll()
        }
        
        state = .stopped
    }
    
    /// 处理新的网络连接
    /// - Parameter connection: 新建立的网络连接
    private func handleNewConnection(_ connection: NWConnection) {
        let id = UUID()
        let proxyConnection = TFYSwiftProxyConnection(connection: connection, config: config, delegate: self)
        
        queue.async {
            self.connections[id] = proxyConnection
            proxyConnection.start()
        }
    }
    
    /// 移除指定ID的连接
    /// - Parameter id: 要移除的连接ID
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
        stop()
    }
}

// MARK: - TFYSwiftProxyConnectionDelegate
extension TFYSwiftProxyServer: TFYSwiftProxyConnectionDelegate {
    /// 连接完成的回调处理
    func connectionDidComplete(_ connection: TFYSwiftProxyConnection) {
        queue.async {
            if let connectionId = self.connections.first(where: { $0.value === connection })?.key {
                self.removeConnection(withId: connectionId)
                logInfo("连接已完成并移除")
            }
        }
    }
    
    /// 连接失败的回调处理
    func connection(_ connection: TFYSwiftProxyConnection, didFailWith error: Error) {
        queue.async {
            if let connectionId = self.connections.first(where: { $0.value === connection })?.key {
                self.removeConnection(withId: connectionId)
                logError("连接失败并移除: \(error.localizedDescription)")
            }
        }
    }
}
