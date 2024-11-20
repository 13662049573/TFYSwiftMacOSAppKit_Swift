//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

class TFYSwiftTrafficManager {
    struct TrafficStats {
        var uploadBytes: UInt64 = 0
        var downloadBytes: UInt64 = 0
        var connections: Int = 0
        var startTime: Date = Date()
    }
    
    private let queue = DispatchQueue(label: "com.tfyswift.traffic")
    private var stats = TrafficStats()
    private var statsHandler: ((TrafficStats) -> Void)?
    private var updateTimer: Timer?
    
    init(statsHandler: ((TrafficStats) -> Void)? = nil) {
        self.statsHandler = statsHandler
        startUpdateTimer()
    }
    
    func recordUpload(_ bytes: UInt64) {
        queue.async {
            self.stats.uploadBytes += bytes
        }
    }
    
    func recordDownload(_ bytes: UInt64) {
        queue.async {
            self.stats.downloadBytes += bytes
        }
    }
    
    func incrementConnections() {
        queue.async {
            self.stats.connections += 1
        }
    }
    
    func decrementConnections() {
        queue.async {
            self.stats.connections = max(0, self.stats.connections - 1)
        }
    }
    
    func resetStats() {
        queue.async {
            self.stats = TrafficStats()
        }
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.queue.async {
                if let stats = self?.stats {
                    self?.statsHandler?(stats)
                }
            }
        }
    }
    
    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    deinit {
        stop()
    }
} 
