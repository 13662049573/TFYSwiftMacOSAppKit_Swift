//
//  NSObject+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import ObjectiveC

/// NSObject操作错误类型
public enum NSObjectError: Error, LocalizedError {
    case invalidKeyPath(String)
    case invalidValue(String)
    case methodNotFound(String)
    case swizzlingFailed(String)
    case keyValueCodingFailed(String)
    case typeMismatch(String)
    case propertyNotFound(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidKeyPath(let path):
            return "无效的键路径: \(path)"
        case .invalidValue(let value):
            return "无效的值: \(value)"
        case .methodNotFound(let method):
            return "方法未找到: \(method)"
        case .swizzlingFailed(let reason):
            return "方法交换失败: \(reason)"
        case .keyValueCodingFailed(let reason):
            return "键值编码失败: \(reason)"
        case .typeMismatch(let expected):
            return "类型不匹配，期望: \(expected)"
        case .propertyNotFound(let property):
            return "属性未找到: \(property)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidKeyPath:
            return "键路径格式不正确或为空"
        case .invalidValue:
            return "提供的值不符合属性类型要求"
        case .methodNotFound:
            return "指定的方法在当前类中不存在"
        case .swizzlingFailed:
            return "运行时方法交换操作失败"
        case .keyValueCodingFailed:
            return "键值编码操作失败"
        case .typeMismatch:
            return "实际类型与期望类型不匹配"
        case .propertyNotFound:
            return "指定的属性在当前对象中不存在"
        }
    }
}

/// 键值编码配置
public struct KVCConfiguration {
    public let defaultValue: Any?
    public let allowNull: Bool
    public let validateValue: Bool
    public let typeCheck: Bool
    public let logErrors: Bool
    
    public init(defaultValue: Any? = nil, 
                allowNull: Bool = false, 
                validateValue: Bool = true,
                typeCheck: Bool = true,
                logErrors: Bool = false) {
        self.defaultValue = defaultValue
        self.allowNull = allowNull
        self.validateValue = validateValue
        self.typeCheck = typeCheck
        self.logErrors = logErrors
    }
    
    /// 默认配置
    public static let `default` = KVCConfiguration()
    
    /// 宽松配置（允许null，不验证类型）
    public static let relaxed = KVCConfiguration(allowNull: true, validateValue: false, typeCheck: false)
    
    /// 严格配置（验证所有内容）
    public static let strict = KVCConfiguration(allowNull: false, validateValue: true, typeCheck: true, logErrors: true)
}

public extension NSObject {
    
    // MARK: - 键值编码操作
    
    /// 获取指定键路径的值，如果值为 nil 或 NSNull，则返回默认值
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 键路径对应的值或默认值
    func getOrDefaultValueForKeyPath(_ keyPath: String, defaultValue: Any?) -> Any? {
        guard !keyPath.isEmpty else { return defaultValue }
        
        var result: Any? = value(forKeyPath: keyPath)
        if result == nil || result is NSNull {
            result = defaultValue
        }
        return result
    }
    
    /// 获取指定键路径的值（类型安全版本）
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 键路径对应的值或默认值
    func getValueForKeyPath<T>(_ keyPath: String, defaultValue: T) -> T {
        guard !keyPath.isEmpty else { return defaultValue }
        
        let result = value(forKeyPath: keyPath)
        if let typedResult = result as? T {
            return typedResult
        }
        return defaultValue
    }
    
