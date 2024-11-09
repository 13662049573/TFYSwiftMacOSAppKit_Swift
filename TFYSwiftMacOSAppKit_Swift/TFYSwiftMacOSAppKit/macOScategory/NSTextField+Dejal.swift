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

    /// 点击手势识别器
    @discardableResult
    func addGestureTap(_ target: Any?, action: Selector?) -> NSClickGestureRecognizer {
        let obj = NSClickGestureRecognizer(target: target, action: action)
        obj.numberOfClicksRequired = 1
        isEnabled = true
        if let window = self.window {
            // 如果窗口有内容视图，可以尝试将手势识别器添加到内容视图上
            if let contentView = window.contentView {
                contentView.addGestureRecognizer(obj)
            }
        }
        return obj
    }

    // 点击手势识别器（使用闭包）
    @discardableResult
    func addGestureTap(_ action: @escaping ((NSClickGestureRecognizer) -> Void)) -> NSClickGestureRecognizer {
        let obj = NSClickGestureRecognizer()
        obj.numberOfClicksRequired = 1
        isEnabled = true
        if let window = self.window {
            // 如果窗口有内容视图，可以尝试将手势识别器添加到内容视图上
            if let contentView = window.contentView {
                contentView.addGestureRecognizer(obj)
            }
        }
        obj.addAction(action)
        return obj
    }

    // 拖拽手势
    @discardableResult
    func addGesturePan(_ action: @escaping ((NSPanGestureRecognizer) -> Void)) -> NSPanGestureRecognizer {
        let obj = NSPanGestureRecognizer(target: nil, action: nil)
        isEnabled = true
        if let window = self.window {
            // 如果窗口有内容视图，可以尝试将手势识别器添加到内容视图上
            if let contentView = window.contentView {
                contentView.addGestureRecognizer(obj)
            }
        }
        obj.addAction { (recognizer) in
            if let gesture = recognizer as? NSPanGestureRecognizer {
                let translate = gesture.translation(in: gesture.view?.superview)
                if let view = self.superview {
                    view.center = CGPoint(x: view.center.x + translate.x, y: view.center.y + translate.y)
                    gesture.setTranslation(CGPoint.zero, in: gesture.view!.superview)
                }
                action(gesture)
            }
        }
        return obj
    }

    // 旋转手势
    @discardableResult
    func addGestureRotation(_ action: @escaping ((NSRotationGestureRecognizer) -> Void)) -> NSRotationGestureRecognizer {
        let obj = NSRotationGestureRecognizer(target: nil, action: nil)
        isEnabled = true
        if let window = self.window {
            // 如果窗口有内容视图，可以尝试将手势识别器添加到内容视图上
            if let contentView = window.contentView {
                contentView.addGestureRecognizer(obj)
            }
        }
        obj.addAction { (recognizer) in
            if let gesture = recognizer as? NSRotationGestureRecognizer {
                if let view = self.superview {
                    view.transform = view.transform.rotated(by: gesture.rotation)
                    gesture.rotation = 0.0
                }
                action(gesture)
            }
        }
        return obj
    }
}
