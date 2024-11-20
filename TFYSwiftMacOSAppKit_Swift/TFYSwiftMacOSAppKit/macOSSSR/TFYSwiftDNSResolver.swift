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
    
    // 解析主机名
    func resolve(_ hostname: String, completion: @escaping ([String]?) -> Void) {
        // 首先检查缓存
        if let cached = getCachedResult(for: hostname) {
            completion(cached)
            return
        }
        
        queue.async {
            var addresses: [String] = []
            var hints = addrinfo(
                ai_flags: AI_PASSIVE,
                ai_family: AF_INET,
                ai_socktype: SOCK_STREAM,
                ai_protocol: IPPROTO_TCP,
                ai_addrlen: 0,
                ai_canonname: nil,
                ai_addr: nil,
                ai_next: nil
            )
            
            var info: UnsafeMutablePointer<addrinfo>?
            let result = getaddrinfo(hostname, nil, &hints, &info)
            
            if result == 0, let firstInfo = info {
                var currentInfo: UnsafeMutablePointer<addrinfo>? = firstInfo
                while let info = currentInfo {
                    if let addr = info.pointee.ai_addr {
                        var hostnameBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(addr, socklen_t(info.pointee.ai_addrlen), &hostnameBuffer, socklen_t(hostnameBuffer.count), nil, 0, NI_NUMERICHOST) == 0 {
                            let address = String(cString: hostnameBuffer)
                            addresses.append(address)
                        }
                    }
                    currentInfo = info.pointee.ai_next
                }
                freeaddrinfo(firstInfo)
            }
            
            self.cacheResult(addresses, for: hostname)
            completion(addresses.isEmpty ? nil : addresses)
        }
    }
    
    // 获取缓存结果
    private func getCachedResult(for hostname: String) -> [String]? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return cache[hostname]
    }
    
    // 缓存解析结果
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
    
    // 清除缓存
    func clearCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        cache.removeAll()
    }
} 
