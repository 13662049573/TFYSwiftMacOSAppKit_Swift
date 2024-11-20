//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

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
        // 实现IP CIDR匹配逻辑
        return false
    }
    
    // GeoIP匹配
    private func matchGeoIP(pattern: String, ip: String) -> Bool {
        // 实现GeoIP匹配逻辑
        return false
    }
    
    // User-Agent匹配
    private func matchUserAgent(pattern: String, userAgent: String) -> Bool {
        return userAgent.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
} 
