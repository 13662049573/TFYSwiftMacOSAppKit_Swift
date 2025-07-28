//
//  TFYSwiftJsonUtils.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Cocoa

// MARK: - 错误定义
public enum JsonUtilsError: LocalizedError, CustomStringConvertible {
    case encodingError(Error)           // 编码错误
    case decodingError(Error)           // 解码错误
    case invalidData                    // 数据无效
    case invalidType                    // 类型不匹配
    case invalidJsonString              // JSON字符串无效
    case unsupportedType                // 不支持的类型
    case fileNotFound                   // 文件未找到
    case fileReadError(Error)           // 文件读取错误
    case fileWriteError(Error)          // 文件写入错误
    case networkError(Error)            // 网络错误
    case timeoutError                   // 超时错误
    case customError(String)            // 自定义错误
    
    public var errorDescription: String? {
        return description
    }
    
    public var description: String {
        switch self {
        case .encodingError(let error):
            return "编码错误: \(error.localizedDescription)"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        case .invalidData:
            return "无效数据"
        case .invalidType:
            return "类型不匹配"
        case .invalidJsonString:
            return "无效的JSON字符串"
        case .unsupportedType:
            return "不支持的数据类型"
        case .fileNotFound:
            return "文件未找到"
        case .fileReadError(let error):
            return "文件读取错误: \(error.localizedDescription)"
        case .fileWriteError(let error):
            return "文件写入错误: \(error.localizedDescription)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .timeoutError:
            return "操作超时"
        case .customError(let message):
            return "自定义错误: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .encodingError, .decodingError, .invalidData, .invalidType:
            return "数据格式错误"
        case .fileNotFound, .fileReadError, .fileWriteError:
            return "文件操作失败"
        case .networkError, .timeoutError:
            return "网络连接问题"
        case .invalidJsonString, .unsupportedType:
            return "数据格式不支持"
        case .customError:
            return "业务逻辑错误"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .encodingError, .decodingError:
            return "请检查数据格式是否符合JSON规范"
        case .invalidData, .invalidType:
            return "请确保数据为有效的JSON格式"
        case .fileNotFound:
            return "请检查文件路径是否正确"
        case .fileReadError, .fileWriteError:
            return "请检查文件权限和磁盘空间"
        case .networkError, .timeoutError:
            return "请检查网络连接并重试"
        case .invalidJsonString:
            return "请确保JSON字符串格式正确"
        case .unsupportedType:
            return "请使用支持的数据类型"
        case .customError:
            return "请联系开发者获取支持"
        }
    }
}

// MARK: - JSON 配置选项
public struct JsonConfig {
    public var prettyPrinted: Bool
    public var sortedKeys: Bool
    public var allowFragments: Bool
    public var readingOptions: JSONSerialization.ReadingOptions
    public var writingOptions: JSONSerialization.WritingOptions
    
    public init(
        prettyPrinted: Bool = true,
        sortedKeys: Bool = false,
        allowFragments: Bool = false,
        readingOptions: JSONSerialization.ReadingOptions = .mutableContainers,
        writingOptions: JSONSerialization.WritingOptions = []
    ) {
        self.prettyPrinted = prettyPrinted
        self.sortedKeys = sortedKeys
        self.allowFragments = allowFragments
        self.readingOptions = readingOptions
        self.writingOptions = writingOptions
    }
    
    public static let `default` = JsonConfig()
    public static let compact = JsonConfig(prettyPrinted: false)
    public static let pretty = JsonConfig(prettyPrinted: true, sortedKeys: true)
}

// MARK: - Encodable 扩展
private struct AnyEncodable<T: Encodable>: Encodable {
    private let value: T
    private let encode: (T, Encoder) throws -> Void

    init(_ value: T, _ encode: @escaping (T, Encoder) throws -> Void) {
        self.value = value
        self.encode = encode
    }

    func encode(to encoder: Encoder) throws {
        try encode(value, encoder)
    }
}

extension JSONEncoder {
    func encode<T: Encodable>(_ value: T, using customEncodeMethod: @escaping (T, Encoder) throws -> Void) throws -> Data {
        try encode(AnyEncodable(value, customEncodeMethod))
    }
}

// MARK: - JSON 工具类实现
public final class TFYSwiftJsonUtils: NSObject {
    
