//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

class TFYSwiftUpdater {
    struct Version: Comparable {
        let major: Int
        let minor: Int
        let patch: Int
        
        init?(_ string: String) {
            let components = string.split(separator: ".").compactMap { Int($0) }
            guard components.count == 3 else { return nil }
            self.major = components[0]
            self.minor = components[1]
            self.patch = components[2]
        }
        
        static func < (lhs: Version, rhs: Version) -> Bool {
            if lhs.major != rhs.major { return lhs.major < rhs.major }
            if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
            return lhs.patch < rhs.patch
        }
    }
    
    struct UpdateInfo: Codable {
        let version: String
        let minSystemVersion: String
        let url: String
        let releaseNotes: String
        let mandatory: Bool
    }
    
    private let currentVersion: Version
    private let updateCheckURL: URL
    private let queue = DispatchQueue(label: "com.tfyswift.updater")
    private var updateTimer: Timer?
    
    init(currentVersion: String, updateCheckURL: URL) {
        self.currentVersion = Version(currentVersion) ?? Version("1.0.0")!
        self.updateCheckURL = updateCheckURL
    }
    
    func checkForUpdates(completion: @escaping (Result<UpdateInfo?, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: updateCheckURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.queue.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                self.queue.async {
                    completion(.failure(TFYSwiftError.systemError("No data received")))
                }
                return
            }
            
            do {
                let updateInfo = try JSONDecoder().decode(UpdateInfo.self, from: data)
                guard let newVersion = Version(updateInfo.version) else {
                    throw TFYSwiftError.systemError("Invalid version format")
                }
                
                self.queue.async {
                    if newVersion > self.currentVersion {
                        completion(.success(updateInfo))
                    } else {
                        completion(.success(nil))
                    }
                }
            } catch {
                self.queue.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func startAutoCheck(interval: TimeInterval = 3600) {
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkForUpdates { result in
                switch result {
                case .success(let updateInfo):
                    if let updateInfo = updateInfo {
                        logInfo("New version available: \(updateInfo.version)")
                        NotificationCenter.default.post(
                            name: NSNotification.Name("TFYSwiftUpdateAvailable"),
                            object: nil,
                            userInfo: ["updateInfo": updateInfo]
                        )
                    }
                case .failure(let error):
                    logError("Update check failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func stopAutoCheck() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func downloadUpdate(_ updateInfo: UpdateInfo, progress: @escaping (Float) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: updateInfo.url) else {
            completion(.failure(TFYSwiftError.systemError("Invalid download URL")))
            return
        }
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let localURL = localURL else {
                completion(.failure(TFYSwiftError.systemError("Download failed")))
                return
            }
            
            do {
                let fileManager = FileManager.default
                let downloadsURL = try fileManager.url(for: .downloadsDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
                let destinationURL = downloadsURL.appendingPathComponent("TFYSwift-\(updateInfo.version).zip")
                
                try? fileManager.removeItem(at: destinationURL)
                try fileManager.moveItem(at: localURL, to: destinationURL)
                
                completion(.success(destinationURL))
            } catch {
                completion(.failure(error))
            }
        }
        
        downloadTask.resume()
    }
    
    deinit {
        stopAutoCheck()
    }
} 
