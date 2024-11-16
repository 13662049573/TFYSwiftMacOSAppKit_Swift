//
//  TFYSwiftChain.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

// MARK: - 基础协议

/// 链式编程基础协议
/// 所有需要支持链式调用的类型都需要遵循此协议
public protocol ChainCompatible {
    /// 关联类型，用于指定实现类型
    associatedtype ChainBaseType
}

// MARK: - NSObject 扩展

extension NSObject: ChainCompatible {
    /// 指定关联类型为自身
    public typealias ChainBaseType = NSObject
}

// MARK: - 链式调用包装结构体

/// 链式调用包装结构体
public struct Chain<Base> {
    /// 被包装的原始对象
    public let base: Base
    
    /// 错误处理闭包
    private var errorHandler: ((ChainError) -> Void)?
    
    /// 调试模式标志
    private var isDebugEnabled: Bool = false
    
    /// 构建并返回原始对象
    public var build: Base {
        return base
    }
    
    /// 初始化方法
    public init(_ base: Base) {
        self.base = base
    }
    
    /// 设置错误处理器
    /// - Parameter handler: 错误处理闭包
    /// - Returns: 链式调用对象
    @discardableResult
    public func setErrorHandler(_ handler: @escaping (ChainError) -> Void) -> Self {
        var copy = self
        copy.errorHandler = handler
        return copy
    }
    
    /// 启用调试模式
    /// - Returns: 链式调用对象
    @discardableResult
    public func enableDebug() -> Self {
        var copy = self
        copy.isDebugEnabled = true
        return copy
    }
    
    /// 执行自定义操作
    /// - Parameter operation: 要执行的操作闭包
    /// - Returns: 链式调用对象
    @discardableResult
    public func custom(_ operation: (Base) throws -> Void) -> Self {
        do {
            try operation(base)
        } catch let error as ChainError {
            handleError(error)
        } catch {
            handleError(.customError(error.localizedDescription))
        }
        return self
    }
    
    /// 条件执行
    /// - Parameters:
    ///   - condition: 条件
    ///   - operation: 满足条件时执行的操作
    /// - Returns: 链式调用对象
    @discardableResult
    public func `if`(_ condition: Bool, _ operation: (Base) throws -> Void) -> Self {
        guard condition else { return self }
        return custom(operation)
    }
    
    /// 异步执行
    /// - Parameter operation: 异步操作闭包
    /// - Returns: 链式调用对象
    @discardableResult
    public func async(_ operation: @escaping (Base) -> Void) -> Self {
        DispatchQueue.global().async {
            operation(self.base)
        }
        return self
    }
    
    /// 主线程执行
    /// - Parameter operation: 主线程操作闭包
    /// - Returns: 链式调用对象
    @discardableResult
    public func onMain(_ operation: @escaping (Base) -> Void) -> Self {
        DispatchQueue.main.async {
            operation(self.base)
        }
        return self
    }
    
    /// 延迟执行
    /// - Parameters:
    ///   - seconds: 延迟秒数
    ///   - operation: 要执行的操作
    /// - Returns: 链式调用对象
    @discardableResult
    public func delay(_ seconds: Double, _ operation: @escaping (Base) -> Void) -> Self {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            operation(self.base)
        }
        return self
    }
    
    /// 打印调试信息
    /// - Parameter message: 调试信息
    /// - Returns: 链式调用对象
    @discardableResult
    public func debug(_ message: String) -> Self {
        if isDebugEnabled {
            print("Debug [\(type(of: base))]: \(message)")
        }
        return self
    }
    
    /// 处理错误
    private func handleError(_ error: ChainError) {
        errorHandler?(error)
        if isDebugEnabled {
            print("Error [\(type(of: base))]: \(error.localizedDescription)")
        }
    }
}

// MARK: - ChainCompatible 协议扩展

public extension ChainCompatible {
    /// 静态链式调用入口
    static var chain: Chain<Self>.Type {
        return Chain<Self>.self
    }
    
    /// 实例链式调用入口
    var chain: Chain<Self> {
        return Chain(self)
    }
}

// MARK: - 错误处理

/// 链式调用错误类型
public enum ChainError: Error {
    case invalidValue(String)
    case invalidOperation(String)
    case typeConversionFailed(String)
    case customError(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidValue(let message):
            return "无效的值: \(message)"
        case .invalidOperation(let message):
            return "无效的操作: \(message)"
        case .typeConversionFailed(let message):
            return "类型转换失败: \(message)"
        case .customError(let message):
            return "自定义错误: \(message)"
        }
    }
}

// MARK: - 属性包装器

/// 属性观察包装器
@propertyWrapper
public struct Observable<Value> {
    private var value: Value
    private var onChange: ((Value) -> Void)?
    
    public var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            onChange?(newValue)
        }
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    /// 设置属性变化回调
    public mutating func setOnChange(_ callback: @escaping (Value) -> Void) {
        onChange = callback
    }
}

/**
 // 1. 基本使用
 class MyView: NSView {
     @Observable var title: String = ""
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
     .enableDebug()
     .setErrorHandler { error in
         print("Error occurred: \(error)")
     }
     .setTitle("Hello")
     .debug("Title set")
     .custom { view in
         // 自定义操作
         view.title = view.title.uppercased()
     }
     .if(true) { view in
         print("Current title: \(view.title)")
     }

 // 2. 异步操作
 myView.chain
     .async { view in
         // 后台线程操作
         Thread.sleep(forTimeInterval: 1)
     }
     .onMain { view in
         // 主线程更新 UI
         view.title = "Updated"
     }
     .delay(2.0) { view in
         // 延迟执行
         view.title = "Delayed"
     }

 // 3. 属性观察
 var observation: Observable<String> = Observable(wrappedValue: "")
 observation.setOnChange { newValue in
     print("Value changed to: \(newValue)")
 }
 */
