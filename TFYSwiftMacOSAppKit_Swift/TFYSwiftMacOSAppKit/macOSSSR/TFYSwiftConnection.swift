//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//


import Foundation
import Network

/// 远程连接类
class TFYSwiftConnection {
    // MARK: - 属性
    
    private let host: String
    private let port: UInt16
    private let password: String
    private let method: TFYSwiftConfig.CryptoMethod
    
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.tfyswift.connection")
    
    var onData: ((Data) -> Void)?
    
    // MARK: - 初始化方法
    
    /// 初始化远程连接
    /// - Parameters:
    ///   - host: 服务器地址
    ///   - port: 服务器端口
    ///   - password: 连接密码
    ///   - method: 加密方法
    init(host: String, 
         port: UInt16, 
         password: String, 
         method: TFYSwiftConfig.CryptoMethod) {
        self.host = host
        self.port = port
        self.password = password
        self.method = method
    }
    
    /// 连接到远程服务器
    /// - Parameter completion: 完成回调，返回可能的错误
    func connect(completion: @escaping (Error?) -> Void) {
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host),
                                         port: NWEndpoint.Port(integerLiteral: port))
        
        connection = NWConnection(to: endpoint, using: .tcp)
        
        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                completion(nil)
            case .failed(let error):
                completion(error)
            case .cancelled:
                completion(TFYSwiftError.connectionError("连接已取消"))
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
    
    /// 发送数据
    /// - Parameters:
    ///   - data: 要发送的数据
    ///   - completion: 完成回调，返回可能的错误
    func send(data: Data, completion: @escaping (Error?) -> Void) {
        connection?.send(content: data, completion: .contentProcessed { error in
            completion(error)
        })
    }
    
    /// 断开连接
    func disconnect() {
        connection?.cancel()
        connection = nil
    }
    
    /// 开始接收数据
    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                print("接收数据错误: \(error.localizedDescription)")
                return
            }
            
            if let data = content {
                self.onData?(data)
            }
            
            if !isComplete {
                self.startReceiving()
            }
        }
    }
    
    deinit {
        disconnect()
    }
} 
