//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

/// SSR管理器类 - 负责协调和管理所有SSR相关组件
public class TFYSwiftSSRManager {
    /// 配置管理器实例
    private let configManager: TFYSwiftConfigManager
    /// 代理服务器实例
    private let proxyServer: TFYSwiftProxyServer
    /// 订阅管理器实例
    private let subscriptionManager: TFYSwiftSubscriptionManager
    /// PAC管理器实例
    private let pacManager: TFYSwiftPACManager
    /// 流量管理器实例
    private let trafficManager: TFYSwiftTrafficManager
    /// 性能监控器实例
    private let performanceMonitor: TFYSwiftPerformanceMonitor
    /// 规则管理器实例
    private let ruleManager: TFYSwiftRuleManager
    
    /// 服务运行状态标志
    private var isRunning = false
    
    /// 初始化SSR管理器
    /// - Throws: 初始化失败时抛出错误
    init() throws {
        // 初始化配置管理器
        self.configManager = try TFYSwiftConfigManager()
        
        // 初始化其他组件
        let config = configManager.getConfig()
        self.proxyServer = TFYSwiftProxyServer(config: config)
        self.subscriptionManager = TFYSwiftSubscriptionManager(configManager: configManager)
        self.pacManager = TFYSwiftPACManager(config: config)
        self.trafficManager = TFYSwiftTrafficManager { stats in
            // 处理流量统计更新
            logInfo("流量统计: \(stats.description)")
        }
        self.performanceMonitor = TFYSwiftPerformanceMonitor()
        self.ruleManager = TFYSwiftRuleManager()
        
        // 加载规则
        if let rulesURL = Bundle.main.url(forResource: "rules", withExtension: "txt") {
            try ruleManager.loadRules(from: rulesURL)
        }
    }
    
    /// 启动SSR服务
    /// - Throws: 启动失败时抛出错误
    func start() throws {
        guard !isRunning else { return }
        
        // 启动性能监控
        performanceMonitor.startMonitoring()
        
        // 启动PAC服务器
        try pacManager.start()
        
        // 启动代理服务器
        try proxyServer.start()
        
        isRunning = true
        logInfo("SSR服务已启动")
    }
    
    /// 停止SSR服务
    func stop() {
        guard isRunning else { return }
        
        performanceMonitor.stopMonitoring()
        pacManager.stop()
        proxyServer.stop()
        
        isRunning = false
        logInfo("SSR服务已停止")
    }
    
    /// 更新订阅
    /// - Parameter url: 订阅地址URL
    func updateSubscription(_ url: URL) {
        subscriptionManager.updateSubscription(url) { [weak self] result in
            switch result {
            case .success(let configs):
                do {
                    let currentConfig = self?.configManager.getConfig()
                    currentConfig?.serverConfigs = configs
                    try self?.configManager.updateConfig(currentConfig!)
                    logInfo("订阅更新成功")
                } catch {
                    logError("更新配置失败: \(error)")
                }
            case .failure(let error):
                logError("更新订阅失败: \(error)")
            }
        }
    }
    
    /// 切换服务器
    /// - Parameter index: 服务器索引
    /// - Throws: 切换失败时抛出错误
    func switchServer(_ index: Int) throws {
        let config = configManager.getConfig()
        guard index >= 0 && index < config.serverConfigs.count else {
            throw TFYSwiftError.configurationError("无效的服务器索引")
        }
        
        let wasRunning = isRunning
        if wasRunning {
            stop()
        }
        
        config.selectedServer = index
        try configManager.updateConfig(config)
        
        if wasRunning {
            try start()
        }
        
        logInfo("已切换到服务器 \(index)")
    }
    
    /// 获取性能报告
    /// - Returns: 性能报告字符串
    func getPerformanceReport() -> String {
        return performanceMonitor.generatePerformanceReport()
    }
    
    /// 获取流量统计
    /// - Returns: 流量统计数据
    func getTrafficStats() -> TFYSwiftTrafficManager.TrafficStats {
        return trafficManager.getStats()
    }
}

/// 使用示例
/**
 // 初始化并启动SSR服务
 do {
     let ssrManager = try TFYSwiftSSRManager()
     
     // 启动服务
     try ssrManager.start()
     
     // 更新订阅
     if let subscriptionURL = URL(string: "https://example.com/subscription") {
         ssrManager.updateSubscription(subscriptionURL)
     }
     
     // 切换服务器
     try ssrManager.switchServer(1)
     
     // 获取性能报告
     let performanceReport = ssrManager.getPerformanceReport()
     print(performanceReport)
     
     // 获取流量统计
     let trafficStats = ssrManager.getTrafficStats()
     print(trafficStats.description)
     
     // 停止服务
     ssrManager.stop()
 } catch {
     logError("SSR服务错误: \(error)")
 }
 */
