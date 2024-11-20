//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

class TFYSwiftPACManager {
    private var httpServer: NWListener?
    private let queue = DispatchQueue(label: "com.tfyswift.pac")
    private let config: TFYSwiftConfig
    private var pacContent: String
    
    init(config: TFYSwiftConfig) {
        self.config = config
        self.pacContent = ""
        loadDefaultPAC()
    }
    
    func start() throws {
        let parameters = NWParameters.tcp
        parameters.setProtocolHandlers([HTTPHandler()])
        
        httpServer = try NWListener(using: parameters,
                                  on: NWEndpoint.Port(integerLiteral: config.globalSettings.pacPort))
        
        httpServer?.stateUpdateHandler = { [weak self] state in
            self?.handleListenerState(state)
        }
        
        httpServer?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
        
        httpServer?.start(queue: queue)
    }
    
    func stop() {
        httpServer?.cancel()
        httpServer = nil
    }
    
    private func loadDefaultPAC() {
        let defaultPAC = """
        function FindProxyForURL(url, host) {
            var direct = 'DIRECT';
            var proxy = 'SOCKS5 127.0.0.1:\(config.globalSettings.socksPort)';
            
            // 本地地址直连
            if (isPlainHostName(host) ||
                isInNet(host, "10.0.0.0", "255.0.0.0") ||
                isInNet(host, "172.16.0.0", "255.240.0.0") ||
                isInNet(host, "192.168.0.0", "255.255.0.0") ||
                isInNet(host, "127.0.0.0", "255.0.0.0")) {
                return direct;
            }
            
            // 自定义规则
            var bypassList = \(config.bypassList.map { "\"\($0)\"" });
            for (var i = 0; i < bypassList.length; i++) {
                if (shExpMatch(host, bypassList[i])) {
                    return direct;
                }
            }
            
            return proxy;
        }
        """
        
        pacContent = defaultPAC
    }
    
    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            print("PAC server ready")
        case .failed(let error):
            print("PAC server failed: \(error)")
        default:
            break
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        let handler = PACConnectionHandler(connection: connection, pacContent: pacContent)
        handler.start()
    }
}

// HTTP 协议处理
private class HTTPHandler: NWProtocolFramerImplementation {
    static let definition = NWProtocolFramer.Definition(implementation: HTTPHandler.self)
    
    required init(framer: NWProtocolFramer.Instance) { }
    
    func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult { .ready }
    func wakeup(framer: NWProtocolFramer.Instance) { }
    func stop(framer: NWProtocolFramer.Instance) -> Bool { true }
    
    func cleanup(framer: NWProtocolFramer.Instance) { }
}

// PAC 连接处理
private class PACConnectionHandler {
    private let connection: NWConnection
    private let pacContent: String
    
    init(connection: NWConnection, pacContent: String) {
        self.connection = connection
        self.pacContent = pacContent
    }
    
    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state)
        }
        
        connection.start(queue: .global())
    }
    
    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            sendPACResponse()
        case .failed, .cancelled:
            connection.cancel()
        default:
            break
        }
    }
    
    private func sendPACResponse() {
        let response = """
        HTTP/1.1 200 OK\r
        Content-Type: application/x-ns-proxy-autoconfig\r
        Content-Length: \(pacContent.utf8.count)\r
        Connection: close\r
        \r
        \(pacContent)
        """
        
        connection.send(content: response.data(using: .utf8), completion: .contentProcessed { [weak self] error in
            if let error = error {
                print("Failed to send PAC response: \(error)")
            }
            self?.connection.cancel()
        })
    }
} 
