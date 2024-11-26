//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation
import Network

/// SSR管理器类 - 负责协调所有SSR相关组件的工作
public class TFYSwiftSSRManager {
    // MARK: - 组件属性
    private var configManager: TFYSwiftConfigManager?
    private var proxyServer: TFYSwiftProxyServer?
    private var pacManager: TFYSwiftPACManager?
    private var ruleManager: TFYSwiftRuleManager?
    private var trafficManager: TFYSwiftTrafficManager
    private var dnsResolver: TFYSwiftDNSResolver
    private var subscriptionManager: TFYSwiftSubscriptionManager?
    private var performanceMonitor: TFYSwiftPerformanceMonitor
    private var updater: TFYSwiftUpdater
    private let logger = TFYSwiftLogger.shared
    
    // MARK: - 状态属性
    private var isRunning: Bool = false
    private let queue = DispatchQueue(label: "com.tfyswift.ssrmanager")
    
    // MARK: - 单例
    public static let shared: TFYSwiftSSRManager = {
        let instance = TFYSwiftSSRManager()
        return instance
    }()
    
    // MARK: - 初始化
    private init() {
        trafficManager = TFYSwiftTrafficManager()
        dnsResolver = TFYSwiftDNSResolver()
        performanceMonitor = TFYSwiftPerformanceMonitor()
        updater = TFYSwiftUpdater()
        
        setupComponents()
    }
    
    // MARK: - 组件设置
    private func setupComponents() {
        // 初始化配置管理器
        configManager = TFYSwiftConfigManager()
        
        guard let config = configManager?.currentConfig else {
            logger.log("无法加载配置", level: .error)
            return
        }
        
        // 初始化其他组件
        proxyServer = TFYSwiftProxyServer(config: config, configManager: configManager!)
        pacManager = TFYSwiftPACManager(config: config)
        ruleManager = TFYSwiftRuleManager()
        subscriptionManager = TFYSwiftSubscriptionManager(configManager: configManager!)
        
        // 设置流量统计回调
        trafficManager.statsHandler = { [weak self] stats in
            self?.handleTrafficUpdate(stats)
        }
        
        // 设置性能监控回调
        performanceMonitor.metricsHandler = { [weak self] metrics in
            self?.handlePerformanceUpdate(metrics)
        }
    }
    
    // MARK: - 公共方法
    
    /// 启动SSR服务
    /// - Parameter completion: 完成回调，返回成功或失败结果
    public func start(completion: @escaping (Result<Void, Error>) -> Void) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else {
                completion(.failure(TFYSwiftError.systemError("实例已被释放")))
                return
            }
            
            guard !self.isRunning else {
                completion(.failure(TFYSwiftError.systemError("服务已在运行中")))
                return
            }
            
            guard let proxyServer = self.proxyServer,
                  let pacManager = self.pacManager else {
                completion(.failure(TFYSwiftError.systemError("组件未正确初始化")))
                return
            }
            
