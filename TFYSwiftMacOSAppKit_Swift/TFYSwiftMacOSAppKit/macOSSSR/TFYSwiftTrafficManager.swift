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
    struct TrafficStats {
        /// 上传字节数
        var uploadBytes: UInt64 = 0
        /// 下载字节数
        var downloadBytes: UInt64 = 0
        /// 统计时间戳
        var timestamp: Date = Date()
        
        /// 统计信息描述
        var description: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            return """
                上传: \(formatter.string(fromByteCount: Int64(uploadBytes)))
                下载: \(formatter.string(fromByteCount: Int64(downloadBytes)))
                时间: \(timestamp)
                """
        }
        
        // MARK: - 便捷方法
        
        /// 总流量（上传+下载）
        var totalBytes: UInt64 {
            return uploadBytes + downloadBytes
        }
        
        /// 格式化的上传流量
        var formattedUpload: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            return formatter.string(fromByteCount: Int64(uploadBytes))
        }
        
        /// 格式化的下载流量
        var formattedDownload: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            return formatter.string(fromByteCount: Int64(downloadBytes))
        }
        
        /// 格式化的总流量
        var formattedTotal: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            return formatter.string(fromByteCount: Int64(totalBytes))
        }
    }
    
    /// 用于同步流量统计操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.traffic")
    /// 流量统计数据
    private var stats = TrafficStats()
    /// 流量统计更新回调处理器
    private var statsHandler: ((TrafficStats) -> Void)?
    
    /// 初始化流量管理器
    /// - Parameter statsHandler: 流量统计更新回调处理器
    init(statsHandler: ((TrafficStats) -> Void)? = nil) {
        self.statsHandler = statsHandler
    }
    
    /// 记录上传流量
    /// - Parameter bytes: 上传的字节数
    func recordUpload(_ bytes: UInt64) {
        queue.async {
            self.stats.uploadBytes += bytes
            self.notifyStatsUpdate()
        }
    }
    
    /// 记录下载流量
    /// - Parameter bytes: 下载的字节数
    func recordDownload(_ bytes: UInt64) {
        queue.async {
            self.stats.downloadBytes += bytes
            self.notifyStatsUpdate()
        }
    }
    
    /// 获取当前流量统计数据
    /// - Returns: 流量统计结构体
    func getStats() -> TrafficStats {
        return queue.sync { stats }
    }
    
    /// 重置流量统计数据
    func resetStats() {
        queue.async {
            self.stats = TrafficStats()
            self.notifyStatsUpdate()
        }
    }
    
    /// 通知流量统计更新
    private func notifyStatsUpdate() {
        statsHandler?(stats)
    }
} 
