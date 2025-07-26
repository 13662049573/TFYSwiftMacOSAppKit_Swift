//
//  NSKeyedUnarchiver+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// NSKeyedUnarchiver 的扩展，提供异步解档功能
public extension NSKeyedUnarchiver {
    
    /// 从数据中异步解档对象
    /// - Parameters:
    ///   - data: 需要解档的数据
    /// - Returns: 包含解档对象和错误信息的元组
    ///   - object: 解档后的对象，如果失败则为 nil
    ///   - error: 解档过程中的错误信息，如果成功则为 nil
    @available(macOS 12.0, *)
    static func unarchiveObject(withData data: Data) async -> (object: Any?, error: Error?) {
        do {
            // 使用 withCheckedThrowingContinuation 处理可能的异步操作
            let object = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Any?, Error>) in
                do {
                    // 使用 NSSecureCoding 协议作为类型约束，支持所有 NSObject 类型
                    if let object = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: data) {
                        continuation.resume(returning: object)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    // 捕获并传递解档过程中的错误
                    continuation.resume(throwing: error)
                }
            }
            return (object, nil)
        } catch {
            return (nil, error)
        }
    }
    
    /// 从文件路径异步解档对象
    /// - Parameters:
    ///   - path: 归档文件的路径
    /// - Returns: 包含解档对象和错误信息的元组
    ///   - object: 解档后的对象，如果失败则为 nil
    ///   - error: 解档过程中的错误信息，如果成功则为 nil
    @available(macOS 12.0, *)
    static func unarchiveObject(withFile path: String) async -> (object: Any?, error: Error?) {
        // 首先尝试读取文件内容
        guard let data = FileManager.default.contents(atPath: path) else {
            // 如果文件读取失败，返回相应的错误
            return (nil, NSError(domain: "NSKeyedUnarchiverError",
                               code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "无法读取指定路径的文件"]))
        }
        
        // 调用数据解档方法
        return await unarchiveObject(withData: data)
    }
    
    /// 从数据中异步解档指定类型的对象（类型安全版本）
    /// - Parameters:
    ///   - type: 要解档的对象类型
    ///   - data: 需要解档的数据
    /// - Returns: 包含解档对象和错误信息的元组
    ///   - object: 解档后的指定类型对象，如果失败则为 nil
    ///   - error: 解档过程中的错误信息，如果成功则为 nil
    /// - Note: 泛型类型 T 必须同时遵循 NSObject 和 NSSecureCoding 协议
    @available(macOS 12.0, *)
    static func unarchiveObject<T>(
        ofClass type: T.Type,
        from data: Data
    ) async -> (object: T?, error: Error?) where T: NSObject & NSSecureCoding {
        do {
            // 使用 withCheckedThrowingContinuation 处理可能的异步操作
            let object = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T?, Error>) in
                do {
                    // 解档指定类型的对象
                    let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: type, from: data)
                    continuation.resume(returning: object)
                } catch {
                    // 捕获并传递解档过程中的错误
                    continuation.resume(throwing: error)
                }
            }
            return (object, nil)
        } catch {
            return (nil, error)
        }
    }
}
