//
//  TFYAnimationEnhancer.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import QuartzCore

public enum TFYAnimationType {
    case fade
    case scale
    case slide
    case rotate
    case bounce
    case elastic
    case custom
}

public class TFYAnimationEnhancer: NSObject {
    // MARK: - Properties
    var duration: CGFloat = 0.0
    var springDamping: CGFloat = 0.0
    var initialSpringVelocity: CGFloat = 0.0
    var animationCurve: NSAnimation.Curve = .easeInOut
    var animationType: TFYAnimationType = .fade
    
    // MARK: - Initialization
    override init() {
        super.init()
        configureAnimationDefaults()
    }
    
    // MARK: - Configuration
    func configureAnimationDefaults() {
        duration = 0.3
        springDamping = 0.7
        initialSpringVelocity = 0.5
        animationCurve = .easeInOut
        animationType = .fade
    }
    
    func configure(duration: CGFloat, springDamping: CGFloat, initialSpringVelocity: CGFloat, animationCurve: NSAnimation.Curve) {
        self.duration = duration
        self.springDamping = springDamping
        self.initialSpringVelocity = initialSpringVelocity
        self.animationCurve = animationCurve
    }
    
    func setAnimationType(_ type: TFYAnimationType) {
        animationType = type
    }
    
    // MARK: - View Setup
    func setup(with view: NSView) {
        view.wantsLayer = true
        view.layer?.opacity = 0.0
    }
    
    func applyAnimation(to view: NSView) {
        switch animationType {
        case .fade:
            applyFadeAnimation(to: view)
        case .scale:
            applyScaleAnimation(to: view)
        case .slide:
            applySlideAnimation(to: view)
        case .rotate:
            applyRotateAnimation(to: view)
        case .bounce:
            applyBounceAnimation(to: view)
        case .elastic:
            applyElasticAnimation(to: view)
        case .custom:
            applyCustomAnimation(to: view)
        }
    }
    
    func reset(_ view: NSView) {
        switch animationType {
        case .fade:
            applyFadeOutAnimation(to: view)
        case .scale:
            applyScaleOutAnimation(to: view)
        case .slide:
            applySlideOutAnimation(to: view)
        case .rotate:
            applyRotateOutAnimation(to: view)
        case .bounce:
            applyBounceOutAnimation(to: view)
        case .elastic:
            applyElasticOutAnimation(to: view)
        case .custom:
            applyCustomOutAnimation(to: view)
        }
    }
    
    // MARK: - Animation Methods
    private func applyFadeAnimation(to view: NSView) {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = duration
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(fadeAnimation, forKey: "fadeIn")
        view.layer?.opacity = 1.0
    }
    
    private func applyFadeOutAnimation(to view: NSView) {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = duration
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(fadeAnimation, forKey: "fadeOut")
        view.layer?.opacity = 0.0
    }
    
