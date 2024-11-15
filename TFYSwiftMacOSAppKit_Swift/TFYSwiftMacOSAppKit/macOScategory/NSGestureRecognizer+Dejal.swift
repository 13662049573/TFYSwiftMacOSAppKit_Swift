//
//  NSGestureRecognizer+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class LinkInfo {
    let key: String
    let value: String?
    init(key: String, value: String?) {
        self.key = key
        self.value = value
    }
}

// 定义关联键结构体
struct GestureRecognizerAssociatedKeys {
    static var functionName: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "functionName".hashValue)!
    static var closure: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "closure".hashValue)!
    static var clickGestureClosure: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "NSClickGestureRecognizer+closure".hashValue)!
}

@objc public extension NSGestureRecognizer {
    // 方法名称(用于自定义)
    var functionName: String {
        get {
            if let obj = objc_getAssociatedObject(self, GestureRecognizerAssociatedKeys.functionName) as? String {
                return obj
            }
            let string = String(describing: self.classForCoder)
            objc_setAssociatedObject(self, GestureRecognizerAssociatedKeys.functionName, string,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return string
        }
        set {
            objc_setAssociatedObject(self, GestureRecognizerAssociatedKeys.functionName, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 闭包回调
    func addAction(_ closure: @escaping (NSGestureRecognizer) -> Void) {
        if objc_getAssociatedObject(self, GestureRecognizerAssociatedKeys.closure) == nil {
            objc_setAssociatedObject(self, GestureRecognizerAssociatedKeys.closure, closure,.OBJC_ASSOCIATION_COPY_NONATOMIC)
            self.target = self
            self.action = #selector(invokeGesture)
        }
    }
    
    @objc private func invokeGesture() {
        if let closure = objc_getAssociatedObject(self, GestureRecognizerAssociatedKeys.closure) as? ((NSGestureRecognizer) -> Void) {
            closure(self)
        }
    }
}

public extension NSClickGestureRecognizer {
    // 闭包回调
    @objc override func addAction(_ closure: @escaping (NSClickGestureRecognizer) -> Void) {
        if objc_getAssociatedObject(self, GestureRecognizerAssociatedKeys.clickGestureClosure) == nil {
            objc_setAssociatedObject(self, GestureRecognizerAssociatedKeys.clickGestureClosure, closure,.OBJC_ASSOCIATION_COPY_NONATOMIC)
            self.target = self
            self.action = #selector(invokeClickGesture)
        }
    }
    
    @objc private func invokeClickGesture() {
        let closure = objc_getAssociatedObject(self, GestureRecognizerAssociatedKeys.clickGestureClosure) as? ((NSClickGestureRecognizer) -> Void)
        if closure != nil {
            closure!(self)
        }
    }
    
    func didTapLabelAttributedText(_ linkInfos: [LinkInfo],
                                      action: @escaping (_ key: String, _ value: String?) -> Void,
                                      lineFragmentPadding: CGFloat) {
            guard let textField = self.view as? NSTextField else {
                let alert = NSAlert()
                alert.messageText = "当前视图类型不支持该操作"
                alert.informativeText = "请使用NSTextField类型的视图"
                alert.addButton(withTitle: "确定")
                alert.runModal()
                return
            }
            let attributedText = NSMutableAttributedString(attributedString: textField.attributedStringValue)
            guard attributedText.length > 0 else {
                return
            }
            // 创建文本布局相关对象
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: textField.bounds.size)
            let textStorage = NSTextStorage(attributedString: attributedText)
            
            // 设置文本容器的属性
            textContainer.lineBreakMode = .byWordWrapping
            if let cell = textField.cell {
                textContainer.maximumNumberOfLines = cell.wraps ? 0 : 1
            }
            textContainer.lineFragmentPadding = lineFragmentPadding
            
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            
            // 获取点击位置
            guard let currentEvent = NSApp.currentEvent else { return }
            let locationInWindow = currentEvent.locationInWindow
            let point = textField.convert(locationInWindow, from: nil)
            
            // 修正字符索引获取方法
            var fraction: CGFloat = 0
            let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: &fraction)
            let charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
            
            if charIndex < attributedText.length {
                for linkInfo in linkInfos {
                    let key = linkInfo.key
                    if let targetRange = attributedText.string.range(of: key) {
                        let nsRange = NSRange(targetRange, in: attributedText.string)
                        
                        if NSLocationInRange(charIndex, nsRange) {
                            // 添加高亮背景色
                            attributedText.addAttribute(.backgroundColor,
                                                     value: NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0),
                                                     range: nsRange)
                            // 更新文本显示
                            textField.attributedStringValue = attributedText
                            // 延迟移除高亮效果
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                // 移除高亮效果
                                attributedText.removeAttribute(.backgroundColor, range: nsRange)
                                textField.attributedStringValue = attributedText
                                // 触发回调
                                action(key, linkInfo.value)
                            }
                            break
                        }
                    }
                }
            }
            // 清理资源
            textStorage.removeLayoutManager(layoutManager)
        }
}
