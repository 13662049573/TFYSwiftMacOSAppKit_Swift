//
//  TFYSwiftJsonUtils.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Dispatch
import Foundation

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

class TFYSwiftJsonUtils {
    // 将字典转换为格式化后的JSON字符串
    static func getJsonStrFromDictionary(_ dictionary: [String: Any]) throws -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options:.prettyPrinted)
            guard let result = String(data: jsonData, encoding:.utf8) else {
                throw JsonUtilsError.invalidData
            }
            return result
        } catch {
            throw JsonUtilsError.encodingError
        }
    }

    // 将字典转换为JSON数据
    static func getJsonDataFromDictionary(_ dictionary: [String: Any]) throws -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: dictionary, options:.prettyPrinted)
        } catch {
            throw JsonUtilsError.encodingError
        }
    }

    // 将字典转换为JSON字符串并返回
    static func dictionaryToString(_ dic: [String: Any]) throws -> String {
        do {
            let dicData = try getJsonDataFromDictionary(dic)
            guard let result = String(data: dicData, encoding:.utf8) else {
                throw JsonUtilsError.invalidData
            }
            return result
        } catch {
            throw JsonUtilsError.encodingError
        }
    }

    // 将数组（字典组成的数组）转换为JSON字符串并返回
    static func arrayToString(_ array: [[String: Any]]) throws -> String {
        do {
            let arrData = try getJsonDataFromArray(array)
            guard let result = String(data: arrData, encoding:.utf8) else {
                throw JsonUtilsError.invalidData
            }
            return result
        } catch {
            throw JsonUtilsError.encodingError
        }
    }

    // 将字符串转换为字典
    static func stringValueDic(_ str: String) throws -> [String: Any] {
        guard let data = str.data(using:.utf8) else {
            throw JsonUtilsError.invalidData
        }
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options:.mutableContainers) as? [String: Any] {
                return dict
            } else {
                throw JsonUtilsError.decodingError
            }
        } catch {
            throw JsonUtilsError.decodingError
        }
    }

    // 将字符串转换为数组
    static func stringValueArr(_ str: String) throws -> [Any] {
        guard let data = str.data(using:.utf8) else {
            throw JsonUtilsError.invalidData
        }
        do {
            if let array = try JSONSerialization.jsonObject(with: data, options:.mutableContainers) as? [Any] {
                return array
            } else {
                throw JsonUtilsError.decodingError
            }
        } catch {
            throw JsonUtilsError.decodingError
        }
    }

    // 将数组（字典组成的数组）转换为JSON数据
    static func getJsonDataFromArray(_ array: [[String: Any]]) throws -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: array, options:.prettyPrinted)
        } catch {
            throw JsonUtilsError.encodingError
        }
    }

    // 将JSON数据解码为指定类型的模型
    static func decodeJsonDataToModel<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JsonUtilsError.decodingError
        }
    }

    // 将单个可编码的模型转换为JSON字符串
    static func toJson<T>(_ model: T) throws -> String where T: Encodable {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = []
            let data = try encoder.encode(model)
            guard let result = String(data: data, encoding:.utf8) else {
                throw JsonUtilsError.invalidData
            }
            return result
        } catch {
            throw JsonUtilsError.encodingError
        }
    }

    // 将可编码的模型数组转换为JSON字符串
    static func modelsToJson<T>(_ models: [T], outputFormat: JSONEncoder.OutputFormatting = .prettyPrinted) throws -> String where T: Encodable {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = outputFormat
            let data = try encoder.encode(models)
            guard let result = String(data: data, encoding:.utf8) else {
                throw JsonUtilsError.invalidData
            }
            return result
        } catch {
            throw JsonUtilsError.encodingError
        }
    }

    // 将JSON字符串转换为字典
    static func dictionaryFrom(jsonString: String) throws -> [String: Any] {
        guard let jsonData = jsonString.data(using:.utf8) else {
            throw JsonUtilsError.invalidData
        }
        do {
            if let dict = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers) as? [String: Any] {
                return dict
            } else {
                throw JsonUtilsError.invalidData
            }
        } catch {
            throw JsonUtilsError.decodingError
        }
    }

    // 将JSON字符串转换为数组（字典组成的数组）
    static func arrayFrom(jsonString: String) throws -> [[String: Any]] {
        guard let jsonData = jsonString.data(using:.utf8) else {
            throw JsonUtilsError.invalidData
        }
        do {
            if let array = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers) as? [[String: Any]] {
                return array
            } else {
                throw JsonUtilsError.invalidData
            }
        } catch {
            throw JsonUtilsError.decodingError
        }
    }

    // 将JSON字符串或字典转换为指定类型的模型
    static func toModel<T>(_ type: T.Type, value: Any) throws -> T where T: Decodable {
        do {
            if let data = try? JSONSerialization.data(withJSONObject: value) {
                let decoder = JSONDecoder()
                decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
                return try decoder.decode(type, from: data)
            } else {
                throw JsonUtilsError.invalidData
            }
        } catch {
            throw JsonUtilsError.decodingError
        }
    }
}
