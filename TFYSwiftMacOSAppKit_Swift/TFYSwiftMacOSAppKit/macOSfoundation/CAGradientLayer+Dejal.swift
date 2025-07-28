//
//  CAGradientLayer+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

/// 渐变方向枚举
public enum GradientMacOsDirection: Int, CaseIterable {
    case level = 0 // 水平渐变
    case vertical // 竖直渐变
    case upwardDiagonalLine // 向上对角线渐变
    case downDiagonalLine // 向下对角线渐变
    case radial // 径向渐变
    case conic // 锥形渐变
    case custom // 自定义渐变
    
    /// 获取渐变方向的描述
    public var description: String {
        switch self {
        case .level:
            return "水平渐变"
        case .vertical:
            return "竖直渐变"
        case .upwardDiagonalLine:
            return "向上对角线渐变"
        case .downDiagonalLine:
            return "向下对角线渐变"
        case .radial:
            return "径向渐变"
        case .conic:
            return "锥形渐变"
        case .custom:
            return "自定义渐变"
        }
    }
}

/// 渐变配置结构体
public struct GradientConfiguration {
    public let size: CGSize
    public let direction: GradientMacOsDirection
    public let colors: [NSColor]
    public let locations: [NSNumber]?
    public let startPoint: CGPoint?
    public let endPoint: CGPoint?
    public let type: CAGradientLayerType
    public let opacity: Float
    
    public init(size: CGSize,
                direction: GradientMacOsDirection,
                colors: [NSColor],
                locations: [NSNumber]? = nil,
                startPoint: CGPoint? = nil,
                endPoint: CGPoint? = nil,
                type: CAGradientLayerType = .axial,
                opacity: Float = 1.0) {
        self.size = size
        self.direction = direction
        self.colors = colors
        self.locations = locations
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
        self.opacity = opacity
    }
}

/// 渐变错误类型
public enum GradientError: Error, LocalizedError {
    case invalidSize(CGSize)
    case emptyColors
    case invalidDirection(String)
    case invalidLocations(String)
    case invalidColorFormat(String)
    case animationFailed(String)
    case performanceWarning(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidSize(let size):
            return "无效的尺寸: \(size)"
        case .emptyColors:
            return "颜色数组为空"
        case .invalidDirection(let direction):
            return "无效的渐变方向: \(direction)"
        case .invalidLocations(let locations):
            return "无效的位置数组: \(locations)"
        case .invalidColorFormat(let format):
            return "无效的颜色格式: \(format)"
        case .animationFailed(let reason):
            return "动画失败: \(reason)"
        case .performanceWarning(let warning):
            return "性能警告: \(warning)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidSize:
            return "尺寸为零或负数"
        case .emptyColors:
            return "颜色数组不能为空"
        case .invalidDirection:
            return "不支持的渐变方向类型"
        case .invalidLocations:
            return "位置数组长度与颜色数组不匹配"
        case .invalidColorFormat:
            return "颜色格式不正确"
        case .animationFailed:
            return "动画创建或执行过程中发生错误"
        case .performanceWarning:
            return "渐变可能影响性能"
        }
    }
}

public extension CAGradientLayer {
    
    // MARK: - 基础渐变创建
    
    /// 创建渐变图层
    /// - Parameters:
    ///   - size: 图层尺寸
    ///   - direction: 渐变方向
    ///   - colors: 颜色数组
    /// - Returns: 渐变图层，如果参数无效则返回nil
    class func colorGradientChange(withSize size: CGSize, direction: GradientMacOsDirection, colorsArr: [NSColor]) -> CAGradientLayer? {
        // 参数有效性检查
        guard size != CGSize.zero else { return nil }
        guard !colorsArr.isEmpty else { return nil }
        
        // 创建渐变图层实例
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // 设置渐变方向
        let (startPoint, endPoint) = direction.points
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // 设置颜色
        gradientLayer.colors = colorsArr.map { $0.cgColor }
        
        return gradientLayer
    }
    
