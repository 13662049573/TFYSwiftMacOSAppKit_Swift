//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import os.log

/// 日志管理器类 - 负责应用程序的日志记录功能
public class TFYSwiftLogger {
    /// 日志级别枚举
    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
    
    /// 日志条目结构体
    private struct LogEntry {
        let timestamp: Date
        let level: LogLevel
        let message: String
        let file: String
        let function: String
        let line: Int
        
        var formatted: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let fileName = (file as NSString).lastPathComponent
            return "[\(dateFormatter.string(from: timestamp))] [\(level.rawValue)] [\(fileName):\(line) \(function)] \(message)"
        }
    }
    
    // 单例实例
    public static let shared = TFYSwiftLogger()
    
    // 存储日志条目的数组
    private var logs: [LogEntry] = []
    private let queue = DispatchQueue(label: "com.tfyswift.logger")
    private let maxLogEntries = 1000 // 最大日志条目数
    
    private init() {}
    
    /// 记录日志
    public func log(_ message: String,
                   level: LogLevel,
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let entry = LogEntry(timestamp: Date(),
                               level: level,
                               message: message,
                               file: file,
                               function: function,
                               line: line)
            
            // 添加日志条目
            self.logs.append(entry)
            
            // 如果超过最大条目数，删除最旧的条目
            if self.logs.count > self.maxLogEntries {
                self.logs.removeFirst()
            }
            
            // 在控制台打印日志
            print(entry.formatted)
        }
    }
    
    /// 记录错误级别日志
    public func error(_ message: String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    /// 记录信息级别日志
    public func info(_ message: String,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// 记录调试级别日志
    public func debug(_ message: String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// 记录警告级别日志
    public func warning(_ message: String,
                       file: String = #file,
                       function: String = #function,
                       line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// 导出日志
    public func exportLogs() -> String {
        return queue.sync {
            return logs.map { $0.formatted }.joined(separator: "\n")
        }
    }
    
    /// 清除日志
    public func clearLogs() {
        queue.async {
            self.logs.removeAll()
        }
    }
    
    /// 获取最近的日志
    public func getRecentLogs(count: Int = 100) -> [String] {
        return queue.sync {
            let startIndex = max(0, logs.count - count)
            return Array(logs[startIndex...]).map { $0.formatted }
        }
    }
    
    /// 保存日志到文件
    public func saveToFile(at url: URL) throws {
        let logsString = exportLogs()
        try logsString.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// 日志分析结果
    public struct LogAnalysis {
        let errorCount: Int
        let warningCount: Int
        let topErrors: [(message: String, count: Int)]
        let timeDistribution: [Date: Int]
        
        var description: String {
            return """
            日志分析结果:
            错误数: \(errorCount)
            警告数: \(warningCount)
            
            常见错误:
            \(topErrors.enumerated().map { "\($0 + 1). \($1.message) (\($1.count)次)" }.joined(separator: "\n"))
            
            时间分布:
            \(timeDistribution.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)条" }.joined(separator: "\n"))
            """
        }
    }
    
    /// 分析日志
    /// - Parameter timeRange: 时间范围（秒）
    /// - Returns: 日志分析结果
    public func analyzeLogs(timeRange: TimeInterval? = nil) -> LogAnalysis {
        return queue.sync {
            let relevantLogs: [LogEntry]
            if let timeRange = timeRange {
                let cutoffDate = Date().addingTimeInterval(-timeRange)
                relevantLogs = logs.filter { $0.timestamp > cutoffDate }
            } else {
                relevantLogs = logs
            }
            
            // 统计错误和警告
            let errorLogs = relevantLogs.filter { $0.level == .error }
            let warningLogs = relevantLogs.filter { $0.level == .warning }
            
            // 分析常见错误
            let errorMessages = errorLogs.map { $0.message }
            let errorCounts = Dictionary(grouping: errorMessages, by: { $0 })
                .mapValues { $0.count }
                .sorted { $0.value > $1.value }
                .prefix(5)
                .map { ($0.key, $0.value) }
            
            // 分析时间分布
            let calendar = Calendar.current
            let timeDistribution = Dictionary(grouping: relevantLogs) {
                calendar.startOfHour(for: $0.timestamp)
            }.mapValues { $0.count }
            
            return LogAnalysis(
                errorCount: errorLogs.count,
                warningCount: warningLogs.count,
                topErrors: Array(errorCounts),
                timeDistribution: timeDistribution
            )
        }
    }
    
    /// 导出日志到文件
    /// - Parameter url: 文件URL
    /// - Throws: 文件操作错误
    public func exportLogs(to url: URL) throws {
        let analysis = analyzeLogs()
        var content = analysis.description + "\n\n完整日志:\n"
        
        content += logs.map { log in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return "[\(dateFormatter.string(from: log.timestamp))] [\(log.level.rawValue)] \(log.message) (\(log.file):\(log.line))"
        }.joined(separator: "\n")
        
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// 清理旧日志
    /// - Parameter maxAge: 最大保留时间（秒）
    public func cleanOldLogs(maxAge: TimeInterval) {
        queue.async {
            let cutoffDate = Date().addingTimeInterval(-maxAge)
            self.logs = self.logs.filter { $0.timestamp > cutoffDate }
            logInfo("已清理旧日志")
        }
    }
}

// MARK: - 便捷日志函数

/// 记录调试级别日志
public func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .debug, file: file, function: function, line: line)
}

/// 记录信息级别日志
public func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .info, file: file, function: function, line: line)
}

/// 记录警告级别日志
public func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .warning, file: file, function: function, line: line)
}

/// 记录错误级别日志
public func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .error, file: file, function: function, line: line)
}