    // MARK: - 共享实例
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }()
    
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "+Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        return decoder
    }()
    
    private override init() {
        super.init()
    }
    
    // MARK: - 配置管理
    public static func configureEncoder(_ config: (JSONEncoder) -> Void) {
        config(jsonEncoder)
    }
    
    public static func configureDecoder(_ config: (JSONDecoder) -> Void) {
        config(jsonDecoder)
    }
    
    // MARK: - 字典/数组转换为 JSON 字符串
    public static func toJsonString(_ value: Any, config: JsonConfig = .default) throws -> String {
        var options: JSONSerialization.WritingOptions = config.writingOptions
        
        if config.prettyPrinted {
            options.insert(.prettyPrinted)
        }
        
        if config.sortedKeys {
            options.insert(.sortedKeys)
        }
        
        let data = try JSONSerialization.data(withJSONObject: value, options: options)
        guard let result = String(data: data, encoding: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        return result
    }
    
    public static func toJsonData(_ value: Any, config: JsonConfig = .default) throws -> Data {
        var options: JSONSerialization.WritingOptions = config.writingOptions
        
        if config.prettyPrinted {
            options.insert(.prettyPrinted)
        }
        
        if config.sortedKeys {
            options.insert(.sortedKeys)
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: value, options: options)
        } catch let error {
            throw JsonUtilsError.encodingError(error)
        }
    }
    
    // MARK: - JSON 字符串转换为字典/数组
    public static func toDictionary(from jsonString: String, config: JsonConfig = .default) throws -> [String: Any] {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data, options: config.readingOptions) as? [String: Any] else {
                throw JsonUtilsError.invalidType
            }
            return dict
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    public static func toArray(from jsonString: String, config: JsonConfig = .default) throws -> [Any] {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        
        do {
            guard let array = try JSONSerialization.jsonObject(with: data, options: config.readingOptions) as? [Any] else {
                throw JsonUtilsError.invalidType
            }
            return array
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    // MARK: - 模型转换
    public static func toJson<T: Encodable>(_ model: T, config: JsonConfig = .default) throws -> String {
        jsonEncoder.outputFormatting = config.prettyPrinted ? .prettyPrinted : []
        
        do {
            let data = try jsonEncoder.encode(model)
            guard let result = String(data: data, encoding: .utf8) else {
                throw JsonUtilsError.invalidData
            }
            return result
        } catch let error {
            throw JsonUtilsError.encodingError(error)
        }
    }
    
    public static func toModel<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            return try jsonDecoder.decode(type, from: data)
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    public static func toModel<T: Decodable>(_ type: T.Type, from jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        
        do {
            return try jsonDecoder.decode(type, from: data)
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    public static func toModels<T: Encodable>(_ models: [T], config: JsonConfig = .default) throws -> String {
        jsonEncoder.outputFormatting = config.prettyPrinted ? .prettyPrinted : []
        
        do {
            let data = try jsonEncoder.encode(models)
            guard let result = String(data: data, encoding: .utf8) else {
                throw JsonUtilsError.invalidData
            }
            return result
        } catch let error {
            throw JsonUtilsError.encodingError(error)
        }
    }
    
    // MARK: - 文件操作
    public static func saveToFile<T: Encodable>(_ model: T, filePath: String, config: JsonConfig = .default) throws {
        let jsonString = try toJson(model, config: config)
        try jsonString.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    public static func loadFromFile<T: Decodable>(_ type: T.Type, filePath: String) throws -> T {
        guard let jsonString = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            throw JsonUtilsError.fileNotFound
        }
        return try toModel(type, from: jsonString)
    }
    
    // MARK: - 网络请求支持
    public static func fromURL<T: Decodable>(_ type: T.Type, url: URL, timeout: TimeInterval = 30) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var result: T?
        var error: Error?
        
        let task = URLSession.shared.dataTask(with: url) { data, response, taskError in
            defer { semaphore.signal() }
            
            if let taskError = taskError {
                error = taskError
                return
            }
            
            guard let data = data else {
                error = JsonUtilsError.invalidData
                return
            }
            
            do {
                result = try jsonDecoder.decode(type, from: data)
            } catch let decodeError {
                error = decodeError
            }
        }
        
        task.resume()
        
        let timeoutResult = semaphore.wait(timeout: .now() + timeout)
        if timeoutResult == .timedOut {
            throw JsonUtilsError.timeoutError
        }
        
        if let error = error {
            throw JsonUtilsError.networkError(error)
        }
        
        guard let result = result else {
            throw JsonUtilsError.invalidData
        }
        
        return result
    }
    
    // MARK: - 验证功能
    public static func isValidJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return true
        } catch {
            return false
        }
    }
    
    public static func validateJSON(_ jsonString: String) -> Result<Void, JsonUtilsError> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(.invalidData)
        }
        
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return .success(())
        } catch let error {
            return .failure(.decodingError(error))
        }
    }
    
    // MARK: - 格式化功能
    public static func formatJSON(_ jsonString: String, config: JsonConfig = .default) throws -> String {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return try toJsonString(jsonObject, config: config)
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    public static func minifyJSON(_ jsonString: String) throws -> String {
        return try formatJSON(jsonString, config: .compact)
    }
    
    // MARK: - 合并功能
    public static func mergeJSON(_ json1: [String: Any], _ json2: [String: Any], overwrite: Bool = true) -> [String: Any] {
        var result = json1
        
        for (key, value) in json2 {
            if overwrite || result[key] == nil {
                result[key] = value
            }
        }
        
        return result
    }
    
    // MARK: - 路径查询
    public static func getValue(from json: [String: Any], path: String) -> Any? {
        let keys = path.components(separatedBy: ".")
        var current: Any = json
        
        for key in keys {
            if let dict = current as? [String: Any], let value = dict[key] {
                current = value
            } else if let array = current as? [Any], let index = Int(key), index >= 0 && index < array.count {
                current = array[index]
            } else {
                return nil
            }
        }
        
        return current
    }
    
    public static func setValue(_ value: Any, in json: inout [String: Any], path: String) -> Bool {
        let keys = path.components(separatedBy: ".")
        var current: [String: Any] = json
        
        for (index, key) in keys.enumerated() {
            if index == keys.count - 1 {
                current[key] = value
                return true
            } else {
                if current[key] == nil {
                    current[key] = [String: Any]()
                }
                
                if let nextDict = current[key] as? [String: Any] {
                    current = nextDict
                } else {
                    return false
                }
            }
        }
        
        return false
    }
    
    // MARK: - 类型转换辅助
    public static func safeString(_ value: Any?) -> String? {
        return value as? String
    }
    
    public static func safeInt(_ value: Any?) -> Int? {
        if let intValue = value as? Int { return intValue }
        if let stringValue = value as? String { return Int(stringValue) }
        if let doubleValue = value as? Double { return Int(doubleValue) }
        return nil
    }
    
    public static func safeDouble(_ value: Any?) -> Double? {
        if let doubleValue = value as? Double { return doubleValue }
        if let intValue = value as? Int { return Double(intValue) }
        if let stringValue = value as? String { return Double(stringValue) }
        return nil
    }
    
    public static func safeBool(_ value: Any?) -> Bool? {
        if let boolValue = value as? Bool { return boolValue }
        if let intValue = value as? Int { return intValue != 0 }
        if let stringValue = value as? String {
            let lowercased = stringValue.lowercased()
            return lowercased == "true" || lowercased == "1" || lowercased == "yes"
        }
        return nil
    }
    
    public static func safeArray(_ value: Any?) -> [Any]? {
        return value as? [Any]
    }
    
    public static func safeDictionary(_ value: Any?) -> [String: Any]? {
        return value as? [String: Any]
    }
}

