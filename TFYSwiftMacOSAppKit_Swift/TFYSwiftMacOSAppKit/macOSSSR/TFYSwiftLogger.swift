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
    /// 日志级别枚举，定义不同的日志重要程度
    enum LogLevel: String {
        case debug = "DEBUG"     // 调试信息
        case info = "INFO"       // 一般信息
        case warning = "WARNING" // 警告信息
        case error = "ERROR"     // 错误信息
        
        /// 将日志级别转换为系统日志类型
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }
    }
    
    /// 用于同步日志操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.logger")
    /// 日志文件路径
    private let logFile: URL
    /// 单个日志文件的最大大小（10MB）
    private let maxLogSize: Int = 10 * 1024 * 1024
    /// 最大日志文件数量
    private let maxLogFiles: Int = 5
    /// 日期格式化器
    private let dateFormatter: DateFormatter
    /// 系统日志对象
    private let osLog: OSLog
    
    /// 单例实例
    static let shared = TFYSwiftLogger()
    
    /// 私有初始化方法
    private init() {
        let fileManager = FileManager.default
        // 获取应用支持目录
        let appSupport = try! fileManager.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
        // 创建日志目录
        let logsDirectory = appSupport.appendingPathComponent("TFYSwift/logs")
        try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        // 设置日志文件路径
        logFile = logsDirectory.appendingPathComponent("tfyswift.log")
        
        // 配置日期格式化器
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        // 创建系统日志对象
        osLog = OSLog(subsystem: "com.tfyswift", category: "SSR")
        
        // 检查是否需要轮转日志
        rotateLogsIfNeeded()
    }
    
    /// 记录日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - level: 日志级别
    ///   - file: 源文件名
    ///   - function: 函数名
    ///   - line: 行号
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(dateFormatter.string(from: Date())) [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
        
        // 异步写入文件
        queue.async {
            if let data = (logMessage + "\n").data(using: .utf8) {
                if let fileHandle = try? FileHandle(forWritingTo: self.logFile) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    try? data.write(to: self.logFile, options: .atomic)
                }
            }
            
            // 检查日志大小并在需要时轮转
            self.rotateLogsIfNeeded()
        }
    }
    
    /// 检查并执行日志轮转
    private func rotateLogsIfNeeded() {
        // 检查当前日志文件大小
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: logFile.path),
              let size = attributes[.size] as? Int,
              size > maxLogSize else {
            return
        }
        
        let fileManager = FileManager.default
        let logsDirectory = logFile.deletingLastPathComponent()
        
        // 移动现有日志文件
        for i in (1...maxLogFiles-1).reversed() {
            let oldFile = logsDirectory.appendingPathComponent("tfyswift.log.\(i)")
            let newFile = logsDirectory.appendingPathComponent("tfyswift.log.\(i+1)")
            
            try? fileManager.removeItem(at: newFile)
            try? fileManager.moveItem(at: oldFile, to: newFile)
        }
        
        let firstRotatedLog = logsDirectory.appendingPathComponent("tfyswift.log.1")
        try? fileManager.moveItem(at: logFile, to: firstRotatedLog)
    }
    
    /// 清除所有日志文件
    func clearLogs() {
        queue.async {
            let fileManager = FileManager.default
            let logsDirectory = self.logFile.deletingLastPathComponent()
            
            // 删除当前日志文件
            try? fileManager.removeItem(at: self.logFile)
            
            // 删除所有轮转的日志文件
            for i in 1...self.maxLogFiles {
                let rotatedLog = logsDirectory.appendingPathComponent("tfyswift.log.\(i)")
                try? fileManager.removeItem(at: rotatedLog)
            }
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
