//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import SystemConfiguration

class TFYSwiftPerformanceMonitor {
    struct PerformanceMetrics {
        var cpuUsage: Double
        var memoryUsage: UInt64
        var connectionCount: Int
        var networkLatency: TimeInterval
        var timestamp: Date
    }
    
    private let queue = DispatchQueue(label: "com.tfyswift.performance")
    private var metricsHandler: ((PerformanceMetrics) -> Void)?
    private var monitorTimer: Timer?
    private var latencyTests: [String: TimeInterval] = [:]
    
    // 性能数据历史
    private var metricsHistory: [PerformanceMetrics] = []
    private let maxHistoryCount = 100
    
    init(metricsHandler: ((PerformanceMetrics) -> Void)? = nil) {
        self.metricsHandler = metricsHandler
    }
    
    // 开始监控性能
    func startMonitoring(interval: TimeInterval = 5.0) {
        monitorTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.collectMetrics()
        }
    }
    
    // 停止监控性能
    func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    // 收集性能指标
    private func collectMetrics() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let metrics = PerformanceMetrics(
                cpuUsage: self.getCPUUsage(),
                memoryUsage: self.getMemoryUsage(),
                connectionCount: self.getConnectionCount(),
                networkLatency: self.getAverageLatency(),
                timestamp: Date()
            )
            
            self.updateMetricsHistory(metrics)
            self.metricsHandler?(metrics)
        }
    }
    
    // 获取 CPU 使用率
    private func getCPUUsage() -> Double {
        var cpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpu: natural_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                         PROCESSOR_CPU_LOAD_INFO,
                                         &numCpu,
                                         &cpuInfo,
                                         &numCpuInfo)
        
        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else {
            return 0.0
        }
        
        defer {
            vm_deallocate(mach_task_self_,
                          vm_address_t(bitPattern: cpuInfo),
                          vm_size_t(Int(numCpuInfo) * MemoryLayout<integer_t>.stride))
        }
        
        let cpuArray = Array(UnsafeBufferPointer(start: cpuInfo, count: Int(numCpuInfo)))
        var totalUsage: Double = 0
        
        for i in 0..<Int(numCpu) {
            let offset = i * Int(CPU_STATE_MAX)
            let user = Double(cpuArray[offset + Int(CPU_STATE_USER)])
            let system = Double(cpuArray[offset + Int(CPU_STATE_SYSTEM)])
            let idle = Double(cpuArray[offset + Int(CPU_STATE_IDLE)])
            let nice = Double(cpuArray[offset + Int(CPU_STATE_NICE)])
            
            let total = user + system + idle + nice
            let usage = (user + system + nice) / total
            totalUsage += usage
        }
        
        return totalUsage / Double(numCpu)
    }
    
    // 获取内存使用量
    private func getMemoryUsage() -> UInt64 {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
        let result = withUnsafeMutablePointer(to: &taskInfo) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: 1) { pointer in
                task_info(mach_task_self_,
                          task_flavor_t(TASK_VM_INFO),
                          pointer,
                          &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return 0
        }
        
        return taskInfo.phys_footprint
    }
    
    // 获取当前连接数
    private func getConnectionCount() -> Int {
        // 使用 netstat 命令获取当前网络连接数
        let task = Process()
        task.launchPath = "/usr/sbin/netstat"
        task.arguments = ["-an"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        
        guard let output = String(data: data, encoding: .utf8) else {
            return 0
        }
        
        // 统计 ESTABLISHED 状态的连接数
        let lines = output.split(separator: "\n")
        let connectionCount = lines.filter { $0.contains("ESTABLISHED") }.count
        
        return connectionCount
    }
    
    // 开始延迟测试
    func startLatencyTest(for server: String) {
        latencyTests[server] = Date().timeIntervalSince1970
    }
    
    // 结束延迟测试
    func endLatencyTest(for server: String) {
        guard let startTime = latencyTests.removeValue(forKey: server) else { return }
        let latency = Date().timeIntervalSince1970 - startTime
        latencyTests[server] = latency
        logInfo("Latency for \(server): \(latency)s")
    }
    
    // 计算平均延迟
    private func getAverageLatency() -> TimeInterval {
        guard !latencyTests.isEmpty else { return 0 }
        let totalLatency = latencyTests.values.reduce(0, +)
        return totalLatency / Double(latencyTests.count)
    }
    
    // 更新性能指标历史
    private func updateMetricsHistory(_ metrics: PerformanceMetrics) {
        metricsHistory.append(metrics)
        if metricsHistory.count > maxHistoryCount {
            metricsHistory.removeFirst()
        }
    }
    
    // 获取性能指标历史
    func getMetricsHistory() -> [PerformanceMetrics] {
        return metricsHistory
    }
    
    // 生成性能报告
    func generatePerformanceReport() -> String {
        var report = "TFYSwift Performance Report\n"
        report += "Generated at: \(Date())\n\n"
        
        let metrics = metricsHistory.last ?? PerformanceMetrics(
            cpuUsage: 0,
            memoryUsage: 0,
            connectionCount: 0,
            networkLatency: 0,
            timestamp: Date()
        )
        
        report += "Current Metrics:\n"
        report += "- CPU Usage: \(String(format: "%.2f%%", metrics.cpuUsage * 100))\n"
        report += "- Memory Usage: \(ByteCountFormatter.string(fromByteCount: Int64(metrics.memoryUsage), countStyle: .file))\n"
        report += "- Active Connections: \(metrics.connectionCount)\n"
        report += "- Network Latency: \(String(format: "%.2fms", metrics.networkLatency * 1000))\n"
        
        return report
    }
    
    deinit {
        stopMonitoring()
    }
} 
