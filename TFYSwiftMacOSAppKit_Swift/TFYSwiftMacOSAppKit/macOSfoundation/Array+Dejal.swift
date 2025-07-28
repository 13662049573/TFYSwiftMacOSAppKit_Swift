//
//  Array+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

/// 数组操作错误类型
public enum ArrayError: Error, LocalizedError {
    case invalidIndex(Int)
    case emptyArray
    case serializationFailed(String)
    case deserializationFailed(String)
    case invalidJSON(String)
    case invalidPlist(String)
    case typeMismatch(String)
    case outOfBounds(Int, Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidIndex(let index):
            return "无效的索引: \(index)"
        case .emptyArray:
            return "数组为空"
        case .serializationFailed(let reason):
            return "序列化失败: \(reason)"
        case .deserializationFailed(let reason):
            return "反序列化失败: \(reason)"
        case .invalidJSON(let reason):
            return "无效的JSON格式: \(reason)"
        case .invalidPlist(let reason):
            return "无效的属性列表格式: \(reason)"
        case .typeMismatch(let expected):
            return "类型不匹配，期望: \(expected)"
        case .outOfBounds(let index, let count):
            return "索引 \(index) 超出数组边界 (0..<\(count))"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidIndex:
            return "索引为负数或超出数组范围"
        case .emptyArray:
            return "数组没有任何元素"
        case .serializationFailed:
            return "数据序列化过程中发生错误"
        case .deserializationFailed:
            return "数据反序列化过程中发生错误"
        case .invalidJSON:
            return "JSON格式不符合标准"
        case .invalidPlist:
            return "属性列表格式不正确"
        case .typeMismatch:
            return "实际类型与期望类型不匹配"
        case .outOfBounds:
            return "访问了数组边界之外的元素"
        }
    }
}

// MARK: - Array 扩展
public extension Array {
    
    // MARK: - 属性列表(Plist)操作
    
    /// 从属性列表数据创建数组
    /// - Parameter plist: 包含数组的属性列表数据
    /// - Returns: 从plist创建的数组,如果失败则返回nil
    static func array(withPlistData plist: Data) -> [Any]? {
        guard let array = try? PropertyListSerialization.propertyList(
            from: plist,
            options: .mutableContainers,
            format: nil) as? [Any] else {
            return nil
        }
        return array
    }
    
    /// 从属性列表数据创建数组（抛出错误版本）
    /// - Parameter plist: 包含数组的属性列表数据
    /// - Returns: 从plist创建的数组
    /// - Throws: ArrayError.deserializationFailed 如果反序列化失败
    static func array(withPlistData plist: Data) throws -> [Any] {
        do {
            guard let array = try PropertyListSerialization.propertyList(
                from: plist,
                options: .mutableContainers,
                format: nil) as? [Any] else {
                throw ArrayError.deserializationFailed("无法从属性列表数据创建数组")
            }
            return array
        } catch {
            throw ArrayError.deserializationFailed("属性列表反序列化失败: \(error.localizedDescription)")
        }
    }
    
    /// 从属性列表XML字符串创建数组
    /// - Parameter plist: 包含数组的属性列表XML字符串
    /// - Returns: 从plist字符串创建的数组,如果失败则返回nil
    static func array(withPlistString plist: String) -> [Any]? {
        guard let data = plist.data(using: .utf8) else { return nil }
        return array(withPlistData: data)
    }
    
    /// 从属性列表XML字符串创建数组（抛出错误版本）
    /// - Parameter plist: 包含数组的属性列表XML字符串
    /// - Returns: 从plist字符串创建的数组
    /// - Throws: ArrayError.deserializationFailed 如果反序列化失败
    static func array(withPlistString plist: String) throws -> [Any] {
        guard let data = plist.data(using: .utf8) else {
            throw ArrayError.deserializationFailed("无法将字符串转换为数据")
        }
        return try array(withPlistData: data)
    }
    
