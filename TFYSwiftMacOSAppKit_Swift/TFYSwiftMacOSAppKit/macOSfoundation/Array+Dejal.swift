//
//  Array+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

// MARK: - NSArray 扩展
public extension Array {
    
    // MARK: - 属性列表(Plist)操作
    
    /**
     从属性列表数据创建数组
     
     - Parameter plist: 包含数组的属性列表数据
     - Returns: 从plist创建的数组,如果失败则返回nil
     */
    static func array(withPlistData plist: Data) -> [Any]? {
        guard let array = try? PropertyListSerialization.propertyList(
            from: plist,
            options: .mutableContainers,
            format: nil) as? [Any] else {
            return nil
        }
        return array
    }
    
    /**
     从属性列表XML字符串创建数组
     
     - Parameter plist: 包含数组的属性列表XML字符串
     - Returns: 从plist字符串创建的数组,如果失败则返回nil
     */
    static func array(withPlistString plist: String) -> [Any]? {
        guard let data = plist.data(using: .utf8) else { return nil }
        return array(withPlistData: data)
    }
    
    /**
     将数组序列化为二进制属性列表数据
     
     - Returns: 二进制plist数据,如果失败则返回nil
     */
    func plistData() -> Data? {
        return try? PropertyListSerialization.data(
            fromPropertyList: self,
            format: .binary,
            options: 0)
    }
    
    /**
     将数组序列化为XML属性列表字符串
     
     - Returns: XML格式的plist字符串,如果失败则返回nil
     */
    func plistString() -> String? {
        guard let data = try? PropertyListSerialization.data(
            fromPropertyList: self,
            format: .xml,
            options: 0) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - JSON 操作
    
    /**
     将数组转换为JSON字符串
     
     - Returns: JSON字符串,如果失败则返回nil
     */
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
    
    /**
     将数组转换为格式化的JSON字符串
     
     - Returns: 格式化的JSON字符串,如果失败则返回nil
     */
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
    
    // MARK: - 安全访问
    
    /**
     获取数组中指定索引的元素,如果索引越界则返回nil
     
     - Parameter index: 要获取元素的索引
     - Returns: 指定索引的元素,如果索引越界则返回nil
     */
    func object(atSafeIndex index: Int) -> Element? {
        guard index >= 0, index < count else {
            return nil
        }
        return self[index]
    }
    
    /**
     随机获取数组中的一个元素
     
     - Returns: 随机选择的元素,如果数组为空则返回nil
     */
    func randomObject() -> Element? {
        guard !isEmpty else { return nil }
        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }
}

// MARK: - 类型转换扩展
public extension Array where Element: Any {
    
    /**
     将数组转换为可选类型数组
     
     - Returns: 转换后的可选类型数组
     */
    func toOptionalArray() -> [Element?] {
        return map { $0 as Element? }
    }
}
