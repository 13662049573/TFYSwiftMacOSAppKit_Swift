//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
//import MaxMindDB

class TFYSwiftRuleManager {
    enum RuleType: String, Codable {
        case domain      // 域名规则
        case ipCIDR     // IP CIDR规则
        case geoIP      // GeoIP规则
        case userAgent  // User-Agent规则
        case final      // 最终规则
    }
    
    enum RuleAction: String, Codable {
        case proxy      // 使用代理
        case direct     // 直接连接
        case reject     // 拒绝连接
        case bypassSSL  // 绕过SSL
    }
    
    struct Rule: Codable {
        let type: RuleType
        let pattern: String
        let action: RuleAction
        let enabled: Bool
        
        init(type: RuleType, pattern: String, action: RuleAction, enabled: Bool = true) {
            self.type = type
            self.pattern = pattern
            self.action = action
            self.enabled = enabled
        }
    }
    
    private var rules: [Rule] = []
    private let queue = DispatchQueue(label: "com.tfyswift.rules")
    private let rulesPath: URL
    
    // 示例的 IP 范围到国家代码的映射
    private let ipCountryMapping: [(range: ClosedRange<UInt32>, countryCode: String)] = [
        (range: 167772160...184549375, countryCode: "US"), // 10.0.0.0/8
        (range: 2886729728...2887778303, countryCode: "CN"), // 172.16.0.0/12
        (range: 3232235520...3232301055, countryCode: "US"), // 192.168.0.0/16
        (range: 2155905152...2170556415, countryCode: "JP"), // 128.0.0.0/8
        (range: 167837696...167837951, countryCode: "FR"), // 10.1.0.0/24
        (range: 167837952...167838207, countryCode: "DE"), // 10.1.1.0/24
        (range: 167838208...167838463, countryCode: "GB"), // 10.1.2.0/24
        (range: 167838464...167838719, countryCode: "AU"), // 10.1.3.0/24
        (range: 167838720...167838975, countryCode: "IN"), // 10.1.4.0/24
        (range: 167838976...167839231, countryCode: "BR"), // 10.1.5.0/24
        (range: 167839232...167839487, countryCode: "RU"), // 10.1.6.0/24
        (range: 167839488...167839743, countryCode: "ZA"), // 10.1.7.0/24
        (range: 167839744...167839999, countryCode: "CA"), // 10.1.8.0/24
        (range: 167840000...167840255, countryCode: "IT"), // 10.1.9.0/24
        (range: 167840256...167840511, countryCode: "ES"), // 10.1.10.0/24
        // 添加更多的 IP 范围和国家代码
    ]
    