    /// 将数组序列化为二进制属性列表数据
    /// - Returns: 二进制plist数据,如果失败则返回nil
    func plistData() -> Data? {
        return try? PropertyListSerialization.data(
            fromPropertyList: self,
            format: .binary,
            options: 0)
    }
    
    /// 将数组序列化为二进制属性列表数据（抛出错误版本）
    /// - Returns: 二进制plist数据
    /// - Throws: ArrayError.serializationFailed 如果序列化失败
    func plistDataThrowing() throws -> Data {
        do {
            return try PropertyListSerialization.data(
                fromPropertyList: self,
                format: .binary,
                options: 0)
        } catch {
            throw ArrayError.serializationFailed("属性列表序列化失败: \(error.localizedDescription)")
        }
    }
    
    /// 将数组序列化为XML属性列表字符串
    /// - Returns: XML格式的plist字符串,如果失败则返回nil
    func plistString() -> String? {
        guard let data = try? PropertyListSerialization.data(
            fromPropertyList: self,
            format: .xml,
            options: 0) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// 将数组序列化为XML属性列表字符串（抛出错误版本）
    /// - Returns: XML格式的plist字符串
    /// - Throws: ArrayError.serializationFailed 如果序列化失败
    func plistStringThrowing() throws -> String {
        let data = try PropertyListSerialization.data(
            fromPropertyList: self,
            format: .xml,
            options: 0)
        guard let string = String(data: data, encoding: .utf8) else {
            throw ArrayError.serializationFailed("无法将数据转换为字符串")
        }
        return string
    }
    
    // MARK: - JSON 操作
    
    /// 将数组转换为JSON字符串
    /// - Returns: JSON字符串,如果失败则返回nil
    func jsonStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        
        guard let data = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    /// 将数组转换为JSON字符串（抛出错误版本）
    /// - Returns: JSON字符串
    /// - Throws: ArrayError.serializationFailed 如果序列化失败
    func jsonStringEncodedThrowing() throws -> String {
        guard JSONSerialization.isValidJSONObject(self) else {
            throw ArrayError.invalidJSON("数组不是有效的JSON对象")
        }
        
        let data = try JSONSerialization.data(
            withJSONObject: self,
            options: [])
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw ArrayError.serializationFailed("无法将JSON数据转换为字符串")
        }
        
        return string
    }
    
