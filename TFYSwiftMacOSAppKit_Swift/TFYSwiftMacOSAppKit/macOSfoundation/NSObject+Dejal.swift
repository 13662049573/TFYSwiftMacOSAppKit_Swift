//
//  NSObject+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSObject {
    // 获取指定键路径的值，如果值为 nil 或 NSNull，则返回默认值
    func getOrDefaultValueForKeyPath(_ keyPath: String, defaultValue: Any?) -> Any? {
        guard let defaultValue = defaultValue else {
            return nil
        }
        var result: Any? = value(forKeyPath: keyPath)
        if result == nil || result is NSNull {
            result = defaultValue
        }
        return result
    }
    
    // 根据字典中的键设置对象的属性值
    func setValueForKey(_ key: String, withDictionary dict: [String : Any]) {
        if let value = dict[key], value is NSObject {
            setValue(value, forKey: key)
        }
    }
    
    // 根据字典中的键或备用键设置对象的属性值
    func setValueForKey(_ key: String, orDictKey altKey: String?, withDictionary dict: [String : Any]) {
        var value: Any? = dict[key]
        if value == nil && altKey != nil {
            value = dict[altKey!]
        }
        if value != nil && value is NSObject {
            setValue(value, forKey: key)
        }
    }
    
    // 根据字典中的键或多个备用键设置对象的属性值
    func setValueForKey(_ key: String, orDictKeys altKeys: [String]?, withDictionary dict: [String : Any]) {
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
    
    // 将对象的指定属性值设置到字典中
    func setValueInDictionary(_ dict: NSMutableDictionary, forKey key: String) {
        setValueInDictionary(dict, forKey: key, removeIfNil: false)
    }
    
    // 将对象的指定属性值设置到字典中，并可选择在值为 nil 时移除该键
    func setValueInDictionary(_ dict: NSMutableDictionary, forKey key: String, removeIfNil: Bool) {
        if let value = self.value(forKey: key) {
            dict[key] = value
        } else if removeIfNil {
            dict.removeObject(forKey: key)
        }
    }
    
    // 判断对象是否是指定类的真正子类（是子类且不是该类本身）
    func isReallySubclassOfClass(_ aClass: AnyClass) -> Bool {
        return self.isKind(of: aClass) && !self.isMember(of: aClass)
    }
    
    // 判断两个对象的描述是否相等（不区分大小写）
    func isEquivalent(_ anObject: Any?) -> Bool {
        if let object = anObject {
            return self.description.caseInsensitiveCompare((object as AnyObject).description) == .orderedSame
        } else {
            return false
        }
    }
    
    // 交换指定类的两个实例方法
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
}
