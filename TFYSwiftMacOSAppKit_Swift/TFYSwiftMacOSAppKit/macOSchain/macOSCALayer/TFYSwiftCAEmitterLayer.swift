//
//  TFYSwiftCAEmitterLayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public extension Chain where Base: CAEmitterLayer {
    
    /// 设置发射器单元格
    @discardableResult
    func emitterCells(_ value: [CAEmitterCell]) -> Self {
        base.emitterCells = value
        return self
    }
    
    /// 设置发射率
    @discardableResult
    func birthRate(_ value: Float) -> Self {
        base.birthRate = value
        return self
    }
    
    /// 设置生命周期
    @discardableResult
    func lifetime(_ value: Float) -> Self {
        base.lifetime = value
        return self
    }
    
    /// 设置发射位置
    @discardableResult
    func emitterPosition(_ value: NSPoint) -> Self {
        base.emitterPosition = value
        return self
    }
    
    /// 设置发射器Z轴位置
    @discardableResult
    func emitterZPosition(_ value: CGFloat) -> Self {
        base.emitterZPosition = value
        return self
    }
    
    /// 设置发射器大小
    @discardableResult
    func emitterSize(_ value: NSSize) -> Self {
        base.emitterSize = value
        return self
    }
    
    /// 设置发射器深度
    @discardableResult
    func emitterDepth(_ value: CGFloat) -> Self {
        base.emitterDepth = value
        return self
    }
    
    /// 设置发射器形状
    @discardableResult
    func emitterShape(_ value: CAEmitterLayerEmitterShape) -> Self {
        base.emitterShape = value
        return self
    }
    
    /// 设置发射器模式
    @discardableResult
    func emitterMode(_ value: CAEmitterLayerEmitterMode) -> Self {
        base.emitterMode = value
        return self
    }
    
    /// 设置渲染模式
    @discardableResult
    func renderMode(_ value: CAEmitterLayerRenderMode) -> Self {
        base.renderMode = value
        return self
    }
    
    /// 设置是否保持深度
    @discardableResult
    func preservesDepth(_ value: Bool) -> Self {
        base.preservesDepth = value
        return self
    }
    
    /// 设置速度
    @discardableResult
    func velocity(_ value: Float) -> Self {
        base.velocity = value
        return self
    }
    
    /// 设置缩放
    @discardableResult
    func scale(_ value: Float) -> Self {
        base.scale = value
        return self
    }
    
    /// 设置自旋
    @discardableResult
    func spin(_ value: Float) -> Self {
        base.spin = value
        return self
    }
    
    /// 设置随机种子
    @discardableResult
    func seed(_ value: UInt32) -> Self {
        base.seed = value
        return self
    }
}
