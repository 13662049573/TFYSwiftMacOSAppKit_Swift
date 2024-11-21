//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 更新管理器类 - 负责检查和下载软件更新
public class TFYSwiftUpdater {
    /// 版本号结构体 - 用于版本比较
    struct Version: Comparable {
        let major: Int      // 主版本号
        let minor: Int      // 次版本号
        let patch: Int      // 补丁版本号
        
        /// 从字符串初始化版本号
        /// - Parameter string: 版本号字符串，格式如："1.2.3"
        init?(_ string: String) {
            let components = string.split(separator: ".").compactMap { Int($0) }
            guard components.count == 3 else { return nil }
            self.major = components[0]
            self.minor = components[1]
            self.patch = components[2]
        }
        
        /// 版本号比较实现
        static func < (lhs: Version, rhs: Version) -> Bool {
            if lhs.major != rhs.major { return lhs.major < rhs.major }
            if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
            return lhs.patch < rhs.patch
        }
    }
    
    /// 更新信息结构体
    struct UpdateInfo: Codable {
        let version: String     // 新版本号
        let url: String        // 更新包下载地址
        let notes: String      // 更新说明
    }
    
    /// 当前版本号
    private let currentVersion: Version
    /// 更新检查地址
    private let checkURL: URL
    /// 用于同步更新操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.updater")
    /// 自动检查定时器
    private var timer: Timer?
    
    /// 初始化更新管理器
    /// - Parameters:
    ///   - currentVersion: 当前版本号字符串
    ///   - checkURL: 更新检查地址
    init(currentVersion: String, checkURL: URL) {
        self.currentVersion = Version(currentVersion) ?? Version("0.0.0")!
        self.checkURL = checkURL
    }
    
    /// 检查更新
    /// - Parameter completion: 完成回调，返回更新信息或错误
    func checkForUpdates(completion: @escaping (Result<UpdateInfo?, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: checkURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.queue.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data,
                  let updateInfo = try? JSONDecoder().decode(UpdateInfo.self, from: data),
                  let newVersion = Version(updateInfo.version) else {
                self.queue.async {
                    completion(.failure(TFYSwiftError.invalidData("更新数据无效")))
                }
                return
            }
            
            self.queue.async {
                if newVersion > self.currentVersion {
                    completion(.success(updateInfo))
                } else {
                    completion(.success(nil))
                }
            }
        }
        task.resume()
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
        guard let url = URL(string: updateInfo.url) else {
            completion(.failure(TFYSwiftError.invalidData("下载地址无效")))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, _, error in
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