    init() throws {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(for: .applicationSupportDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
        rulesPath = appSupport.appendingPathComponent("TFYSwift/rules.json")
        loadRules()
    }
    
    // 加载规则
    private func loadRules() {
        do {
            let data = try Data(contentsOf: rulesPath)
            rules = try JSONDecoder().decode([Rule].self, from: data)
        } catch {
            // 加载默认规则
            rules = defaultRules()
            try? saveRules()
        }
    }
    
    // 保存规则
    private func saveRules() throws {
        let data = try JSONEncoder().encode(rules)
        try data.write(to: rulesPath)
    }
    
    // 默认规则
    private func defaultRules() -> [Rule] {
        return [
            Rule(type: .domain, pattern: "*.local", action: .direct),
            Rule(type: .ipCIDR, pattern: "192.168.0.0/16", action: .direct),
            Rule(type: .ipCIDR, pattern: "10.0.0.0/8", action: .direct),
            Rule(type: .ipCIDR, pattern: "172.16.0.0/12", action: .direct),
            Rule(type: .geoIP, pattern: "CN", action: .direct),
            Rule(type: .final, pattern: "*", action: .proxy)
        ]
    }
    
    // 添加规则
    func addRule(_ rule: Rule) throws {
        queue.sync {
            rules.append(rule)
            try? saveRules()
        }
    }
    
    // 删除规则
    func removeRule(at index: Int) throws {
        queue.sync {
            guard index < rules.count else { return }
            rules.remove(at: index)
            try? saveRules()
        }
    }
    
    // 更新规则
    func updateRule(at index: Int, with rule: Rule) throws {
        queue.sync {
            guard index < rules.count else { return }
            rules[index] = rule
            try? saveRules()
        }
    }
    
    // 匹配规则
    func matchRules(domain: String? = nil, ip: String? = nil, userAgent: String? = nil) -> RuleAction {
        return queue.sync {
            for rule in rules where rule.enabled {
                if let match = matchRule(rule, domain: domain, ip: ip, userAgent: userAgent) {
                    return match
                }
            }
            return .proxy // 默认使用代理
        }
    }
    
    // 规则匹配逻辑
    private func matchRule(_ rule: Rule, domain: String?, ip: String?, userAgent: String?) -> RuleAction? {
        switch rule.type {
        case .domain:
            guard let domain = domain else { return nil }
            if matchDomain(pattern: rule.pattern, domain: domain) {
                return rule.action
            }
            
        case .ipCIDR:
            guard let ip = ip else { return nil }
            if matchIPCIDR(pattern: rule.pattern, ip: ip) {
                return rule.action
            }
            
        case .geoIP:
            guard let ip = ip else { return nil }
            if matchGeoIP(pattern: rule.pattern, ip: ip) {
                return rule.action
            }
            
        case .userAgent:
            guard let userAgent = userAgent else { return nil }
            if matchUserAgent(pattern: rule.pattern, userAgent: userAgent) {
                return rule.action
            }
            
        case .final:
            return rule.action
        }
        
        return nil
    }
    
    // 域名匹配
    private func matchDomain(pattern: String, domain: String) -> Bool {
        let patternParts = pattern.split(separator: ".")
        let domainParts = domain.split(separator: ".")
        
        guard patternParts.count <= domainParts.count else { return false }
        
        let patternReversed = Array(patternParts.reversed())
        let domainReversed = Array(domainParts.reversed())
        
        for i in 0..<patternReversed.count {
            if patternReversed[i] != "*" && patternReversed[i] != domainReversed[i] {
                return false
            }
        }
        
        return true
    }
    
    // IP CIDR匹配
    private func matchIPCIDR(pattern: String, ip: String) -> Bool {
        let components = pattern.split(separator: "/")
        guard components.count == 2,
              let networkAddress = ipToUInt32(ip: String(components[0])),
              let prefixLength = Int(components[1]),
              let targetIP = ipToUInt32(ip: ip) else {
            return false
        }
        let mask = UInt32.max << (32 - prefixLength)
        return (networkAddress & mask) == (targetIP & mask)
    }
    
    // 将 IP 地址转换为 UInt32
    private func ipToUInt32(ip: String) -> UInt32? {
        let components = ip.split(separator: ".").compactMap { UInt8($0) }
        guard components.count == 4 else { return nil }
        return (UInt32(components[0]) << 24) | (UInt32(components[1]) << 16) | (UInt32(components[2]) << 8) | UInt32(components[3])
    }
    
    // GeoIP匹配
    private func matchGeoIP(pattern: String, ip: String) -> Bool {
        guard let ipValue = ipToUInt32(ip: ip) else { return false }
        
        for mapping in ipCountryMapping {
            if mapping.range.contains(ipValue) {
                return mapping.countryCode == pattern
            }
        }
        return false
    }
    
    // GeoIP匹配 
//    private func matchGeoIP(pattern: String, ip: String) -> Bool {
//        guard let dbPath = Bundle.main.path(forResource: "GeoLite2-Country", ofType: "mmdb"),
//              let reader = MMDBReader(url: URL(fileURLWithPath: dbPath)) else {
//            return false
//        }
//        
//        do {
//            let result = try reader.lookup(ipAddress: ip)
//            if let country = result?.country?.isoCode {
//                return country == pattern
//            }
//        } catch {
//            print("GeoIP lookup error: \(error)")
//        }
//        
//        return false
//    }
    
    // User-Agent匹配
    private func matchUserAgent(pattern: String, userAgent: String) -> Bool {
        return userAgent.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
} 
