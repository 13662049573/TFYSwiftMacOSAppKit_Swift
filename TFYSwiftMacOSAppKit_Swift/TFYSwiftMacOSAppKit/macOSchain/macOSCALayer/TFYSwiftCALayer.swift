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

    @discardableResult
    func bounds(_ value:NSRect) -> Self {
        base.bounds = value
        return self
    }
    
    @discardableResult
    func position(_ value:CGPoint) -> Self {
        base.position = value
        return self
    }
    
    @discardableResult
    func zPosition(_ value:CGFloat) -> Self {
        base.zPosition = value
        return self
    }
    
    @discardableResult
    func anchorPoint(_ value:NSPoint) -> Self {
        base.anchorPoint = value
        return self
    }
    
    @discardableResult
    func anchorPointZ(_ value:CGFloat) -> Self {
        base.anchorPointZ = value
        return self
    }
    
    @discardableResult
    func transform(_ value:CATransform3D) -> Self {
        base.transform = value
        return self
    }
    
    @discardableResult
    func affineTransform(_ value:CGAffineTransform) -> Self {
        base.setAffineTransform(value)
        return self
    }
    
    @discardableResult
    func frame(_ value:NSRect) -> Self {
        base.frame = value
        return self
    }
    
    @discardableResult
    func hidden(_ value:Bool) -> Self {
        base.isHidden = value
        return self
    }
    
    @discardableResult
    func doubleSided(_ value:Bool) -> Self {
        base.isDoubleSided = value
        return self
    }
    
    @discardableResult
    func geometryFlipped(_ value:Bool) -> Self {
        base.isGeometryFlipped = value
        return self
    }
    
    @discardableResult
    func addToSuperLayer(_ value:CALayer) -> Self {
        base.addSublayer(value)
        return self
    }
    
    @discardableResult
    func removeFromSuperlayer() -> Self {
        base.removeFromSuperlayer()
        return self
    }
    
    @discardableResult
    func insertSublayer(_ value:CALayer,at:UInt32) -> Self {
        base.insertSublayer(value, at: at)
        return self
    }
    
    @discardableResult
    func insertSublayer(_ value:CALayer,above:CALayer?) -> Self {
        base.insertSublayer(value, above: above)
        return self
    }
    
    @discardableResult
    func insertSublayer(_ value:CALayer,below:CALayer?) -> Self {
        base.insertSublayer(value, below: below)
        return self
    }
    
    @discardableResult
    func relpaceSublayer(_ value:CALayer,with:CALayer) -> Self {
        base.replaceSublayer(value, with: with)
        return self
    }
    
    @discardableResult
    func mask(_ value:CALayer?) -> Self {
        base.mask = value
        return self
    }
    
    @discardableResult
    func masksToBounds(_ value:Bool) -> Self {
        base.masksToBounds = value
        return self
    }
    
    @discardableResult
    func contents(_ value:Any) -> Self {
        base.contents = value
        return self
    }
    
    @discardableResult
    func contentsRect(_ value:NSRect) -> Self {
        base.contentsRect = value
        return self
    }
    
    @discardableResult
    func contentsGravity(_ value:String) -> Self {
        base.contentsGravity = CALayerContentsGravity(rawValue: value)
        return self
    }
    
    @discardableResult
    func contentsScale(_ value:CGFloat) -> Self {
        base.contentsScale = value
        return self
    }
    
    @discardableResult
    func contentsCenter(_ value:NSRect) -> Self {
        base.contentsCenter = value
        return self
    }
    
    @discardableResult
    func contentsFormat(_ value:String) -> Self {
        base.contentsFormat = CALayerContentsFormat(rawValue: value)
        return self
    }
    
    @discardableResult
    func minificationFilter(_ value:String) -> Self {
        base.minificationFilter = CALayerContentsFilter(rawValue: value)
        return self
    }
    
    @discardableResult
    func magnificationFilter(_ value:String) -> Self {
        base.magnificationFilter = CALayerContentsFilter(rawValue: value)
        return self
    }
    
    @discardableResult
    func minificationFilterBias(_ value:Float) -> Self {
        base.minificationFilterBias = value
        return self
    }
    
    @discardableResult
    func opaque(_ value:Bool) -> Self {
        base.isOpaque = value
        return self
    }
    
    @discardableResult
    func needsDisplayOnBoundsChange(_ value:Bool) -> Self {
        base.needsDisplayOnBoundsChange = value
        return self
    }
    
    @discardableResult
    func drawsAsynchronously(_ value:Bool) -> Self {
        base.drawsAsynchronously = value
        return self
    }
    
    @discardableResult
    func edgeAntialiasingMask(_ value:CAEdgeAntialiasingMask) -> Self {
        base.edgeAntialiasingMask = value
        return self
    }
    
    @discardableResult
    func allowsEdgeAntialiasing(_ value:Bool) -> Self {
        base.allowsEdgeAntialiasing = value
        return self
    }
    
    @discardableResult
    func backgroundColor(_ value:CGColor) -> Self {
        base.backgroundColor = value
        return self
    }
    
    @discardableResult
    func cornerRadius(_ value:CGFloat) -> Self {
        base.cornerRadius = value
        return self
    }
    
    @discardableResult
    func maskedCorners(_ value:CACornerMask) -> Self {
        base.maskedCorners = value
        return self
    }
    
    @discardableResult
    func borderWidth(_ value:CGFloat) -> Self {
        base.borderWidth = value
        return self
    }
    
    @discardableResult
    func borderColor(_ value:CGColor) -> Self {
        base.borderColor = value
        return self
    }
    
    @discardableResult
    func opacity(_ value:Float) -> Self {
        base.opacity = value
        return self
    }
    
    @discardableResult
    func allowsGroupOpacity(_ value:Bool) -> Self {
        base.allowsGroupOpacity = value
        return self
    }
    
    @discardableResult
    func compositingFilter(_ value:Any) -> Self {
        base.compositingFilter = value
        return self
    }
    
    @discardableResult
    func filters(_ value:[Any]) -> Self {
        base.filters = value
        return self
    }
    
    @discardableResult
    func backgroundFilters(_ value:[Any]) -> Self {
        base.backgroundFilters = value
        return self
    }
    
    @discardableResult
    func shouldRasterize(_ value:Bool) -> Self {
        base.shouldRasterize = value
        return self
    }
    
    @discardableResult
    func rasterizationScale(_ value:CGFloat) -> Self {
        base.rasterizationScale = value
        return self
    }
    
    @discardableResult
    func shadowColor(_ value:CGColor) -> Self {
        base.shadowColor = value
        return self
    }
    
    @discardableResult
    func shadowOpacity(_ value:Float) -> Self {
        base.shadowOpacity = value
        return self
    }
    
    @discardableResult
    func shadowOffset(_ value:CGSize) -> Self {
        base.shadowOffset = value
        return self
    }
    
    @discardableResult
    func shadowRadius(_ value:CGFloat) -> Self {
        base.shadowRadius = value
        return self
    }
    
    @discardableResult
    func shadowPath(_ value:CGPath) -> Self {
        base.shadowPath = value
        return self
    }
    
    @discardableResult
    func actions(_ value:[String : any CAAction]) -> Self {
        base.actions = value
        return self
    }
    
    @discardableResult
    func addAnimation(_ value:CAAnimation,key:String) -> Self {
        base.add(value, forKey: key)
        return self
    }
    
    @discardableResult
    func removeAnimation(_ value:String) -> Self {
        base.removeAnimation(forKey: value)
        return self
    }
    
    @discardableResult
    func removeAllAnimation() -> Self {
        base.removeAllAnimations()
        return self
    }
    
    @discardableResult
    func name(_ value:String) -> Self {
        base.name = value
        return self
    }
    
    @discardableResult
    func delegate(_ value:(any CALayerDelegate)) -> Self {
        base.delegate = value
        return self
    }
    
    @discardableResult
    func style(_ value:[AnyHashable : Any]) -> Self {
        base.style = value
        return self
    }
}
