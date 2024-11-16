//
//  TFYSwiftChain.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - 基础协议

/// 链式编程基础协议
/// 所有需要支持链式调用的类型都需要遵循此协议
public protocol TFYCompatible {
    /// 关联类型，用于指定实现类型
    associatedtype ChainType
}

// MARK: - NSObject 扩展

/// 默认让所有 NSObject 子类都支持链式调用
extension NSObject: TFYCompatible {
    public typealias ChainType = NSObject
}

// MARK: - 属性兼容协议

/// Swift属性兼容协议
/// 用于处理回调和属性观察
public protocol TFYSwiftPropertyCompatible {
    /// 关联类型，用于定义回调中的数据类型
    associatedtype ValueType
    
    /// 定义回调闭包类型
    typealias SwiftCallBack = ((ValueType?) -> Void)
    
    /// 回调闭包属性
    var swiftCallBack: SwiftCallBack? { get set }
}

// MARK: - 错误处理

/// 链式调用错误枚举
public enum ChainError: Error {
    case invalidValue
    case invalidOperation
    case typeConversionFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidValue:
            return "无效的值"
        case .invalidOperation:
            return "无效的操作"
        case .typeConversionFailed:
            return "类型转换失败"
        }
    }
}

// MARK: - 链式调用包装结构体

/// 链式调用包装结构体
/// - Parameter Base: 被包装的对象类型
public struct Chain<Base> {
    /// 被包装的原始对象
    public let base: Base
    
    /// 构建并返回原始对象
    /// 用于链式调用结束后获取原始对象
    public var build: Base {
        return base
    }
    
    /// 初始化方法
    /// - Parameter base: 要包装的对象
    public init(_ base: Base) {
        self.base = base
    }
    
    /// 执行自定义操作
    /// - Parameter operation: 要执行的操作闭包
    /// - Returns: 链式调用对象
    @discardableResult
    public func custom(_ operation: (Base) throws -> Void) rethrows -> Self {
        try operation(base)
        return self
    }
    
    /// 条件执行
    /// - Parameters:
    ///   - condition: 条件
    ///   - operation: 满足条件时执行的操作
    /// - Returns: 链式调用对象
    @discardableResult
    public func `if`(_ condition: Bool, _ operation: (Base) throws -> Void) rethrows -> Self {
        if condition {
            try operation(base)
        }
        return self
    }
    
    /// 获取原始对象的某个属性值
    /// - Parameter keyPath: 属性路径
    /// - Returns: 属性值
    public func value<T>(_ keyPath: KeyPath<Base, T>) -> T {
        return base[keyPath: keyPath]
    }
}

// MARK: - TFYCompatible 协议扩展

/// TFYCompatible 协议扩展
/// 为遵循协议的类型提供链式调用支持
extension TFYCompatible {
    /// 静态链式调用入口
    /// 用于类型方法的链式调用
    static public var chain: Chain<Self>.Type {
        get { Chain<Self>.self }
        set {}
    }
    
    /// 实例链式调用入口
    /// 用于实例方法的链式调用
    public var chain: Chain<Self> {
        get { Chain(self) }
        set {}
    }
}

// MARK: - 实用工具扩展

extension Chain {
    /// 打印调试信息
    /// - Parameter message: 调试信息
    /// - Returns: 链式调用对象
    @discardableResult
    public func debug(_ message: String) -> Self {
        #if DEBUG
        print("Debug: \(message)")
        #endif
        return self
    }
    
    /// 执行异步操作
    /// - Parameter operation: 异步操作闭包
    /// - Returns: 链式调用对象
    @discardableResult
    public func async(_ operation: @escaping (Base) -> Void) -> Self {
        DispatchQueue.global().async {
            operation(self.base)
        }
        return self
    }
}

/**
 // 1. 基本使用
 class MyView: NSView {
     var title: String = ""
 }

 extension Chain where Base: MyView {
     @discardableResult
     func setTitle(_ title: String) -> Self {
         base.title = title
         return self
     }
 }

 let myView = MyView()
 myView.chain
     .setTitle("Hello")
     .debug("Title set")
     .custom { view in
         // 自定义操作
         view.title = view.title.uppercased()
     }
     .if(true) { view in
         // 条件执行
         print("Current title: \(view.title)")
     }

 // 2. 异步操作
 myView.chain.async { view in
     // 在后台线程执行
     Thread.sleep(forTimeInterval: 1)
     DispatchQueue.main.async {
         view.title = "Updated"
     }
 }

 // 3. 属性观察
 class ObservableClass: NSObject, TFYSwiftPropertyCompatible {
     typealias ValueType = String
     var swiftCallBack: ((String?) -> Void)?
     
     var value: String = "" {
         didSet {
             swiftCallBack?(value)
         }
     }
 }
 */

