//
//  CAGradientLayer+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

// 渐变方式枚举
public enum GradientMacOsDirection: Int {
    case level = 0 // 水平渐变
    case vertical // 竖直渐变
    case upwardDiagonalLine // 向下对角线渐变
    case downDiagonalLine // 向上对角线渐变
}

public extension CAGradientLayer {
    // 创建渐变颜色的静态方法
    class func colorGradientChange(withSize size: CGSize, direction: GradientMacOsDirection, colorsArr: [NSColor]) -> CAGradientLayer? {
        // 参数有效性检查，如果尺寸为零或者颜色数组为空，则返回 nil
        if size == CGSize.zero || colorsArr.isEmpty {
            return nil
        }
        
        // 创建渐变图层实例
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // 根据不同的渐变方向设置起始点
        var startPoint = CGPoint.zero
        if direction == .downDiagonalLine {
            startPoint = CGPoint(x: 0.0, y: 1.0)
        }
        gradientLayer.startPoint = startPoint
        
        // 根据不同的渐变方向设置结束点
        var endPoint = CGPoint.zero
        switch direction {
        case .level:
            endPoint = CGPoint(x: 1.0, y: 0.0)
        case .vertical:
            endPoint = CGPoint(x: 0.0, y: 1.0)
        case .upwardDiagonalLine:
            endPoint = CGPoint(x: 1.0, y: 1.0)
        case .downDiagonalLine:
            endPoint = CGPoint(x: 1.0, y: 0.0)
        }
        gradientLayer.endPoint = endPoint
        
        // 将颜色数组转换为适用于 CAGradientLayer 的格式
        var cgColors: [Any] = []
        for color in colorsArr {
            cgColors.append(color.cgColor)
        }
        gradientLayer.colors = cgColors
        
        // 返回创建好的渐变图层实例
        return gradientLayer
    }
}
