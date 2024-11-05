//
//  TFYSwiftGCD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

typealias AsyncClosure = (@escaping () -> Void) -> Void

public class TFYSwiftGCD: NSObject {
    // 将闭包异步执行在主队队列上
    static func asyncInMainQueue(execute work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
        
    // 将闭包异步执行在全局并发队列上
    static func asyncInGlobalQueue(execute work: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async(execute: work)
    }
        
    // 将闭包异步延迟执行
    static func asyncAfter(seconds: TimeInterval, execute work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
}