    /// 使用配置创建渐变图层
    /// - Parameter configuration: 渐变配置
    /// - Returns: 渐变图层
    /// - Throws: GradientError 如果配置无效
    class func createGradient(with configuration: GradientConfiguration) throws -> CAGradientLayer {
        // 验证配置
        guard configuration.size != CGSize.zero else {
            throw GradientError.invalidSize(configuration.size)
        }
        guard !configuration.colors.isEmpty else {
            throw GradientError.emptyColors
        }
        if let locations = configuration.locations {
            guard locations.count == configuration.colors.count else {
                throw GradientError.invalidLocations("位置数组长度(\(locations.count))与颜色数组长度(\(configuration.colors.count))不匹配")
            }
        }
        
        // 创建渐变图层
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: configuration.size.width, height: configuration.size.height)
        
        // 设置渐变类型
        gradientLayer.type = configuration.type
        
        // 设置渐变方向
        if let startPoint = configuration.startPoint {
            gradientLayer.startPoint = startPoint
        } else {
            let (startPoint, _) = configuration.direction.points
            gradientLayer.startPoint = startPoint
        }
        
        if let endPoint = configuration.endPoint {
            gradientLayer.endPoint = endPoint
        } else {
            let (_, endPoint) = configuration.direction.points
            gradientLayer.endPoint = endPoint
        }
        
        // 设置颜色和位置
        gradientLayer.colors = configuration.colors.map { $0.cgColor }
        if let locations = configuration.locations {
            gradientLayer.locations = locations
        }
        
        // 设置透明度
        gradientLayer.opacity = configuration.opacity
        
