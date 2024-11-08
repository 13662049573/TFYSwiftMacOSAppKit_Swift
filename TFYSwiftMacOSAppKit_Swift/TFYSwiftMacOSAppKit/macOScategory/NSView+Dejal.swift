//
//  NSView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

extension NSView {
    
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

private let timeIndex:TimeInterval = 60.0
private let ButtonTitleFormat:String = "剩余%ld秒"
private let RetainTitle:String = "重新获取"

public extension NSView {
    
    private struct AssociateKeys {
        static var timeName   = "time" + "funcName"
        static var formatName    = "time" + "format"
        static var stopTimeName    = "time" + "time"
        static var timeTimeName    = "time" + "gcd"
        static var userTimeName    = "time" + "userTimeName"
    }

    func tfy_removeAllSubViews() {
        while subviews.count > 0 {
            subviews.first?.removeFromSuperview()
        }
    }

    func tfy_viewController() -> NSViewController? {
        var nextResponder = self.nextResponder
        var view = self
        while !(nextResponder is NSViewController) {
            view = view.superview!
            nextResponder = view.nextResponder
        }
        return nextResponder as? NSViewController
    }
    
    var tfy_time:TimeInterval {
        set {
            objc_setAssociatedObject(self, (AssociateKeys.timeName), NSNumber(value: newValue), .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            let number:NSNumber = objc_getAssociatedObject(self, (AssociateKeys.timeName)) as! NSNumber
            return number.doubleValue
        }
    }
    
    private var tfy_userTime:TimeInterval {
        set {
            objc_setAssociatedObject(self, (AssociateKeys.userTimeName), NSNumber(value: newValue), .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            let number:NSNumber = objc_getAssociatedObject(self, (AssociateKeys.userTimeName)) as! NSNumber
            return number.doubleValue
        }
    }
    
    var tfy_format:String? {
        set {
            objc_setAssociatedObject(self, (AssociateKeys.formatName),newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            return objc_getAssociatedObject(self, (AssociateKeys.formatName)) as? String
        }
    }
    
    private var stopTime:Int {
        set {
            objc_setAssociatedObject(self, (AssociateKeys.stopTimeName), NSNumber(integerLiteral: newValue), .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            let number:NSNumber = objc_getAssociatedObject(self, (AssociateKeys.stopTimeName)) as! NSNumber
            return number.intValue
        }
    }
    
    private var timer:DispatchSourceTimer? {
        set {
            objc_setAssociatedObject(self, (AssociateKeys.timeTimeName),newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            return objc_getAssociatedObject(self, (AssociateKeys.timeTimeName)) as? DispatchSourceTimer
        }
    }
    
    func tfy_startTimer(block: @escaping (String, Int) -> Void) {
        if stopTime == 0 {
            if tfy_time == 0 {
                tfy_time = timeIndex
            }
            if tfy_format == nil {
                tfy_format = ButtonTitleFormat
            }
            let globalQueue = DispatchQueue.global(qos:.default)
            timer = DispatchSource.makeTimerSource(queue: globalQueue)
            timer?.schedule(deadline:.now(), repeating: 1.0 * Double(NSEC_PER_SEC), leeway:.nanoseconds(0))
            timer?.setEventHandler { [self] in
                if tfy_time <= 1 {
                    timer?.cancel()
                } else {
                    tfy_time -= 1
                    DispatchQueue.main.async {
                        self.stopTime = 1
                        block(String(format: self.tfy_format!, self.tfy_time), 0)
                    }
                }
            }
            timer?.setCancelHandler {
                DispatchQueue.main.async {
                    self.stopTime = 0
                    block(RetainTitle, 1)
                    if self.tfy_userTime > 0 {
                        self.tfy_time = self.tfy_userTime
                    } else {
                        self.tfy_time = timeIndex
                    }
                }
            }
            timer?.resume()
        }
    }

    func tfy_endTimer() {
        if let timer = timer {
            timer.cancel()
        }
    }
}

