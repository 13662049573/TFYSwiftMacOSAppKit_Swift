//
//  NotificationCenter+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

// MARK: - 线程安全的通知数据结构
private struct ThreadSafeNotificationData {
    let name: NSNotification.Name
    let object: AnyObject?
    let userInfo: [AnyHashable: SendableValue]?
    
    init(name: NSNotification.Name,
         object: Any? = nil,
         userInfo: [AnyHashable: Any]? = nil) {
        self.name = name
        self.object = object as AnyObject?
        self.userInfo = userInfo?.mapValues { SendableValue($0) }
    }
    
    // 转换为可用于发送通知的 userInfo 字典
    var notificationUserInfo: [AnyHashable: Any]? {
        return userInfo?.reduce(into: [AnyHashable: Any]()) { result, pair in
            result[pair.key] = pair.value.anyValue
        }
    }
}

// MARK: - 可跨线程传递的值类型
// @unchecked Sendable is intentional: every case wraps only immutable value types
// (String, Data, Date) or thread-safe Foundation objects (NSNumber), and the
// recursive array/dictionary cases only contain other SendableValue instances.
// AnyHashable keys in the dictionary case may theoretically wrap non-Sendable
// types, but this enum is private and only constructed via ThreadSafeNotificationData
// whose callers are responsible for supplying Sendable-compatible keys.
private enum SendableValue: @unchecked Sendable {
    case string(String)
    case number(NSNumber)
    case data(Data)
    case date(Date)
    case array([SendableValue])
    case dictionary([AnyHashable: SendableValue])
    case null
    
    init(_ value: Any) {
        switch value {
        case let str as String:
            self = .string(str)
        case let num as NSNumber:
            self = .number(num)
        case let data as Data:
            self = .data(data)
        case let date as Date:
            self = .date(date)
        case let arr as [Any]:
            self = .array(arr.map { SendableValue($0) })
        case let dict as [AnyHashable: Any]:
            self = .dictionary(dict.mapValues { SendableValue($0) })
        case Optional<Any>.none:
            self = .null
        default:
            self = .null
        }
    }
    
    var anyValue: Any {
        switch self {
        case .string(let value): return value
        case .number(let value): return value
        case .data(let value): return value
        case .date(let value): return value
        case .array(let value): return value.map { $0.anyValue }
        case .dictionary(let value):
            return value.reduce(into: [AnyHashable: Any]()) { result, pair in
                result[pair.key] = pair.value.anyValue
            }
        case .null: return NSNull()
        }
    }
}

// MARK: - NotificationCenter 扩展
public extension NotificationCenter {
    
    /**
     在主线程发送通知
     */
    func postNotificationOnMainThread(name: NSNotification.Name,
                                    object: Any? = nil,
                                    userInfo: [AnyHashable: Any]? = nil) {
        postNotificationOnMainThread(name: name,
                                   object: object,
                                   userInfo: userInfo,
                                   waitUntilDone: false)
    }
    
    /**
     在主线程发送通知,可选择是否等待完成
     */
    func postNotificationOnMainThread(name: NSNotification.Name,
                                    object: Any? = nil,
                                    userInfo: [AnyHashable: Any]? = nil,
                                    waitUntilDone wait: Bool) {
        // 创建线程安全的通知数据
        let safeData = ThreadSafeNotificationData(name: name,
                                                object: object,
                                                userInfo: userInfo)
        
        if Thread.isMainThread {
            post(name: safeData.name,
                 object: safeData.object,
                 userInfo: safeData.notificationUserInfo)
        } else {
            if wait {
                DispatchQueue.main.sync { [weak self] in
                    self?.post(name: safeData.name,
                             object: safeData.object,
                             userInfo: safeData.notificationUserInfo)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.post(name: safeData.name,
                             object: safeData.object,
                             userInfo: safeData.notificationUserInfo)
                }
            }
        }
    }
    
