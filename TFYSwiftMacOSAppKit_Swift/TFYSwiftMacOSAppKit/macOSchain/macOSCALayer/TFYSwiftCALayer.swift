//
//  TFYSwiftCALayer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public extension Chain where Base: CALayer {
    /// 设置图层的边界矩形
    @discardableResult
    func bounds(_ value: NSRect) -> Self {
        base.bounds = value
        return self
    }
    
    /// 设置图层的位置（相对于父图层）
    @discardableResult
    func position(_ value: CGPoint) -> Self {
        base.position = value
        return self
    }
    
    /// 设置图层在Z轴上的位置
    @discardableResult
    func zPosition(_ value: CGFloat) -> Self {
        base.zPosition = value
        return self
    }
    
    /// 设置图层的锚点（默认为{0.5, 0.5}，即中心点）
    @discardableResult
    func anchorPoint(_ value: NSPoint) -> Self {
        base.anchorPoint = value
        return self
    }
    
    /// 设置图层在Z轴上的锚点
    @discardableResult
    func anchorPointZ(_ value: CGFloat) -> Self {
        base.anchorPointZ = value
        return self
    }
    
    /// 设置图层的3D变换
    @discardableResult
    func transform(_ value: CATransform3D) -> Self {
        base.transform = value
        return self
    }
    
    /// 设置图层的2D仿射变换
    @discardableResult
    func affineTransform(_ value: CGAffineTransform) -> Self {
        base.setAffineTransform(value)
        return self
    }
    
    /// 设置图层的框架矩形
    @discardableResult
    func frame(_ value: NSRect) -> Self {
        base.frame = value
        return self
    }
    
    /// 设置图层是否隐藏
    @discardableResult
    func hidden(_ value: Bool) -> Self {
        base.isHidden = value
        return self
    }
    
    /// 设置图层是否双面显示
    @discardableResult
    func doubleSided(_ value: Bool) -> Self {
        base.isDoubleSided = value
        return self
    }
    
    /// 设置图层的几何结构是否翻转
    @discardableResult
    func geometryFlipped(_ value: Bool) -> Self {
        base.isGeometryFlipped = value
        return self
    }
    
    /// 添加子图层
    @discardableResult
    func addToSuperLayer(_ value: CALayer) -> Self {
        base.addSublayer(value)
        return self
    }
    
    /// 从父图层中移除
    @discardableResult
    func removeFromSuperlayer() -> Self {
        base.removeFromSuperlayer()
        return self
    }
    
    /// 在指定索引处插入子图层
    @discardableResult
    func insertSublayer(_ value: CALayer, at: UInt32) -> Self {
        base.insertSublayer(value, at: at)
        return self
    }
    
    /// 在指定图层之上插入子图层
    @discardableResult
    func insertSublayer(_ value: CALayer, above: CALayer?) -> Self {
        base.insertSublayer(value, above: above)
        return self
    }
    
    /// 在指定图层之下插入子图层
    @discardableResult
    func insertSublayer(_ value: CALayer, below: CALayer?) -> Self {
        base.insertSublayer(value, below: below)
        return self
    }
    
    /// 替换子图层
    @discardableResult
    func relpaceSublayer(_ value: CALayer, with: CALayer) -> Self {
        base.replaceSublayer(value, with: with)
        return self
    }
    
    /// 设置图层的遮罩
    @discardableResult
    func mask(_ value: CALayer?) -> Self {
        base.mask = value
        return self
    }
    
    /// 设置是否裁剪超出边界的内容
    @discardableResult
    func masksToBounds(_ value: Bool) -> Self {
        base.masksToBounds = value
        return self
    }
    
    /// 设置图层的内容
    @discardableResult
    func contents(_ value: Any) -> Self {
        base.contents = value
        return self
    }
    
    /// 设置内容的显示区域
    @discardableResult
    func contentsRect(_ value: NSRect) -> Self {
        base.contentsRect = value
        return self
    }
    
    /// 设置内容的对齐方式
    @discardableResult
    func contentsGravity(_ value: CALayerContentsGravity) -> Self {
        base.contentsGravity = value
        return self
    }
    
    /// 设置内容的缩放比例
    @discardableResult
    func contentsScale(_ value: CGFloat) -> Self {
        base.contentsScale = value
        return self
    }
    
    /// 设置内容的中心区域
    @discardableResult
    func contentsCenter(_ value: NSRect) -> Self {
        base.contentsCenter = value
        return self
    }
    
    /// 设置内容的格式
    @discardableResult
    func contentsFormat(_ value: CALayerContentsFormat) -> Self {
        base.contentsFormat = value
        return self
    }
    
    /// 设置缩小时的过滤器
    @discardableResult
    func minificationFilter(_ value: CALayerContentsFilter) -> Self {
        base.minificationFilter = value
        return self
    }
    
    /// 设置放大时的过滤器
    @discardableResult
    func magnificationFilter(_ value: CALayerContentsFilter) -> Self {
        base.magnificationFilter = value
        return self
    }
    
    /// 设置最小化过滤器的偏差值
    @discardableResult
    func minificationFilterBias(_ value: Float) -> Self {
        base.minificationFilterBias = value
        return self
    }
    
    /// 设置图层是否不透明
    @discardableResult
    func opaque(_ value: Bool) -> Self {
        base.isOpaque = value
        return self
    }
    
    /// 设置边界改变时是否需要重绘
    @discardableResult
    func needsDisplayOnBoundsChange(_ value: Bool) -> Self {
        base.needsDisplayOnBoundsChange = value
        return self
    }
    
    /// 设置是否异步绘制
    @discardableResult
    func drawsAsynchronously(_ value: Bool) -> Self {
        base.drawsAsynchronously = value
        return self
    }
    
    /// 设置边缘抗锯齿遮罩
    @discardableResult
    func edgeAntialiasingMask(_ value: CAEdgeAntialiasingMask) -> Self {
        base.edgeAntialiasingMask = value
        return self
    }
    
    /// 设置是否允许边缘抗锯齿
    @discardableResult
    func allowsEdgeAntialiasing(_ value: Bool) -> Self {
        base.allowsEdgeAntialiasing = value
        return self
    }
    
    /// 设置背景颜色
    @discardableResult
    func backgroundColor(_ value: CGColor) -> Self {
        base.backgroundColor = value
        return self
    }
    
    /// 设置圆角半径
    @discardableResult
    func cornerRadius(_ value: CGFloat) -> Self {
        base.cornerRadius = value
        return self
    }
    
    /// 设置要应用圆角的角
    @discardableResult
    func maskedCorners(_ value: CACornerMask) -> Self {
        base.maskedCorners = value
        return self
    }
    
    /// 设置边框宽度
    @discardableResult
    func borderWidth(_ value: CGFloat) -> Self {
        base.borderWidth = value
        return self
    }
    
    /// 设置边框颜色
    @discardableResult
    func borderColor(_ value: CGColor) -> Self {
        base.borderColor = value
        return self
    }
    
    /// 设置透明度
    @discardableResult
    func opacity(_ value: Float) -> Self {
        base.opacity = value
        return self
    }
    
    /// 设置是否允许组透明度
    @discardableResult
    func allowsGroupOpacity(_ value: Bool) -> Self {
        base.allowsGroupOpacity = value
        return self
    }
    
    /// 设置合成滤镜
    @discardableResult
    func compositingFilter(_ value: Any) -> Self {
        base.compositingFilter = value
        return self
    }
    
    /// 设置滤镜数组
    @discardableResult
    func filters(_ value: [Any]) -> Self {
        base.filters = value
        return self
    }
    
    /// 设置背景滤镜数组
    @discardableResult
    func backgroundFilters(_ value: [Any]) -> Self {
        base.backgroundFilters = value
        return self
    }
    
    /// 设置是否栅格化
    @discardableResult
    func shouldRasterize(_ value: Bool) -> Self {
        base.shouldRasterize = value
        return self
    }
    
    /// 设置栅格化比例
    @discardableResult
    func rasterizationScale(_ value: CGFloat) -> Self {
        base.rasterizationScale = value
        return self
    }
    
    /// 设置阴影颜色
    @discardableResult
    func shadowColor(_ value: CGColor) -> Self {
        base.shadowColor = value
        return self
    }
    
    /// 设置阴影不透明度
    @discardableResult
    func shadowOpacity(_ value: Float) -> Self {
        base.shadowOpacity = value
        return self
    }
    
    /// 设置阴影偏移量
    @discardableResult
    func shadowOffset(_ value: CGSize) -> Self {
        base.shadowOffset = value
        return self
    }
    
    /// 设置阴影半径
    @discardableResult
    func shadowRadius(_ value: CGFloat) -> Self {
        base.shadowRadius = value
        return self
    }
    
    /// 设置阴影路径
    @discardableResult
    func shadowPath(_ value: CGPath) -> Self {
        base.shadowPath = value
        return self
    }
    
    /// 设置动作字典
    @discardableResult
    func actions(_ value: [String : any CAAction]) -> Self {
        base.actions = value
        return self
    }
    
    /// 添加动画
    @discardableResult
    func addAnimation(_ value: CAAnimation, key: String) -> Self {
        base.add(value, forKey: key)
        return self
    }
    
    /// 移除指定键的动画
    @discardableResult
    func removeAnimation(_ value: String) -> Self {
        base.removeAnimation(forKey: value)
        return self
    }
    
    /// 移除所有动画
    @discardableResult
    func removeAllAnimation() -> Self {
        base.removeAllAnimations()
        return self
    }
    
    /// 设置图层名称
    @discardableResult
    func name(_ value: String) -> Self {
        base.name = value
        return self
    }
    
    /// 设置代理
    @discardableResult
    func delegate(_ value: (any CALayerDelegate)) -> Self {
        base.delegate = value
        return self
    }
    
    /// 设置样式字典
    @discardableResult
    func style(_ value: [AnyHashable : Any]) -> Self {
        base.style = value
        return self
    }
}

