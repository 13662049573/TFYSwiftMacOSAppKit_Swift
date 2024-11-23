//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import SystemConfiguration

/// 性能监控器类 - 负责监控系统CPU和内存使用情况
public class TFYSwiftPerformanceMonitor {
    /// 性能指标结构体 - 存储单次性能采样数据
    struct PerformanceMetrics {
        var cpuUsage: Double        // CPU使用率（0-1）
        var memoryUsage: UInt64     // 内存使用量（字节）
        var timestamp: Date         // 采样时间戳
        
        /// 计算性能得分（0-100）
        var performanceScore: Double {
            let cpuScore = (1.0 - cpuUsage) * 100
            let memoryScore = (1.0 - Double(memoryUsage) / Double(ProcessInfo.processInfo.physicalMemory)) * 100
            return (cpuScore + memoryScore) / 2.0
        }
    }
    
    /// 用于同步性能监控操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.performance")
    /// 性能数据回调处理器
    private var metricsHandler: ((PerformanceMetrics) -> Void)?
    /// 定时器，用于定期采集性能数据
    private var monitorTimer: Timer?
    /// 性能数据历史记录
    private var metricsHistory: [PerformanceMetrics] = []
    /// 最大历史记录数量
    private let maxHistoryCount = 100
    
    /// 初始化性能监控器
    /// - Parameter metricsHandler: 性能数据回调处理器
    init(metricsHandler: ((PerformanceMetrics) -> Void)? = nil) {
        self.metricsHandler = metricsHandler
    }
    
    /// 开始性能监控
    func startMonitoring() {
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.collectMetrics()
        }
    }
    
    /// 停止性能监控
    func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    /// 采集性能指标
    private func collectMetrics() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let metrics = PerformanceMetrics(
                cpuUsage: self.getCPUUsage(),
                memoryUsage: self.getMemoryUsage(),
                timestamp: Date()
            )
            
            self.updateMetricsHistory(metrics)
            self.metricsHandler?(metrics)
        }
    }
    
    /// 获取CPU使用率
    private func getCPUUsage() -> Double {
        var numCpus: natural_t = 0
        var cpuInfo: processor_info_array_t? = nil
        var numCpuInfo: mach_msg_type_number_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCpus,
                                       &cpuInfo,
                                       &numCpuInfo)
        
        if result == KERN_SUCCESS, let cpuInfo = cpuInfo {
            var totalUsage: Double = 0.0
            let cpuInfoArray = UnsafeBufferPointer(start: cpuInfo, count: Int(numCpuInfo))
            
            for i in stride(from: 0, to: Int(numCpus), by: 1) {
                let offset = i * Int(CPU_STATE_MAX)
                let user = Double(cpuInfoArray[offset + Int(CPU_STATE_USER)])
                let system = Double(cpuInfoArray[offset + Int(CPU_STATE_SYSTEM)])
                let idle = Double(cpuInfoArray[offset + Int(CPU_STATE_IDLE)])
                let nice = Double(cpuInfoArray[offset + Int(CPU_STATE_NICE)])
                
                let total = user + system + idle + nice
                let usage = (user + system + nice) / total
                totalUsage += usage
            }
            
            // 释放内存
            vm_deallocate(mach_task_self_,
                         vm_address_t(UInt(bitPattern: cpuInfo)),
                         vm_size_t(numCpuInfo * UInt32(MemoryLayout<integer_t>.stride)))
            
            return totalUsage / Double(numCpus)
        }
        
        return 0.0
    }
    
    /// 获取内存使用量
    private func getMemoryUsage() -> UInt64 {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            return taskInfo.phys_footprint
        }
        return 0
    }
    
    /// 更新性能数据历史记录
    private func updateMetricsHistory(_ metrics: PerformanceMetrics) {
        metricsHistory.append(metrics)
        if metricsHistory.count > maxHistoryCount {
            metricsHistory.removeFirst()
        }
    }
    
    /// 获取性能数据历史记录
    func getMetricsHistory() -> [PerformanceMetrics] {
        return metricsHistory
    }
    
    /// 生成性能报告
    func generatePerformanceReport() -> String {
        var report = "性能报告\n"
        report += "生成时间: \(Date())\n\n"
        
        if let lastMetrics = metricsHistory.last {
            report += "当前性能得分: \(String(format: "%.1f", lastMetrics.performanceScore))\n"
            report += "CPU使用率: \(String(format: "%.1f%%", lastMetrics.cpuUsage * 100))\n"
            report += "内存使用量: \(ByteCountFormatter.string(fromByteCount: Int64(lastMetrics.memoryUsage), countStyle: .memory))\n"
        }
        
        return report
    }
    
    /// 析构函数 - 确保监控器被正确停止
    deinit {
        stopMonitoring()
    }
} 
