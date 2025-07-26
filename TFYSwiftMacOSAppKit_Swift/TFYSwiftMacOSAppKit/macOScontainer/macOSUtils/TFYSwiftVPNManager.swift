//
//  TFYSwiftVPNManager.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/15.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import NetworkExtension

class TFYSwiftVPNManager {
    
    static let shared = TFYSwiftVPNManager()
    var onVPNStatusChange: ((NEVPNStatus) -> Void)?

    private var vpnManager: NETunnelProviderManager?
    
    private init() {
        observeVPNStatus()
    }

    func setupVPN(providerBundleIdentifier: String, serverAddress: String, username: String, password: String, accelerateDomains: [String]? = nil) {
        let manager = NETunnelProviderManager()
        let protocolConfiguration = NETunnelProviderProtocol()

        protocolConfiguration.providerBundleIdentifier = providerBundleIdentifier
        protocolConfiguration.serverAddress = serverAddress

        var providerConfiguration = [
            "username": username,
            "password": password
        ]
        
        // Serialize accelerateDomains to a JSON string if present
        if let domains = accelerateDomains {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: domains, options: [])
                let jsonString = String(data: jsonData, encoding: .utf8)
                providerConfiguration["accelerateDomains"] = jsonString
            } catch {
                print("Failed to serialize accelerateDomains: \(error)")
            }
        }

        protocolConfiguration.providerConfiguration = providerConfiguration

        manager.protocolConfiguration = protocolConfiguration
        manager.localizedDescription = accelerateDomains != nil ? "My Custom VPN with Acceleration" : "My Custom VPN"
        manager.isEnabled = true

        manager.saveToPreferences { error in
            if let saveError = error {
                print("Failed to save VPN Configuration: \(saveError.localizedDescription)")
            } else {
                print("VPN Configuration saved successfully.")
                self.connectVPN()
            }
        }
        self.vpnManager = manager
    }

    func connectVPN() {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let managers = managers, let manager = managers.first else {
                print("No VPN Configurations found.")
                return
            }

            do {
                try manager.connection.startVPNTunnel()
                print("VPN Connection started.")
            } catch let startError {
                print("Error starting VPN Connection: \(startError.localizedDescription)")
            }
        }
    }

    func disconnectVPN() {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let managers = managers, let manager = managers.first else {
                print("No VPN Configurations found.")
                return
            }

            manager.connection.stopVPNTunnel()
            print("VPN Connection stopped.")
        }
    }

    private func observeVPNStatus() {
        NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: nil) { [weak self] notification in
            guard let strongSelf = self,
                  let connection = notification.object as? NEVPNConnection else { return }
            let status = connection.status
            strongSelf.onVPNStatusChange?(status)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/**
 TFYSwiftVPNManager.shared.onVPNStatusChange = { status in
     switch status {
     case .connected:
         print("VPN is Connected")
     case .disconnected:
         print("VPN is Disconnected")
     case .connecting:
         print("VPN is Connecting")
     case .disconnecting:
         print("VPN is Disconnecting")
     case .invalid:
         print("VPN Configuration is Invalid")
     case .reasserting:
         print("VPN is Reasserting")
     @unknown default:
         print("Unknown VPN Status")
     }
 }

 // Setup standard VPN
 TFYSwiftVPNManager.shared.setupVPN(
     providerBundleIdentifier: "com.yourcompany.vpn.app.extension",
     serverAddress: "vpn.server.com",
     username: "user123",
     password: "pass123"
 )

 // Setup VPN with network acceleration
 TFYSwiftVPNManager.shared.setupVPN(
     providerBundleIdentifier: "com.yourcompany.vpn.app.extension",
     serverAddress: "fast.vpn.server.com",
     username: "user123",
     password: "pass123",
     accelerateDomains: ["youtube.com", "netflix.com", "hulu.com"]
 )
 */
