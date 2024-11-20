//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//


import Foundation
import Network

class TFYSwiftConnection {
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case error(Error)
    }
    
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.tfyswift.network")
    private var stateHandler: ((ConnectionState) -> Void)?
    private var readBuffer = Data()
    private var isReading = false
    
    // 重试相关
    private var retryCount = 0
    private let maxRetries = 3
    private let retryInterval: TimeInterval = 5
    
    init(stateHandler: ((ConnectionState) -> Void)? = nil) {
        self.stateHandler = stateHandler
    }
    
    func connect(to host: String, port: UInt16, tls: Bool = true) throws {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        let parameters: NWParameters
        if tls {
            parameters = NWParameters.tls
            let options = NWProtocolTLS.Options()
            sec_protocol_options_set_verify_block(options.securityProtocolOptions, { _, _, complete in
                complete(true) // 允许自签名证书
            }, queue)
            parameters.defaultProtocolStack.applicationProtocols = ["http/1.1"]
        } else {
            parameters = NWParameters.tcp
        }
        
        connection = NWConnection(to: endpoint, using: parameters)
        connection?.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state)
        }
        
        stateHandler?(.connecting)
        connection?.start(queue: queue)
    }
    
    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            retryCount = 0
            stateHandler?(.connected)
            startReading()
        case .failed(let error):
            handleConnectionError(error)
        case .waiting(let error):
            print("Connection waiting: \(error)")
        case .cancelled:
            stateHandler?(.disconnected)
        default:
            break
        }
    }
    
    private func handleConnectionError(_ error: Error) {
        if retryCount < maxRetries {
            retryCount += 1
            queue.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
                guard let self = self else { return }
                if let connection = self.connection,
                   let endpoint = connection.endpoint,
                   let parameters = connection.parameters {
                    self.connection = NWConnection(to: endpoint, using: parameters)
                    self.connection?.stateUpdateHandler = { [weak self] state in
                        self?.handleConnectionState(state)
                    }
                    self.connection?.start(queue: self.queue)
                }
            }
        } else {
            stateHandler?(.error(error))
        }
    }
    
    private func startReading() {
        guard !isReading else { return }
        isReading = true
        readNextChunk()
    }
    
    private func readNextChunk() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                self.stateHandler?(.error(error))
                self.isReading = false
                return
            }
            
            if let data = content {
                self.readBuffer.append(data)
                self.processReadBuffer()
            }
            
            if !isComplete {
                self.readNextChunk()
            } else {
                self.isReading = false
            }
        }
    }
    
    private func processReadBuffer() {
        // 实现数据处理逻辑
    }
    
    func send(_ data: Data) {
        connection?.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.stateHandler?(.error(error))
            }
        })
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        isReading = false
        readBuffer.removeAll()
        stateHandler?(.disconnected)
    }
    
    deinit {
        disconnect()
    }
} 
