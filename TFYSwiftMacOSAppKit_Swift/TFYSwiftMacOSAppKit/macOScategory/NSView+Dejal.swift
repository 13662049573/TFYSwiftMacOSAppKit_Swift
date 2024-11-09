//
//  NSView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

extension NSView {

    static func initializeOnce() {
        DispatchQueue.once(token: "viewToken") {
            exchangeInstanceMethodsForClass(self.classForCoder(), originalSelector: #selector(self.init(frame:)), swizzledSelector: #selector(initWithFrame_hook(frameRect:)))
            exchangeInstanceMethodsForClass(self.classForCoder(), originalSelector: #selector(self.init(coder:)), swizzledSelector: #selector(initWithCoder_hook(decoder:)))
        }
    }
    
    @objc func initWithFrame_hook(frameRect: NSRect) -> Self {
        let obj = self.initWithFrame_hook(frameRect: frameRect)
        obj.wantsLayer = true
        return obj
    }

    @objc func initWithCoder_hook(decoder: NSCoder) -> Self {
        let obj = self.initWithCoder_hook(decoder: decoder)
        obj.wantsLayer = true
        return obj
    }
}

public extension NSView {

    var macos_origin:CGPoint {
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin
        }
    }
    
    var macos_x:CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var macos_y:CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var macos_size:CGSize {
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return self.frame.size
        }
    }
    
    var macos_width:CGFloat {
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.width
        }
    }
    
    var macos_height:CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.height
        }
    }
    
    var macos_top:CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    var macos_bottom:CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue - self.frame.size.height
            self.frame = frame
        }
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    var macos_left:CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var macos_right:CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue - self.frame.size.width
            self.frame = frame
        }
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
}

private let defaultTimeInterval: TimeInterval = 60.0
private let buttonTitleFormat: String = "剩余%ld 秒"
private let retainButtonTitle: String = "重新获取"

public extension NSView {
    