    /**
     在后台线程发送通知
     */
    func postNotificationOnBackgroundThread(name: NSNotification.Name,
                                          object: Any? = nil,
                                          userInfo: [AnyHashable: Any]? = nil) {
        // 创建线程安全的通知数据
        let safeData = ThreadSafeNotificationData(name: name,
                                                object: object,
                                                userInfo: userInfo)
        
        DispatchQueue.global().async { [weak self] in
            self?.post(name: safeData.name,
                      object: safeData.object,
                      userInfo: safeData.notificationUserInfo)
        }
    }
    
    // MARK: - 便利方法
    
    /**
     添加观察者并在主线程处理通知
     */
    @discardableResult
    func addObserverOnMainThread(_ observer: Any,
                                name: NSNotification.Name?,
                                object: Any? = nil,
                                queue: OperationQueue = .main,
                                using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return addObserver(forName: name,
                          object: object,
                          queue: queue,
                          using: block)
    }
}
// MARK: - 便利的通知名称定义
public extension Notification.Name {
    /// Demo / 自定义业务可用的示例通知名（非系统事件）。
    static let exampleNotification = Notification.Name("TFYSwiftMacOSAppKit.ExampleNotification")
    
    // MARK: Deprecated — 请使用系统 NSApplication 通知，勿依赖这些自定义字符串名
    
    @available(*, deprecated, message: "Use NSApplication.didBecomeActiveNotification instead")
    static let applicationDidBecomeActive = Notification.Name("ApplicationDidBecomeActive")
    @available(*, deprecated, message: "Use NSApplication.willResignActiveNotification instead")
    static let applicationWillResignActive = Notification.Name("ApplicationWillResignActive")
    @available(*, deprecated, message: "macOS has no applicationDidEnterBackground; use didResignActiveNotification")
    static let applicationDidEnterBackground = Notification.Name("ApplicationDidEnterBackground")
    @available(*, deprecated, message: "macOS has no applicationWillEnterForeground; use didBecomeActiveNotification")
    static let applicationWillEnterForeground = Notification.Name("ApplicationWillEnterForeground")
    
    /// 网络状态变化（由业务方自行 post；与 TFYNetworkReachability 配合使用）
    static let networkStatusChanged = Notification.Name("TFYSwiftMacOSAppKit.NetworkStatusChanged")
    static let networkReachable = Notification.Name("TFYSwiftMacOSAppKit.NetworkReachable")
    static let networkUnreachable = Notification.Name("TFYSwiftMacOSAppKit.NetworkUnreachable")
    
    static let dataDidUpdate = Notification.Name("TFYSwiftMacOSAppKit.DataDidUpdate")
    static let dataDidRefresh = Notification.Name("TFYSwiftMacOSAppKit.DataDidRefresh")
    static let dataDidError = Notification.Name("TFYSwiftMacOSAppKit.DataDidError")
    
    static let userDidLogin = Notification.Name("TFYSwiftMacOSAppKit.UserDidLogin")
    static let userDidLogout = Notification.Name("TFYSwiftMacOSAppKit.UserDidLogout")
    static let userDidUpdateProfile = Notification.Name("TFYSwiftMacOSAppKit.UserDidUpdateProfile")
}

// MARK: - 通知错误类型
public enum NotificationError: Error, LocalizedError {
    case invalidObserver
    case invalidNotificationName
    case threadSafetyError(String)
    case notificationQueueError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidObserver:
            return "无效的观察者"
        case .invalidNotificationName:
            return "无效的通知名称"
        case .threadSafetyError(let reason):
            return "线程安全错误: \(reason)"
        case .notificationQueueError(let reason):
            return "通知队列错误: \(reason)"
        }
    }
}

// MARK: - 高级通知功能
public extension NotificationCenter {
    
    /// 安全地添加观察者（带错误处理）
    /// - Parameters:
    ///   - observer: 观察者
    ///   - name: 通知名称
    ///   - object: 通知对象
    ///   - queue: 操作队列
    ///   - block: 处理块
    /// - Returns: 观察者令牌
    /// - Throws: NotificationError 如果添加失败
    @discardableResult
    func addObserverSafely(_ observer: Any,
                           name: NSNotification.Name?,
                           object: Any? = nil,
                           queue: OperationQueue = .main,
                           using block: @escaping (Notification) -> Void) throws -> NSObjectProtocol {
        guard observer is NSObject else {
            throw NotificationError.invalidObserver
        }
        
        guard name != nil else {
            throw NotificationError.invalidNotificationName
        }
        
        return addObserver(forName: name,
                          object: object,
                          queue: queue,
                          using: block)
    }
    
