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
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.tfyswift.network")
    
    func connect(to host: String, port: UInt16) throws {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        let parameters = NWParameters.tls
        connection = NWConnection(to: endpoint, using: parameters)
        
        connection?.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state)
        }
        
        connection?.start(queue: queue)
    }
    
    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            print("Connection established")
        case .failed(let error):
            print("Connection failed: \(error)")
        case .waiting(let error):
            print("Connection waiting: \(error)")
        default:
            break
        }
    }
    
    func send(_ data: Data, completion: @escaping (Error?) -> Void) {
        connection?.send(content: data, completion: .contentProcessed { error in
            completion(error)
        })
    }
    
    func receive(completion: @escaping (Data?, Error?) -> Void) {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { content, _, isComplete, error in
            completion(content, error)
        }
    }
} 
