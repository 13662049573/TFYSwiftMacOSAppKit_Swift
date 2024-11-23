//
//  Timer+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/20.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation

// MARK: - Timer 扩展
public extension Timer {
    
    /**
     创建并调度一个定时器到当前 RunLoop 的默认模式
     
     - Parameters:
        - interval: 定时器触发间隔(秒)
        - block: 定时器触发时执行的闭包
        - repeats: 是否重复执行
     - Returns: 新创建的定时器对象
     
     - Note: 闭包会被定时器强引用,直到定时器失效
     */
    @discardableResult
    class func scheduledTimer(withTimeInterval interval: TimeInterval,
                            block: @escaping (Timer) -> Void,
                            repeats: Bool) -> Timer {
        // 创建定时器并保存闭包
        let timer = Timer.scheduledTimer(timeInterval: interval,
                                       target: self,
                                       selector: #selector(executeTimerBlock(_:)),
                                       userInfo: block,
                                       repeats: repeats)
        return timer
    }
    
    /**
     创建一个定时器(需要手动添加到 RunLoop)
     
     - Parameters:
        - interval: 定时器触发间隔(秒)
        - block: 定时器触发时执行的闭包
        - repeats: 是否重复执行
     - Returns: 新创建的定时器对象
     */
    class func timer(withTimeInterval interval: TimeInterval,
                    block: @escaping (Timer) -> Void,
                    repeats: Bool) -> Timer {
        let timer = Timer(timeInterval: interval,
                         target: self,
                         selector: #selector(executeTimerBlock(_:)),
                         userInfo: block,
                         repeats: repeats)
        return timer
    }
    
    // 执行定时器闭包
    @objc private class func executeTimerBlock(_ timer: Timer) {
        if let block = timer.userInfo as? (Timer) -> Void {
            block(timer)
        }
    }
}

