//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// 网络诊断结果
public struct DiagnosticResult {
    let isReachable: Bool
    let latency: TimeInterval?
    let errorMessage: String?
    let timestamp: Date
    
    var description: String {
        var report = [String]()
        report.append("可达性: \(isReachable ? "可达" : "不可达")")
        if let latency = latency {
            report.append("延迟: \(String(format: "%.2f", latency * 1000))ms")
        }
        if let error = errorMessage {
            report.append("错误: \(error)")
        }
        report.append("检测时间: \(timestamp)")
        return report.joined(separator: "\n")
    }
}

public class TFYSwiftNetworkDiagnostics {
    private let host: String
    private let port: UInt16
    private let timeout: TimeInterval
    private let queue = DispatchQueue(label: "com.tfyswift.networkdiagnostics")
    
    /// 初始化网络诊断工具
    /// - Parameters:
    ///   - host: 目标主机地址
    ///   - port: 目标端口
    ///   - timeout: 超时时间（秒）
    public init(host: String, port: UInt16, timeout: TimeInterval = 5.0) {
        self.host = host
        self.port = port
        self.timeout = timeout
    }
    
    /// 运行网络诊断
    /// - Parameter completion: 完成回调，返回诊断结果
    public func runDiagnostics(completion: @escaping (DiagnosticResult) -> Void) {
        let startTime = Date()
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host),
                                         port: NWEndpoint.Port(integerLiteral: port))
        
        let connection = NWConnection(to: endpoint, using: .tcp)
        
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .ready:
                let latency = Date().timeIntervalSince(startTime)
                connection.cancel()
                self.queue.async {
                    completion(DiagnosticResult(
                        isReachable: true,
                        latency: latency,
                        errorMessage: nil,
                        timestamp: startTime
                    ))
                }
                
            case .failed(let error):
                connection.cancel()
                self.queue.async {
                    completion(DiagnosticResult(
                        isReachable: false,
                        latency: nil,
                        errorMessage: error.localizedDescription,
                        timestamp: startTime
                    ))
                }
                
            case .cancelled:
                // 连接已取消，不需要额外处理
                break
                
            default:
                // 其他状态不需要处理
                break
            }
        }
        
        // 设置超时
        queue.asyncAfter(deadline: .now() + timeout) { [weak self] in
            guard let self = self else { return }
            
            if connection.state != .ready && connection.state != .cancelled {
                connection.cancel()
                completion(DiagnosticResult(
                    isReachable: false,
                    latency: nil,
                    errorMessage: "连接超时",
                    timestamp: startTime
                ))
            }
        }
        
        connection.start(queue: queue)
    }
    
    /// 执行 Ping 测试
    private func pingTest(completion: @escaping (TimeInterval?) -> Void) {
        // 这里可以添加 ICMP ping 实现
        // 由于 ICMP 需要特殊权限，这里仅作为示例
        completion(nil)
    }
    
    /// 执行路由追踪
    private func traceRoute(completion: @escaping ([String]) -> Void) {
        // 这里可以添加路由追踪实现
        // 由于需要特殊权限，这里仅作为示例
        completion([])
    }
}

// 添加详细的网络诊断功能

extension TFYSwiftNetworkDiagnostics {
    /// 诊断项目类型
    public enum DiagnosticItem {
        case connectivity    // 连接性测试
        case dns            // DNS解析测试
        case latency        // 延迟测试
        case speed          // 速度测试
        case route          // 路由追踪
        case portCheck      // 端口检查
    }
    
    /// 诊断结果详情
    public struct DiagnosticDetails {
        let timestamp: Date
        let item: DiagnosticItem
        let success: Bool
        let duration: TimeInterval
        let message: String
        let rawData: Any?
        
        var description: String {
            return """
            [\(timestamp)] \(item) 测试:
            结果: \(success ? "成功" : "失败")
            耗时: \(String(format: "%.2f", duration))秒
            详情: \(message)
            """
        }
    }
    