    /// 批量添加观察者
    /// - Parameters:
    ///   - observer: 观察者
    ///   - notifications: 通知配置数组
    /// - Returns: 观察者令牌数组
    func addObserver(_ observer: Any,
                    forNotifications notifications: [(name: NSNotification.Name, object: Any?, queue: OperationQueue)],
                    using block: @escaping (Notification) -> Void) -> [NSObjectProtocol] {
        return notifications.map { notification in
            return addObserver(forName: notification.name,
                             object: notification.object,
                             queue: notification.queue,
                             using: block)
        }
    }
    
    /// 延迟发送通知
    /// - Parameters:
    ///   - name: 通知名称
    ///   - object: 通知对象
    ///   - userInfo: 用户信息
    ///   - delay: 延迟时间
    func postNotification(name: NSNotification.Name,
                        object: Any? = nil,
                        userInfo: [AnyHashable: Any]? = nil,
                        afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.post(name: name, object: object, userInfo: userInfo)
        }
    }
    
    /// 重复发送通知
    /// - Parameters:
    ///   - name: 通知名称
    ///   - object: 通知对象
    ///   - userInfo: 用户信息
    ///   - interval: 重复间隔
    ///   - count: 重复次数（nil表示无限重复）
    /// - Returns: 定时器，用于停止重复
    func postNotificationRepeatedly(name: NSNotification.Name,
                                  object: Any? = nil,
                                  userInfo: [AnyHashable: Any]? = nil,
                                  interval: TimeInterval,
                                  count: Int? = nil) -> Timer {
        var repeatCount = 0
        return Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            self?.post(name: name, object: object, userInfo: userInfo)
            
            if let maxCount = count {
                repeatCount += 1
                if repeatCount >= maxCount {
                    timer.invalidate()
                }
            }
        }
    }
    
    /// 移除指定观察者的所有通知
    /// - Parameter observer: 观察者
    func removeAllNotifications(for observer: Any) {
        removeObserver(observer)
    }
    
    /// 移除指定观察者的特定通知
    /// - Parameters:
    ///   - observer: 观察者
    ///   - name: 通知名称
    ///   - object: 通知对象
    func removeNotification(_ observer: Any,
                          name: NSNotification.Name?,
                          object: Any? = nil) {
        removeObserver(observer, name: name, object: object)
    }
    
    /// 获取通知统计信息（已废弃：无法真实统计系统 NotificationCenter）
    @available(*, deprecated, message: "Always returned stub zeros; track observers via NotificationObserverManager instead")
    func getNotificationStatistics() -> [String: Any] {
        return [
            "totalNotifications": 0,
            "activeObservers": 0,
            "lastNotificationTime": Date()
        ]
    }
}

// MARK: - 通知观察者管理
public class NotificationObserverManager {
    private var observers: [NSObjectProtocol] = []
    private let notificationCenter: NotificationCenter
    
    public init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    
    /// 添加观察者
    /// - Parameters:
    ///   - name: 通知名称
    ///   - object: 通知对象
    ///   - queue: 操作队列
    ///   - block: 处理块
    public func addObserver(name: NSNotification.Name?,
                           object: Any? = nil,
                           queue: OperationQueue = .main,
                           using block: @escaping (Notification) -> Void) {
        let observer = notificationCenter.addObserver(forName: name,
                                                    object: object,
                                                    queue: queue,
                                                    using: block)
        observers.append(observer)
    }
    
    /// 移除所有观察者
    public func removeAllObservers() {
        observers.forEach { notificationCenter.removeObserver($0) }
        observers.removeAll()
    }
    
    /// 移除指定观察者
    /// - Parameter observer: 观察者令牌
    public func removeObserver(_ observer: NSObjectProtocol) {
        notificationCenter.removeObserver(observer)
        observers.removeAll { $0 === observer }
    }
    
    deinit {
        removeAllObservers()
    }
}