        return gradientLayer
    }
    
    // MARK: - 便利方法
    
    /// 创建水平渐变
    /// - Parameters:
    ///   - size: 图层尺寸
    ///   - colors: 颜色数组
    /// - Returns: 水平渐变图层
    class func horizontalGradient(size: CGSize, colors: [NSColor]) -> CAGradientLayer? {
        return colorGradientChange(withSize: size, direction: .level, colorsArr: colors)
    }
    
    /// 创建垂直渐变
    /// - Parameters:
    ///   - size: 图层尺寸
    ///   - colors: 颜色数组
    /// - Returns: 垂直渐变图层
    class func verticalGradient(size: CGSize, colors: [NSColor]) -> CAGradientLayer? {
        return colorGradientChange(withSize: size, direction: .vertical, colorsArr: colors)
    }
    
    /// 创建径向渐变
    /// - Parameters:
    ///   - size: 图层尺寸
    ///   - colors: 颜色数组
    ///   - center: 中心点
    ///   - radius: 半径
    /// - Returns: 径向渐变图层
    class func radialGradient(size: CGSize, colors: [NSColor], center: CGPoint = CGPoint(x: 0.5, y: 0.5), radius: CGFloat = 0.5) -> CAGradientLayer? {
        guard size != CGSize.zero, !colors.isEmpty else { return nil }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.type = .radial
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = center
        gradientLayer.endPoint = CGPoint(x: center.x + radius, y: center.y + radius)
        
        return gradientLayer
    }
    
    /// 创建锥形渐变
    /// - Parameters:
    ///   - size: 图层尺寸
    ///   - colors: 颜色数组
    ///   - center: 中心点
    /// - Returns: 锥形渐变图层
    class func conicGradient(size: CGSize, colors: [NSColor], center: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CAGradientLayer? {
        guard size != CGSize.zero, !colors.isEmpty else { return nil }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.type = .conic
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = center
        gradientLayer.endPoint = CGPoint(x: center.x + 1, y: center.y)
        
        return gradientLayer
    }
    
    // MARK: - 预设渐变
    
    /// 创建彩虹渐变
    /// - Parameter size: 图层尺寸
    /// - Returns: 彩虹渐变图层
    class func rainbowGradient(size: CGSize) -> CAGradientLayer? {
        let colors: [NSColor] = [
            .red, .orange, .yellow, .green, .blue, .purple
        ]
        return horizontalGradient(size: size, colors: colors)
    }
    
    /// 创建日落渐变
    /// - Parameter size: 图层尺寸
    /// - Returns: 日落渐变图层
    class func sunsetGradient(size: CGSize) -> CAGradientLayer? {
        let colors: [NSColor] = [
            NSColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0),
            NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),
            NSColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0)
        ]
        return verticalGradient(size: size, colors: colors)
    }
    
    /// 创建海洋渐变
    /// - Parameter size: 图层尺寸
    /// - Returns: 海洋渐变图层
    class func oceanGradient(size: CGSize) -> CAGradientLayer? {
        let colors: [NSColor] = [
            NSColor(red: 0.0, green: 0.5, blue: 0.8, alpha: 1.0),
            NSColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0),
            NSColor(red: 0.0, green: 0.9, blue: 1.0, alpha: 1.0)
        ]
        return verticalGradient(size: size, colors: colors)
    }
    
    /// 创建森林渐变
    /// - Parameter size: 图层尺寸
    /// - Returns: 森林渐变图层
    class func forestGradient(size: CGSize) -> CAGradientLayer? {
        let colors: [NSColor] = [
            NSColor(red: 0.0, green: 0.3, blue: 0.1, alpha: 1.0),
            NSColor(red: 0.0, green: 0.5, blue: 0.2, alpha: 1.0),
            NSColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        ]
        return verticalGradient(size: size, colors: colors)
    }
    
    // MARK: - 渐变操作
    
    /// 更新渐变颜色
    /// - Parameter colors: 新的颜色数组
    func updateColors(_ colors: [NSColor]) {
        guard !colors.isEmpty else { return }
        self.colors = colors.map { $0.cgColor }
    }
    
    /// 更新渐变方向
    /// - Parameter direction: 新的渐变方向
    func updateDirection(_ direction: GradientMacOsDirection) {
        let (startPoint, endPoint) = direction.points
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    /// 添加颜色停止点
    /// - Parameter location: 位置（0.0-1.0）
    func addColorStop(at location: CGFloat) {
        var locations = self.locations?.map { $0.floatValue } ?? []
        locations.append(Float(location))
        locations.sort()
        self.locations = locations.map { NSNumber(value: $0) }
    }
    
    /// 移除颜色停止点
    /// - Parameter location: 位置
    func removeColorStop(at location: CGFloat) {
        guard var locations = self.locations?.map({ $0.floatValue }) else { return }
        locations.removeAll { abs($0 - Float(location)) < 0.01 }
        self.locations = locations.map { NSNumber(value: $0) }
    }
    
    // MARK: - 动画支持
    
    /// 创建颜色变化动画
    /// - Parameters:
    ///   - toColors: 目标颜色数组
    ///   - duration: 动画持续时间
    /// - Returns: 颜色变化动画
    func colorChangeAnimation(toColors: [NSColor], duration: CFTimeInterval = 0.3) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = self.colors
        animation.toValue = toColors.map { $0.cgColor }
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    /// 创建方向变化动画
    /// - Parameters:
    ///   - toDirection: 目标方向
    ///   - duration: 动画持续时间
    /// - Returns: 方向变化动画
    func directionChangeAnimation(toDirection: GradientMacOsDirection, duration: CFTimeInterval = 0.3) -> CABasicAnimation {
        let (_, endPoint) = toDirection.points
        let animation = CABasicAnimation(keyPath: "endPoint")
        animation.fromValue = self.endPoint
        animation.toValue = endPoint
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    // MARK: - 高级渐变功能
    
    /// 创建多步骤动画
    /// - Parameters:
    ///   - steps: 动画步骤数组
    ///   - duration: 总动画持续时间
    /// - Returns: 动画组
    func multiStepAnimation(steps: [GradientAnimationStep], duration: CFTimeInterval) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.animations = steps.map { step in
            switch step.type {
            case .color:
                guard let colors = step.colors else {
                    return CABasicAnimation(keyPath: "colors")
                }
                return colorChangeAnimation(toColors: colors, duration: step.duration)
            case .direction:
                guard let direction = step.direction else {
                    return CABasicAnimation(keyPath: "startPoint")
                }
                return directionChangeAnimation(toDirection: direction, duration: step.duration)
            case .opacity:
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = self.opacity
                animation.toValue = step.opacity
                animation.duration = step.duration
                return animation
            }
        }
        group.duration = duration
        return group
    }
    
    /// 创建呼吸效果动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - minOpacity: 最小透明度
    ///   - maxOpacity: 最大透明度
    /// - Returns: 呼吸效果动画
    func breathingAnimation(duration: CFTimeInterval = 2.0, minOpacity: Float = 0.3, maxOpacity: Float = 1.0) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = minOpacity
        animation.toValue = maxOpacity
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    /// 创建脉冲效果动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - scale: 缩放比例
    /// - Returns: 脉冲效果动画
    func pulseAnimation(duration: CFTimeInterval = 1.0, scale: CGFloat = 1.2) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = scale
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    /// 创建波浪效果动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - amplitude: 波浪幅度
    /// - Returns: 波浪效果动画
    func waveAnimation(duration: CFTimeInterval = 2.0, amplitude: CGFloat = 0.1) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -amplitude
        animation.toValue = amplitude
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    /// 创建旋转渐变动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - clockwise: 是否顺时针旋转
    /// - Returns: 旋转动画
    func rotationAnimation(duration: CFTimeInterval = 3.0, clockwise: Bool = true) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = clockwise ? 2 * Double.pi : -2 * Double.pi
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        return animation
    }
    
    /// 创建渐变移动动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - distance: 移动距离
    ///   - direction: 移动方向
    /// - Returns: 移动动画
    func moveAnimation(duration: CFTimeInterval = 2.0, distance: CGFloat = 50, direction: GradientMoveDirection = .horizontal) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.\(direction.axis)")
        animation.fromValue = -distance
        animation.toValue = distance
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    /// 创建渐变缩放动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - scaleX: X轴缩放比例
    ///   - scaleY: Y轴缩放比例
    /// - Returns: 缩放动画
    func scaleAnimation(duration: CFTimeInterval = 1.5, scaleX: CGFloat = 1.2, scaleY: CGFloat = 1.2) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = [1.0, 1.0]
        animation.toValue = [scaleX, scaleY]
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    /// 创建渐变闪烁动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - minOpacity: 最小透明度
    ///   - maxOpacity: 最大透明度
    /// - Returns: 闪烁动画
    func blinkAnimation(duration: CFTimeInterval = 0.5, minOpacity: Float = 0.0, maxOpacity: Float = 1.0) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = maxOpacity
        animation.toValue = minOpacity
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    /// 创建渐变抖动动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - intensity: 抖动强度
    /// - Returns: 抖动动画
    func shakeAnimation(duration: CFTimeInterval = 0.1, intensity: CGFloat = 10) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-intensity, intensity, -intensity, intensity, -intensity, intensity, 0]
        animation.duration = duration
        animation.repeatCount = .infinity
        return animation
    }
    
    /// 创建渐变弹跳动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - height: 弹跳高度
    /// - Returns: 弹跳动画
    func bounceAnimation(duration: CFTimeInterval = 1.0, height: CGFloat = 20) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.values = [0, -height, 0, -height/2, 0]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
}

