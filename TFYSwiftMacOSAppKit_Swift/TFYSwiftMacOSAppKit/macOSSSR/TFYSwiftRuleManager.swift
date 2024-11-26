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
    
    /// 规则组结构体
    public struct RuleGroup {
        let name: String
        let rules: [Rule]
        let isEnabled: Bool
        
        init(name: String, rules: [Rule], isEnabled: Bool = true) {
            self.name = name
            self.rules = rules
            self.isEnabled = isEnabled
        }
    }
    
    /// 规则优先级枚举
    public enum RulePriority: Int, Comparable {
        case high = 0
        case medium = 1
        case low = 2
        
        public static func < (lhs: RulePriority, rhs: RulePriority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    /// 规则匹配结果
    public struct MatchResult {
        let rule: Rule?
        let action: RuleAction
        let matchedPattern: String?
        
        init(rule: Rule? = nil, action: RuleAction = .direct, matchedPattern: String? = nil) {
            self.rule = rule
            self.action = action
            self.matchedPattern = matchedPattern
        }
    }
    
    /// 添加规则组
    /// - Parameter group: 规则组
    public func addRuleGroup(_ group: RuleGroup) {
        queue.async {
            self.ruleGroups[group.name] = group
            self.saveRules()
        }
    }
    
    /// 删除规则组
    /// - Parameter name: 规则组名称
    public func removeRuleGroup(name: String) {
        queue.async {
            self.ruleGroups.removeValue(forKey: name)
            self.saveRules()
        }
    }
    
    /// 更新规则组
    /// - Parameter group: 规则组
    public func updateRuleGroup(_ group: RuleGroup) {
        queue.async {
            self.ruleGroups[group.name] = group
            self.saveRules()
        }
    }
    
    /// 匹配规则
    /// - Parameters:
    ///   - domain: 域名
    ///   - ip: IP地址
    ///   - userAgent: User-Agent
    /// - Returns: 匹配结果
    public func matchRules(domain: String? = nil, ip: String? = nil, userAgent: String? = nil) -> MatchResult {
        return queue.sync {
            // 按优先级排序规则组
            let sortedGroups = ruleGroups.values
                .filter { $0.isEnabled }
                .sorted { $0.rules.first?.priority ?? .low < $1.rules.first?.priority ?? .low }
            
            // 遍历规则组进行匹配
            for group in sortedGroups {
                for rule in group.rules {
                    if let matchedPattern = matchRule(rule, domain: domain, ip: ip, userAgent: userAgent) {
                        return MatchResult(rule: rule, action: rule.action, matchedPattern: matchedPattern)
                    }
                }
            }
            
            // 未匹配到规则，返回默认动作
            return MatchResult(action: defaultAction)
        }
    }
    
    /// 匹配单条规则
    private func matchRule(_ rule: Rule, domain: String?, ip: String?, userAgent: String?) -> String? {
        switch rule.type {
        case .domain(let pattern):
            if let domain = domain, matchDomain(pattern: pattern, domain: domain) {
                return pattern
            }
            
        case .ipRange(let pattern):
            if let ip = ip, matchIP(pattern: pattern, ip: ip) {
                return pattern
            }
            
        case .userAgent(let pattern):
            if let userAgent = userAgent, matchUserAgent(pattern: pattern, userAgent: userAgent) {
                return pattern
            }
        }
        
        return nil
    }
    
    /// 导入规则
    /// - Parameter url: 规则文件URL
    /// - Parameter completion: 完成回调
    public func importRules(from url: URL, completion: @escaping (Result<Int, Error>) -> Void) {
        queue.async {
            do {
                let data = try Data(contentsOf: url)
                let rules = try self.parseRules(from: data)
                
                // 创建新规则组
                let groupName = url.deletingPathExtension().lastPathComponent
                let group = RuleGroup(name: groupName, rules: rules)
                
                // 添加规则组
                self.ruleGroups[groupName] = group
                self.saveRules()
                
                completion(.success(rules.count))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// 解析规则文件
    private func parseRules(from data: Data) throws -> [Rule] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw TFYSwiftError.invalidData("无效的规则文件格式")
        }
        
        var rules: [Rule] = []
        
        // 按行解析规则
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 跳过空行和注释
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
                continue
            }
            
            // 解析规则
            if let rule = parseRule(from: trimmed) {
                rules.append(rule)
            }
        }
        
        return rules
    }
    
    /// 解析单条规则
    private func parseRule(from line: String) -> Rule? {
        // 解析规则格式：类型,模式,动作,描述
        let components = line.components(separatedBy: ",")
        guard components.count >= 3 else { return nil }
        
        let typeStr = components[0].trimmingCharacters(in: .whitespaces)
        let pattern = components[1].trimmingCharacters(in: .whitespaces)
        let actionStr = components[2].trimmingCharacters(in: .whitespaces)
        let description = components.count > 3 ? components[3].trimmingCharacters(in: .whitespaces) : ""
        
        // 解析规则类型
        let type: RuleType
        switch typeStr.lowercased() {
        case "domain":
            type = .domain(pattern)
        case "ip":
            type = .ipRange(pattern)
        case "useragent":
            type = .userAgent(pattern)
        default:
            return nil
        }
        
        // 解析动作
        let action: RuleAction
        switch actionStr.lowercased() {
        case "proxy":
            action = .proxy
        case "direct":
            action = .direct
        case "reject":
            action = .reject
        default:
            return nil
        }
        
        return Rule(type: type, action: action, description: description)
    }
    
    /// 保存规则到文件
    private func saveRules() {
        do {
            let data = try JSONEncoder().encode(ruleGroups)
            try data.write(to: rulesFileURL)
            logInfo("规则保存成功")
        } catch {
            logError("保存规则失败: \(error)")
        }
    }
    
    /// 加载规则从文件
    private func loadRules() {
        guard FileManager.default.fileExists(atPath: rulesFileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: rulesFileURL)
            ruleGroups = try JSONDecoder().decode([String: RuleGroup].self, from: data)
            logInfo("规则加载成功")
        } catch {
            logError("加载规则失败: \(error)")
        }
    }
} 
