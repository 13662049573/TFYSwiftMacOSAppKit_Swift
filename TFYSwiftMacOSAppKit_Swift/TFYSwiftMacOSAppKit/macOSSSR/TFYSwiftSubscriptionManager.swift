import Foundation

/// 订阅节点结构
struct SubscriptionNode: Codable {
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

/// 订阅管理器类
class TFYSwiftSubscriptionManager {
    // 将 config 改为可变属性
    private var config: TFYSwiftConfig
    // 专用队列用于处理订阅更新
    private let queue = DispatchQueue(label: "com.tfyswift.subscription")
    // 自动更新定时器
    private var updateTimer: Timer?
    
    /// 初始化订阅管理器
    /// - Parameter config: 配置对象
    init(config: TFYSwiftConfig) {
        self.config = config
    }
    
    /// 添加订阅
    /// - Parameter url: 订阅URL
    func addSubscription(_ url: String) {
        // 创建新的配置副本
        var newConfig = config
        if !newConfig.subscribeUrls.contains(url) {
            // 添加新的订阅URL
            newConfig.subscribeUrls.append(url)
            // 更新配置
            config = newConfig
            // 保存配置
            try? config.save()
            print("已添加订阅: \(url)")
        }
    }
    
    /// 移除订阅
    /// - Parameter url: 要移除的订阅URL
    func removeSubscription(_ url: String) {
        var newConfig = config
        if let index = newConfig.subscribeUrls.firstIndex(of: url) {
            // 移除指定的订阅URL
            newConfig.subscribeUrls.remove(at: index)
            // 更新配置
            config = newConfig
            // 保存配置
            try? config.save()
            print("已移除订阅: \(url)")
        }
    }
    
    /// 更新所有订阅
    /// - Parameter completion: 完成回调，返回可能的错误
    func updateSubscriptions(completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        // 遍历所有订阅URL进行更新
        for url in config.subscribeUrls {
            group.enter()
            updateSubscription(url) { error in
                if let error = error {
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        // 所有更新完成后的处理
        group.notify(queue: queue) {
            completion(errors.first)
            try? self.config.save()
        }
    }
    
    /// 更新单个订阅
    /// - Parameters:
    ///   - url: 订阅URL
    ///   - completion: 完成回调
    private func updateSubscription(_ url: String, completion: @escaping (Error?) -> Void) {
        guard let subscriptionURL = URL(string: url) else {
            completion(TFYSwiftError.configurationError("无效的订阅URL"))
            return
        }
        
        // 发起网络请求获取订阅内容
        let task = URLSession.shared.dataTask(with: subscriptionURL) { [weak self] data, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            // 解码Base64数据
            guard let data = data,
                  let base64Decoded = Data(base64Encoded: data),
                  let configString = String(data: base64Decoded, encoding: .utf8) else {
                completion(TFYSwiftError.configurationError("无效的订阅数据"))
                return
            }
            
            self?.parseSubscriptionConfig(configString, completion: completion)
        }
        
        task.resume()
    }
    
    /// 解析订阅配置
    /// - Parameters:
    ///   - configString: 配置字符串
    ///   - completion: 完成回调
    private func parseSubscriptionConfig(_ configString: String, completion: @escaping (Error?) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 分割多行配置
            let lines = configString.components(separatedBy: .newlines)
            var newNodes: [SubscriptionNode] = []
            
            for line in lines {
                // 跳过空行
                guard !line.trimmingCharacters(in: .whitespaces).isEmpty else {
                    continue
                }
                
                do {
                    // 尝试解析 SSR URL
                    if let node = try self.parseSSRURL(line) {
                        newNodes.append(node)
                    }
                } catch {
                    print("解析节点失败: \(error.localizedDescription)")
                }
            }
            
            if newNodes.isEmpty {
                completion(TFYSwiftError.configurationError("未找到有效的节点配置"))
                return
            }
            
            // 更新配置
            self.updateConfig(with: newNodes)
            completion(nil)
        }
    }
    
    /// 解析 SSR URL
    /// - Parameter url: SSR URL 字符串
    /// - Returns: 解析后的节点配置
    private func parseSSRURL(_ url: String) throws -> SubscriptionNode? {
        // 验证 URL 格式
        guard url.hasPrefix("ssr://") else {
            return nil
        }
        
        // 移除 "ssr://" 前缀
        let base64String = String(url.dropFirst(6))
        
        // Base64 解码
        guard let decodedData = Data(base64Encoded: base64String.padding(toLength: ((base64String.count + 3) / 4) * 4,
                                                                        withPad: "=",
                                                                        startingAt: 0)),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            throw TFYSwiftError.configurationError("无效的 Base64 编码")
        }
        
        // 解析 SSR 参数
        let components = decodedString.components(separatedBy: ":")
        guard components.count >= 6 else {
            throw TFYSwiftError.configurationError("无效的 SSR 配置格式")
        }
        
        // 解析主要参数
        let server = components[0]
        let port = Int(components[1]) ?? 0
        let protocolType = components[2]  // 使用新的变量名
        let method = components[3]
        let obfs = components[4]
        
        // 解析剩余参数
        let remainingBase64 = components[5].components(separatedBy: "/?")
        guard let passwordData = Data(base64Encoded: remainingBase64[0].padding(toLength: ((remainingBase64[0].count + 3) / 4) * 4,
                                                                              withPad: "=",
                                                                              startingAt: 0)),
              let password = String(data: passwordData, encoding: .utf8) else {
            throw TFYSwiftError.configurationError("无效的密码编码")
        }
        
        // 解析附加参数
        var remarks: String?
        var protocolParam: String?
        var obfsParam: String?
        var group: String?
        
        if remainingBase64.count > 1 {
            let params = remainingBase64[1].components(separatedBy: "&")
            for param in params {
                let keyValue = param.components(separatedBy: "=")
                if keyValue.count == 2 {
                    let key = keyValue[0]
                    let value = keyValue[1]
                    
                    if let decodedValue = decodeBase64URL(value) {
                        switch key {
                        case "remarks":
                            remarks = decodedValue
                        case "protoparam":
                            protocolParam = decodedValue
                        case "obfsparam":
                            obfsParam = decodedValue
                        case "group":
                            group = decodedValue
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        // 创建节点配置
        return SubscriptionNode(
            server: server,
            server_port: port,
            password: password,
            method: method,
            protocolType: protocolType,
            protocol_param: protocolParam,
            obfs: obfs,
            obfs_param: obfsParam,
            remarks: remarks,
            group: group
        )
    }
    
    /// 解码 Base64 URL 编码的字符串
    /// - Parameter string: Base64 URL 编码的字符串
    /// - Returns: 解码后的字符串
    private func decodeBase64URL(_ string: String) -> String? {
        let base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .padding(toLength: ((string.count + 3) / 4) * 4,
                    withPad: "=",
                    startingAt: 0)
        
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    /// 更新配置
    /// - Parameter nodes: 新的节点列表
    private func updateConfig(with nodes: [SubscriptionNode]) {
        var newConfig = config
        
        // 更新节点配置
        // TODO: 根据实际需求更新配置
        // 例如：更新服务器列表、更新分组信息等
        
        // 保存更新后的配置
        config = newConfig
        try? config.save()
        
        print("成功更新 \(nodes.count) 个节点")
    }
    
    /// 开始自动更新
    /// - Parameter interval: 更新间隔（秒）
    func startAutoUpdate(interval: TimeInterval = 3600) {
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateSubscriptions { _ in }
        }
    }
    
    /// 停止自动更新
    func stopAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    deinit {
        stopAutoUpdate()
    }
} 
