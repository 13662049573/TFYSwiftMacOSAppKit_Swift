//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Network

class TFYSwiftProxy {
    enum ProxyState {
        case stopped
        case starting
        case running
        case error(Error)
    }
    
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.tfyswift.proxy", qos: .userInitiated)
    private var connections: [String: TFYSwiftProxyConnection] = [:]
    private let connectionsLock = NSLock()
    private var stateHandler: ((ProxyState) -> Void)?
    private let config: TFYSwiftConfig
    private var isRunning = false
    
    init(config: TFYSwiftConfig, stateHandler: ((ProxyState) -> Void)? = nil) {
        self.config = config
        self.stateHandler = stateHandler
    }
    
    func start() throws {
        guard !isRunning else { return }
        isRunning = true
        stateHandler?(.starting)
        
        // 创建本地监听器
        try setupLocalListener()
        
        // 设置系统代理
        try setupSystemProxy()
        
        stateHandler?(.running)
    }
    
    func stop() {
        guard isRunning else { return }
        isRunning = false
        
        // 停止监听
        listener?.cancel()
        listener = nil
        
        // 断开所有连接
        disconnectAllConnections()
        
        // 清除系统代理
        clearSystemProxy()
        
        stateHandler?(.stopped)
    }
    
    private func setupLocalListener() throws {
        let parameters = NWParameters.tcp
        
        // 配置 SOCKS5 参数
        if config.globalSettings.socksPort > 0 {
            parameters.includePeerToPeer = true
        }
        
        listener = try NWListener(using: parameters,
                                on: NWEndpoint.Port(integerLiteral: config.globalSettings.localPort))
        
        listener?.stateUpdateHandler = { [weak self] state in
            self?.handleListenerState(state)
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
        
        listener?.start(queue: queue)
    }
    
    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            print("Proxy listener ready")
        case .failed(let error):
            stateHandler?(.error(error))
            stop()
        case .cancelled:
            print("Proxy listener cancelled")
        default:
            break
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        let proxyConnection = TFYSwiftProxyConnection(
            connection: connection,
            config: config,
            delegate: self
        )
        
        let connectionId = UUID().uuidString
        addConnection(proxyConnection, withId: connectionId)
        
        proxyConnection.start()
    }
    
    private func addConnection(_ connection: TFYSwiftProxyConnection, withId id: String) {
        connectionsLock.lock()
        defer { connectionsLock.unlock() }
        connections[id] = connection
    }
    
    private func removeConnection(withId id: String) {
        connectionsLock.lock()
        defer { connectionsLock.unlock() }
        connections.removeValue(forKey: id)
    }
    
    private func disconnectAllConnections() {
        connectionsLock.lock()
        defer { connectionsLock.unlock() }
        connections.forEach { $0.value.stop() }
        connections.removeAll()
    }
    
    // 系统代理设置
    private func setupSystemProxy() throws {
        #if os(macOS)
        let script = """
        tell application "System Events"
            tell current location of network preferences
                set proxySettings to get proxy settings of first service whose name contains "Wi-Fi" or name contains "Ethernet"
                set enabled of proxySettings to true
                set SOCKSEnable of proxySettings to true
                set SOCKSPort of proxySettings to \(config.globalSettings.socksPort)
                set SOCKSHost of proxySettings to "127.0.0.1"
            end tell
        end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                throw TFYSwiftError.systemError("Failed to set system proxy: \(error)")
            }
        }
        #endif
    }
    
    private func clearSystemProxy() {
        #if os(macOS)
        let script = """
        tell application "System Events"
            tell current location of network preferences
                set proxySettings to get proxy settings of first service whose name contains "Wi-Fi" or name contains "Ethernet"
                set enabled of proxySettings to false
                set SOCKSEnable of proxySettings to false
            end tell
        end tell
        """
        
        if let scriptObject = NSAppleScript(source: script) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
        }
        #endif
    }
}

// MARK: - TFYSwiftProxyConnectionDelegate
extension TFYSwiftProxy: TFYSwiftProxyConnectionDelegate {
    func connectionDidComplete(_ connection: TFYSwiftProxyConnection) {
        if let id = connections.first(where: { $0.value === connection })?.key {
            removeConnection(withId: id)
        }
    }
    
    func connection(_ connection: TFYSwiftProxyConnection, didFailWith error: Error) {
        if let id = connections.first(where: { $0.value === connection })?.key {
            removeConnection(withId: id)
        }
        print("Connection failed: \(error.localizedDescription)")
    }
} 
