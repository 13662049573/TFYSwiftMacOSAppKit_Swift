//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// PAC代理自动配置管理器类 - 负责处理PAC文件的分发和管理
public class TFYSwiftPACManager {
    /// HTTP服务器监听器
    private var httpServer: NWListener?
    /// 用于同步PAC操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.pac")
    /// 全局配置对象
    private let config: TFYSwiftConfig
    /// PAC文件内容
    private var pacContent: String
    
    /// 初始化PAC管理器
    /// - Parameter config: 全局配置对象
    init(config: TFYSwiftConfig) {
        self.config = config
        self.pacContent = ""
        loadDefaultPAC()
    }
    
    /// 加载默认PAC文件
    private func loadDefaultPAC() {
        if let path = Bundle.main.path(forResource: "default", ofType: "pac"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            pacContent = content
        }
    }
    
    /// 启动PAC服务器
    /// - Throws: 启动失败时抛出错误
    func start() throws {
        let port = NWEndpoint.Port(integerLiteral: UInt16(config.globalSettings.pacPort))
        let parameters = NWParameters.tcp
        
        // 创建并配置HTTP服务器
        httpServer = try NWListener(using: parameters, on: port)
        httpServer?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                logInfo("PAC服务器已启动，端口: \(self?.config.globalSettings.pacPort ?? 0)")
            case .failed(let error):
                logError("PAC服务器启动失败: \(error)")
            case .cancelled:
                logInfo("PAC服务器已停止")
            default:
                break
            }
        }
        
        // 设置新连接处理器
        httpServer?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }
        
        // 在指定队列上启动服务器
        httpServer?.start(queue: queue)
    }
    
    /// 停止PAC服务器
    func stop() {
        httpServer?.cancel()
        httpServer = nil
    }
    
    /// 处理新的网络连接
    /// - Parameter connection: 网络连接对象
    private func handleConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.handleRequest(connection)
            case .failed(let error):
                logError("连接失败: \(error)")
                connection.cancel()
            case .cancelled:
                break
            default:
                break
            }
        }
        
        connection.start(queue: queue)
    }
    
    /// 处理HTTP请求
    /// - Parameter connection: 网络连接对象
    private func handleRequest(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                logError("接收请求失败: \(error)")
                connection.cancel()
                return
            }
            
            // 检查是否为GET请求
            if let content = content,
               let request = String(data: content, encoding: .utf8),
               request.contains("GET") {
                self.sendPACResponse(connection)
            } else {
                connection.cancel()
            }
        }
    }
    
    /// 发送PAC文件响应
    /// - Parameter connection: 网络连接对象
    private func sendPACResponse(_ connection: NWConnection) {
        // 构建HTTP响应
        let response = """
        HTTP/1.1 200 OK\r
        Content-Type: application/x-ns-proxy-autoconfig\r
        Content-Length: \(pacContent.utf8.count)\r
        Connection: close\r
        \r
        \(pacContent)
        """
        
        // 发送响应
        connection.send(content: response.data(using: .utf8), completion: .contentProcessed { error in
            if let error = error {
                logError("发送PAC响应失败: \(error)")
            }
            connection.cancel()
        })
    }
    
    /// 析构函数 - 确保服务器被正确关闭
    deinit {
        stop()
    }
}