    /// 获取指定键路径的值（类型安全版本，带配置）
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    ///   - configuration: 配置选项
    /// - Returns: 键路径对应的值或默认值
    func getValueForKeyPath<T>(_ keyPath: String, defaultValue: T, configuration: KVCConfiguration = .default) -> T {
        guard !keyPath.isEmpty else { 
            if configuration.logErrors {
                print("NSObject+Dejal: 空键路径")
            }
            return defaultValue 
        }
        
        let result = value(forKeyPath: keyPath)
        
        if result == nil || result is NSNull {
            if !configuration.allowNull {
                if configuration.logErrors {
                    print("NSObject+Dejal: 键路径 '\(keyPath)' 的值为空")
                }
                return defaultValue
            }
        }
        
        if let typedResult = result as? T {
            return typedResult
        }
        
        if configuration.typeCheck && configuration.logErrors {
            print("NSObject+Dejal: 键路径 '\(keyPath)' 的类型不匹配，期望 \(T.self)，实际 \(type(of: result))")
        }
        
        return defaultValue
    }
    
    /// 获取指定键路径的值（抛出错误版本）
    /// - Parameter keyPath: 键路径
    /// - Returns: 键路径对应的值
    /// - Throws: NSObjectError.invalidKeyPath 如果键路径无效
    func getValueForKeyPath(_ keyPath: String) throws -> Any {
        guard !keyPath.isEmpty else {
            throw NSObjectError.invalidKeyPath(keyPath)
        }
        
        let result = value(forKeyPath: keyPath)
        if result == nil {
            throw NSObjectError.keyValueCodingFailed("键路径 '\(keyPath)' 对应的值为空")
        }
        return result!
    }
    
    /// 安全地设置键路径的值
    /// - Parameters:
    ///   - value: 要设置的值
    ///   - keyPath: 键路径
    /// - Returns: 是否设置成功
    @discardableResult
    func setValueSafely(_ value: Any?, forKeyPath keyPath: String) -> Bool {
        guard !keyPath.isEmpty else { return false }
        
        setValue(value, forKeyPath: keyPath)
        return true
    }
    
    /// 设置键路径的值（抛出错误版本）
    /// - Parameters:
    ///   - value: 要设置的值
    ///   - keyPath: 键路径
    /// - Throws: NSObjectError.invalidKeyPath 如果键路径无效
    func setValueThrowing(_ value: Any?, forKeyPath keyPath: String) throws {
        guard !keyPath.isEmpty else {
            throw NSObjectError.invalidKeyPath(keyPath)
        }
        
        setValue(value, forKeyPath: keyPath)
    }
    
    // MARK: - 字典操作
    
    /// 根据字典中的键设置对象的属性值
    /// - Parameters:
    ///   - key: 键名
    ///   - dict: 字典
    func setValueForKey(_ key: String, withDictionary dict: [String : Any]) {
        guard !key.isEmpty else { return }
        
        if let value = dict[key], value is NSObject {
            setValue(value, forKey: key)
        }
    }
    
    /// 根据字典中的键或备用键设置对象的属性值
    /// - Parameters:
    ///   - key: 主键名
    ///   - altKey: 备用键名
    ///   - dict: 字典
    func setValueForKey(_ key: String, orDictKey altKey: String?, withDictionary dict: [String : Any]) {
        guard !key.isEmpty else { return }
        
        var value: Any? = dict[key]
        if value == nil && altKey != nil {
            value = dict[altKey!]
        }
        if value != nil && value is NSObject {
            setValue(value, forKey: key)
        }
    }
    
    /// 根据字典中的键或多个备用键设置对象的属性值
    /// - Parameters:
    ///   - key: 主键名
    ///   - altKeys: 备用键名数组
    ///   - dict: 字典
    func setValueForKey(_ key: String, orDictKeys altKeys: [String]?, withDictionary dict: [String : Any]) {
        guard !key.isEmpty else { return }
        
        var value: Any? = dict[key]
        if value == nil && altKeys != nil {
            for altKey in altKeys! {
                if value == nil {
                    value = dict[altKey]
                }
            }
        }
        if value != nil && value is NSObject {
            setValue(value, forKey: key)
        }
    }
    
    /// 将对象的指定属性值设置到字典中
    /// - Parameters:
    ///   - dict: 目标字典
    ///   - key: 键名
    func setValueInDictionary(_ dict: NSMutableDictionary, forKey key: String) {
        setValueInDictionary(dict, forKey: key, removeIfNil: false)
    }
    