// MARK: - 常量定义

public extension CALayer {
    /// 内容对齐方式常量
    struct ContentsGravity {
        public static let center = CALayerContentsGravity.center
        public static let top = CALayerContentsGravity.top
        public static let bottom = CALayerContentsGravity.bottom
        public static let left = CALayerContentsGravity.left
        public static let right = CALayerContentsGravity.right
        public static let topLeft = CALayerContentsGravity.topLeft
        public static let topRight = CALayerContentsGravity.topRight
        public static let bottomLeft = CALayerContentsGravity.bottomLeft
        public static let bottomRight = CALayerContentsGravity.bottomRight
        public static let resize = CALayerContentsGravity.resize
        public static let resizeAspect = CALayerContentsGravity.resizeAspect
        public static let resizeAspectFill = CALayerContentsGravity.resizeAspectFill
    }
    
    /// 内容格式常量
    struct ContentsFormat {
        public static let RGBA8Uint = CALayerContentsFormat.RGBA8Uint
        public static let RGBA16Float = CALayerContentsFormat.RGBA16Float
        public static let gray8Uint = CALayerContentsFormat.gray8Uint
    }
    
    /// 内容过滤器常量
    struct ContentsFilter {
        public static let linear = CALayerContentsFilter.linear
        public static let nearest = CALayerContentsFilter.nearest
        public static let trilinear = CALayerContentsFilter.trilinear
    }
}