    /// 将数组转换为格式化的JSON字符串
    /// - Returns: 格式化的JSON字符串,如果失败则返回nil
    func jsonPrettyStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        
        guard let data = try? JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    /// 将数组转换为格式化的JSON字符串（抛出错误版本）
    /// - Returns: 格式化的JSON字符串
    /// - Throws: ArrayError.serializationFailed 如果序列化失败
    func jsonPrettyStringEncodedThrowing() throws -> String {
        guard JSONSerialization.isValidJSONObject(self) else {
            throw ArrayError.invalidJSON("数组不是有效的JSON对象")
        }
        
        let data = try JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted)
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw ArrayError.serializationFailed("无法将JSON数据转换为字符串")
        }
        
        return string
    }
    
    // MARK: - 安全访问
    
    /// 获取数组中指定索引的元素,如果索引越界则返回nil
    /// - Parameter index: 要获取元素的索引
    /// - Returns: 指定索引的元素,如果索引越界则返回nil
    func object(atSafeIndex index: Int) -> Element? {
        guard index >= 0, index < count else {
            return nil
        }
        return self[index]
    }
    
    /// 获取数组中指定索引的元素（抛出错误版本）
    /// - Parameter index: 要获取元素的索引
    /// - Returns: 指定索引的元素
    /// - Throws: ArrayError.invalidIndex 如果索引越界
    func object(atIndex index: Int) throws -> Element {
        guard index >= 0, index < count else {
            throw ArrayError.outOfBounds(index, count)
        }
        return self[index]
    }
    
    /// 安全地设置指定索引的元素
    /// - Parameters:
    ///   - element: 要设置的元素
    ///   - index: 索引
    /// - Returns: 是否设置成功
    @discardableResult
    mutating func setElement(_ element: Element, atSafeIndex index: Int) -> Bool {
        guard index >= 0, index < count else {
            return false
        }
        self[index] = element
        return true
    }
    
    /// 设置指定索引的元素（抛出错误版本）
    /// - Parameters:
    ///   - element: 要设置的元素
    ///   - index: 索引
    /// - Throws: ArrayError.outOfBounds 如果索引越界
    mutating func setElement(_ element: Element, atIndex index: Int) throws {
        guard index >= 0, index < count else {
            throw ArrayError.outOfBounds(index, count)
        }
        self[index] = element
    }
    
    /// 随机获取数组中的一个元素
    /// - Returns: 随机选择的元素,如果数组为空则返回nil
    func randomObject() -> Element? {
        guard !isEmpty else { return nil }
        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }
    
    /// 随机获取数组中的一个元素（抛出错误版本）
    /// - Returns: 随机选择的元素
    /// - Throws: ArrayError.emptyArray 如果数组为空
    func randomObjectThrowing() throws -> Element {
        guard !isEmpty else {
            throw ArrayError.emptyArray
        }
        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }
    
    // MARK: - 数组操作
    
    /// 获取数组的第一个元素（安全版本）
    /// - Returns: 第一个元素，如果数组为空则返回nil
    var firstSafe: Element? {
        return isEmpty ? nil : first
    }
    
    /// 获取数组的最后一个元素（安全版本）
    /// - Returns: 最后一个元素，如果数组为空则返回nil
    var lastSafe: Element? {
        return isEmpty ? nil : last
    }
    
    /// 获取数组的第一个元素（抛出错误版本）
    /// - Returns: 第一个元素
    /// - Throws: ArrayError.emptyArray 如果数组为空
    var firstThrowing: Element {
        get throws {
            guard let first = first else {
                throw ArrayError.emptyArray
            }
            return first
        }
    }
    
    /// 获取数组的最后一个元素（抛出错误版本）
    /// - Returns: 最后一个元素
    /// - Throws: ArrayError.emptyArray 如果数组为空
    var lastThrowing: Element {
        get throws {
            guard let last = last else {
                throw ArrayError.emptyArray
            }
            return last
        }
    }
    
    /// 安全地移除并返回第一个元素
    /// - Returns: 第一个元素，如果数组为空则返回nil
    mutating func removeFirstSafe() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
    
    /// 安全地移除并返回最后一个元素
    /// - Returns: 最后一个元素，如果数组为空则返回nil
    mutating func removeLastSafe() -> Element? {
        guard !isEmpty else { return nil }
        return removeLast()
    }
    
    /// 移除并返回第一个元素（抛出错误版本）
    /// - Returns: 第一个元素
    /// - Throws: ArrayError.emptyArray 如果数组为空
    mutating func removeFirstThrowing() throws -> Element {
        guard !isEmpty else {
            throw ArrayError.emptyArray
        }
        return removeFirst()
    }
    
    /// 移除并返回最后一个元素（抛出错误版本）
    /// - Returns: 最后一个元素
    /// - Throws: ArrayError.emptyArray 如果数组为空
    mutating func removeLastThrowing() throws -> Element {
        guard !isEmpty else {
            throw ArrayError.emptyArray
        }
        return removeLast()
    }
    
    // MARK: - 数组转换和操作
    
    /// 将数组转换为可选类型数组
    /// - Returns: 转换后的可选类型数组
    func toOptionalArray() -> [Element?] {
        return map { $0 as Element? }
    }
    
    /// 将数组转换为Set
    /// - Returns: 转换后的Set
    func toSet() -> Set<Element> where Element: Hashable {
        return Set(self)
    }
    
    /// 将数组转换为Dictionary
    /// - Parameter transform: 转换闭包
    /// - Returns: 转换后的Dictionary
    func toDictionary<K, V>(_ transform: (Element) -> (K, V)) -> [K: V] {
        return Dictionary(uniqueKeysWithValues: map(transform))
    }
    
    /// 将数组分组
    /// - Parameter key: 分组键闭包
    /// - Returns: 分组后的Dictionary
    func grouped<K: Hashable>(by key: (Element) -> K) -> [K: [Element]] {
        return Dictionary(grouping: self, by: key)
    }
    
    /// 移除重复元素（保持顺序）
    /// - Returns: 移除重复元素后的数组
    func removingDuplicates() -> [Element] where Element: Hashable {
        var seen = Set<Element>()
        return filter { element in
            if seen.contains(element) {
                return false
            } else {
                seen.insert(element)
                return true
            }
        }
    }
    
    /// 移除重复元素（保持顺序，使用自定义比较）
    /// - Parameter isEqual: 比较闭包
    /// - Returns: 移除重复元素后的数组
    func removingDuplicates(by isEqual: (Element, Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(where: { isEqual($0, element) }) {
                result.append(element)
            }
        }
        return result
    }
    
    // MARK: - 数组切片和子数组
    
    /// 安全地获取数组切片
    /// - Parameters:
    ///   - start: 起始索引
    ///   - end: 结束索引
    /// - Returns: 数组切片，如果索引无效则返回nil
    func slice(from start: Int, to end: Int) -> ArraySlice<Element>? {
        guard start >= 0, end <= count, start <= end else {
            return nil
        }
        return self[start..<end]
    }
    
    /// 获取数组的前N个元素
    /// - Parameter count: 元素数量
    /// - Returns: 前N个元素的数组
    func prefixElements(_ count: Int) -> [Element] {
        return Array(self.prefix(count))
    }
    
    /// 获取数组的后N个元素
    /// - Parameter count: 元素数量
    /// - Returns: 后N个元素的数组
    func suffixElements(_ count: Int) -> [Element] {
        return Array(self.suffix(count))
    }
    
    // MARK: - 数组统计
    
    /// 计算数组元素的总和
    /// - Returns: 总和
    func sum() -> Element where Element: Numeric {
        return reduce(0, +)
    }
    
    /// 计算数组元素的平均值
    /// - Returns: 平均值
    func average() -> Double where Element: BinaryFloatingPoint {
        guard !isEmpty else { return 0 }
        return Double(reduce(0, +)) / Double(count)
    }
    
    /// 计算数组元素的平均值
    /// - Returns: 平均值
    func average() -> Double where Element: BinaryInteger {
        guard !isEmpty else { return 0 }
        return Double(reduce(0, +)) / Double(count)
    }
    
    /// 获取数组中的最大值
    /// - Returns: 最大值，如果数组为空则返回nil
    func maxElement() -> Element? where Element: Comparable {
        return self.max()
    }
    
    /// 获取数组中的最小值
    /// - Returns: 最小值，如果数组为空则返回nil
    func minElement() -> Element? where Element: Comparable {
        return self.min()
    }
    
    // MARK: - 数组条件检查
    
    /// 检查数组是否包含指定元素
    /// - Parameter element: 要检查的元素
    /// - Returns: 是否包含
    func containsElement(_ element: Element) -> Bool where Element: Equatable {
        return self.contains(element)
    }
    
    /// 检查数组是否包含满足条件的元素
    /// - Parameter predicate: 条件闭包
    /// - Returns: 是否包含满足条件的元素
    func containsElement(where predicate: (Element) -> Bool) -> Bool {
        return self.contains(where: predicate)
    }
    
    /// 检查数组的所有元素是否都满足条件
    /// - Parameter predicate: 条件闭包
    /// - Returns: 是否所有元素都满足条件
    func allElementsSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        return self.allSatisfy(predicate)
    }
    
    /// 检查数组是否为空
    var isEmptyArray: Bool {
        return self.isEmpty
    }
    
    /// 检查数组是否不为空
    var isNotEmptyArray: Bool {
        return !isEmpty
    }
    
    // MARK: - 数组变换
    
    /// 将数组元素转换为字符串
    /// - Parameter separator: 分隔符
    /// - Returns: 字符串表示
    func joinedElements(separator: String = "") -> String where Element: CustomStringConvertible {
        return map { $0.description }.joined(separator: separator)
    }
    
    /// 将数组元素转换为字符串
    /// - Parameters:
    ///   - separator: 分隔符
    ///   - transform: 转换闭包
    /// - Returns: 字符串表示
    func joinedElements<T>(separator: String = "", transform: (Element) -> T) -> String where T: CustomStringConvertible {
        return map(transform).map { $0.description }.joined(separator: separator)
    }
    
    /// 将数组元素转换为字符串
    /// - Parameters:
    ///   - separator: 分隔符
    ///   - transform: 转换闭包
    /// - Returns: 字符串表示
    func joinedElements(separator: String = "", transform: (Element) -> String) -> String {
        return map(transform).joined(separator: separator)
    }
    
    // MARK: - 高级数组操作
    
    /// 批量处理数组元素
    /// - Parameters:
    ///   - transform: 转换闭包
    ///   - batchSize: 批处理大小
    /// - Returns: 处理后的数组
    func batchProcess<T>(_ transform: (Element) -> T, batchSize: Int = 1000) -> [T] {
        var results: [T] = []
        results.reserveCapacity(count)
        
        for i in stride(from: 0, to: count, by: batchSize) {
            let end = Swift.min(i + batchSize, count)
            let batch = Array(self[i..<end])
            let transformed = batch.map(transform)
            results.append(contentsOf: transformed)
        }
        
        return results
    }
    
    /// 异步批量处理数组元素
    /// - Parameters:
    ///   - transform: 转换闭包
    ///   - batchSize: 批处理大小
    ///   - completion: 完成回调
    func batchProcessAsync<T>(_ transform: @escaping (Element) -> T, 
                             batchSize: Int = 1000,
                             completion: @escaping ([T]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.batchProcess(transform, batchSize: batchSize)
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    /// 分块处理数组
    /// - Parameter size: 块大小
    /// - Returns: 分块后的数组
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    /// 获取数组的所有排列组合
    /// - Returns: 所有排列组合
    func permutations() -> [[Element]] where Element: Hashable {
        guard count > 1 else { return [self] }
        
        var result: [[Element]] = []
        let elements = self
        
        func generatePermutations(_ arr: [Element], _ n: Int) {
            if n == 1 {
                result.append(arr)
                return
            }
            
            for i in 0..<n {
                var newArr = arr
                newArr.swapAt(i, n - 1)
                generatePermutations(newArr, n - 1)
                newArr.swapAt(i, n - 1)
            }
        }
        
        generatePermutations(elements, count)
        return result
    }
    
    /// 获取数组的所有子集
    /// - Returns: 所有子集
    func subsets() -> [[Element]] {
        guard !isEmpty else { return [[]] }
        
        let first = self[0]
        let rest = Array(self.dropFirst())
        let restSubsets = rest.subsets()
        
        var result = restSubsets
        for subset in restSubsets {
            result.append([first] + subset)
        }
        
        return result
    }
    
    /// 获取数组的所有组合（指定长度）
    /// - Parameter length: 组合长度
    /// - Returns: 所有组合
    func combinations(length: Int) -> [[Element]] {
        guard length <= count else { return [] }
        guard length > 0 else { return [[]] }
        
        if length == 1 {
            return map { [$0] }
        }
        
        var result: [[Element]] = []
        for i in 0...(count - length) {
            let first = self[i]
            let rest = Array(self.dropFirst(i + 1))
            let restCombinations = rest.combinations(length: length - 1)
            for combination in restCombinations {
                result.append([first] + combination)
            }
        }
        
        return result
    }
    

    
    /// 数组去重（保持顺序，使用键路径）
    /// - Parameter keyPath: 键路径
    /// - Returns: 去重后的数组
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            let key = element[keyPath: keyPath]
            if seen.contains(key) {
                return false
            } else {
                seen.insert(key)
                return true
            }
        }
    }
    
    /// 数组排序（使用键路径）
    /// - Parameter keyPath: 键路径
    /// - Returns: 排序后的数组
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
    
    /// 数组排序（使用键路径，降序）
    /// - Parameter keyPath: 键路径
    /// - Returns: 排序后的数组
    func sortedDescending<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
    }
    
    /// 数组分组（使用键路径）
    /// - Parameter keyPath: 键路径
    /// - Returns: 分组后的字典
    func grouped<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [T: [Element]] {
        return Dictionary(grouping: self) { $0[keyPath: keyPath] }
    }
    
    /// 数组映射（使用键路径）
    /// - Parameter keyPath: 键路径
    /// - Returns: 映射后的数组
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }
    
    /// 数组过滤（使用键路径）
    /// - Parameter keyPath: 键路径
    /// - Returns: 过滤后的数组
    func filter<T>(_ keyPath: KeyPath<Element, T>, where predicate: (T) -> Bool) -> [Element] {
        return filter { predicate($0[keyPath: keyPath]) }
    }
    
    /// 数组查找（使用键路径）
    /// - Parameter keyPath: 键路径
    /// - Returns: 找到的元素
    func first<T>(where keyPath: KeyPath<Element, T>, equals value: T) -> Element? where T: Equatable {
        return first { $0[keyPath: keyPath] == value }
    }
    
    /// 数组查找（使用键路径）
    /// - Parameter keyPath: 键路径
    /// - Returns: 找到的元素
    func first<T>(_ keyPath: KeyPath<Element, T>, where predicate: (T) -> Bool) -> Element? {
        return first { predicate($0[keyPath: keyPath]) }
    }
}