// MARK: - 链式编程支持
extension TFYSwiftJsonUtils {
    
    /// 链式JSON构建器
    public class JsonBuilder {
        private var dictionary: [String: Any] = [:]
        private var array: [Any] = []
        private var isArray: Bool = false
        
        public init() {}
        
        public init(dictionary: [String: Any]) {
            self.dictionary = dictionary
            self.isArray = false
        }
        
        public init(array: [Any]) {
            self.array = array
            self.isArray = true
        }
        
        @discardableResult
        public func set(_ key: String, _ value: Any) -> Self {
            dictionary[key] = value
            return self
        }
        
        @discardableResult
        public func add(_ value: Any) -> Self {
            array.append(value)
            return self
        }
        
        @discardableResult
        public func setIf(_ key: String, _ value: Any?, condition: Bool) -> Self {
            guard condition else { return self }
            dictionary[key] = value
            return self
        }
        
        @discardableResult
        public func addIf(_ value: Any?, condition: Bool) -> Self {
            guard condition else { return self }
            array.append(value as Any)
            return self
        }
        
        public func build() -> [String: Any]? {
            return isArray ? nil : dictionary
        }
        
        public func buildArray() -> [Any]? {
            return isArray ? array : nil
        }
        
        public func buildJsonString(config: JsonConfig = .default) throws -> String {
            if isArray {
                return try TFYSwiftJsonUtils.toJsonString(array, config: config)
            } else {
                return try TFYSwiftJsonUtils.toJsonString(dictionary, config: config)
            }
        }
    }
    
