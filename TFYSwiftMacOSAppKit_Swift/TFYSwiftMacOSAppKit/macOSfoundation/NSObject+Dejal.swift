//
//  NSObject+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import AppKit

public extension NSObject {
    
    func tfy_valueForKeyPath(_ keyPath: String, defaultValue: Any) -> Any {
        var result: Any?
        result = value(forKeyPath: keyPath)
        if result == nil || result is NSNull {
            result = defaultValue
        }
        return result!
    }
    
    func tfy_setValueForKey(_ key: String, withDictionary dict: [String : Any]) {
        if let value = dict[key] {
            self.setValue(value, forKey: key)
        }
    }
    
    func tfy_setValueForKey(_ key: String, orDictKey altKey: String?, withDictionary dict: [String : Any]) {
        var value: Any? = dict[key]
        
        if value == nil && altKey != nil {
            value = dict[altKey!]
        }
        
        if value != nil {
            self.setValue(value, forKey: key)
        }
    }
    
    func tfy_setValueForKey(_ key: String, orDictKeys altKeys: [String]?, withDictionary dict: [String : Any]) {
        var value: Any? = dict[key]
        
        if value == nil && altKeys != nil {
            for altKey in altKeys! {
                if value == nil {
                    value = dict[altKey]
                }
            }
        }
        
        if value != nil {
            self.setValue(value, forKey: key)
        }
    }
    
    func tfy_setValueInDictionary(_ dict: NSMutableDictionary, forKey key: String) {
        tfy_setValueInDictionary(dict, forKey: key, removeIfNil: false)
    }
    
    func tfy_setValueInDictionary(_ dict: NSMutableDictionary, forKey key: String, removeIfNil: Bool) {
        if let value = self.value(forKey: key) {
            dict[key] = value
        } else if removeIfNil {
            dict.removeObject(forKey: key)
        }
    }
    
    func tfy_isReallySubclassOfClass(_ aClass: AnyClass) -> Bool {
        return self.isKind(of: aClass) && !self.isMember(of: aClass)
    }
    
    func tfy_isEquivalent(_ anObject: Any?) -> Bool {
        if let object = anObject {
            return self.description.caseInsensitiveCompare((object as AnyObject).description) == .orderedSame
        } else {
            return false
        }
    }
    
    func tfy_isEquivalentTo(_ anObject: Any?) -> Bool {
        if let object = anObject {
            return self.description.caseInsensitiveCompare((object as AnyObject).description) == .orderedSame
        } else {
            return false
        }
    }
    
    func tfy_exchangeInstanceMethod(_ anClass: AnyClass, method1Sel: Selector, method2Sel: Selector) {
       let originalMethod = class_getInstanceMethod(anClass, method1Sel)
       let swizzledMethod = class_getInstanceMethod(anClass, method2Sel)

       var didAddMethod = false
       if let original = originalMethod, let swizzled = swizzledMethod {
           didAddMethod = class_addMethod(anClass, method1Sel, method_getImplementation(swizzled), method_getTypeEncoding(swizzled))
       }

       if didAddMethod {
           class_replaceMethod(anClass, method2Sel, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
       } else {
           method_exchangeImplementations(originalMethod!, swizzledMethod!)
       }
    }
}