// MARK: - 使用示例和最佳实践

/*

// MARK: - 基础使用示例

// 1. 安全访问
let numbers = [1, 2, 3, 4, 5]
let first = numbers.firstSafe // 1
let last = numbers.lastSafe // 5
let random = numbers.randomObject() // 随机元素

// 2. 属性列表操作
let plistData = numbers.plistData()
let plistString = numbers.plistString()
let arrayFromPlist = Array<Int>.array(withPlistData: plistData!)

// 3. JSON操作
let jsonString = numbers.jsonStringEncoded()
let prettyJson = numbers.jsonPrettyStringEncoded()

// MARK: - 错误处理

// 4. 抛出错误版本
do {
    let first = try numbers.firstThrowing
    let last = try numbers.lastThrowing
    let random = try numbers.randomObjectThrowing()
} catch ArrayError.emptyArray {
    print("数组为空")
} catch {
    print("其他错误: \(error)")
}

// 5. 序列化错误处理
do {
    let jsonString = try numbers.jsonStringEncodedThrowing()
    let plistData = try numbers.plistDataThrowing()
} catch ArrayError.serializationFailed {
    print("序列化失败")
} catch {
    print("其他错误: \(error)")
}

// MARK: - 数组操作

// 6. 数组转换
let stringArray = ["a", "b", "c"]
let optionalArray = stringArray.toOptionalArray() // [String?]
let set = stringArray.toSet() // Set<String>
let dict = stringArray.toDictionary { ($0, $0.count) } // [String: Int]

// 7. 数组分组
let users = [
    User(name: "Alice", age: 25),
    User(name: "Bob", age: 30),
    User(name: "Charlie", age: 25)
]
let groupedByAge = users.grouped(by: { $0.age }) // [Int: [User]]

// 8. 移除重复元素
let numbersWithDuplicates = [1, 2, 2, 3, 3, 4]
let uniqueNumbers = numbersWithDuplicates.removingDuplicates() // [1, 2, 3, 4]

// 9. 数组切片
let slice = numbers.slice(from: 1, to: 4) // [2, 3, 4]
let prefix = numbers.prefix(3) // [1, 2, 3]
let suffix = numbers.suffix(3) // [3, 4, 5]

// MARK: - 数组统计

// 10. 数值统计
let numbers = [1, 2, 3, 4, 5]
let sum = numbers.sum() // 15
let average = numbers.average() // 3.0
let max = numbers.max() // 5
let min = numbers.min() // 1

// 11. 浮点数统计
let doubles = [1.5, 2.5, 3.5, 4.5, 5.5]
let sum = doubles.sum() // 17.5
let average = doubles.average() // 3.5

// MARK: - 数组条件检查

// 12. 条件检查
let numbers = [1, 2, 3, 4, 5]
let containsThree = numbers.contains(3) // true
let hasEven = numbers.contains { $0 % 2 == 0 } // true
let allPositive = numbers.allSatisfy { $0 > 0 } // true
let isEmpty = numbers.isEmpty // false
let isNotEmpty = numbers.isNotEmpty // true

// MARK: - 数组变换

// 13. 字符串转换
let words = ["hello", "world", "swift"]
let joined = words.joined(separator: " ") // "hello world swift"
let upperJoined = words.joined(separator: " ", transform: { $0.uppercased() }) // "HELLO WORLD SWIFT"

// MARK: - 高级用法

// 14. 自定义比较的重复元素移除
struct Person {
    let name: String
    let age: Int
}

let people = [
    Person(name: "Alice", age: 25),
    Person(name: "Bob", age: 30),
    Person(name: "Alice", age: 25)
]

let uniquePeople = people.removingDuplicates { $0.name == $1.name } // 移除同名的人

// 15. 复杂分组
let transactions = [
    Transaction(amount: 100, category: "food", date: Date()),
    Transaction(amount: 200, category: "transport", date: Date()),
    Transaction(amount: 150, category: "food", date: Date())
]

let groupedByCategory = transactions.grouped(by: { $0.category })
let groupedByDate = transactions.grouped(by: { Calendar.current.startOfDay(for: $0.date) })

// 16. 性能优化 - 批量操作
extension Array {
    func batchProcess<T>(_ transform: (Element) -> T, batchSize: Int = 1000) -> [T] {
        var results: [T] = []
        results.reserveCapacity(count)
        
        for i in stride(from: 0, to: count, by: batchSize) {
            let end = min(i + batchSize, count)
            let batch = Array(self[i..<end])
            let transformed = batch.map(transform)
            results.append(contentsOf: transformed)
        }
        
        return results
    }
}

// 17. 内存优化 - 延迟计算
extension Array {
    func lazyMap<T>(_ transform: @escaping (Element) -> T) -> LazyMapSequence<Array<Element>, T> {
        return self.lazy.map(transform)
    }
}

// MARK: - 最佳实践

// 18. 错误处理最佳实践
func processArraySafely<T>(_ array: [T], operation: (T) -> Void) {
    guard array.isNotEmpty else {
        print("数组为空，跳过处理")
        return
    }
    
    for (index, element) in array.enumerated() {
        do {
            operation(element)
        } catch {
            print("处理元素 \(index) 时出错: \(error)")
        }
    }
}

// 19. 性能监控
func measureArrayOperation<T>(_ array: [T], operation: ([T]) -> Void) -> TimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation(array)
    let endTime = CFAbsoluteTimeGetCurrent()
    return endTime - startTime
}

// 20. 数组缓存
class ArrayCache<T> {
    private var cache: [String: [T]] = [:]
    
    func getOrCreate(for key: String, create: () -> [T]) -> [T] {
        if let cached = cache[key] {
            return cached
        }
        
        let newArray = create()
        cache[key] = newArray
        return newArray
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

*/
