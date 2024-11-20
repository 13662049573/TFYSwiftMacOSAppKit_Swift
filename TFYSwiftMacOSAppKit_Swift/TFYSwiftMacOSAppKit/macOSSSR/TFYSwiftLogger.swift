//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import os.log

class TFYSwiftLogger {
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }
    }
    
    private let queue = DispatchQueue(label: "com.tfyswift.logger")
    private let logFile: URL
    private let maxLogSize: Int = 10 * 1024 * 1024 // 10MB
    private let maxLogFiles: Int = 5
    private let dateFormatter: DateFormatter
    private let osLog: OSLog
    
    static let shared = TFYSwiftLogger()
    
    private init() {
        let fileManager = FileManager.default
        let appSupport = try! fileManager.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
        let logsDirectory = appSupport.appendingPathComponent("TFYSwift/logs")
        try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        logFile = logsDirectory.appendingPathComponent("tfyswift.log")
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        osLog = OSLog(subsystem: "com.tfyswift", category: "SSR")
        
        rotateLogsIfNeeded()
    }
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
        
        // 写入系统日志
        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
        
        // 写入文件
        queue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                if !FileManager.default.fileExists(atPath: self.logFile.path) {
                    FileManager.default.createFile(atPath: self.logFile.path, contents: nil)
                }
                
                if let handle = try? FileHandle(forWritingTo: self.logFile) {
                    handle.seekToEndOfFile()
                    handle.write((logMessage + "\n").data(using: .utf8)!)
                    handle.closeFile()
                }
                
                self.rotateLogsIfNeeded()
            }
        }
    }
    
    private func rotateLogsIfNeeded() {
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
    
    func clearLogs() {
        queue.async {
            let fileManager = FileManager.default
            let logsDirectory = self.logFile.deletingLastPathComponent()
            
            try? fileManager.removeItem(at: self.logFile)
            
            for i in 1...self.maxLogFiles {
                let rotatedLog = logsDirectory.appendingPathComponent("tfyswift.log.\(i)")
                try? fileManager.removeItem(at: rotatedLog)
            }
        }
    }
}

// 便捷日志函数
func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .debug, file: file, function: function, line: line)
}

func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .info, file: file, function: function, line: line)
}

func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .warning, file: file, function: function, line: line)
}

func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    TFYSwiftLogger.shared.log(message, level: .error, file: file, function: function, line: line)
} 