// MARK: - 辅助类型

/// 渐变动画步骤类型
public enum GradientAnimationType {
    case color
    case direction
    case opacity
}

/// 渐变移动方向
public enum GradientMoveDirection {
    case horizontal
    case vertical
    
    var axis: String {
        switch self {
        case .horizontal:
            return "x"
        case .vertical:
            return "y"
        }
    }
}

/// 渐变动画步骤
public struct GradientAnimationStep {
    public let type: GradientAnimationType
    public let duration: CFTimeInterval
    public let colors: [NSColor]?
    public let direction: GradientMacOsDirection?
    public let opacity: Float?
    
    public init(type: GradientAnimationType, duration: CFTimeInterval, colors: [NSColor]? = nil, direction: GradientMacOsDirection? = nil, opacity: Float? = nil) {
        self.type = type
        self.duration = duration
        self.colors = colors
        self.direction = direction
        self.opacity = opacity
    }
}

// MARK: - 私有扩展

private extension GradientMacOsDirection {
    /// 获取渐变方向的起始点和结束点
    var points: (startPoint: CGPoint, endPoint: CGPoint) {
        switch self {
        case .level:
            return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .vertical:
            return (CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 1.0))
        case .upwardDiagonalLine:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1.0, y: 1.0))
        case .downDiagonalLine:
            return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
        case .radial:
            return (CGPoint(x: 0.5, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .conic:
            return (CGPoint(x: 0.5, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .custom:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1.0, y: 1.0))
        }
    }
}

