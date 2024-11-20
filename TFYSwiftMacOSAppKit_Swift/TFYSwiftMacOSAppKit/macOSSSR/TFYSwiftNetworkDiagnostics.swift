//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

public class TFYSwiftNetworkDiagnostics {
    struct DiagnosticResult {
        let ping: TimeInterval
        let downloadSpeed: Double
        let uploadSpeed: Double
        let packetLoss: Double
    }
    
    private let queue = DispatchQueue(label: "com.tfyswift.networkdiagnostics")
    
    // 运行网络诊断
    func runDiagnostics(to host: String, completion: @escaping (DiagnosticResult) -> Void) {
        queue.async {
            let ping = self.ping(host: host)
            let downloadSpeed = self.measureDownloadSpeed(host: host)
            let uploadSpeed = self.measureUploadSpeed(host: host)
            let packetLoss = self.measurePacketLoss(host: host)
            
            let result = DiagnosticResult(
                ping: ping,
                downloadSpeed: downloadSpeed,
                uploadSpeed: uploadSpeed,
                packetLoss: packetLoss
            )
            
            completion(result)
        }
    }
    
    // 测量 ping 时间
    private func ping(host: String) -> TimeInterval {
        // 使用系统命令 ping 来测量延迟
        let task = Process()
        task.launchPath = "/sbin/ping"
        task.arguments = ["-c", "4", host]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        
        guard let output = String(data: data, encoding: .utf8) else {
            return -1
        }
        
        // 解析输出以获取平均延迟
        let lines = output.split(separator: "\n")
        for line in lines {
            if line.contains("round-trip") {
                let components = line.split(separator: "/")
                if components.count > 4, let avgPing = Double(components[3]) {
                    return avgPing
                }
            }
        }
        
        return -1
    }
    
    // 测量下载速度
    private func measureDownloadSpeed(host: String) -> Double {
        // 使用 URLSession 下载一个文件来测量下载速度
        guard let url = URL(string: "http://\(host)/largefile") else {
            return 0.0
        }
        
        let startTime = Date()
        let semaphore = DispatchSemaphore(value: 0)
        var speed: Double = 0.0
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let elapsedTime = Date().timeIntervalSince(startTime)
                speed = Double(data.count) / elapsedTime / 1024.0 // KB/s
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        return speed
    }
    
    // 测量上传速度
    private func measureUploadSpeed(host: String) -> Double {
        // 使用 URLSession 上传一个文件来测量上传速度
        guard let url = URL(string: "http://\(host)/upload") else {
            return 0.0
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let data = Data(repeating: 0, count: 10 * 1024 * 1024) // 10MB 数据
        let startTime = Date()
        let semaphore = DispatchSemaphore(value: 0)
        var speed: Double = 0.0
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if error == nil {
                let elapsedTime = Date().timeIntervalSince(startTime)
                speed = Double(data.count) / elapsedTime / 1024.0 // KB/s
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        return speed
    }
    
    // 测量丢包率
    private func measurePacketLoss(host: String) -> Double {
        // 使用系统命令 ping 来测量丢包率
        let task = Process()
        task.launchPath = "/sbin/ping"
        task.arguments = ["-c", "10", host]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        
        guard let output = String(data: data, encoding: .utf8) else {
            return -1
        }
        
        // 解析输出以获取丢包率
        let lines = output.split(separator: "\n")
        for line in lines {
            if line.contains("packet loss") {
                let components = line.split(separator: ",")
                if components.count > 2 {
                    let lossComponent = components[2].trimmingCharacters(in: .whitespaces)
                    if let lossPercentage = Double(lossComponent.split(separator: "%")[0]) {
                        return lossPercentage
                    }
                }
            }
        }
        
        return -1
    }
} 
