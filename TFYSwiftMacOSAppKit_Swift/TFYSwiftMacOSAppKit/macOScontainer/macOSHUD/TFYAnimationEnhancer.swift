//
//  TFYAnimationEnhancer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYAnimationEnhancer: NSObject {
    
    // MARK: - Properties
    public var duration: CGFloat = 0.3
    public var springDamping: CGFloat = 0.7
    public var initialSpringVelocity: CGFloat = 0.5
    public var animationCurve: NSAnimation.Curve = .easeInOut
    
    // MARK: - Initialization
    override init() {
        super.init()
        configureAnimationDefaults()
    }
    
    // MARK: - Configuration
    public func configureAnimationDefaults() {
        duration = 0.3
        springDamping = 0.7
        initialSpringVelocity = 0.5
        animationCurve = .easeInOut
    }
    
    public func configure(duration: CGFloat,
                         springDamping: CGFloat,
                         initialSpringVelocity: CGFloat,
                         animationCurve: NSAnimation.Curve) {
        self.duration = duration
        self.springDamping = springDamping
        self.initialSpringVelocity = initialSpringVelocity
        self.animationCurve = animationCurve
    }
    
    // MARK: - Animation Methods
    public func addSuccessAnimation(to view: NSView) {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.2, 0.9, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.4, 0.6, 1.0]
        scaleAnimation.duration = duration
        
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotateAnimation.values = [0, CGFloat.pi * 2]
        rotateAnimation.keyTimes = [0.0, 1.0]
        rotateAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, rotateAnimation]
        groupAnimation.duration = duration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(groupAnimation, forKey: "successAnimation")
    }
    
    public func addErrorAnimation(to view: NSView) {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        shakeAnimation.values = [0, -CGFloat.pi/8, CGFloat.pi/8, 0]
        shakeAnimation.keyTimes = [0.0, 0.3, 0.6, 1.0]
        shakeAnimation.duration = duration
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.1, 0.9, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.3, 0.6, 1.0]
        scaleAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [shakeAnimation, scaleAnimation]
        groupAnimation.duration = duration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(groupAnimation, forKey: "errorAnimation")
    }
    
    public func addShakeAnimation(to view: NSView) {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [0, -10, 10, -5, 5, 0]
        shakeAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        shakeAnimation.duration = duration
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(shakeAnimation, forKey: "shakeAnimation")
    }
    
    public func addPulseAnimation(to view: NSView) {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.duration = duration
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(pulseAnimation, forKey: "pulseAnimation")
    }
    
    // MARK: - View Setup
    public func setup(view: NSView) {
        view.wantsLayer = true
        view.layer?.opacity = 0.0
    }
    
    public func applyAnimation(to view: NSView) {
        view.layer?.opacity = 1.0
    }
    
    public func reset(view: NSView) {
        view.layer?.removeAllAnimations()
        view.layer?.opacity = 0.0
    }
}
