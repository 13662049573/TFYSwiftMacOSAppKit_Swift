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
    public struct PerformanceMetrics {
        public var cpuUsage: Double        // CPU使用率（0-1）
        public var memoryUsage: UInt64     // 内存使用量（字节）
        public var timestamp: Date         // 采样时间戳
        
        /// 计算性能得分（0-100）
        public var performanceScore: Double {
            let cpuScore = (1.0 - cpuUsage) * 100
            let memoryScore = (1.0 - Double(memoryUsage) / Double(ProcessInfo.processInfo.physicalMemory)) * 100
            return (cpuScore + memoryScore) / 2.0
        }
    }
    
    /// 性能指标更新回调类型
    public typealias MetricsHandler = (PerformanceMetrics) -> Void
    
    /// 性能指标更新回调
    public var metricsHandler: MetricsHandler?
    
    /// 当前性能指标
    private(set) public var currentMetrics: PerformanceMetrics?
    
    private let queue = DispatchQueue(label: "com.tfyswift.performance")
    private var timer: Timer?
    private let updateInterval: TimeInterval
    
    public init(updateInterval: TimeInterval = 1.0) {
        self.updateInterval = updateInterval
    }
    
    /// 开始监控
    public func startMonitoring() {
        stopMonitoring()
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }
    
    /// 停止监控
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 更新性能指标
    private func updateMetrics() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let metrics = PerformanceMetrics(
                cpuUsage: self.getCPUUsage(),
                memoryUsage: self.getMemoryUsage(),
                timestamp: Date()
            )
            
            self.currentMetrics = metrics
            DispatchQueue.main.async {
                self.metricsHandler?(metrics)
            }
        }
    }
    
    /// 获取CPU使用率
    private func getCPUUsage() -> Double {
        // 实现CPU使用率获取逻辑
        return 0.0 // 临时返回值
    }
    
    /// 获取内存使用量
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        }
        
        return 0
    }
    
    deinit {
        stopMonitoring()
    }
    
    /// 性能警告级别
    public enum PerformanceAlertLevel: Int {
        case normal = 0     // 正常
        case warning = 1    // 警告
        case critical = 2   // 严重
        
        static func forCPUUsage(_ usage: Double) -> PerformanceAlertLevel {
            switch usage {
            case 0..<0.7:
                return .normal
            case 0.7..<0.9:
                return .warning
            default:
                return .critical
            }
        }
        
        static func forMemoryUsage(_ usage: Double) -> PerformanceAlertLevel {
            switch usage {
            case 0..<0.8:
                return .normal
            case 0.8..<0.9:
                return .warning
            default:
                return .critical
            }
        }
    }
    
    /// 性能报告结构体
    public struct PerformanceReport {
        let metrics: PerformanceMetrics
        let cpuAlertLevel: PerformanceAlertLevel
        let memoryAlertLevel: PerformanceAlertLevel
        let timestamp: Date
        
        var description: String {
            return """
            性能报告 (\(timestamp))
            CPU使用率: \(String(format: "%.1f%%", metrics.cpuUsage * 100)) [\(cpuAlertLevel)]
            内存使用: \(ByteCountFormatter.string(fromByteCount: Int64(metrics.memoryUsage), countStyle: .memory)) [\(memoryAlertLevel)]
            性能得分: \(String(format: "%.1f", metrics.performanceScore))
            """
        }
    }
    
    /// 开始性能监控
    /// - Parameters:
    ///   - interval: 监控间隔（秒）
    ///   - handler: 性能指标回调
    public func startMonitoring(interval: TimeInterval = 1.0, handler: @escaping MetricsHandler) {
        stopMonitoring()
        
        self.metricsHandler = handler
        
        // 创建定时器
        monitorTimer = DispatchSource.makeTimerSource(queue: queue)
        monitorTimer?.schedule(deadline: .now(), repeating: interval)
        
        monitorTimer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            // 收集性能指标
            let cpuUsage = self.getCPUUsage()
            let memoryUsage = self.getMemoryUsage()
            
            // 创建性能指标
            let metrics = PerformanceMetrics(
                cpuUsage: cpuUsage,
                memoryUsage: memoryUsage,
                timestamp: Date()
            )
            
            // 创建性能报告
            let report = PerformanceReport(
                metrics: metrics,
                cpuAlertLevel: .forCPUUsage(cpuUsage),
                memoryAlertLevel: .forMemoryUsage(Double(memoryUsage) / Double(ProcessInfo.processInfo.physicalMemory)),
                timestamp: Date()
            )
            
            // 检查是否需要发出警告
            self.checkPerformanceAlert(report)
            
            // 更新历史数据
            self.updateMetricsHistory(metrics)
            
            // 调用回调
            DispatchQueue.main.async {
                handler(metrics)
            }
        }
        
        monitorTimer?.resume()
    }
    
    /// 获取CPU使用率
    private func getCPUUsage() -> Double {
        var cpuInfo = processor_info_array_t?.init(mutating: nil)
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCpus,
                                       &cpuInfo,
                                       &numCpuInfo)
        
        guard result == KERN_SUCCESS else {
            return 0.0
        }
        
        let cpuUser = Double(cpuInfo![CPU_STATE_USER])
        let cpuSystem = Double(cpuInfo![CPU_STATE_SYSTEM])
        let cpuIdle = Double(cpuInfo![CPU_STATE_IDLE])
        let cpuNice = Double(cpuInfo![CPU_STATE_NICE])
        
        let totalTicks = cpuUser + cpuSystem + cpuIdle + cpuNice
        let usedTicks = cpuUser + cpuSystem
        
        return usedTicks / totalTicks
    }
    
    /// 更新性能指标历史
    private func updateMetricsHistory(_ metrics: PerformanceMetrics) {
        metricsHistory.append(metrics)
        
        // 保持历史记录在限定大小内
        if metricsHistory.count > maxHistorySize {
            metricsHistory.removeFirst()
        }
    }
    
    /// 检查性能警告
    private func checkPerformanceAlert(_ report: PerformanceReport) {
        // 检查 CPU 警告
        if report.cpuAlertLevel == .critical {
            logWarning("CPU使用率过高: \(String(format: "%.1f%%", report.metrics.cpuUsage * 100))")
        }
        
        // 检查内存警告
        if report.memoryAlertLevel == .critical {
            logWarning("内存使用过高: \(ByteCountFormatter.string(fromByteCount: Int64(report.metrics.memoryUsage), countStyle: .memory))")
        }
    }
    
    /// 获取性能趋势分析
    public func getPerformanceTrend(timeRange: TimeInterval = 300) -> PerformanceTrend {
        let now = Date()
        let relevantMetrics = metricsHistory.filter {
            now.timeIntervalSince($0.timestamp) <= timeRange
        }
        
        guard !relevantMetrics.isEmpty else {
            return PerformanceTrend(trend: .stable, confidence: 0)
        }
        
        // 计算CPU使用率趋势
        let cpuTrend = calculateTrend(
            relevantMetrics.map { $0.cpuUsage }
        )
        
        // 计算内存使用趋势
        let memoryTrend = calculateTrend(
            relevantMetrics.map { Double($0.memoryUsage) }
        )
        
        // 综合评估趋势
        return combineTrends(cpu: cpuTrend, memory: memoryTrend)
    }
    
    /// 性能趋势
    public struct PerformanceTrend {
        public enum Trend {
            case improving
            case stable
            case degrading
        }
        
        let trend: Trend
        let confidence: Double // 0-1
    }
    
    /// 计算数值趋势
    private func calculateTrend(_ values: [Double]) -> Double {
        guard values.count >= 2 else { return 0 }
        
        let n = Double(values.count)
        let indices = Array(0..<values.count).map { Double($0) }
        
        // 计算线性回归斜率
        let sumX = indices.reduce(0, +)
        let sumY = values.reduce(0, +)
        let sumXY = zip(indices, values).map(*).reduce(0, +)
        let sumXX = indices.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        return slope
    }
    
    /// 合并CPU和内存趋势
    private func combineTrends(cpu: Double, memory: Double) -> PerformanceTrend {
        let avgTrend = (cpu + memory) / 2
        let confidence = min(abs(avgTrend) * 10, 1.0) // 将趋势转换为0-1的置信度
        
        let trend: PerformanceTrend.Trend
        if abs(avgTrend) < 0.01 {
            trend = .stable
        } else if avgTrend < 0 {
            trend = .improving
        } else {
            trend = .degrading
        }
        
        return PerformanceTrend(trend: trend, confidence: confidence)
    }
} 
