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
    /// 服务器是否在运行
    private var isRunning: Bool = false
    
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
    /// - Parameter completion: 完成回调，返回成功或失败结果
    public func start(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(TFYSwiftError.systemError("实例已被释放")))
                return
            }
            
            guard !self.isRunning else {
                completion(.failure(TFYSwiftError.systemError("PAC服务器已在运行")))
                return
            }
            
            do {
                // 创建HTTP服务器
                let parameters = NWParameters.tcp
                guard let port = NWEndpoint.Port(rawValue: self.config.globalSettings.pacPort) else {
                    completion(.failure(TFYSwiftError.configurationError("无效的端口号")))
                    return
                }
                
                self.httpServer = try NWListener(using: parameters, on: port)
                
                // 设置监听器状态处理
                self.httpServer?.stateUpdateHandler = { [weak self] state in
                    self?.handleListenerState(state)
                }
                
                // 设置新连接处理
                self.httpServer?.newConnectionHandler = { [weak self] connection in
                    self?.handleNewConnection(connection)
                }
                
                // 启动监听
                self.httpServer?.start(queue: self.queue)
                self.isRunning = true
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// 停止PAC服务器
    /// - Parameter completion: 完成回调，返回成功或失败结果
    public func stop(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(TFYSwiftError.systemError("实例已被释放")))
                return
            }
            
            guard self.isRunning else {
                completion(.failure(TFYSwiftError.systemError("PAC服务器未在运行")))
                return
            }
            
            self.httpServer?.cancel()
            self.httpServer = nil
            self.isRunning = false
            completion(.success(()))
        }
    }
    
    /// 处理新的网络连接
    private func handleNewConnection(_ connection: NWConnection) {
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
    
    /// 处理监听器状态变化
    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            logInfo("PAC服务器就绪")
        case .failed(let error):
            logError("PAC服务器失败: \(error)")
        case .cancelled:
            logInfo("PAC服务器已停止")
        default:
            break
        }
    }
    
    /// 析构函数 - 确保服务器被正确关闭
    deinit {
        stop { _ in }
    }
    
    /// PAC 模式枚举
    public enum PACMode {
        case auto           // 自动模式
        case global        // 全局模式
        case manual        // 手动模式
    }
    
    /// 更新 PAC 文件内容
    /// - Parameters:
    ///   - rules: 代理规则列表
    ///   - mode: PAC 模式
    ///   - completion: 完成回调
    public func updatePACFile(rules: [String], mode: PACMode, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            do {
                // 生成新的 PAC 内容
                let newContent = try self.generatePACContent(rules: rules, mode: mode)
                
                // 更新 PAC 内容
                self.pacContent = newContent
                
                // 如果服务器正在运行，重启服务器以应用新配置
                if self.isRunning {
                    try self.restartServer()
                }
                
                completion(.success(()))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// 生成 PAC 文件内容
    private func generatePACContent(rules: [String], mode: PACMode) throws -> String {
        // PAC 文件模板
        let template = """
        function FindProxyForURL(url, host) {
            // 代理服务器地址
            var proxy = "SOCKS5 \(config.globalSettings.localAddress):\(config.globalSettings.socksPort); DIRECT";
            
            // 直连域名列表
            var directDomains = \(getDirectDomainsJSON());
            
            // 代理域名列表
            var proxyDomains = \(getProxyDomainsJSON(rules));
            
            // 判断是否是 IP 地址
            if (isPlainHostName(host) || isInNet(host, "10.0.0.0", "255.0.0.0") ||
                isInNet(host, "172.16.0.0", "255.240.0.0") ||
                isInNet(host, "192.168.0.0", "255.255.0.0") ||
                isInNet(host, "127.0.0.0", "255.255.255.0")) {
                return "DIRECT";
            }
            
            // 根据模式返回代理设置
            switch ("\(mode)") {
                case "global":
                    return proxy;
                case "manual":
                    // 检查是否在直连列表中
                    for (var i = 0; i < directDomains.length; i++) {
                        if (dnsDomainIs(host, directDomains[i])) {
                            return "DIRECT";
                        }
                    }
                    // 检查是否在代理列表中
                    for (var i = 0; i < proxyDomains.length; i++) {
                        if (dnsDomainIs(host, proxyDomains[i])) {
                            return proxy;
                        }
                    }
                    return "DIRECT";
                default:
                    // 自动模式
                    return proxy;
            }
        }
        """
        
        return template
    }
    
    /// 获取直连域名列表的 JSON 字符串
    private func getDirectDomainsJSON() -> String {
        let domains = [
            "localhost",
            "127.0.0.1",
            "*.local",
            "*.cn"
        ]
        
        return JSONStringify(domains)
    }
    
    /// 获取代理域名列表的 JSON 字符串
    private func getProxyDomainsJSON(_ rules: [String]) -> String {
        return JSONStringify(rules)
    }
    
    /// 将数组转换为 JSON 字符串
    private func JSONStringify(_ array: [String]) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: [])
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        } catch {
            logError("JSON序列化失败: \(error)")
        }
        return "[]"
    }
    
    /// 重启 PAC 服务器
    private func restartServer() throws {
        stop { _ in }
        try startServer()
    }
    
    /// 启动 PAC 服务器
    private func startServer() throws {
        // 创建 TCP 监听器
        let parameters = NWParameters.tcp
        
        // 设置本地端点
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(config.globalSettings.localAddress),
            port: NWEndpoint.Port(integerLiteral: UInt16(config.globalSettings.pacPort))
        )
        
        // 创建监听器
        httpServer = try NWListener(using: parameters, on: endpoint)
        
        // 设置连接处理
        httpServer?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
        
        // 启动监听器
        httpServer?.start(queue: queue)
    }
}