    /// 将对象的指定属性值设置到字典中，并可选择在值为 nil 时移除该键
    /// - Parameters:
    ///   - dict: 目标字典
    ///   - key: 键名
    ///   - removeIfNil: 是否在值为nil时移除键
    func setValueInDictionary(_ dict: NSMutableDictionary, forKey key: String, removeIfNil: Bool) {
        guard !key.isEmpty else { return }
        
        if let value = self.value(forKey: key) {
            dict[key] = value
        } else if removeIfNil {
            dict.removeObject(forKey: key)
        }
    }
    
    /// 批量设置字典中的值到对象
    /// - Parameters:
    ///   - dict: 源字典
    ///   - keys: 要设置的键数组
    func setValuesFromDictionary(_ dict: [String: Any], forKeys keys: [String]) {
        for key in keys {
            if let value = dict[key] {
                setValue(value, forKey: key)
            }
        }
    }
    
    /// 批量设置字典中的所有值到对象
    /// - Parameter dict: 源字典
    func setValuesFromDictionary(_ dict: [String: Any]) {
        for (key, value) in dict {
            setValue(value, forKey: key)
        }
    }
    
    /// 将对象转换为字典
    /// - Parameter keys: 要包含的键数组
    /// - Returns: 字典表示
    func toDictionary(withKeys keys: [String]) -> [String: Any] {
        var dict: [String: Any] = [:]
        for key in keys {
            if let value = value(forKey: key) {
                dict[key] = value
            }
        }
        return dict
    }
    
    /// 将对象转换为字典（包含所有属性）
    /// - Returns: 字典表示
    func toDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dict: [String: Any] = [:]
        
        for child in mirror.children {
            if let label = child.label {
                dict[label] = child.value
            }
        }
        
