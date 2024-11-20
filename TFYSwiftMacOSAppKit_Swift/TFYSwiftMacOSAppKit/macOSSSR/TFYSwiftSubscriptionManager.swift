//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

class TFYSwiftSubscriptionManager {
    private let config: TFYSwiftConfig
    private let queue = DispatchQueue(label: "com.tfyswift.subscription")
    private var updateTimer: Timer?
    
    init(config: TFYSwiftConfig) {
        self.config = config
    }
    
    func addSubscription(_ url: String) {
        if !config.subscribeUrls.contains(url) {
            config.subscribeUrls.append(url)
            try? config.save()
        }
    }
    
    func removeSubscription(_ url: String) {
        if let index = config.subscribeUrls.firstIndex(of: url) {
            config.subscribeUrls.remove(at: index)
            try? config.save()
        }
    }
    
    func updateSubscriptions(completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for url in config.subscribeUrls {
            group.enter()
            updateSubscription(url) { error in
                if let error = error {
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: queue) {
            completion(errors.first)
            try? self.config.save()
        }
    }
    
    private func updateSubscription(_ url: String, completion: @escaping (Error?) -> Void) {
        guard let subscriptionURL = URL(string: url) else {
            completion(TFYSwiftError.configurationError("Invalid subscription URL"))
            return
        }
        
        let task = URLSession.shared.dataTask(with: subscriptionURL) { [weak self] data, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data,
                  let base64Decoded = Data(base64Encoded: data),
                  let configString = String(data: base64Decoded, encoding: .utf8) else {
                completion(TFYSwiftError.configurationError("Invalid subscription data"))
                return
            }
            
            self?.parseSubscriptionConfig(configString, completion: completion)
        }
        
        task.resume()
    }
    
    private func parseSubscriptionConfig(_ configString: String, completion: @escaping (Error?) -> Void) {
        // 解析订阅配置并更新到 config
        // 具体实现取决于订阅格式
        completion(nil)
    }
    
    func startAutoUpdate(interval: TimeInterval = 3600) {
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateSubscriptions { _ in }
        }
    }
    
    func stopAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    deinit {
        stopAutoUpdate()
    }
} 
