//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//



import Foundation
import Network

protocol TFYSwiftProxyConnectionDelegate: AnyObject {
    func connectionDidComplete(_ connection: TFYSwiftProxyConnection)
    func connection(_ connection: TFYSwiftProxyConnection, didFailWith error: Error)
}

class TFYSwiftProxyConnection {
    private let connection: NWConnection
    private let config: TFYSwiftConfig
    private weak var delegate: TFYSwiftProxyConnectionDelegate?
    private var remoteConnection: TFYSwiftConnection?
    private var crypto: TFYSwiftCrypto?
    private let queue = DispatchQueue(label: "com.tfyswift.proxyconnection")
    
    private var buffer = Data()
    private var stage: ConnectionStage = .initial
    
    enum ConnectionStage {
        case initial
        case handshake
        case authentication
        case request
        case relay
        case completed
    }
    
    init(connection: NWConnection, config: TFYSwiftConfig, delegate: TFYSwiftProxyConnectionDelegate?) {
        self.connection = connection
        self.config = config
        self.delegate = delegate
    }
    
    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state)
        }
        
        connection.start(queue: queue)
    }
    
    func stop() {
        connection.cancel()
        remoteConnection?.disconnect()
    }
    
    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            startReading()
        case .failed(let error):
            delegate?.connection(self, didFailWith: error)
        case .cancelled:
            delegate?.connectionDidComplete(self)
        default:
            break
        }
    }
    
    private func startReading() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.connection(self, didFailWith: error)
                return
            }
            
            if let data = content {
                self.handleReceivedData(data)
            }
            
            if !isComplete {
                self.startReading()
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        buffer.append(data)
        
        switch stage {
        case .initial:
            handleInitialStage()
        case .handshake:
            handleHandshakeStage()
        case .authentication:
            handleAuthenticationStage()
        case .request:
            handleRequestStage()
        case .relay:
            handleRelayStage()
        case .completed:
            break
        }
    }
    
    // 实现各个阶段的处理逻辑...
    private func handleInitialStage() {
        guard buffer.count >= 1 else { return }
        
        let version = buffer[0]
        if version == 0x05 { // SOCKS5
            stage = .handshake
            handleHandshakeStage()
        } else {
            delegate?.connection(self, didFailWith: TFYSwiftError.protocolError("Unsupported protocol version"))
        }
    }
    
    private func handleHandshakeStage() {
        // SOCKS5 握手处理
    }
    
    private func handleAuthenticationStage() {
        // SOCKS5 认证处理
    }
    
    private func handleRequestStage() {
        // SOCKS5 请求处理
    }
    
    private func handleRelayStage() {
        // 数据转发处理
    }
} 
