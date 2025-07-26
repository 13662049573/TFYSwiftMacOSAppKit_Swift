//
//  TFYSwiftJsonUtils.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - 错误定义
enum JsonUtilsError: LocalizedError {
    case encodingError(Error)  // 编码错误
    case decodingError(Error)  // 解码错误
    case invalidData           // 数据无效
    case invalidType           // 类型不匹配
    
    var errorDescription: String? {
        switch self {
        case .encodingError(let error): return "编码错误: \(error.localizedDescription)"
        case .decodingError(let error): return "解码错误: \(error.localizedDescription)"
        case .invalidData: return "无效数据"
        case .invalidType: return "类型不匹配"
        }
    }
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
final class TFYSwiftJsonUtils {
    // MARK: - 共享实例
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted  // 设置输出格式为美化打印
        return encoder
    }()
    
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "+Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        return decoder
    }()
    
    private init() {} // 防止类被实例化
    
    // MARK: - 字典/数组转换为 JSON 字符串
    static func toJsonString(_ value: Any, prettyPrinted: Bool = true) throws -> String {
        let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : []
        let data = try JSONSerialization.data(withJSONObject: value, options: options)
        guard let result = String(data: data, encoding: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        return result
    }
    
    static func toJsonData(_ value: Any, prettyPrinted: Bool = true) throws -> Data {
        let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : []
        do {
            return try JSONSerialization.data(withJSONObject: value, options: options)
        } catch let error {
            throw JsonUtilsError.encodingError(error)
        }
    }
    
    // MARK: - JSON 字符串转换为字典/数组
    static func toDictionary(from jsonString: String) throws -> [String: Any] {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                throw JsonUtilsError.invalidType
            }
            return dict
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    static func toArray(from jsonString: String) throws -> [Any] {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        do {
            guard let array = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any] else {
                throw JsonUtilsError.invalidType
            }
            return array
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    // MARK: - 模型转换
    static func toJson<T: Encodable>(_ model: T, prettyPrinted: Bool = false) throws -> String {
        jsonEncoder.outputFormatting = prettyPrinted ? .prettyPrinted : []
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
    
    static func toModel<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            return try jsonDecoder.decode(type, from: data)
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    static func toModel<T: Decodable>(_ type: T.Type, from jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonUtilsError.invalidData
        }
        
        do {
            return try jsonDecoder.decode(type, from: data)
        } catch let error {
            throw JsonUtilsError.decodingError(error)
        }
    }
    
    static func toModels<T: Encodable>(_ models: [T], prettyPrinted: Bool = true) throws -> String {
        jsonEncoder.outputFormatting = prettyPrinted ? .prettyPrinted : []
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
}