    /// 执行完整网络诊断
    /// - Parameters:
    ///   - items: 要执行的诊断项目
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    public func performFullDiagnosis(
        items: Set<DiagnosticItem> = Set(DiagnosticItem.allCases),
        progress: ((Float, String) -> Void)? = nil,
        completion: @escaping ([DiagnosticDetails]) -> Void
    ) {
        queue.async {
            var results: [DiagnosticDetails] = []
            let totalItems = items.count
            var completedItems = 0
            
            // 连接性测试
            if items.contains(.connectivity) {
                progress?(Float(completedItems) / Float(totalItems), "正在测试网络连接...")
                results.append(self.testConnectivity())
                completedItems += 1
            }
            
            // DNS解析测试
            if items.contains(.dns) {
                progress?(Float(completedItems) / Float(totalItems), "正在测试DNS解析...")
                results.append(self.testDNS())
                completedItems += 1
            }
            
            // 延迟测试
            if items.contains(.latency) {
                progress?(Float(completedItems) / Float(totalItems), "正在测试网络延迟...")
                results.append(self.testLatency())
                completedItems += 1
            }
            
            // 速度测试
            if items.contains(.speed) {
                progress?(Float(completedItems) / Float(totalItems), "正在测试网络速度...")
                results.append(self.testSpeed())
                completedItems += 1
            }
            
            // 路由追踪
            if items.contains(.route) {
                progress?(Float(completedItems) / Float(totalItems), "正在追踪网络路由...")
                results.append(self.testRoute())
                completedItems += 1
            }
            
            // 端口检查
            if items.contains(.portCheck) {
                progress?(Float(completedItems) / Float(totalItems), "正在检查端口...")
                results.append(self.testPorts())
                completedItems += 1
            }
            
            progress?(1.0, "诊断完成")
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    /// 测试网络连接性
    private func testConnectivity() -> DiagnosticDetails {
        let startTime = Date()
        var success = false
        var message = ""
        
        let semaphore = DispatchSemaphore(value: 0)
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: URL(string: "https://www.apple.com")!) { _, response, error in
            if let error = error {
                message = "连接失败: \(error.localizedDescription)"
            } else if let httpResponse = response as? HTTPURLResponse {
                success = (200...299).contains(httpResponse.statusCode)
                message = "HTTP状态码: \(httpResponse.statusCode)"
            }
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .now() + 10)
        
        return DiagnosticDetails(
            timestamp: startTime,
            item: .connectivity,
            success: success,
            duration: Date().timeIntervalSince(startTime),
            message: message,
            rawData: nil
        )
    }
    
    /// 测试DNS解析
    private func testDNS() -> DiagnosticDetails {
        let startTime = Date()
        var success = false
        var message = ""
        var rawData: [String: Any]? = nil
        
        let resolver = TFYSwiftDNSResolver()
        let semaphore = DispatchSemaphore(value: 0)
        
        resolver.resolve(host) { result in
            switch result {
            case .success(let addresses):
                success = true
                message = "解析成功: \(addresses.joined(separator: ", "))"
                rawData = ["addresses": addresses]
            case .failure(let error):
                message = "解析失败: \(error.localizedDescription)"
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 10)
        
        return DiagnosticDetails(
            timestamp: startTime,
            item: .dns,
            success: success,
            duration: Date().timeIntervalSince(startTime),
            message: message,
            rawData: rawData
        )
    }
    
    /// 测试网络延迟
    private func testLatency() -> DiagnosticDetails {
        let startTime = Date()
        var success = false
        var message = ""
        var rawData: [String: TimeInterval]? = nil
        
        let results = (0..<5).map { _ -> TimeInterval in
            let pingStart = Date()
            let semaphore = DispatchSemaphore(value: 0)
            
            let session = URLSession(configuration: .ephemeral)
            let task = session.dataTask(with: URL(string: "https://\(host)")!) { _, _, _ in
                semaphore.signal()
            }
            task.resume()
            
            _ = semaphore.wait(timeout: .now() + 5)
            return Date().timeIntervalSince(pingStart)
        }
        
        let validResults = results.filter { $0 < 5 }
        if !validResults.isEmpty {
            let avgLatency = validResults.reduce(0, +) / Double(validResults.count)
            success = true
            message = "平均延迟: \(String(format: "%.2f", avgLatency * 1000))ms"
            rawData = ["latencies": validResults]
        } else {
            message = "延迟测试失败"
        }
        
        return DiagnosticDetails(
            timestamp: startTime,
            item: .latency,
            success: success,
            duration: Date().timeIntervalSince(startTime),
            message: message,
            rawData: rawData
        )
    }
    
    /// 测试网络速度
    private func testSpeed() -> DiagnosticDetails {
        // 实现速度测试逻辑
        return DiagnosticDetails(
            timestamp: Date(),
            item: .speed,
            success: true,
            duration: 0,
            message: "速度测试功能待实现",
            rawData: nil
        )
    }
    
    /// 测试网络路由
    private func testRoute() -> DiagnosticDetails {
        // 实现路由追踪逻辑
        return DiagnosticDetails(
            timestamp: Date(),
            item: .route,
            success: true,
            duration: 0,
            message: "路由追踪功能待实现",
            rawData: nil
        )
    }
    
    /// 测试端口
    private func testPorts() -> DiagnosticDetails {
        let startTime = Date()
        var success = false
        var message = ""
        var rawData: [Int: Bool] = [:]
        
        let portsToTest = [80, 443, Int(port)]
        let group = DispatchGroup()
        
        for port in portsToTest {
            group.enter()
            testPort(port) { isOpen in
                rawData[port] = isOpen
                group.leave()
            }
        }
        
        group.wait()
        
        let openPorts = rawData.filter { $0.value }.map { $0.key }
        success = !openPorts.isEmpty
        message = "开放端口: \(openPorts.map(String.init).joined(separator: ", "))"
        
        return DiagnosticDetails(
            timestamp: startTime,
            item: .portCheck,
            success: success,
            duration: Date().timeIntervalSince(startTime),
            message: message,
            rawData: rawData
        )
    }
    
    /// 测试单个端口
    private func testPort(_ port: Int, completion: @escaping (Bool) -> Void) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: UInt16(port))
        )
        
        let connection = NWConnection(to: endpoint, using: .tcp)
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                connection.cancel()
                completion(true)
            case .failed, .cancelled:
                completion(false)
            default:
                break
            }
        }
        
        connection.start(queue: queue)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            connection.cancel()
        }
    }
}

// MARK: - DiagnosticItem Extension
extension TFYSwiftNetworkDiagnostics.DiagnosticItem: CaseIterable {
    public static var allCases: [TFYSwiftNetworkDiagnostics.DiagnosticItem] {
        return [.connectivity, .dns, .latency, .speed, .route, .portCheck]
    }
} 
