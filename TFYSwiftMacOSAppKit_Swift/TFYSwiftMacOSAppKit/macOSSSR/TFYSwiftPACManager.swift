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
        let framerOptions = NWProtocolFramer.Options(definition: HTTPHandler.definition)
        parameters.defaultProtocolStack.applicationProtocols.insert(framerOptions, at: 0)
        
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
    
    func handleOutput(framer: NWProtocolFramer.Instance, message: NWProtocolFramer.Message, messageLength: Int, isComplete: Bool) {
        // 创建 HTTP 响应头
        let responseHeader = """
        HTTP/1.1 200 OK\r
        Content-Type: application/x-ns-proxy-autoconfig\r
        Content-Length: \(messageLength)\r
        Connection: close\r
        \r
        """
        
        // 将响应头写入输出缓冲区
        if let headerData = responseHeader.data(using: .utf8) {
            let headerLength = headerData.count
            
            // 创建一个可变的 Data 对象来存储响应头
            var headerBuffer = Data(count: headerLength)
            
            // 将响应头数据复制到缓冲区
            headerBuffer.withUnsafeMutableBytes { rawBufferPointer in
                headerData.withUnsafeBytes { dataBufferPointer in
                    guard let destPtr = rawBufferPointer.baseAddress,
                          let srcPtr = dataBufferPointer.baseAddress else {
                        return
                    }
                    memcpy(destPtr, srcPtr, headerLength)
                }
            }
            
            // 写入输出
            framer.writeOutput(data: headerBuffer)
        }
        
        // 写入消息内容
        if messageLength > 0 {
            var messageBuffer = Data(count: messageLength)
            framer.writeOutput(data: messageBuffer)
        }
        
        print("HTTP response sent, length: \(messageLength), isComplete: \(isComplete)")
    }
    
    // 定义协议标签
    static let label: String = "com.tfyswift.pac.http"
    
    static let definition = NWProtocolFramer.Definition(implementation: HTTPHandler.self)
    
    required init(framer: NWProtocolFramer.Instance) { }
    
    // 启动协议帧处理
    func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult {
        print("HTTPHandler started")
        return .ready
    }
    
    // 处理输入数据
    func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        // 读取数据
        while true {
            var parsedLength = 0
            let result = framer.parseInput(minimumIncompleteLength: 1, maximumLength: Int.max) { buffer, isComplete in
                guard let buffer = buffer,
                      let request = String(bytes: buffer, encoding: .utf8) else {
                    return 0
                }
                
                // 简单解析 HTTP 请求
                if request.starts(with: "GET") {
                    // 处理 GET 请求
                    let message = NWProtocolFramer.Message(definition: HTTPHandler.definition)
                    if framer.deliverInputNoCopy(length: buffer.count, message: message, isComplete: true) {
                        parsedLength = buffer.count
                        return buffer.count
                    }
                }
                return 0
            }
            
            // 如果没有解析到数据，退出循环
            if parsedLength == 0 {
                break
            }
        }
        return 0
    }
    
    // 唤醒协议帧处理
    func wakeup(framer: NWProtocolFramer.Instance) {
        print("HTTPHandler wakeup")
    }
    
    // 停止协议帧处理
    func stop(framer: NWProtocolFramer.Instance) -> Bool {
        print("HTTPHandler stopped")
        return true
    }
    
    // 清理协议帧处理
    func cleanup(framer: NWProtocolFramer.Instance) {
        print("HTTPHandler cleanup")
    }
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
