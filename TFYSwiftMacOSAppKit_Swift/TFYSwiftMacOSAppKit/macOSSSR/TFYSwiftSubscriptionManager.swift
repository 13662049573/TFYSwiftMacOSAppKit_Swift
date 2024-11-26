import Foundation

/// 订阅节点结构 - 用于解析和存储单个SSR节点的配置信息
public struct SubscriptionNode: Codable {
    let server: String          // 服务器地址
    let server_port: Int        // 服务器端口
    let password: String        // 密码
    let method: String          // 加密方法
    let protocolType: String    // 协议（改名避免关键字冲突）
    let protocol_param: String? // 协议参数
    let obfs: String           // 混淆
    let obfs_param: String?    // 混淆参数
    let remarks: String?       // 节点备注
    let group: String?         // 节点分组
    
    // 用于 Codable 的编码键
    enum CodingKeys: String, CodingKey {
        case server
        case server_port
        case password
        case method
        case protocolType = "protocol"  // 将 protocolType 映射到 JSON 中的 "protocol" 键
        case protocol_param
        case obfs
        case obfs_param
        case remarks
        case group
    }
}

/// 订阅管理器类 - 负责处理SSR订阅的更新和解析
public class TFYSwiftSubscriptionManager {
    private let configManager: TFYSwiftConfigManager
    private let queue = DispatchQueue(label: "com.tfyswift.subscription")
    
    /// 初始化订阅管理器
    /// - Parameter configManager: 配置管理器实例
    init(configManager: TFYSwiftConfigManager) {
        self.configManager = configManager
    }
    
    /// 更新订阅
    /// - Parameters:
    ///   - url: 订阅地址URL
    ///   - completion: 完成回调，返回配置列表或错误
    public func updateSubscription(url: URL, completion: @escaping (Result<[ServerConfig], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let configs = try? self?.parseSubscriptionData(data) else {
                completion(.failure(TFYSwiftError.invalidData("无效的订阅数据")))
                return
            }
            
            completion(.success(configs))
        }
        task.resume()
    }
    
    /// 解析订阅数据
    private func parseSubscriptionData(_ data: Data) throws -> [ServerConfig] {
        // 1. 解码 Base64 数据
        guard let decodedString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let decodedData = Data(base64Encoded: decodedString) else {
            throw TFYSwiftError.invalidData("无效的Base64数据")
        }
        
        // 2. 解析 SSR 链接
        guard let linksString = String(data: decodedData, encoding: .utf8) else {
            throw TFYSwiftError.invalidData("无效的SSR链接")
        }
        
        // 3. 分割多个链接
        let links = linksString.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // 4. 解析每个链接
        return try links.compactMap { link -> ServerConfig? in
            guard link.hasPrefix("ssr://") else { return nil }
            
            // 移除 "ssr://" 前缀并解码
            let base64String = String(link.dropFirst(6))
            guard let data = Data(base64Encoded: base64String),
                  let content = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            // 解析 SSR 参数
            let parts = content.components(separatedBy: ":")
            guard parts.count >= 6 else { return nil }
            
            let serverHost = parts[0]
            guard let serverPort = UInt16(parts[1]),
                  let protocol = parts[2],
                  let method = parts[3],
                  let obfs = parts[4] else {
                return nil
            }
            
            // 解析剩余参数
            let remainingParts = parts[5].components(separatedBy: "/?")
            guard let passwordBase64 = remainingParts[0],
                  let password = String(data: Data(base64Encoded: passwordBase64)!, encoding: .utf8) else {
                return nil
            }
            
            // 创建服务器配置
            return ServerConfig(
                serverHost: serverHost,
                serverPort: serverPort,
                password: password,
                method: method,
                protocolType: protocol,
                obfs: obfs,
                remarks: nil,
                group: nil
            )
        }
    }
}

// 添加订阅管理功能

extension TFYSwiftSubscriptionManager {
    /// 订阅配置
    public struct SubscriptionConfig: Codable {
        let url: URL
        let name: String
        let autoUpdate: Bool
        let updateInterval: TimeInterval
        let lastUpdate: Date?
        
        public init(
            url: URL,
            name: String,
            autoUpdate: Bool = true,
            updateInterval: TimeInterval = 86400, // 默认24小时
            lastUpdate: Date? = nil
        ) {
            self.url = url
            self.name = name
            self.autoUpdate = autoUpdate
            self.updateInterval = updateInterval
            self.lastUpdate = lastUpdate
        }
    }
    
    /// 订阅状态
    public enum SubscriptionStatus {
        case idle
        case updating
        case error(Error)
    }
    
