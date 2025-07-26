//
//  NSTextField+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSTextField {
    
    private struct AssociatedKeys {
        static var placeholderColorName:UnsafeRawPointer = UnsafeRawPointer(bitPattern: "textColor".hashValue)!
    }
    
    var placeholderStringColor:NSColor {
        set {
            objc_setAssociatedObject(self, AssociatedKeys.placeholderColorName,newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            msSetPlaceholder(placeholder: self.placeholderString, color: newValue)
        }
        get {
            return (objc_getAssociatedObject(self, AssociatedKeys.placeholderColorName) as? NSColor)!
        }
    }
    
    func msSetPlaceholder(placeholder: String?, color: NSColor) {
        let font = self.font
        let attrs: [NSAttributedString.Key: Any] = [
           .font: font!,
           .foregroundColor: color
        ]
        let titleStr = placeholder ?? ""
        if titleStr.count > 0 {
            let attributedString = NSMutableAttributedString(string: titleStr, attributes: attrs)
            let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            style.alignment = self.alignment
            attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: titleStr.count))
            self.placeholderAttributedString = attributedString
        }
    }
    
    func fitFontSize(maxSize: NSSize = NSSize.zero) {
        var text = self.stringValue
        var newSize = NSSize.zero
        self.sizeToFit()
        newSize = self.frame.size
        var width = newSize.width
        var height = newSize.height
        let characterSize = width/CGFloat(text.count)
        if maxSize.width > 0 {
            if width > maxSize.width {
                width = maxSize.width
                let array = text.components(separatedBy: " ")
                var newString = ""
                var heightCount = 1
                if array.count > 1 {
                    var currentCount = 0
                    for i in 0..<array.count {
                        if currentCount + array[i].count > Int(maxSize.width / characterSize) {
                            newString += "\n"
                            heightCount += 1
                            currentCount = 0
                        }
                        newString += array[i] + " "
                        currentCount += array[i].count + 1
                    }
                    text = newString
                } else {
                    // 使用新的初始化方法替换旧的
                    let newIndex = String.Index(utf16Offset: text.utf16.count/2, in: text)
                    text.insert("\n", at: newIndex)
                }
                height = height * CGFloat(heightCount)
            }
        }
        self.stringValue = text
        self.frame.size = NSSize(width: width, height: height)
    }
}

public extension NSTextField {
    // 添加轻点手势
    @discardableResult
    func addGestureTap(_ target: AnyObject?, action: Selector?) -> NSClickGestureRecognizer {
        let obj = NSClickGestureRecognizer(target: target, action: action)
        self.isEnabled = true
        self.addGestureRecognizer(obj)
        return obj
    }
    
    // 添加轻点手势，使用闭包方式
    @discardableResult
    func addGestureTap(_ action: @escaping ((NSClickGestureRecognizer) -> Void)) -> NSClickGestureRecognizer {
        let obj = NSClickGestureRecognizer(target: nil, action: nil)
        self.isEnabled = true
        self.addGestureRecognizer(obj)
        obj.addAction(action)
        return obj
    }
    
    // 添加长按手势
    @discardableResult
    func addGestureLongPress(_ target: AnyObject?, action: Selector?, for minimumPressDuration: TimeInterval = 0.5) -> NSPressGestureRecognizer {
        let obj = NSPressGestureRecognizer(target: target, action: action)
        obj.minimumPressDuration = minimumPressDuration
        self.isEnabled = true
        self.addGestureRecognizer(obj)
        return obj
    }
    
    // 添加长按手势，使用闭包方式
    @discardableResult
    func addGestureLongPress(_ action: @escaping ((NSPressGestureRecognizer) -> Void), for minimumPressDuration: TimeInterval = 0.5) -> NSPressGestureRecognizer {
        let obj = NSPressGestureRecognizer(target: nil, action: nil)
        obj.minimumPressDuration = minimumPressDuration
        self.isEnabled = true
        self.addGestureRecognizer(obj)
        obj.addAction { recognizer in
            action(recognizer as! NSPressGestureRecognizer)
        }
        return obj
    }
    
    // 添加拖拽手势
    @discardableResult
    func addGesturePan(_ action: @escaping ((NSPanGestureRecognizer) -> Void)) -> NSPanGestureRecognizer {
        let obj = NSPanGestureRecognizer(target: nil, action: nil)
        self.isEnabled = true
        self.addGestureRecognizer(obj)
        obj.addAction { recognizer in
            if let gesture = recognizer as? NSPanGestureRecognizer, let view = gesture.view {
                let translate = gesture.translation(in: view.superview)
                view.frame.origin.x += translate.x
                view.frame.origin.y += translate.y
                gesture.setTranslation(.zero, in: view.superview)
                action(gesture)
            }
        }
        return obj
    }
    
    // 启动定时器
    func timerStart(interval: Int = 60) {
        var time = interval
        let codeTimer = DispatchSource.makeTimerSource()
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        codeTimer.setEventHandler {
            DispatchQueue.main.async {
                time -= 1
                self.isEnabled = time <= 0
                self.stringValue = time > 0 ? "剩余\(time)s" : "发送验证码"
                if time <= 0 {
                    codeTimer.cancel()
                }
            }
        }
        codeTimer.resume()
    }
    
}
