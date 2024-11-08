//
//  NSView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

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
}