    private func applyScaleAnimation(to view: NSView) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(scaleAnimation, forKey: "scaleIn")
        view.layer?.opacity = 1.0
    }
    
    private func applyScaleOutAnimation(to view: NSView) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.0
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(scaleAnimation, forKey: "scaleOut")
        view.layer?.opacity = 0.0
    }
    
    private func applySlideAnimation(to view: NSView) {
        let slideAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        slideAnimation.fromValue = -50.0
        slideAnimation.toValue = 0.0
        slideAnimation.duration = duration
        slideAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(slideAnimation, forKey: "slideIn")
        view.layer?.opacity = 1.0
    }
    
    private func applySlideOutAnimation(to view: NSView) {
        let slideAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        slideAnimation.fromValue = 0.0
        slideAnimation.toValue = 50.0
        slideAnimation.duration = duration
        slideAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(slideAnimation, forKey: "slideOut")
        view.layer?.opacity = 0.0
    }
    
    private func applyRotateAnimation(to view: NSView) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = Double.pi * 2
        rotateAnimation.duration = duration
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotateAnimation, fadeAnimation]
        groupAnimation.duration = duration
        
        view.layer?.add(groupAnimation, forKey: "rotateIn")
        view.layer?.opacity = 1.0
    }
    
    private func applyRotateOutAnimation(to view: NSView) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -Double.pi * 2
        rotateAnimation.duration = duration
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotateAnimation, fadeAnimation]
        groupAnimation.duration = duration
        
        view.layer?.add(groupAnimation, forKey: "rotateOut")
        view.layer?.opacity = 0.0
    }
    
    private func applyBounceAnimation(to view: NSView) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [0.0, 1.2, 0.9, 1.0]
        bounceAnimation.keyTimes = [0.0, 0.6, 0.8, 1.0] as [NSNumber]
        bounceAnimation.duration = duration
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [bounceAnimation, fadeAnimation]
        groupAnimation.duration = duration
        
        view.layer?.add(groupAnimation, forKey: "bounceIn")
        view.layer?.opacity = 1.0
    }
    
    private func applyBounceOutAnimation(to view: NSView) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.1, 0.8, 0.0]
        bounceAnimation.keyTimes = [0.0, 0.2, 0.6, 1.0] as [NSNumber]
        bounceAnimation.duration = duration
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [bounceAnimation, fadeAnimation]
        groupAnimation.duration = duration
        
        view.layer?.add(groupAnimation, forKey: "bounceOut")
        view.layer?.opacity = 0.0
    }
    
    private func applyElasticAnimation(to view: NSView) {
        let elasticAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        elasticAnimation.values = [0.0, 1.3, 0.8, 1.1, 0.95, 1.0]
        elasticAnimation.keyTimes = [0.0, 0.3, 0.5, 0.7, 0.9, 1.0] as [NSNumber]
        elasticAnimation.duration = duration
        elasticAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [elasticAnimation, fadeAnimation]
        groupAnimation.duration = duration
        
        view.layer?.add(groupAnimation, forKey: "elasticIn")
        view.layer?.opacity = 1.0
    }
    
    private func applyElasticOutAnimation(to view: NSView) {
        let elasticAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        elasticAnimation.values = [1.0, 1.1, 0.9, 1.05, 0.95, 0.0]
        elasticAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0] as [NSNumber]
        elasticAnimation.duration = duration
        elasticAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [elasticAnimation, fadeAnimation]
        groupAnimation.duration = duration
        
        view.layer?.add(groupAnimation, forKey: "elasticOut")
        view.layer?.opacity = 0.0
    }
    
    private func applyCustomAnimation(to view: NSView) {
        // 自定义动画：组合缩放和旋转
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = duration
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = Double.pi
        rotateAnimation.duration = duration
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, rotateAnimation, fadeAnimation]
        groupAnimation.duration = duration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(groupAnimation, forKey: "customIn")
        view.layer?.opacity = 1.0
    }
    
    private func applyCustomOutAnimation(to view: NSView) {
        // 自定义动画：组合缩放和旋转
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.0
        scaleAnimation.duration = duration
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -Double.pi
        rotateAnimation.duration = duration
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = duration
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, rotateAnimation, fadeAnimation]
        groupAnimation.duration = duration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(groupAnimation, forKey: "customOut")
        view.layer?.opacity = 0.0
    }
    
    // MARK: - Animations
    func addSuccessAnimation(to view: NSView) {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.2, 0.9, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.4, 0.6, 1.0] as [NSNumber]
        scaleAnimation.duration = duration
        
        // Rotation animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotateAnimation.values = [0, Double.pi * 2]
        rotateAnimation.keyTimes = [0.0, 1.0] as [NSNumber]
        rotateAnimation.duration = duration
        
        // Group animation
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, rotateAnimation]
        groupAnimation.duration = duration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(groupAnimation, forKey: "successAnimation")
    }
    
    func addErrorAnimation(to view: NSView) {
        // Shake animation
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        shakeAnimation.values = [0, -Double.pi/8, Double.pi/8, 0]
        shakeAnimation.keyTimes = [0.0, 0.3, 0.6, 1.0] as [NSNumber]
        shakeAnimation.duration = duration
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.1, 0.9, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.3, 0.6, 1.0] as [NSNumber]
        scaleAnimation.duration = duration
        
        // Group animation
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [shakeAnimation, scaleAnimation]
        groupAnimation.duration = duration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(groupAnimation, forKey: "errorAnimation")
    }
    
    func addShakeAnimation(to view: NSView) {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [0, -10, 10, -5, 5, 0]
        shakeAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0] as [NSNumber]
        shakeAnimation.duration = duration
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(shakeAnimation, forKey: "shakeAnimation")
    }
    
    func addPulseAnimation(to view: NSView) {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.duration = duration
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer?.add(pulseAnimation, forKey: "pulseAnimation")
    }
}