// MARK: - 使用示例和最佳实践

/*
 
 // MARK: - 基础使用示例
 
 // 1. 创建简单的水平渐变
 let horizontalGradient = CAGradientLayer.horizontalGradient(
     size: CGSize(width: 200, height: 100),
     colors: [.red, .blue]
 )
 
 // 2. 创建垂直渐变
 let verticalGradient = CAGradientLayer.verticalGradient(
     size: CGSize(width: 200, height: 100),
     colors: [.green, .yellow]
 )
 
 // 3. 使用配置创建渐变
 let config = GradientConfiguration(
     size: CGSize(width: 200, height: 100),
     direction: .upwardDiagonalLine,
     colors: [.red, .orange, .yellow],
     locations: [0.0, 0.5, 1.0],
     opacity: 0.8
 )
 
 do {
     let gradient = try CAGradientLayer.createGradient(with: config)
     view.layer?.addSublayer(gradient)
 } catch {
     print("创建渐变失败: \(error)")
 }
 
 // MARK: - 预设渐变使用
 
 // 4. 创建彩虹渐变
 let rainbowGradient = CAGradientLayer.rainbowGradient(
     size: CGSize(width: 300, height: 50)
 )
 
 // 5. 创建日落渐变
 let sunsetGradient = CAGradientLayer.sunsetGradient(
     size: CGSize(width: 200, height: 150)
 )
 
 // MARK: - 动画示例
 
 // 6. 颜色变化动画
 if let gradient = horizontalGradient {
     let animation = gradient.colorChangeAnimation(
         toColors: [.purple, .orange],
         duration: 1.0
     )
     gradient.add(animation, forKey: "colorChange")
 }
 
 // 7. 方向变化动画
 if let gradient = verticalGradient {
     let animation = gradient.directionChangeAnimation(
         toDirection: .upwardDiagonalLine,
         duration: 0.5
     )
     gradient.add(animation, forKey: "directionChange")
 }
 
 // MARK: - 高级用法
 
 // 8. 径向渐变
 let radialGradient = CAGradientLayer.radialGradient(
     size: CGSize(width: 200, height: 200),
     colors: [.white, .black],
     center: CGPoint(x: 0.5, y: 0.5),
     radius: 0.8
 )
 
 // 9. 锥形渐变
 let conicGradient = CAGradientLayer.conicGradient(
     size: CGSize(width: 200, height: 200),
     colors: [.red, .yellow, .green, .blue, .purple, .red]
 )
 
 // 10. 动态更新渐变
 if let gradient = horizontalGradient {
     gradient.updateColors([.cyan, .magenta])
     gradient.updateDirection(.vertical)
     gradient.addColorStop(at: 0.3)
 }
 
 // MARK: - 最佳实践
 
 // 11. 错误处理
 do {
     let invalidConfig = GradientConfiguration(
         size: CGSize.zero,
         direction: .level,
         colors: []
     )
     let gradient = try CAGradientLayer.createGradient(with: invalidConfig)
 } catch GradientError.invalidSize {
     print("尺寸无效")
 } catch GradientError.emptyColors {
     print("颜色数组为空")
 } catch {
     print("其他错误: \(error)")
 }
 
 // 12. 性能优化 - 重用渐变图层
 class GradientView: NSView {
     private let gradientLayer = CAGradientLayer()
     
     override init(frame frameRect: NSRect) {
         super.init(frame: frameRect)
         setupGradient()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         setupGradient()
     }
     
     private func setupGradient() {
         gradientLayer.frame = bounds
         layer?.addSublayer(gradientLayer)
     }
     
     func updateGradient(direction: GradientMacOsDirection, colors: [NSColor]) {
         gradientLayer.updateDirection(direction)
         gradientLayer.updateColors(colors)
     }
 }
 
 */
