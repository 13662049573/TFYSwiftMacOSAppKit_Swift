//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

/// 远程连接类 - 负责处理网络连接的建立、数据传输和断开
public class TFYSwiftConnection {
    // MARK: - 属性
    
    /// 远程主机地址
    private let host: String
    
    /// 远程主机端口
    private let port: UInt16
    
    /// Network framework的连接对象
    internal var connection: NWConnection?
    
    /// 用于同步网络操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.connection")
    
    /// 数据接收回调闭包
    /// - Parameter Data: 接收到的数据
    public var onData: ((Data) -> Void)?
    
    // MARK: - 初始化方法
    /// 初始化连接对象
    /// - Parameters:
    ///   - host: 远程主机地址
    ///   - port: 远程主机端口
    init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
    
    // MARK: - 公共方法
    /// 建立连接
    /// - Parameter completion: 连接完成回调，error为nil表示连接成功
    func connect(completion: @escaping (Error?) -> Void) {
        // 创建网络端点
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        // 创建TCP连接
        connection = NWConnection(to: endpoint, using: .tcp)
        
        // 设置连接状态处理
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                completion(nil)  // 连接成功
            case .failed(let error):
                completion(error)  // 连接失败
            default:
                break
            }
        }
        
        // 启动连接
        connection?.start(queue: queue)
    }
    
    /// 接收数据
    /// - Parameters:
    ///   - minimumIncompleteLength: 最小接收长度
    ///   - maximumLength: 最大接收长度
    ///   - completion: 接收完成回调
    func receive(minimumIncompleteLength: Int, maximumLength: Int, completion: @escaping (Data?, NWConnection.ContentContext?, Bool, Error?) -> Void) {
        connection?.receive(minimumIncompleteLength: minimumIncompleteLength, maximumLength: maximumLength, completion: completion)
    }
    
    /// 发送数据
    /// - Parameters:
    ///   - data: 要发送的数据
    ///   - completion: 发送完成回调，error为nil表示发送成功
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
    
    // MARK: - 私有方法
    /// 开始持续接收数据
    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            // 如果收到数据，调用回调处理
            if let data = content {
                self?.onData?(data)
            }
            
            // 如果连接未完成，继续接收数据
            if !isComplete {
                self?.startReceiving()
            }
        }
    }
    
    /// 析构函数 - 确保连接被正确关闭
    deinit {
        disconnect()
    }
} 