        return dict
    }
    
    // MARK: - 类型检查
    
    /// 判断对象是否是指定类的真正子类（是子类且不是该类本身）
    /// - Parameter aClass: 要检查的类
    /// - Returns: 是否为真正子类
    func isReallySubclassOfClass(_ aClass: AnyClass) -> Bool {
        return self.isKind(of: aClass) && !self.isMember(of: aClass)
    }
    
    /// 判断对象是否是指定类的实例或子类实例
    /// - Parameter aClass: 要检查的类
    /// - Returns: 是否为实例
    func isInstanceOfClass(_ aClass: AnyClass) -> Bool {
        return self.isKind(of: aClass)
    }
    
    /// 判断对象是否是指定类的成员（不包括子类）
    /// - Parameter aClass: 要检查的类
    /// - Returns: 是否为成员
    func isMemberOfClass(_ aClass: AnyClass) -> Bool {
        return self.isMember(of: aClass)
    }
    
    /// 判断两个对象的描述是否相等（不区分大小写）
    /// - Parameter anObject: 要比较的对象
    /// - Returns: 是否相等
    func isEquivalent(_ anObject: Any?) -> Bool {
        if let object = anObject {
            return self.description.caseInsensitiveCompare((object as AnyObject).description) == .orderedSame
        } else {
            return false
        }
    }
    
    /// 判断两个对象是否相等（深度比较）
    /// - Parameter anObject: 要比较的对象
    /// - Returns: 是否相等
    func isDeeplyEqual(_ anObject: Any?) -> Bool {
        guard let object = anObject else { return false }
        
        if self === object as AnyObject {
            return true
        }
        
        if let nsObject = object as? NSObject {
            return self.isEqual(nsObject)
        }
        
        return self.isEquivalent(object)
    }
    
    // MARK: - 方法交换
    
    /// 交换指定类的两个实例方法
    /// - Parameters:
    ///   - targetClass: 目标类
    ///   - originalSelector: 原始方法选择器
    ///   - swizzledSelector: 交换方法选择器
    class func exchangeInstanceMethodsForClass(_ targetClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(targetClass, originalSelector),
              let swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector) else {
            return
        }
        var didAddMethod = false
        let swizzledImp = method_getImplementation(swizzledMethod)
        let swizzledEncoding = method_getTypeEncoding(swizzledMethod)
        if swizzledEncoding != nil {
            didAddMethod = class_addMethod(targetClass, originalSelector, swizzledImp, swizzledEncoding!)
        }
        if didAddMethod {
            let originalImp = method_getImplementation(originalMethod)
            let originalEncoding = method_getTypeEncoding(originalMethod)
            if originalEncoding != nil {
                class_replaceMethod(targetClass, swizzledSelector, originalImp, originalEncoding!)
            }
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    /// 交换指定类的两个类方法
    /// - Parameters:
    ///   - targetClass: 目标类
    ///   - originalSelector: 原始方法选择器
    ///   - swizzledSelector: 交换方法选择器
    class func exchangeClassMethodsForClass(_ targetClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getClassMethod(targetClass, originalSelector),
              let swizzledMethod = class_getClassMethod(targetClass, swizzledSelector) else {
            return
        }
        var didAddMethod = false
        let swizzledImp = method_getImplementation(swizzledMethod)
        let swizzledEncoding = method_getTypeEncoding(swizzledMethod)
        if swizzledEncoding != nil {
            didAddMethod = class_addMethod(targetClass, originalSelector, swizzledImp, swizzledEncoding!)
        }
        if didAddMethod {
            let originalImp = method_getImplementation(originalMethod)
            let originalEncoding = method_getTypeEncoding(originalMethod)
            if originalEncoding != nil {
                class_replaceMethod(targetClass, swizzledSelector, originalImp, originalEncoding!)
            }
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    /// 安全地交换方法（抛出错误版本）
    /// - Parameters:
    ///   - targetClass: 目标类
    ///   - originalSelector: 原始方法选择器
    ///   - swizzledSelector: 交换方法选择器
    /// - Throws: NSObjectError.methodNotFound 如果方法未找到
    class func exchangeInstanceMethodsSafely(_ targetClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) throws {
        guard let originalMethod = class_getInstanceMethod(targetClass, originalSelector) else {
            throw NSObjectError.methodNotFound("原始方法 '\(originalSelector)' 未找到")
        }
        guard let swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector) else {
            throw NSObjectError.methodNotFound("交换方法 '\(swizzledSelector)' 未找到")
        }
        
        var didAddMethod = false
        let swizzledImp = method_getImplementation(swizzledMethod)
        let swizzledEncoding = method_getTypeEncoding(swizzledMethod)
        if swizzledEncoding != nil {
            didAddMethod = class_addMethod(targetClass, originalSelector, swizzledImp, swizzledEncoding!)
        }
        if didAddMethod {
            let originalImp = method_getImplementation(originalMethod)
            let originalEncoding = method_getTypeEncoding(originalMethod)
            if originalEncoding != nil {
                class_replaceMethod(targetClass, swizzledSelector, originalImp, originalEncoding!)
            }
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    // MARK: - 便利方法
    
    /// 获取对象的类名
    var className: String {
        return NSStringFromClass(type(of: self))
    }
    
    /// 获取对象的类名（不包含模块名）
    var simpleClassName: String {
        let fullName = className
        if let range = fullName.range(of: ".", options: .backwards) {
            return String(fullName[range.upperBound...])
        }
        return fullName
    }
    
    /// 获取对象的模块名
    var moduleName: String {
        let fullName = className
        if let range = fullName.range(of: ".", options: .backwards) {
            return String(fullName[..<range.lowerBound])
        }
        return ""
    }
    
    /// 判断对象是否为nil或NSNull
    var isNilOrNull: Bool {
        return self is NSNull
    }
    
    // MARK: - 类型安全的便利方法
    
    /// 获取字符串值
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 字符串值
    func getString(forKeyPath keyPath: String, defaultValue: String = "") -> String {
        return getValueForKeyPath(keyPath, defaultValue: defaultValue)
    }
    
    /// 获取整数值
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 整数值
    func getInt(forKeyPath keyPath: String, defaultValue: Int = 0) -> Int {
        return getValueForKeyPath(keyPath, defaultValue: defaultValue)
    }
    
    /// 获取双精度浮点数值
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 双精度浮点数值
    func getDouble(forKeyPath keyPath: String, defaultValue: Double = 0.0) -> Double {
        return getValueForKeyPath(keyPath, defaultValue: defaultValue)
    }
    
    /// 获取布尔值
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 布尔值
    func getBool(forKeyPath keyPath: String, defaultValue: Bool = false) -> Bool {
        return getValueForKeyPath(keyPath, defaultValue: defaultValue)
    }
    
    /// 获取数组值
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 数组值
    func getArray<T>(forKeyPath keyPath: String, defaultValue: [T] = []) -> [T] {
        return getValueForKeyPath(keyPath, defaultValue: defaultValue)
    }
    
    /// 获取字典值
    /// - Parameters:
    ///   - keyPath: 键路径
    ///   - defaultValue: 默认值
    /// - Returns: 字典值
    func getDictionary(forKeyPath keyPath: String, defaultValue: [String: Any] = [:]) -> [String: Any] {
        return getValueForKeyPath(keyPath, defaultValue: defaultValue)
    }
    
    /// 安全地执行闭包
    /// - Parameter closure: 要执行的闭包
    /// - Returns: 闭包的返回值
    func safeExecute<T>(_ closure: () -> T) -> T? {
        return closure()
    }
    
    /// 延迟执行闭包
    /// - Parameters:
    ///   - delay: 延迟时间
    ///   - closure: 要执行的闭包
    func performAfter(_ delay: TimeInterval, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
    }
    
    /// 在主队列执行闭包
    /// - Parameter closure: 要执行的闭包
    func performOnMainQueue(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
    
    /// 在后台队列执行闭包
    /// - Parameter closure: 要执行的闭包
    func performOnBackgroundQueue(_ closure: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async(execute: closure)
    }
}

// MARK: - 使用示例和最佳实践

/*

// MARK: - 基础使用示例

// 1. 键值编码操作
let user = User()
let name = user.getOrDefaultValueForKeyPath("name", defaultValue: "Unknown")
let age = user.getValueForKeyPath("age", defaultValue: 0)
let email = user.getValueForKeyPath("email", defaultValue: "")

// 2. 安全设置值
let success = user.setValueSafely("John", forKeyPath: "name")
do {
    try user.setValueThrowing(25, forKeyPath: "age")
} catch NSObjectError.invalidKeyPath {
    print("无效的键路径")
} catch {
    print("其他错误: \(error)")
}

// 3. 字典操作
let dict = ["name": "Alice", "age": 30, "email": "alice@example.com"]
user.setValuesFromDictionary(dict)
user.setValueForKey("name", withDictionary: dict)
user.setValueForKey("age", orDictKey: "userAge", withDictionary: dict)

// 4. 类型检查
let isSubclass = user.isReallySubclassOfClass(NSObject.self)
let isInstance = user.isInstanceOfClass(User.self)
let isMember = user.isMemberOfClass(User.self)

// MARK: - 高级用法

// 5. 方法交换
extension UIViewController {
    @objc func swizzled_viewDidLoad() {
        print("ViewDidLoad called")
        swizzled_viewDidLoad() // 调用原始方法
    }
    
    static func swizzleViewDidLoad() {
        exchangeInstanceMethodsForClass(
            UIViewController.self,
            originalSelector: #selector(UIViewController.viewDidLoad),
            swizzledSelector: #selector(UIViewController.swizzled_viewDidLoad)
        )
    }
}

// 6. 安全的方法交换
do {
    try NSObject.exchangeInstanceMethodsSafely(
        UIViewController.self,
        originalSelector: #selector(UIViewController.viewDidLoad),
        swizzledSelector: #selector(UIViewController.swizzled_viewDidLoad)
    )
} catch NSObjectError.methodNotFound {
    print("方法未找到")
} catch {
    print("其他错误: \(error)")
}

// 7. 对象转换
let userDict = user.toDictionary()
let userDictWithKeys = user.toDictionary(withKeys: ["name", "age"])

// 8. 对象比较
let user1 = User(name: "Alice", age: 25)
let user2 = User(name: "Alice", age: 25)
let isEqual = user1.isDeeplyEqual(user2)
let isEquivalent = user1.isEquivalent(user2)

// MARK: - 便利方法使用

// 9. 类信息
print("类名: \(user.className)")
print("简单类名: \(user.simpleClassName)")
print("模块名: \(user.moduleName)")

// 10. 安全执行
let result = user.safeExecute {
    // 可能抛出错误的代码
    return "success"
}

// 11. 延迟执行
user.performAfter(2.0) {
    print("2秒后执行")
}

// 12. 队列执行
user.performOnMainQueue {
    // 在主队列执行的代码
    print("在主队列执行")
}

user.performOnBackgroundQueue {
    // 在后台队列执行的代码
    print("在后台队列执行")
}

// MARK: - 最佳实践

// 13. 批量设置值
extension NSObject {
    func configure(with configuration: [String: Any]) {
        for (key, value) in configuration {
            setValueSafely(value, forKeyPath: key)
        }
    }
}

// 14. 类型安全的键值编码
extension NSObject {
    func getString(forKey key: String, defaultValue: String = "") -> String {
        return getValueForKeyPath(key, defaultValue: defaultValue)
    }
    
    func getInt(forKey key: String, defaultValue: Int = 0) -> Int {
        return getValueForKeyPath(key, defaultValue: defaultValue)
    }
    
    func getBool(forKey key: String, defaultValue: Bool = false) -> Bool {
        return getValueForKeyPath(key, defaultValue: defaultValue)
    }
    
    func getDouble(forKey key: String, defaultValue: Double = 0.0) -> Double {
        return getValueForKeyPath(key, defaultValue: defaultValue)
    }
}

// 15. 对象缓存
class ObjectCache {
    private static var cache: [String: NSObject] = [:]
    
    static func getOrCreate<T: NSObject>(for key: String, create: () -> T) -> T {
        if let cached = cache[key] as? T {
            return cached
        }
        
        let newObject = create()
        cache[key] = newObject
        return newObject
    }
    
    static func clearCache() {
        cache.removeAll()
    }
}

// 16. 对象监控
class ObjectMonitor {
    private var observers: [NSObject: [String: Any]] = [:]
    
    func monitor<T: NSObject>(_ object: T, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [.new, .old], closure: @escaping (T, NSKeyValueObservedChange<Any>) -> Void) {
        let observer = object.observe(\.self, options: options) { obj, change in
            closure(obj, change)
        }
        
        if observers[object] == nil {
            observers[object] = [:]
        }
        observers[object]?[keyPath] = observer
    }
    
    func stopMonitoring(_ object: NSObject) {
        observers[object]?.removeAll()
        observers.removeValue(forKey: object)
    }
}

// 17. 性能优化 - 对象池
class ObjectPool<T: NSObject> {
    private var pool: [T] = []
    private let createObject: () -> T
    private let resetObject: (T) -> Void
    
    init(createObject: @escaping () -> T, resetObject: @escaping (T) -> Void) {
        self.createObject = createObject
        self.resetObject = resetObject
    }
    
    func getObject() -> T {
        if let object = pool.popLast() {
            return object
        }
        return createObject()
    }
    
    func returnObject(_ object: T) {
        resetObject(object)
        pool.append(object)
    }
}

*/
