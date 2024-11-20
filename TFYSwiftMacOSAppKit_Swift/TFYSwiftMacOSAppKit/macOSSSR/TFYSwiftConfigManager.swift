//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

public class TFYSwiftConfigManager {
    private var config: TFYSwiftConfig
    private let queue = DispatchQueue(label: "com.tfyswift.configmanager")
    
    init(config: TFYSwiftConfig) {
        self.config = config
    }
    
    func exportConfig(to url: URL, completion: @escaping (Error?) -> Void) {
        queue.async {
            do {
                let data = try JSONEncoder().encode(self.config)
                try data.write(to: url)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func importConfig(from url: URL, completion: @escaping (Error?) -> Void) {
        queue.async {
            do {
                let data = try Data(contentsOf: url)
                let importedConfig = try JSONDecoder().decode(TFYSwiftConfig.self, from: data)
                self.config.servers = importedConfig.servers
                self.config.selectedServer = importedConfig.selectedServer
                self.config.globalSettings = importedConfig.globalSettings
                self.config.subscribeUrls = importedConfig.subscribeUrls
                self.config.bypassList = importedConfig.bypassList
                self.config.forwardList = importedConfig.forwardList
                try self.config.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
} 
