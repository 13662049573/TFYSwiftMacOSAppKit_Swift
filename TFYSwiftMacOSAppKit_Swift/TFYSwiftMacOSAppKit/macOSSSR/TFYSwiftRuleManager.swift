//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
//import MaxMindDB

/// 规则管理器类 - 负责管理和匹配代理规则
public class TFYSwiftRuleManager {
    /// 规则类型枚举
    enum RuleType {
        case domain(String)      // 域名规则，如：*.example.com
        case ipRange(String)     // IP范围规则，如：192.168.1.0/24
        case userAgent(String)   // User-Agent规则，用于匹配浏览器标识
    }
    
    /// 规则动作枚举
    enum RuleAction {
        case proxy              // 使用代理访问
        case direct             // 直接访问
        case reject             // 拒绝访问
    }
    
    /// 规则结构体 - 定义单条规则的结构
    struct Rule {
        let type: RuleType      // 规则类型
        let action: RuleAction  // 规则动作
        let description: String // 规则描述
    }
    
    /// 用于同步规则操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.rulemanager")
    /// 存储所有规则的数组
    private var rules: [Rule] = []
    
    /// 从文件加载规则
    /// - Parameter url: 规则文件的URL
    /// - Throws: 加载失败时抛出错误
    func loadRules(from url: URL) throws {
        let content = try String(contentsOf: url, encoding: .utf8)
        let newRules = try parseRules(content)
        
        queue.sync {
            self.rules = newRules
        }
    }
    
    /// 解析规则文本内容
    /// - Parameter content: 规则文本内容
    /// - Returns: 解析后的规则数组
    private func parseRules(_ content: String) throws -> [Rule] {
        return content.components(separatedBy: .newlines)
            .filter { !$0.isEmpty && !$0.hasPrefix("#") } // 过滤空行和注释
            .compactMap { line -> Rule? in
                let components = line.components(separatedBy: ",")
                guard components.count >= 3 else { return nil }
                
                let typeStr = components[0].trimmingCharacters(in: .whitespaces)
                let pattern = components[1].trimmingCharacters(in: .whitespaces)
                let actionStr = components[2].trimmingCharacters(in: .whitespaces)
                
                guard let type = parseRuleType(typeStr, pattern: pattern),
                      let action = parseRuleAction(actionStr) else {
                    return nil
                }
                
                return Rule(
                    type: type,
                    action: action,
                    description: components.count > 3 ? components[3] : ""
                )
            }
    }
    
    /// 解析规则类型
    /// - Parameters:
    ///   - type: 规则类型字符串
    ///   - pattern: 规则匹配模式
    /// - Returns: 规则类型枚举值
    private func parseRuleType(_ type: String, pattern: String) -> RuleType? {
        switch type.lowercased() {
        case "domain":
            return .domain(pattern)
        case "ip":
            return .ipRange(pattern)
        case "useragent":
            return .userAgent(pattern)
        default:
            return nil
        }
    }
    
    /// 解析规则动作
    /// - Parameter action: 规则动作字符串
    /// - Returns: 规则动作枚举值
    private func parseRuleAction(_ action: String) -> RuleAction? {
        switch action.lowercased() {
        case "proxy":
            return .proxy
        case "direct":
            return .direct
        case "reject":
            return .reject
        default:
            return nil
        }
    }
    
    /// 匹配规则
    /// - Parameters:
    ///   - domain: 域名
    ///   - ip: IP地址
    ///   - userAgent: 用户代理字符串
    /// - Returns: 匹配到的规则动作
    func matchRule(domain: String? = nil, ip: String? = nil, userAgent: String? = nil) -> RuleAction {
        return queue.sync {
            for rule in rules {
                switch rule.type {
                case .domain(let pattern):
                    if let domain = domain, matchDomain(pattern: pattern, domain: domain) {
                        return rule.action
                    }
                case .ipRange(let pattern):
                    if let ip = ip, matchIP(pattern: pattern, ip: ip) {
                        return rule.action
                    }
                case .userAgent(let pattern):
                    if let userAgent = userAgent, matchUserAgent(pattern: pattern, userAgent: userAgent) {
                        return rule.action
                    }
                }
            }
            return .direct  // 默认直连
        }
    }
    
    /// 域名匹配
    private func matchDomain(pattern: String, domain: String) -> Bool {
        if pattern.hasPrefix("*.") {
            let suffix = pattern.dropFirst(2)
            return domain.hasSuffix(suffix)
        }
        return pattern == domain
    }
    
    /// IP匹配
    private func matchIP(pattern: String, ip: String) -> Bool {
        // 简单IP匹配，可以根据需要扩展CIDR匹配
        return pattern == ip
    }
    
    /// User-Agent匹配
    private func matchUserAgent(pattern: String, userAgent: String) -> Bool {
        return userAgent.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
} 
