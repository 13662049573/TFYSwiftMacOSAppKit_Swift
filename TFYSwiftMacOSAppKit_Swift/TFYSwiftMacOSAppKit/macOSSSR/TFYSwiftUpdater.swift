//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 更新信息结构体
public struct UpdateInfo {
    let version: String
    let releaseNotes: String
    let downloadURL: URL
    
    public init(version: String, releaseNotes: String, downloadURL: URL) {
        self.version = version
        self.releaseNotes = releaseNotes
        self.downloadURL = downloadURL
    }
}

/// 更新管理器类 - 负责检查和下载软件更新
public class TFYSwiftUpdater {
    /// 版本号结构体 - 用于版本比较
    private struct Version: Comparable {
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
    
    /// 当前版本号
    private let currentVersion: String
    /// 更新检查地址
    private let checkURL: URL
    /// 用于同步更新操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.updater")
    /// 自动检查定时器
    private var timer: Timer?
    
    /// 初始化更新管理器
    /// - Parameters:
    ///   - currentVersion: 当前应用版本号
    ///   - checkURL: 检查更新的API地址
    init(currentVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0",
         checkURL: URL = URL(string: "https://api.example.com/updates")!) {
        self.currentVersion = currentVersion
        self.checkURL = checkURL
    }
    
    /// 检查更新
    /// - Parameter completion: 完成回调，如果有更新返回更新信息，否则返回 nil
    public func checkForUpdates(completion: @escaping (Result<UpdateInfo?, Error>) -> Void) {
        // 实现检查更新的逻辑
        guard let url = URL(string: "https://api.example.com/version") else {
            completion(.failure(TFYSwiftError.networkError("无效的更新检查URL")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(TFYSwiftError.networkError("没有接收到数据")))
                return
            }
            
            do {
                // 解析服务器返回的版本信息
                let decoder = JSONDecoder()
                let versionInfo = try decoder.decode(VersionResponse.self, from: data)
                
                // 比较版本号
                if versionInfo.hasUpdate {
                    let updateInfo = UpdateInfo(
                        version: versionInfo.latestVersion,
                        releaseNotes: versionInfo.releaseNotes,
                        downloadURL: versionInfo.downloadURL
                    )
                    completion(.success(updateInfo))
                } else {
                    completion(.success(nil)) // 没有可用更新
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    /// 版本响应结构体
    private struct VersionResponse: Codable {
        let latestVersion: String
        let hasUpdate: Bool
        let releaseNotes: String
        let downloadURL: URL
    }
    
    /// 开始自动检查更新
    /// - Parameter interval: 检查间隔（秒），默认3600秒
    func startAutoCheck(interval: TimeInterval = 3600) {
        stopAutoCheck()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkForUpdates { _ in }
        }
    }
    
    /// 停止自动检查更新
    func stopAutoCheck() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 下载更新包
    /// - Parameters:
    ///   - updateInfo: 更新信息
    ///   - completion: 完成回调，返回下载文件的本地URL或错误
    func downloadUpdate(_ updateInfo: UpdateInfo, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: updateInfo.downloadURL) { localURL, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let localURL = localURL else {
                completion(.failure(TFYSwiftError.systemError("下载失败")))
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
        
        task.resume()
    }
    
    /// 析构函数 - 确保停止自动检查
    deinit {
        stopAutoCheck()
    }
}

// 添加自动更新功能

extension TFYSwiftUpdater {
    /// 更新配置
    public struct UpdateConfig: Codable {
        let checkInterval: TimeInterval    // 检查间隔
        let autoDownload: Bool            // 是否自动下载
        let autoInstall: Bool             // 是否自动安装
        let betaChannel: Bool             // 是否使用测试版通道
        
        public init(
            checkInterval: TimeInterval = 86400,  // 默认24小时
            autoDownload: Bool = false,
            autoInstall: Bool = false,
            betaChannel: Bool = false
        ) {
            self.checkInterval = checkInterval
            self.autoDownload = autoDownload
            self.autoInstall = autoInstall
            self.betaChannel = betaChannel
        }
    }
    
    /// 更新状态
    public enum UpdateStatus {
        case checking
        case available(UpdateInfo)
        case notAvailable
        case downloading(Progress)
        case downloaded(URL)
        case installing
        case error(Error)
    }
    
    /// 更新进度回调
    public typealias UpdateProgressHandler = (UpdateStatus) -> Void
    
    /// 检查更新
    /// - Parameters:
    ///   - force: 是否强制检查
    ///   - completion: 完成回调
    public func checkForUpdates(force: Bool = false, completion: @escaping (Result<UpdateInfo?, Error>) -> Void) {
        guard force || shouldCheckForUpdates() else {
            completion(.success(nil))
            return
        }
        
        status = .checking
        notifyStatusChange()
        
        let request = URLRequest(url: updateURL)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.status = .error(error)
                self.notifyStatusChange()
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let updateInfo = try? JSONDecoder().decode(UpdateInfo.self, from: data) else {
                let error = TFYSwiftError.invalidData("无效的更新信息")
                self.status = .error(error)
                self.notifyStatusChange()
                completion(.failure(error))
                return
            }
            
            // 检查版本号
            if self.isNewerVersion(updateInfo.version) {
                self.status = .available(updateInfo)
                self.notifyStatusChange()
                completion(.success(updateInfo))
            } else {
                self.status = .notAvailable
                self.notifyStatusChange()
                completion(.success(nil))
            }
            
            // 更新最后检查时间
            self.lastCheckTime = Date()
            self.saveLastCheckTime()
        }
        
        task.resume()
    }
    
    /// 下载更新
    /// - Parameter updateInfo: 更新信息
    public func downloadUpdate(_ updateInfo: UpdateInfo) {
        guard case .available = status else { return }
        
        let downloadTask = URLSession.shared.downloadTask(with: updateInfo.downloadURL) { [weak self] url, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.status = .error(error)
                self.notifyStatusChange()
                return
            }
            
            guard let url = url else {
                let error = TFYSwiftError.networkError("下载失败")
                self.status = .error(error)
                self.notifyStatusChange()
                return
            }
            
            // 移动下载文件到临时目录
            let tempDir = FileManager.default.temporaryDirectory
            let downloadedURL = tempDir.appendingPathComponent(updateInfo.version).appendingPathExtension("zip")
            
            do {
                if FileManager.default.fileExists(atPath: downloadedURL.path) {
                    try FileManager.default.removeItem(at: downloadedURL)
                }
                try FileManager.default.moveItem(at: url, to: downloadedURL)
                
                self.status = .downloaded(downloadedURL)
                self.notifyStatusChange()
                
                // 如果配置了自动安装，则开始安装
                if self.config.autoInstall {
                    self.installUpdate(downloadedURL)
                }
            } catch {
                self.status = .error(error)
                self.notifyStatusChange()
            }
        }
        
        // 设置进度监听
        downloadTask.progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
        
        status = .downloading(downloadTask.progress)
        notifyStatusChange()
        
        downloadTask.resume()
    }
    
    /// 安装更新
    /// - Parameter updateURL: 更新文件URL
    public func installUpdate(_ updateURL: URL) {
        guard case .downloaded = status else { return }
        
        status = .installing
        notifyStatusChange()
        
        do {
            // 验证更新包
            try verifyUpdate(at: updateURL)
            
            // 解压更新包
            let extractedURL = try extractUpdate(from: updateURL)
            
            // 备份当前版本
            try backupCurrentVersion()
            
            // 安装新版本
            try installNewVersion(from: extractedURL)
            
            // 清理临时文件
            try cleanupUpdate(updateURL)
            
            // 重启应用
            restartApplication()
            
        } catch {
            status = .error(error)
            notifyStatusChange()
        }
    }
    
    // MARK: - Private Methods
    
    private func verifyUpdate(at url: URL) throws {
        // 实现更新包验证逻辑
    }
    
    private func extractUpdate(from url: URL) throws -> URL {
        // 实现更新包解压逻辑
        return url
    }
    
    private func backupCurrentVersion() throws {
        // 实现当前版本备份逻辑
    }
    
    private func installNewVersion(from url: URL) throws {
        // 实现新版本安装逻辑
    }
    
    private func cleanupUpdate(_ url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    private func restartApplication() {
        let executablePath = Bundle.main.executablePath!
        Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [executablePath])
        NSApplication.shared.terminate(nil)
    }
    
    private func shouldCheckForUpdates() -> Bool {
        guard let lastCheck = lastCheckTime else { return true }
        return Date().timeIntervalSince(lastCheck) >= config.checkInterval
    }
    
    private func isNewerVersion(_ version: String) -> Bool {
        // 实现版本号比较逻辑
        return true
    }
    
    private func saveLastCheckTime() {
        UserDefaults.standard.set(lastCheckTime, forKey: "LastUpdateCheck")
    }
    
    private func notifyStatusChange() {
        DispatchQueue.main.async {
            self.progressHandler?(self.status)
        }
    }
    
    // MARK: - KVO
    
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "fractionCompleted",
           let progress = object as? Progress {
            status = .downloading(progress)
            notifyStatusChange()
        }
    }
} 
