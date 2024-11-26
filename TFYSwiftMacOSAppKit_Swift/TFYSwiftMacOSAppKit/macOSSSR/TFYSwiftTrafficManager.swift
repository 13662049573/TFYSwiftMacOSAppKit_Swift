//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 流量管理器类 - 负责记录和统计网络流量
public class TFYSwiftTrafficManager {
    /// 流量统计结构体 - 存储流量数据
    public struct TrafficStats {
        /// 上传字节数
        public var uploadBytes: UInt64 = 0
        /// 下载字节数
        public var downloadBytes: UInt64 = 0
        /// 统计时间戳
        public var timestamp: Date = Date()
        
        /// 统计信息描述
        public var description: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            return """
                上传: \(formatter.string(fromByteCount: Int64(uploadBytes)))
                下载: \(formatter.string(fromByteCount: Int64(downloadBytes)))
                """
        }
    }
    
    /// 流量统计更新回调类型
    public typealias StatsHandler = (TrafficStats) -> Void
    
    /// 流量统计更新回调
    public var statsHandler: StatsHandler?
    
    /// 当前流量统计
    private var stats: TrafficStats = TrafficStats()
    
    /// 用于同步流量统计的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.traffic")
    
    /// 初始化流量管理器
    public init() {}
    
    /// 记录上传流量
    /// - Parameter bytes: 上传的字节数
    public func recordUpload(_ bytes: UInt64) {
        queue.async {
            self.stats.uploadBytes += bytes
            self.notifyStatsUpdate()
        }
    }
    
    /// 记录下载流量
    /// - Parameter bytes: 下载的字节数
    public func recordDownload(_ bytes: UInt64) {
        queue.async {
            self.stats.downloadBytes += bytes
            self.notifyStatsUpdate()
        }
    }
    
    /// 获取当前流量统计数据
    /// - Returns: 流量统计结构体
    public func getStats() -> TrafficStats {
        return queue.sync { stats }
    }
    
    /// 重置流量统计数据
    public func resetStats() {
        queue.async {
            self.stats = TrafficStats()
            self.notifyStatsUpdate()
        }
    }
    
    /// 通知流量统计更新
    private func notifyStatsUpdate() {
        let currentStats = stats
        DispatchQueue.main.async {
            self.statsHandler?(currentStats)
        }
    }
    
    /// 流量限制配置
    public struct TrafficLimit {
        let dailyLimit: UInt64?      // 每日流量限制（字节）
        let monthlyLimit: UInt64?    // 每月流量限制（字节）
        let speedLimit: UInt64?      // 速度限制（字节/秒）
        
        public init(dailyLimit: UInt64? = nil,
                   monthlyLimit: UInt64? = nil,
                   speedLimit: UInt64? = nil) {
            self.dailyLimit = dailyLimit
            self.monthlyLimit = monthlyLimit
            self.speedLimit = speedLimit
        }
    }
    
    /// 流量统计详情
    public struct TrafficDetails {
        let currentSpeed: Double      // 当前速度（字节/秒）
        let peakSpeed: Double        // 峰值速度（字节/秒）
        let averageSpeed: Double     // 平均速度（字节/秒）
        let totalUpload: UInt64      // 总上传流量（字节）
        let totalDownload: UInt64    // 总下载流量（字节）
        let startTime: Date          // 统计开始时间
        
        var description: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            
            return """
            流量统计详情:
            当前速度: \(formatter.string(fromByteCount: Int64(currentSpeed)))/s
            峰值速度: \(formatter.string(fromByteCount: Int64(peakSpeed)))/s
            平均速度: \(formatter.string(fromByteCount: Int64(averageSpeed)))/s
            总上传: \(formatter.string(fromByteCount: Int64(totalUpload)))
            总下载: \(formatter.string(fromByteCount: Int64(totalDownload)))
            统计时长: \(formatTimeInterval(Date().timeIntervalSince(startTime)))
            """
        }
    }
    
    /// 流量报警配置
    public struct TrafficAlert {
        let usageThreshold: Double    // 使用量阈值（0-1）
        let speedThreshold: UInt64    // 速度阈值（字节/秒）
        let handler: (TrafficAlertType) -> Void
        
        public enum TrafficAlertType {
            case usageLimit(current: UInt64, limit: UInt64)
            case speedLimit(current: UInt64, limit: UInt64)
        }
    }
    
    /// 流量限制
    private var trafficLimit: TrafficLimit?
    
    /// 流量报警
    private var trafficAlert: TrafficAlert?
    
    /// 流量历史记录
    private var trafficHistory: [TrafficStats] = []
    
    /// 流量历史记录的开始时间
    private var startTime: Date = Date()
    
    /// 流量历史记录的最后更新时间
    private var lastSpeedUpdate: Date?
    
    /// 流量历史记录的最后字节数
    private var lastBytes: UInt64 = 0
    
    /// 流量历史记录的当前字节数
    private var currentBytes: UInt64 = 0
    
    /// 流量历史记录的峰值速度
    private var peakSpeed: Double = 0
    
    /// 设置流量限制
    /// - Parameter limit: 流量限制配置
    public func setTrafficLimit(_ limit: TrafficLimit) {
        queue.async {
            self.trafficLimit = limit
            self.checkTrafficLimit()
        }
    }
    
    /// 设置流量报警
    /// - Parameter alert: 流量报警配置
    public func setTrafficAlert(_ alert: TrafficAlert) {
        queue.async {
            self.trafficAlert = alert
        }
    }
    
    /// 获取流量统计详情
    /// - Returns: 流量统计详情
    public func getTrafficDetails() -> TrafficDetails {
        return queue.sync {
            let now = Date()
            let duration = now.timeIntervalSince(startTime)
            
            return TrafficDetails(
                currentSpeed: calculateCurrentSpeed(),
                peakSpeed: peakSpeed,
                averageSpeed: calculateAverageSpeed(duration: duration),
                totalUpload: stats.uploadBytes,
                totalDownload: stats.downloadBytes,
                startTime: startTime
            )
        }
    }
    
    /// 计算当前速度
    private func calculateCurrentSpeed() -> Double {
        guard let lastUpdate = lastSpeedUpdate else { return 0 }
        
        let timeDiff = Date().timeIntervalSince(lastUpdate)
        guard timeDiff > 0 else { return 0 }
        
        let byteDiff = Double(currentBytes - lastBytes)
        return byteDiff / timeDiff
    }
    
    /// 计算平均速度
    private func calculateAverageSpeed(duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        
        let totalBytes = Double(stats.uploadBytes + stats.downloadBytes)
        return totalBytes / duration
    }
    
    /// 检查流量限制
    private func checkTrafficLimit() {
        guard let limit = trafficLimit else { return }
        
        // 检查每日流量限制
        if let dailyLimit = limit.dailyLimit {
            let dailyUsage = getDailyTrafficUsage()
            if dailyUsage >= dailyLimit {
                handleTrafficLimitExceeded(.usageLimit(current: dailyUsage, limit: dailyLimit))
            }
        }
        
        // 检查每月流量限制
        if let monthlyLimit = limit.monthlyLimit {
            let monthlyUsage = getMonthlyTrafficUsage()
            if monthlyUsage >= monthlyLimit {
                handleTrafficLimitExceeded(.usageLimit(current: monthlyUsage, limit: monthlyLimit))
            }
        }
        
        // 检查速度限制
        if let speedLimit = limit.speedLimit {
            let currentSpeed = UInt64(calculateCurrentSpeed())
            if currentSpeed >= speedLimit {
                handleTrafficLimitExceeded(.speedLimit(current: currentSpeed, limit: speedLimit))
            }
        }
    }
    
    /// 获取每日流量使用量
    private func getDailyTrafficUsage() -> UInt64 {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return trafficHistory
            .filter { calendar.startOfDay(for: $0.timestamp) == today }
            .reduce(0) { $0 + $1.uploadBytes + $1.downloadBytes }
    }
    
    /// 获取每月流量使用量
    private func getMonthlyTrafficUsage() -> UInt64 {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        guard let monthStart = calendar.date(from: components) else { return 0 }
        
        return trafficHistory
            .filter { $0.timestamp >= monthStart }
            .reduce(0) { $0 + $1.uploadBytes + $1.downloadBytes }
    }
    
    /// 处理流量限制超出
    private func handleTrafficLimitExceeded(_ type: TrafficAlert.TrafficAlertType) {
        trafficAlert?.handler(type)
        
        switch type {
        case .usageLimit(let current, let limit):
            logWarning("流量使用超出限制: \(formatBytes(current))/\(formatBytes(limit))")
        case .speedLimit(let current, let limit):
            logWarning("速度超出限制: \(formatBytes(current))/s / \(formatBytes(limit))/s")
        }
    }
    
    /// 格式化字节数
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    /// 格式化时间间隔
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 
