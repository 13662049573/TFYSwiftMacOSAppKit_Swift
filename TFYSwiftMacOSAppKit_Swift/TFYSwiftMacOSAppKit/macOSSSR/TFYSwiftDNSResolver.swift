//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

class TFYSwiftDNSResolver {
    private let queue = DispatchQueue(label: "com.tfyswift.dns")
    private var cache: [String: [String]] = [:]
    private let cacheLock = NSLock()
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    struct DNSRecord {
        let ip: String
        let timestamp: Date
    }
    
    func resolve(_ hostname: String, completion: @escaping ([String]?) -> Void) {
        // 首先检查缓存
        if let cached = getCachedResult(for: hostname) {
            completion(cached)
            return
        }
        
        let host = NWEndpoint.Host(hostname)
        let endpoint = NWEndpoint.hostPort(host: host, port: 0)
        
        NWConnection.extractPath(to: endpoint, options: .init()) { path in
            guard let path = path else {
                completion(nil)
                return
            }
            
            var addresses: [String] = []
            for endpoint in path.endpoints {
                if case .hostPort(let host, _) = endpoint {
                    addresses.append(host.debugDescription)
                }
            }
            
            self.cacheResult(addresses, for: hostname)
            completion(addresses)
        }
    }
    
    private func getCachedResult(for hostname: String) -> [String]? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return cache[hostname]
    }
    
    private func cacheResult(_ addresses: [String], for hostname: String) {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        cache[hostname] = addresses
        
        // 设置缓存过期清理
        queue.asyncAfter(deadline: .now() + cacheTimeout) { [weak self] in
            self?.cacheLock.lock()
            defer { self?.cacheLock.unlock() }
            self?.cache.removeValue(forKey: hostname)
        }
    }
    
    func clearCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        cache.removeAll()
    }
} 