    /// 创建JSON构建器
    public static func builder() -> JsonBuilder {
        return JsonBuilder()
    }
    
    /// 从字典创建构建器
    public static func builder(from dictionary: [String: Any]) -> JsonBuilder {
        return JsonBuilder(dictionary: dictionary)
    }
    
    /// 从数组创建构建器
    public static func builder(from array: [Any]) -> JsonBuilder {
        return JsonBuilder(array: array)
    }
}

// MARK: - 便利扩展
public extension Dictionary where Key == String, Value == Any {
    
    /// 转换为JSON字符串
    func toJsonString(config: JsonConfig = .default) throws -> String {
        return try TFYSwiftJsonUtils.toJsonString(self, config: config)
    }
    
    /// 转换为JSON数据
    func toJsonData(config: JsonConfig = .default) throws -> Data {
        return try TFYSwiftJsonUtils.toJsonData(self, config: config)
    }
    
    /// 获取路径值
    func getValue(path: String) -> Any? {
        return TFYSwiftJsonUtils.getValue(from: self, path: path)
    }
    
    /// 设置路径值
    mutating func setValue(_ value: Any, path: String) -> Bool {
        return TFYSwiftJsonUtils.setValue(value, in: &self, path: path)
    }
}

public extension Array {
    
    /// 转换为JSON字符串
    func toJsonString(config: JsonConfig = .default) throws -> String {
        return try TFYSwiftJsonUtils.toJsonString(self, config: config)
    }
    
    /// 转换为JSON数据
    func toJsonData(config: JsonConfig = .default) throws -> Data {
        return try TFYSwiftJsonUtils.toJsonData(self, config: config)
    }
}

public extension String {
    
    /// 验证是否为有效JSON
    var isValidJSON: Bool {
        return TFYSwiftJsonUtils.isValidJSON(self)
    }
    
    /// 格式化JSON
    func formatJSON(config: JsonConfig = .default) throws -> String {
        return try TFYSwiftJsonUtils.formatJSON(self, config: config)
    }
    
    /// 压缩JSON
    func minifyJSON() throws -> String {
        return try TFYSwiftJsonUtils.minifyJSON(self)
    }
    
    /// 转换为字典
    func toDictionary(config: JsonConfig = .default) throws -> [String: Any] {
        return try TFYSwiftJsonUtils.toDictionary(from: self, config: config)
    }
    
    /// 转换为数组
    func toArray(config: JsonConfig = .default) throws -> [Any] {
        return try TFYSwiftJsonUtils.toArray(from: self, config: config)
    }
    
    /// 转换为模型
    func toModel<T: Decodable>(_ type: T.Type) throws -> T {
        return try TFYSwiftJsonUtils.toModel(type, from: self)
    }
}

public extension Encodable {
    
    /// 转换为JSON字符串
    func toJsonString(config: JsonConfig = .default) throws -> String {
        return try TFYSwiftJsonUtils.toJson(self, config: config)
    }
    
    /// 转换为JSON数据
    func toJsonData(config: JsonConfig = .default) throws -> Data {
        let jsonString = try toJsonString(config: config)
        return jsonString.data(using: .utf8) ?? Data()
    }
    
    /// 保存到文件
    func saveToFile(_ filePath: String, config: JsonConfig = .default) throws {
        try TFYSwiftJsonUtils.saveToFile(self, filePath: filePath, config: config)
    }
}
