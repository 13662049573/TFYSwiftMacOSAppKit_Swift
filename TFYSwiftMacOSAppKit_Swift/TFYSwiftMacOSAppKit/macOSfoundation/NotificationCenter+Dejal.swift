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
    // 示例通知名称
    static let exampleNotification = Notification.Name("ExampleNotification")
}
