//
//  TFYSwiftCAEmitterLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

/// CAEmitterLayer的链式扩展
public extension Chain where Base: CAEmitterLayer {
    
    /// 设置发射器单元格
    /// - Parameter value: 发射器单元格数组
    /// - Returns: 链式调用对象
    @discardableResult
    func emitterCells(_ value: [CAEmitterCell]) -> Self {
        base.emitterCells = value
        return self
    }
    
    /// 设置发射率
    /// - Parameter value: 发射率（每秒产生的粒子数）
    /// - Returns: 链式调用对象
    @discardableResult
    func birthRate(_ value: Float) -> Self {
        base.birthRate = value
        return self
    }
    
    /// 设置生命周期
    /// - Parameter value: 生命周期（秒）
    /// - Returns: 链式调用对象
    @discardableResult
    func lifetime(_ value: Float) -> Self {
        base.lifetime = value
        return self
    }
    
    /// 设置发射位置
    /// - Parameter value: 发射位置坐标
    /// - Returns: 链式调用对象
    @discardableResult
    func emitterPosition(_ value: NSPoint) -> Self {
        base.emitterPosition = value
        return self
    }
    
    /// 设置发射器Z轴位置
    /// - Parameter value: Z轴位置
    /// - Returns: 链式调用对象
    @discardableResult
    func emitterZPosition(_ value: CGFloat) -> Self {
        base.emitterZPosition = value
        return self
    }
    
    /// 设置发射器大小
    /// - Parameter value: 发射器大小
    /// - Returns: 链式调用对象
    @discardableResult
    func emitterSize(_ value: NSSize) -> Self {
        base.emitterSize = value
        return self
    }
    
    /// 设置发射器深度
    /// - Parameter value: 发射器深度
    /// - Returns: 链式调用对象
    @discardableResult
    func emitterDepth(_ value: CGFloat) -> Self {
        base.emitterDepth = value
        return self
    }
    
    /// 设置发射器形状
    /// - Parameter value: 发射器形状
    /// - Returns: 链式调用对象
    @discardableResult
    func emitterShape(_ value: String) -> Self {
        base.emitterShape = value
        return self
    }
    
    /// 设置发射器模式
    /// - Parameter value: 发射器模式
    /// - Returns: 链式调用对象
    @discardableResult
    func emitterMode(_ value: String) -> Self {
        base.emitterMode = value
        return self
    }
    
    /// 设置渲染模式
    /// - Parameter value: 渲染模式
    /// - Returns: 链式调用对象
    @discardableResult
    func renderMode(_ value: String) -> Self {
        base.renderMode = value
        return self
    }
    
    /// 设置是否保持深度
    /// - Parameter value: 是否保持深度
    /// - Returns: 链式调用对象
    @discardableResult
    func preservesDepth(_ value: Bool) -> Self {
        base.preservesDepth = value
        return self
    }
    
    /// 设置速度
    /// - Parameter value: 速度
    /// - Returns: 链式调用对象
    @discardableResult
    func velocity(_ value: Float) -> Self {
        base.velocity = value
        return self
    }
    
    /// 设置缩放
    /// - Parameter value: 缩放比例
    /// - Returns: 链式调用对象
    @discardableResult
    func scale(_ value: Float) -> Self {
        base.scale = value
        return self
    }
    
    /// 设置自旋
    /// - Parameter value: 自旋速度
    /// - Returns: 链式调用对象
    @discardableResult
    func spin(_ value: Float) -> Self {
        base.spin = value
        return self
    }
    
    /// 设置随机种子
    /// - Parameter value: 随机种子值
    /// - Returns: 链式调用对象
    @discardableResult
    func seed(_ value: UInt32) -> Self {
        base.seed = value
        return self
    }
}

// MARK: - 常量定义

public extension CAEmitterLayer {
    /// 发射器形状常量
    struct EmitterShape {
        public static let point = "point"           // 点形状
        public static let line = "line"             // 线形状
        public static let rectangle = "rectangle"    // 矩形形状
        public static let cuboid = "cuboid"         // 立方体形状
        public static let circle = "circle"         // 圆形形状
        public static let sphere = "sphere"         // 球形形状
    }
    
    /// 发射器模式常量
    struct EmitterMode {
        public static let points = "points"         // 点模式
        public static let outline = "outline"       // 轮廓模式
        public static let surface = "surface"       // 表面模式
        public static let volume = "volume"         // 体积模式
    }
    
    /// 渲染模式常量
    struct RenderMode {
        public static let unordered = "unordered"   // 无序渲染
        public static let oldestFirst = "oldestFirst" // 最老的粒子先渲染
        public static let oldestLast = "oldestLast"  // 最老的粒子后渲染
        public static let backToFront = "backToFront" // 从后向前渲染
        public static let additive = "additive"      // 叠加渲染
    }
}
