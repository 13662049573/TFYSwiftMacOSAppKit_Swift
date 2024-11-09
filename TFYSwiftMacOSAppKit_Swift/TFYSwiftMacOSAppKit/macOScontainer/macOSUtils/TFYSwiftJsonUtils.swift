//
//  TFYSwiftJsonUtils.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Dispatch

extension JSONEncoder {
    func encode<T: Encodable>(_ value: T, using customEncodeMethod: @escaping (T, Encoder) throws -> Void) throws -> Data {
        let anyEncodable = AnyEncodable(value, customEncodeMethod)
        return try self.encode(anyEncodable)
    }
}

struct AnyEncodable<T: Encodable>: Encodable {
    private let _encode: (T, Encoder) throws -> Void
    private let value: T

    init(_ value: T, _ customEncodeMethod: @escaping (T, Encoder) throws -> Void) {
        self.value = value
        self._encode = customEncodeMethod
    }

    func encode(to encoder: Encoder) throws {
        try _encode(value, encoder)
    }
}

enum JsonUtilsError: Error {
    case encodingError
    case decodingError
    case invalidData
    case otherError(message: String)
}

public class TFYSwiftJsonUtils: NSObject {
    // 将字典转换为格式化后的 JSON 字符串
    public static func getJsonStrFromDictionary(_ dictionary: [String : Any]) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options:.prettyPrinted)
        return String(data: jsonData, encoding:.utf8)!
    }

    // 将字典转换为 JSON 数据
    public static func getJsonDataFromDictionary(_ dictionary: [String : Any]) throws -> Data {
        return try JSONSerialization.data(withJSONObject: dictionary, options:.prettyPrinted)
    }

    // 将字典转换为 JSON 字符串并返回
    public static func dictionaryToString(_ dic: [String : Any]) throws -> String {
        let dicData = try getJsonDataFromDictionary(dic)
        return String(data: dicData, encoding: String.Encoding.utf8)!
    }

    // 将数组（字典组成的数组）转换为 JSON 字符串并返回
    public static func arrayToString(_ array: Array<Dictionary<String, Any>>) throws -> String {
        let arrData = try getJsonDataFromArray(array)
        return String(data: arrData, encoding: String.Encoding.utf8)!
    }

    // 将字符串转换为字典
    public static func stringValueDic(_ str: String) throws -> [String : Any] {
        let data = str.data(using: String.Encoding.utf8)!
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
    }

    // 将字符串转换为数组
    public static func stringValueArr(_ str: String) throws -> [Any] {
        let data = str.data(using: String.Encoding.utf8)!
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Any]
    }

    // 将数组（字典组成的数组）转换为 JSON 数据
    public static func getJsonDataFromArray(_ array: Array<Dictionary<String, Any>>) throws -> Data {
        return try JSONSerialization.data(withJSONObject: array, options:.prettyPrinted)
    }

    // 将 JSON 数据解码为指定类型的模型
    public static func decodeJsonDataToModel<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    // 将单个可编码的模型转换为 JSON 字符串
    public static func toJson<T>(_ model: T) throws -> String where T : Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        let data = try encoder.encode(model)
        return String(data: data, encoding:.utf8)!
    }

    // 将可编码的模型数组转换为 JSON 字符串
    public static func modelsToJson<T>(_ models: [T], outputFormat: JSONEncoder.OutputFormatting = .prettyPrinted) throws -> String where T : Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormat
        let data = try encoder.encode(models)
        return String(data: data, encoding:.utf8)!
    }

    // 将 JSON 字符串转换为字典
    public static func dictionaryFrom(jsonString: String) throws -> Dictionary<String, Any> {
        guard let jsonData = jsonString.data(using:.utf8) else { throw JsonUtilsError.invalidData }
        if let dict = try? JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers) as? Dictionary<String, Any> {
            return dict
        } else {
            throw JsonUtilsError.invalidData
        }
    }

    // 将 JSON 字符串转换为数组（字典组成的数组）
    public static func arrayFrom(jsonString: String) throws -> [Dictionary<String, Any>] {
        guard let jsonData = jsonString.data(using:.utf8) else { throw JsonUtilsError.invalidData }
        if let array = try? JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers) as? [Dictionary<String, Any>] {
            return array
        } else {
            throw JsonUtilsError.invalidData
        }
    }

    // 将 JSON 字符串或字典转换为指定类型的模型
    public static func toModel<T>(_ type: T.Type, value: Any) throws -> T where T : Decodable {
        if let data = try? JSONSerialization.data(withJSONObject: value) {
            let decoder = JSONDecoder()
            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
            return try decoder.decode(type, from: data)
        } else {
            throw JsonUtilsError.invalidData
        }
    }
}