            // 启动代理服务器
            proxyServer.start { result in
                switch result {
                case .success:
                    // 启动PAC服务器
                    pacManager.start { result in
                        switch result {
                        case .success:
                            self.isRunning = true
                            self.performanceMonitor.startMonitoring()
                            completion(.success(()))
                        case .failure(let error):
                            // 回滚代理服务器
                            proxyServer.stop { _ in
                                completion(.failure(error))
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        queue.async(execute: workItem)
    }
    
    /// 停止SSR服务
    /// - Parameter completion: 完成回调
    public func stop(completion: @escaping (Result<Void, Error>) -> Void) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else {
                completion(.failure(TFYSwiftError.systemError("实例已被释放")))
                return
            }
            
            guard self.isRunning else {
                completion(.failure(TFYSwiftError.systemError("服务未在运行")))
                return
            }
            
            guard let proxyServer = self.proxyServer,
                  let pacManager = self.pacManager else {
                completion(.failure(TFYSwiftError.systemError("组件未正确初始化")))
                return
            }
            
            // 停止所有服务
            proxyServer.stop { result in
                switch result {
                case .success:
                    pacManager.stop { result in
                        switch result {
                        case .success:
                            self.performanceMonitor.stopMonitoring()
                            self.isRunning = false
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        queue.async(execute: workItem)
    }
    
    /// 更新服务器配置
    /// - Parameters:
    ///   - config: 新的服务器配置
    ///   - completion: 完成回调
    public func updateServerConfig(_ config: ServerConfig, completion: @escaping (Result<Void, Error>) -> Void) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  let configManager = self.configManager else {
                completion(.failure(TFYSwiftError.systemError("配置管理器未初始化")))
                return
            }
            
            configManager.updateServerConfig(config) { result in
                switch result {
                case .success:
                    // 如果服务正在运行，需要重启服务
                    if self.isRunning {
                        self.restart(completion: completion)
                    } else {
                        completion(.success(()))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        queue.async(execute: workItem)
    }
    
    /// 更新订阅
    /// - Parameters:
    ///   - url: 订阅地址
    ///   - completion: 完成回调
    public func updateSubscription(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  let subscriptionManager = self.subscriptionManager else {
                completion(.failure(TFYSwiftError.systemError("订阅管理器未初始化")))
                return
            }
            
            subscriptionManager.updateSubscription(url: url) { [weak self] result in
                switch result {
                case .success(let configs):
                    self?.configManager?.updateServerConfigs(configs, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        queue.async(execute: workItem)
    }
    
    // MARK: - 私有方法
    
    /// 重启服务
    private func restart(completion: @escaping (Result<Void, Error>) -> Void) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.stop { result in
                switch result {
                case .success:
                    self?.start(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        queue.async(execute: workItem)
    }
    
    /// 处理流量统计更新
    private func handleTrafficUpdate(_ stats: TFYSwiftTrafficManager.TrafficStats) {
        logger.log("流量统计更新: \(stats.description)", level: .info)
    }
    
    /// 处理性能指标更新
    private func handlePerformanceUpdate(_ metrics: TFYSwiftPerformanceMonitor.PerformanceMetrics) {
        logger.log("性能指标更新: CPU使用率: \(metrics.cpuUsage * 100)%, 内存使用: \(metrics.memoryUsage) bytes", level: .info)
    }
}

// MARK: - 便捷访问方法
public extension TFYSwiftSSRManager {
    /// 获取当前配置
    var currentConfig: TFYSwiftConfig? {
        return configManager?.currentConfig
    }
    
    /// 获取当前服务器配置
    var currentServer: ServerConfig? {
        return configManager?.currentConfig.currentServer
    }
    
    /// 获取当前状态信息
    var statusInfo: String {
        return queue.sync {
            """
            运行状态: \(isRunning ? "运行中" : "已停止")
            活动连接: \(proxyServer?.connectionCount ?? 0)
            流量统计: \(trafficManager.getStats().description)
            """
        }
    }
    
    /// 运行网络诊断
    func runDiagnostics(completion: @escaping (String) -> Void) {
        guard let currentServer = self.currentServer else {
            completion("错误: 未配置服务器")
            return
        }
        
        let diagnostics = TFYSwiftNetworkDiagnostics(
            host: currentServer.serverHost,
            port: currentServer.serverPort
        )
        
        diagnostics.runDiagnostics { result in
            completion("""
                诊断报告:
                服务器: \(currentServer.serverHost):\(currentServer.serverPort)
                \(result.description)
                """)
        }
    }
    
    /// 导出日志
    func exportLogs() -> String {
        return logger.exportLogs()
    }
    
    /// 清除日志
    func clearLogs() {
        logger.clearLogs()
    }
    
    /// 检查更新
    func checkForUpdates(completion: @escaping (Result<UpdateInfo?, Error>) -> Void) {
        updater.checkForUpdates(completion: completion)
    }
    
    /// 对指定服务器运行网络诊断
    func runDiagnostics(host: String, port: UInt16, completion: @escaping (String) -> Void) {
        let diagnostics = TFYSwiftNetworkDiagnostics(host: host, port: port)
        diagnostics.runDiagnostics { result in
            completion("""
                诊断报告:
                服务器: \(host):\(port)
                \(result.description)
                """)
        }
    }
}


/**
 // 启动 SSR 服务
 TFYSwiftSSRManager.shared.start { result in
     switch result {
     case .success:
         print("服务启动成功")
     case .failure(let error):
         print("启动失败: \(error)")
     }
 }

 // 更新订阅
 if let subscriptionURL = URL(string: "https://example.com/subscription") {
     TFYSwiftSSRManager.shared.updateSubscription(url: subscriptionURL) { result in
         switch result {
         case .success:
             print("订阅更新成功")
         case .failure(let error):
             print("更新失败: \(error)")
         }
     }
 }

 // 获取状态信息
 print(TFYSwiftSSRManager.shared.statusInfo)

 // 运行诊断
 TFYSwiftSSRManager.shared.runDiagnostics { report in
     print(report)
 }
 */