    /// 添加订阅
    /// - Parameters:
    ///   - url: 订阅URL
    ///   - name: 订阅名称
    ///   - completion: 完成回调
    public func addSubscription(
        url: URL,
        name: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        queue.async {
            // 检查是否已存在相同URL的订阅
            guard !self.subscriptions.contains(where: { $0.url == url }) else {
                completion(.failure(TFYSwiftError.duplicateSubscription))
                return
            }
            
            let config = SubscriptionConfig(url: url, name: name)
            self.subscriptions.append(config)
            
            // 保存配置
            self.saveSubscriptions()
            
            // 立即更新订阅
            self.updateSubscription(config) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 更新订阅
    /// - Parameters:
    ///   - config: 订阅配置
    ///   - completion: 完成回调
    public func updateSubscription(
        _ config: SubscriptionConfig,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        queue.async {
            self.status = .updating
            
            let request = URLRequest(url: config.url, cachePolicy: .reloadIgnoringLocalCacheData)
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.status = .error(error)
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = TFYSwiftError.invalidData("Empty subscription data")
                    self.status = .error(error)
                    completion(.failure(error))
                    return
                }
                
                do {
                    // 解析订阅数据
                    let servers = try self.parseSubscriptionData(data)
                    
                    // 更新服务器配置
                    self.updateServerConfigs(servers, from: config)
                    
                    // 更新最后更新时间
                    var updatedConfig = config
                    updatedConfig = SubscriptionConfig(
                        url: config.url,
                        name: config.name,
                        autoUpdate: config.autoUpdate,
                        updateInterval: config.updateInterval,
                        lastUpdate: Date()
                    )
                    
                    if let index = self.subscriptions.firstIndex(where: { $0.url == config.url }) {
                        self.subscriptions[index] = updatedConfig
                    }
                    
                    // 保存配置
                    self.saveSubscriptions()
                    
                    self.status = .idle
                    completion(.success(()))
                    
                } catch {
                    self.status = .error(error)
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    /// 删除订阅
    /// - Parameters:
    ///   - url: 订阅URL
    ///   - removeServers: 是否同时删除相关服务器
    public func removeSubscription(
        url: URL,
        removeServers: Bool = false,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        queue.async {
            guard let index = self.subscriptions.firstIndex(where: { $0.url == url }) else {
                completion(.failure(TFYSwiftError.subscriptionNotFound))
                return
            }
            
            let config = self.subscriptions[index]
            self.subscriptions.remove(at: index)
            
            if removeServers {
                // 删除相关服务器配置
                self.removeServerConfigs(from: config)
            }
            
            // 保存配置
            self.saveSubscriptions()
            
            completion(.success(()))
        }
    }
    
    /// 检查订阅更新
    public func checkSubscriptionUpdates() {
        queue.async {
            let now = Date()
            
            for subscription in self.subscriptions where subscription.autoUpdate {
                // 检查是否需要更新
                if let lastUpdate = subscription.lastUpdate,
                   now.timeIntervalSince(lastUpdate) < subscription.updateInterval {
                    continue
                }
                
                // 更新订阅
                self.updateSubscription(subscription) { _ in }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func parseSubscriptionData(_ data: Data) throws -> [ServerConfig] {
        // 解码Base64数据
        guard let decodedString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let decodedData = Data(base64Encoded: decodedString) else {
            throw TFYSwiftError.invalidData("Invalid Base64 data")
        }
        
        // 解析SSR链接
        guard let linksString = String(data: decodedData, encoding: .utf8) else {
            throw TFYSwiftError.invalidData("Invalid decoded data")
        }
        
        return try linksString.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { try parseSSRLink($0) }
    }
    
    private func parseSSRLink(_ link: String) throws -> ServerConfig {
        // 实现SSR链接解析逻辑
        // 返回ServerConfig实例
        return ServerConfig(id: UUID().uuidString,
                          serverHost: "",
                          serverPort: 0,
                          password: "",
                          method: "",
                          protocolType: "",
                          obfs: "")
    }
    
    private func updateServerConfigs(_ servers: [ServerConfig], from subscription: SubscriptionConfig) {
        // 更新服务器配置的实现
    }
    
    private func removeServerConfigs(from subscription: SubscriptionConfig) {
        // 删除服务器配置的实现
    }
    
    private func saveSubscriptions() {
        do {
            let data = try JSONEncoder().encode(subscriptions)
            try data.write(to: subscriptionsURL)
        } catch {
            logError("Failed to save subscriptions: \(error)")
        }
    }
    
    private func loadSubscriptions() {
        guard FileManager.default.fileExists(atPath: subscriptionsURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: subscriptionsURL)
            subscriptions = try JSONDecoder().decode([SubscriptionConfig].self, from: data)
        } catch {
            logError("Failed to load subscriptions: \(error)")
        }
    }
}