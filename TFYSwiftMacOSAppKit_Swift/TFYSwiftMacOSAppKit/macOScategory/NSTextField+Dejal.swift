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
        static var textChangeHandler: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "textChangeHandler".hashValue)!
        static var validationHandler: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "validationHandler".hashValue)!
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
    
    // MARK: - 新增实用方法
    
    /// 设置文本变化回调
    /// - Parameter handler: 文本变化回调
    func setTextChangeHandler(_ handler: @escaping (String) -> Void) {
        objc_setAssociatedObject(self, AssociatedKeys.textChangeHandler, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.target = self
        self.action = #selector(handleTextChange(_:))
    }
    
    @objc private func handleTextChange(_ sender: NSTextField) {
        if let handler = objc_getAssociatedObject(self, AssociatedKeys.textChangeHandler) as? (String) -> Void {
            handler(sender.stringValue)
        }
    }
    
    /// 设置文本验证回调
    /// - Parameter handler: 验证回调，返回是否有效
    func setValidationHandler(_ handler: @escaping (String) -> Bool) {
        objc_setAssociatedObject(self, AssociatedKeys.validationHandler, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    /// 验证当前文本
    /// - Returns: 是否有效
    func validateText() -> Bool {
        if let handler = objc_getAssociatedObject(self, AssociatedKeys.validationHandler) as? (String) -> Bool {
            return handler(stringValue)
        }
        return true
    }
    
    /// 添加焦点效果
    func addFocusEffect() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing), name: NSControl.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing), name: NSControl.textDidEndEditingNotification, object: self)
    }
    
    @objc private func textFieldDidBeginEditing() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 1.0
        })
    }
    
    @objc private func textFieldDidEndEditing() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 0.8
        })
    }
    
    /// 设置最大字符数
    /// - Parameter maxLength: 最大字符数
    func setMaxLength(_ maxLength: Int) {
        self.target = self
        self.action = #selector(handleTextDidChange(_:))
        objc_setAssociatedObject(self, "maxLength", maxLength, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func handleTextDidChange(_ sender: NSTextField) {
        if let maxLength = objc_getAssociatedObject(self, "maxLength") as? Int {
            if sender.stringValue.count > maxLength {
                sender.stringValue = String(sender.stringValue.prefix(maxLength))
            }
        }
    }
    
    /// 检查文本是否为空
    var isEmpty: Bool {
        return stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 设置文本字段为只读
    /// - Parameter readOnly: 是否只读
    func setReadOnly(_ readOnly: Bool) {
        self.isEditable = !readOnly
        self.isSelectable = !readOnly
        if readOnly {
            self.backgroundColor = NSColor.controlBackgroundColor
        }
    }
    
    /// 获取当前光标位置
    var cursorPosition: Int {
        if let textView = self.currentEditor() as? NSTextView {
            return textView.selectedRange().location
        }
        return 0
    }
    
    /// 设置光标位置
    /// - Parameter position: 光标位置
    func setCursorPosition(_ position: Int) {
        if let textView = self.currentEditor() as? NSTextView {
            let range = NSRange(location: position, length: 0)
            textView.setSelectedRange(range)
        }
    }
    
    /// 复制文本到剪贴板
    func copyText() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(stringValue, forType: .string)
    }
    
    /// 从剪贴板粘贴文本
    func pasteText() {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string) {
            self.stringValue = text
        }
    }
    
    /// 撤销操作
    func undo() {
        if let textView = self.currentEditor() as? NSTextView {
            textView.undoManager?.undo()
        }
    }
    
    /// 重做操作
    func redo() {
        if let textView = self.currentEditor() as? NSTextView {
            textView.undoManager?.redo()
        }
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
    
    // MARK: - 新增手势和动画方法
    
    /// 添加缩放手势
    @discardableResult
    func addGesturePinch(_ action: @escaping ((NSMagnificationGestureRecognizer) -> Void)) -> NSMagnificationGestureRecognizer {
        let obj = NSMagnificationGestureRecognizer(target: nil, action: nil)
        self.isEnabled = true
        self.addGestureRecognizer(obj)
        obj.addAction { recognizer in
            action(recognizer as! NSMagnificationGestureRecognizer)
        }
        return obj
    }
    
    /// 添加旋转手势
    @discardableResult
    func addGestureRotation(_ action: @escaping ((NSRotationGestureRecognizer) -> Void)) -> NSRotationGestureRecognizer {
        let obj = NSRotationGestureRecognizer(target: nil, action: nil)
        self.isEnabled = true
        self.addGestureRecognizer(obj)
        obj.addAction { recognizer in
            action(recognizer as! NSRotationGestureRecognizer)
        }
        return obj
    }
}
