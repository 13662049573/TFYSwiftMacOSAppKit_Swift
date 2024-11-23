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
    /// 用于同步订阅操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.subscription")
    /// 配置管理器实例
    private let configManager: TFYSwiftConfigManager
    
    /// 初始化订阅管理器
    /// - Parameter configManager: 配置管理器实例
    init(configManager: TFYSwiftConfigManager) {
        self.configManager = configManager
    }
    
    /// 更新订阅
    /// - Parameters:
    ///   - url: 订阅地址URL
    ///   - completion: 完成回调，返回解析后的服务器配置数组或错误
    func updateSubscription(_ url: URL, completion: @escaping (Result<[ServerConfig], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.queue.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data,
                  let content = String(data: data, encoding: .utf8) else {
                self.queue.async {
                    completion(.failure(TFYSwiftError.invalidData("订阅数据无效")))
                }
                return
            }
            
            self.queue.async {
                do {
                    let configs = try self.parseSubscription(content)
                    completion(.success(configs))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    /// 解析订阅内容
    /// - Parameter content: Base64编码的订阅内容
    /// - Returns: 服务器配置数组
    private func parseSubscription(_ content: String) throws -> [ServerConfig] {
        guard let data = Data(base64Encoded: content.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw TFYSwiftError.invalidData("Base64数据无效")
        }
        
        guard let decodedString = String(data: data, encoding: .utf8) else {
            throw TFYSwiftError.invalidData("订阅内容解码失败")
        }
        
        return try decodedString
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { try parseServerConfig($0) }
    }
    
    /// 解析单个服务器配置
    /// - Parameter uri: SSR URI字符串
    /// - Returns: 服务器配置对象
    private func parseServerConfig(_ uri: String) throws -> ServerConfig {
        guard uri.hasPrefix("ssr://") else {
            throw TFYSwiftError.invalidData("无效的SSR URI")
        }
        
        let base64String = String(uri.dropFirst(6))
        guard let data = Data(base64Encoded: base64String.padding(toLength: ((base64String.count + 3) / 4) * 4,
                                                                withPad: "=",
                                                                startingAt: 0)),
              let content = String(data: data, encoding: .utf8) else {
            throw TFYSwiftError.invalidData("Base64内容无效")
        }
        
        let components = content.components(separatedBy: ":")
        guard components.count >= 6 else {
            throw TFYSwiftError.invalidData("SSR配置格式无效")
        }
        
        let mainParts = components[0...5].map { $0 }
        
        // 解析附加参数
        var params: [String: String] = [:]
        if components.count > 1 {
            let queryItems = components[1].components(separatedBy: "&")
            for item in queryItems {
                let pair = item.components(separatedBy: "=")
                if pair.count == 2 {
                    params[pair[0]] = pair[1]
                }
            }
        }
        
        return ServerConfig(
            server: mainParts[0],
            serverPort: UInt16(mainParts[1]) ?? 0,
            method: mainParts[3],
            password: decodeBase64URL(mainParts[5]) ?? "",
            protocolType: mainParts[2],
            protocolParam: decodeBase64URL(params["protoparam"] ?? ""),
            obfs: mainParts[4],
            obfsParam: decodeBase64URL(params["obfsparam"] ?? ""),
            remarks: decodeBase64URL(params["remarks"] ?? ""),
            group: decodeBase64URL(params["group"] ?? "")
        )
    }
    
    /// 解码Base64URL编码的字符串
    /// - Parameter string: Base64URL编码的字符串
    /// - Returns: 解码后的字符串，失败返回nil
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
} 
