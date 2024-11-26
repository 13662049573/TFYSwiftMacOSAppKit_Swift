//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// DNS解析器类 - 负责域名解析和缓存管理
public class TFYSwiftDNSResolver {
    /// 用于DNS解析操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.dns")
    
    /// DNS解析结果缓存，键为域名，值为缓存条目
    private var cache: [String: CacheEntry] = [:]
    
    /// 用于保护缓存访问的锁
    private let cacheLock = NSLock()
    
    /// 缓存超时时间（300秒 = 5分钟）
    private let cacheTimeout: TimeInterval = 300
    
    /// 缓存条目结构体 - 存储DNS解析结果及其相关信息
    private struct CacheEntry {
        let addresses: [String]     // IP地址列表
        let timestamp: Date         // 缓存创建时间
        let ttl: TimeInterval       // 生存时间
        
        /// 判断缓存是否过期
        var isExpired: Bool {
            return Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    /// 解析域名为IP地址
    /// - Parameters:
    ///   - hostname: 要解析的域名
    ///   - completion: 解析完成的回调，参数为解析得到的IP地址数组，失败则为nil
    func resolve(_ hostname: String, completion: @escaping ([String]?) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 首先检查缓存中是否有有效结果
            if let cached = self.getCachedResult(for: hostname) {
                completion(cached)
                return
            }
            
            // 使用系统DNS解析功能
            let host = CFHostCreateWithName(kCFAllocatorDefault, hostname as CFString).takeRetainedValue()
            
            if CFHostStartInfoResolution(host, .addresses, nil) {
                if let addresses = CFHostGetAddressing(host, nil)?.takeUnretainedValue() as NSArray? {
                    var result: [String] = []
                    
                    // 遍历解析得到的地址
                    for case let addr as NSData in addresses {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        
                        // 将地址转换为字符串形式
                        if getnameinfo(addr.bytes.assumingMemoryBound(to: sockaddr.self),
                                     socklen_t(addr.length),
                                     &hostname,
                                     socklen_t(hostname.count),
                                     nil,
                                     0,
                                     NI_NUMERICHOST) == 0 {
                            if let address = String(cString: hostname, encoding: .utf8) {
                                result.append(address)
                            }
                        }
                    }
                    
                    // 如果成功解析到地址，则缓存结果并返回
                    if !result.isEmpty {
                        self.cacheResult(result, for: hostname)
                        completion(result)
                        return
                    }
                }
            }
            
            // 解析失败，返回nil
            completion(nil)
        }
    }
    
    /// 从缓存中获取解析结果
    /// - Parameter hostname: 域名
    /// - Returns: 缓存的IP地址数组，如果缓存不存在或已过期则返回nil
    private func getCachedResult(for hostname: String) -> [String]? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        
        if let entry = cache[hostname], !entry.isExpired {
            return entry.addresses
        }
        return nil
    }
    
    /// 将解析结果存入缓存
    /// - Parameters:
    ///   - addresses: IP地址数组
    ///   - hostname: 对应的域名
    private func cacheResult(_ addresses: [String], for hostname: String) {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        
        cache[hostname] = CacheEntry(
            addresses: addresses,
            timestamp: Date(),
            ttl: cacheTimeout
        )
    }
    
    /// 清除所有缓存
    func clearCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        cache.removeAll()
    }
    
    /// DNS 解析结果
    public struct DNSResult {
        let addresses: [String]
        let timestamp: Date
        let ttl: TimeInterval
        
        var isExpired: Bool {
            return Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    /// DNS 解析选项
    public struct DNSOptions {
        let timeout: TimeInterval
        let useCache: Bool
        let preferIPv6: Bool
        
        public init(
            timeout: TimeInterval = 5.0,
            useCache: Bool = true,
            preferIPv6: Bool = false
        ) {
            self.timeout = timeout
            self.useCache = useCache
            self.preferIPv6 = preferIPv6
        }
    }
    
    /// 异步解析域名
    /// - Parameters:
    ///   - hostname: 域名
    ///   - options: 解析选项
    ///   - completion: 完成回调
    public func resolve(
        _ hostname: String,
        options: DNSOptions = DNSOptions(),
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        queue.async {
            // 检查缓存
            if options.useCache, let cached = self.getCachedResult(for: hostname) {
                completion(.success(cached))
                return
            }
            
            // 创建 NWEndpoint.Host
            let host = NWEndpoint.Host(hostname)
            
            // 创建连接参数
            var parameters = NWParameters()
            parameters.preferNoProxies = true
            
            // 设置地址类型
            if options.preferIPv6 {
                parameters.requiredInterfaceType = .ipv6
            } else {
                parameters.requiredInterfaceType = .ipv4
            }
            
            // 创建连接
            let connection = NWConnection(
                host: host,
                port: 80,
                using: parameters
            )
            
            // 设置状态处理
            connection.stateUpdateHandler = { [weak self] state in
                switch state {
                case .preparing:
                    break
                    
                case .ready:
                    // 获取连接的远程地址
                    if let endpoint = connection.currentPath?.remoteEndpoint,
                       let addresses = self?.extractAddresses(from: endpoint) {
                        // 缓存结果
                        self?.cacheResult(addresses, for: hostname)
                        completion(.success(addresses))
                    } else {
                        completion(.failure(TFYSwiftError.networkError("无法获取远程地址")))
                    }
                    connection.cancel()
                    
                case .failed(let error):
                    completion(.failure(error))
                    connection.cancel()
                    
                case .cancelled:
                    break
                    
                default:
                    break
                }
            }
            
            // 设置超时
            self.queue.asyncAfter(deadline: .now() + options.timeout) {
                if connection.state != .cancelled {
                    connection.cancel()
                    completion(.failure(TFYSwiftError.networkError("DNS解析超时")))
                }
            }
            
            // 启动连接
            connection.start(queue: self.queue)
        }
    }
    
    /// 从端点提取地址
    private func extractAddresses(from endpoint: NWEndpoint) -> [String]? {
        switch endpoint {
        case .hostPort(let host, _):
            return [host.debugDescription]
        default:
            return nil
        }
    }
    
    /// 清理过期缓存
    private func cleanExpiredCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        
        let now = Date()
        cache = cache.filter { !$0.value.isExpired }
    }
} 