    private struct AssociatedObjectKeys {
        static var timeKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "timeKey".hashValue)!
        static var formatKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "formatKey".hashValue)!
        static var stopTimeKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "stopTimeKey".hashValue)!
        static var timerKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "timerKey".hashValue)!
        static var userTimeKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "userTimeKey".hashValue)!
    }

    func removeAllSubviews() {
        while subviews.count > 0 {
            subviews.first?.removeFromSuperview()
        }
    }

    func viewController() -> NSViewController? {
        // 更简洁的获取视图控制器的方式
        if let window = window {
            if let delegate = window.delegate as? NSViewController {
                return delegate
            }
        }
        return nil
    }

    var timeInterval: TimeInterval {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.timeKey, NSNumber(value: newValue),.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let number: NSNumber = objc_getAssociatedObject(self, AssociatedObjectKeys.timeKey) as! NSNumber
            return number.doubleValue
        }
    }

    private var userTimeInterval: TimeInterval {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.userTimeKey, NSNumber(value: newValue),.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let number: NSNumber = objc_getAssociatedObject(self, AssociatedObjectKeys.userTimeKey) as! NSNumber
            return number.doubleValue
        }
    }

    var titleFormat: String? {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.formatKey, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, AssociatedObjectKeys.formatKey) as? String
        }
    }

    private var stopTime: Int {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.stopTimeKey, NSNumber(integerLiteral: newValue),.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let number: NSNumber = objc_getAssociatedObject(self, AssociatedObjectKeys.stopTimeKey) as! NSNumber
            return number.intValue
        }
    }

    private var timer: DispatchSourceTimer? {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.timerKey, newValue,.OBJC_ASSOCIATION_COPY)
        }
        get {
            return objc_getAssociatedObject(self, AssociatedObjectKeys.timerKey) as? DispatchSourceTimer
        }
    }

    func startOrStopTimer(start: Bool, block: @escaping (String, Int) -> Void) {
        if start {
            if timeInterval == 0 {
                timeInterval = defaultTimeInterval
            }
            if titleFormat == nil {
                titleFormat = buttonTitleFormat
            }
            let globalQueue = DispatchQueue.global(qos:.default)
            timer = DispatchSource.makeTimerSource(queue: globalQueue)
            timer?.schedule(deadline:.now(), repeating: 1.0 * Double(NSEC_PER_SEC), leeway:.nanoseconds(0))
            timer?.setEventHandler { [self] in
                if timeInterval <= 1 {
                    timer?.cancel()
                } else {
                    timeInterval -= 1
                    DispatchQueue.main.async {
                        self.stopTime = 1
                        block(String(format: self.titleFormat!, self.timeInterval), 0)
                    }
                }
            }
            timer?.setCancelHandler {
                DispatchQueue.main.async {
                    self.stopTime = 0
                    block(retainButtonTitle, 1)
                    if self.userTimeInterval > 0 {
                        self.timeInterval = self.userTimeInterval
                    } else {
                        self.timeInterval = defaultTimeInterval
                    }
                }
            }
            timer?.resume()
        } else {
            if let timer = timer {
                timer.cancel()
            }
        }
    }
    
    func startAnimationWithFadeInDuration(fadeInDuration: TimeInterval) {
        self.alphaValue = 0.0
        // 这里假设没有找到 startAnimation 的实现，我们可以使用另一种动画方式来替代，比如使用隐式动画。
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1) // 设置一个短暂的初始动画时间
        self.layer?.opacity = 0.01
        CATransaction.commit()
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = fadeInDuration
            self.animator().alphaValue = 1.0
        }, completionHandler: nil)
    }
    
    func adjustAutoresizeMasks() -> [NSNumber] {
        return adjustAutoresizingAroundPosition(NSMaxY(self.frame), stickPositionToTop: true)
    }

    func adjustAutoresizingAroundPosition(_ position: CGFloat, stickPositionToTop: Bool) -> [NSNumber] {
        var subviewMasks = [NSNumber]()
        var superview = self
        var oldSuperview = superview

        // 将 position 声明为变量
        var positionValue = position

        while !superview.isFlipped {
            // 首先调整父视图的蒙版:
            let mask = superview.autoresizingMask
            subviewMasks.append(NSNumber(value: mask.rawValue))

            // Make it stick to the top and bottom of the window, and change height:
            var newMask = mask
            newMask.insert(.height)
            newMask.remove(.maxYMargin)
            newMask.remove(.minYMargin)
            superview.autoresizingMask = newMask

            let subviews = superview.subviews

            for subview in subviews {
                if subview != oldSuperview {
                    let oldSubviewMask = subview.autoresizingMask
                    subviewMasks.append(NSNumber(value: oldSuperview.autoresizingMask.rawValue))

                    var stickToBottom = NSMaxY(subview.frame) <= positionValue
                    if !stickPositionToTop && NSMaxY(subview.frame) == positionValue {
                        stickToBottom = true
                    }

                    if stickToBottom {
                        // 这个子视图在我们下面。让它粘在窗口底部，不改变高度:
                        var newSubviewMask = oldSubviewMask
                        newSubviewMask.remove(.height)
                        newSubviewMask.insert(.maxYMargin)
                        newSubviewMask.remove(.minYMargin)
                        subview.autoresizingMask = newSubviewMask
                    } else {
                        // 这个子视图在我们上面。让它粘在窗户顶部，不改变高度:
                        var newSubviewMask = oldSubviewMask
                        newSubviewMask.remove(.height)
                        newSubviewMask.remove(.maxYMargin)
                        newSubviewMask.insert(.minYMargin)
                        subview.autoresizingMask = newSubviewMask
                    }
                }
            }

            // 到这个父视图的父视图，重复这个过程;注意，循环算法必须在下面的恢复方法中完全复制。理想情况下，这两个方法都应该使用另一个方法来获得下一个子视图，但我不能在这个阶段重构它，所以要注意这个问题:
            oldSuperview = superview
            positionValue = NSMaxY(superview.frame)
            superview = superview.superview!
        }

        return subviewMasks
    }

    func restoreAutoresizeMasks(_ masks: [NSNumber]) {
        var superview = self
        var oldSuperview = superview
        var enumerator = masks.makeIterator()

        while !superview.isFlipped {
            // 第一项是父视图的蒙版:
            if let maskValue = enumerator.next() {
               let autoresizingMask = NSView.AutoresizingMask(rawValue: maskValue.uintValue)
               superview.autoresizingMask = autoresizingMask
            } else {
                // 处理掩码数组耗尽的情况，可以抛出错误或进行适当的处理
                fatalError("掩码数组耗尽")
            }

            // 以下是子视图掩码:
            let subviews = superview.subviews

            for subview in subviews {
                if subview != oldSuperview {
                    if let subviewMaskValue = enumerator.next() {
                        let subviewAutoresizingMask = NSView.AutoresizingMask(rawValue: subviewMaskValue.uintValue)
                            subview.autoresizingMask = subviewAutoresizingMask
                    } else {
                        // 处理掩码数组耗尽的情况，可以抛出错误或进行适当的处理
                        fatalError("掩码数组耗尽")
                    }
                }
            }
            // 到这个父视图的父视图，重复这个过程;注意，循环算法必须在上面的 adjust 方法中完全复制。理想情况下，这两个方法都应该使用另一个方法来获得下一个子视图，但我不能在这个阶段重构它，所以要注意这个问题:
            oldSuperview = superview
            superview = superview.superview!
        }
    }
}
