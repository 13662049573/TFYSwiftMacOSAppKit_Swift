//
//  NSTextField+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

private final class TFYTextFieldObservationBag {
    var textChangeObserver: NSObjectProtocol?
    var focusBeginObserver: NSObjectProtocol?
    var focusEndObserver: NSObjectProtocol?
    var maxLengthObserver: NSObjectProtocol?
    
    deinit {
        let notificationCenter = NotificationCenter.default
        [textChangeObserver, focusBeginObserver, focusEndObserver, maxLengthObserver]
            .compactMap { $0 }
            .forEach(notificationCenter.removeObserver)
    }
}

public extension NSTextField {
    
    private struct AssociatedKeys {
        static var placeholderColorName: UInt8 = 0
        static var textChangeHandler: UInt8 = 0
        static var validationHandler: UInt8 = 0
        static var maxLength: UInt8 = 0
        static var observationBag: UInt8 = 0
    }
    
    var placeholderStringColor:NSColor {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.placeholderColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            msSetPlaceholder(placeholder: self.placeholderString, color: newValue)
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.placeholderColorName) as? NSColor) ?? .placeholderTextColor
        }
    }
    
    func msSetPlaceholder(placeholder: String?, color: NSColor) {
        let font = self.font ?? .systemFont(ofSize: NSFont.systemFontSize)
        let attrs: [NSAttributedString.Key: Any] = [
           .font: font,
           .foregroundColor: color
        ]
        let titleStr = placeholder ?? ""
        if !titleStr.isEmpty {
            let attributedString = NSMutableAttributedString(string: titleStr, attributes: attrs)
            let style = NSMutableParagraphStyle()
            style.alignment = self.alignment
            attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: (titleStr as NSString).length))
            self.placeholderAttributedString = attributedString
        }
    }

    /// 设置富文本占位符
    /// - Parameter attributedString: 富文本占位符
    func setAttributedPlaceholder(_ attributedString: NSAttributedString?) {
        placeholderAttributedString = attributedString
    }
    
    func fitFontSize(maxSize: NSSize = NSSize.zero) {
        let text = self.stringValue
        guard !text.isEmpty else { return }

        self.lineBreakMode = .byWordWrapping
        self.maximumNumberOfLines = 0
        self.cell?.wraps = true
        self.cell?.isScrollable = false

        let targetWidth = maxSize.width > 0 ? maxSize.width : self.frame.size.width
        let usedFont = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let attrs: [NSAttributedString.Key: Any] = [.font: usedFont]
        let boundingRect = (text as NSString).boundingRect(
            with: NSSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs
        )

        let fittedHeight = maxSize.height > 0 ? min(ceil(boundingRect.height), maxSize.height) : ceil(boundingRect.height)
        self.frame.size = NSSize(width: targetWidth, height: fittedHeight)
    }
    
    // MARK: - 新增实用方法
    
    /// 设置文本变化回调
    /// - Parameter handler: 文本变化回调
    func setTextChangeHandler(_ handler: @escaping (String) -> Void) {
        objc_setAssociatedObject(self, &AssociatedKeys.textChangeHandler, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        let bag = ensureObservationBag()
        if bag.textChangeObserver == nil {
            bag.textChangeObserver = NotificationCenter.default.addObserver(
                forName: NSControl.textDidChangeNotification,
                object: self,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                if let handler = objc_getAssociatedObject(self, &AssociatedKeys.textChangeHandler) as? (String) -> Void {
                    handler(self.stringValue)
                }
            }
        }
    }
    
    @objc private func handleTextChange(_ sender: NSTextField) {
        if let handler = objc_getAssociatedObject(self, &AssociatedKeys.textChangeHandler) as? (String) -> Void {
            handler(sender.stringValue)
        }
    }
    
    /// 设置文本验证回调
    /// - Parameter handler: 验证回调，返回是否有效
    func setValidationHandler(_ handler: @escaping (String) -> Bool) {
        objc_setAssociatedObject(self, &AssociatedKeys.validationHandler, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    /// 验证当前文本
    /// - Returns: 是否有效
    func validateText() -> Bool {
        if let handler = objc_getAssociatedObject(self, &AssociatedKeys.validationHandler) as? (String) -> Bool {
            return handler(stringValue)
        }
        return true
    }
    
    /// 添加焦点效果
    func addFocusEffect() {
        let bag = ensureObservationBag()
        
        if bag.focusBeginObserver == nil {
            bag.focusBeginObserver = NotificationCenter.default.addObserver(
                forName: NSControl.textDidBeginEditingNotification,
                object: self,
                queue: .main
            ) { [weak self] _ in
                self?.textFieldDidBeginEditing()
            }
        }
        
        if bag.focusEndObserver == nil {
            bag.focusEndObserver = NotificationCenter.default.addObserver(
                forName: NSControl.textDidEndEditingNotification,
                object: self,
                queue: .main
            ) { [weak self] _ in
                self?.textFieldDidEndEditing()
            }
        }
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
        objc_setAssociatedObject(self, &AssociatedKeys.maxLength, maxLength, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let bag = ensureObservationBag()
        if bag.maxLengthObserver == nil {
            bag.maxLengthObserver = NotificationCenter.default.addObserver(
                forName: NSControl.textDidChangeNotification,
                object: self,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.enforceMaxLength()
            }
        }
    }
    
    @objc private func handleTextDidChange(_ sender: NSTextField) {
        if let maxLength = objc_getAssociatedObject(self, &AssociatedKeys.maxLength) as? Int {
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
        self.isSelectable = true
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

    /// 选中全部文本
    func selectAllText() {
        currentEditor()?.selectAll(nil)
    }

    /// 追加文本
    /// - Parameter text: 需要追加的文本
    func appendText(_ text: String) {
        stringValue += text
    }

    /// 前置插入文本
    /// - Parameter text: 需要插入的文本
    func prependText(_ text: String) {
        stringValue = text + stringValue
    }

    /// 设置边框样式
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - width: 边框宽度
    ///   - cornerRadius: 圆角
    func setBorderStyle(color: NSColor, width: CGFloat = 1, cornerRadius: CGFloat = 6) {
        wantsLayer = true
        layer?.borderColor = color.cgColor
        layer?.borderWidth = width
        layer?.cornerRadius = cornerRadius
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
            guard let gesture = recognizer as? NSPressGestureRecognizer else { return }
            action(gesture)
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
    
    private static var timerSourceKey: UInt8 = 0
    
    func timerStart(interval: Int = 60) {
        if let existing = objc_getAssociatedObject(self, &NSTextField.timerSourceKey) as? DispatchSourceTimer {
            existing.cancel()
        }
        var time = interval
        let codeTimer = DispatchSource.makeTimerSource(queue: .main)
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        objc_setAssociatedObject(self, &NSTextField.timerSourceKey, codeTimer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        codeTimer.setEventHandler { [weak self] in
            guard let self = self else { return }
            time -= 1
            self.isEnabled = time <= 0
            self.stringValue = time > 0 ? "剩余\(time)s" : "发送验证码"
            if time <= 0 {
                codeTimer.cancel()
                objc_setAssociatedObject(self, &NSTextField.timerSourceKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
            guard let gesture = recognizer as? NSMagnificationGestureRecognizer else { return }
            action(gesture)
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
            guard let gesture = recognizer as? NSRotationGestureRecognizer else { return }
            action(gesture)
        }
        return obj
    }
    
    private func ensureObservationBag() -> TFYTextFieldObservationBag {
        if let bag = objc_getAssociatedObject(self, &AssociatedKeys.observationBag) as? TFYTextFieldObservationBag {
            return bag
        }
        
        let bag = TFYTextFieldObservationBag()
        objc_setAssociatedObject(self, &AssociatedKeys.observationBag, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return bag
    }
    
    private func enforceMaxLength() {
        if let fieldEditor = currentEditor() as? NSTextView,
           fieldEditor.markedRange().length > 0 {
            return
        }
        if let maxLength = objc_getAssociatedObject(self, &AssociatedKeys.maxLength) as? Int,
           stringValue.count > maxLength {
            stringValue = String(stringValue.prefix(maxLength))
        }
    }
}
