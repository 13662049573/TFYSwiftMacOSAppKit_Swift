//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// 网络诊断工具类 - 用于检测网络连接状态和性能
public class TFYSwiftNetworkDiagnostics {
    // MARK: - 类型定义
    /// 诊断结果结构体 - 存储单次网络诊断的结果
    struct DiagnosticResult {
        let timestamp: Date           // 诊断完成时间戳
        let isSuccess: Bool           // 诊断是否成功
        let latency: TimeInterval?    // 网络延迟（如果成功）
        let error: Error?            // 错误信息（如果失败）
        
        /// 诊断结果的文字描述
        var description: String {
            let status = isSuccess ? "成功" : "失败"
            let latencyStr = latency.map { String(format: "%.2fms", $0 * 1000) } ?? "N/A"
            let errorStr = error?.localizedDescription ?? "无"
            
            return """
                状态: \(status)
                延迟: \(latencyStr)
                错误: \(errorStr)
                时间: \(timestamp)
                """
        }
    }
    
    // MARK: - 属性
    /// 用于网络诊断操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.diagnostics")
    /// 目标主机地址
    private let host: String
    /// 目标端口号
    private let port: UInt16
    /// 超时时间（秒）
    private let timeout: TimeInterval
    
    // MARK: - 初始化
    /// 初始化网络诊断工具
    /// - Parameters:
    ///   - host: 目标主机地址
    ///   - port: 目标端口号
    ///   - timeout: 超时时间，默认5秒
    init(host: String, port: UInt16, timeout: TimeInterval = 5.0) {
        self.host = host
        self.port = port
        self.timeout = timeout
    }
    
    // MARK: - 公共方法
    /// 执行ping测试
    /// - Parameter completion: 完成回调，返回诊断结果
    func ping(completion: @escaping (DiagnosticResult) -> Void) {
        queue.async {
            let startTime = Date()
            let connection = TFYSwiftConnection(host: self.host, port: self.port)
            
            // 尝试建立连接
            connection.connect { error in
                let endTime = Date()
                let latency = error == nil ? endTime.timeIntervalSince(startTime) : nil
                
                // 创建诊断结果
                let result = DiagnosticResult(
                    timestamp: endTime,
                    isSuccess: error == nil,
                    latency: latency,
                    error: error
                )
                
                // 断开连接并返回结果
                connection.disconnect()
                completion(result)
            }
            
            // 超时处理
            self.queue.asyncAfter(deadline: .now() + self.timeout) {
                connection.disconnect()
            }
        }
    }
    
    /// 检查网络连接状态
    /// - Parameter completion: 完成回调，返回是否有可用网络
    func checkConnectivity(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            completion(path.status == .satisfied)
            monitor.cancel()
        }
        monitor.start(queue: queue)
    }
} 
