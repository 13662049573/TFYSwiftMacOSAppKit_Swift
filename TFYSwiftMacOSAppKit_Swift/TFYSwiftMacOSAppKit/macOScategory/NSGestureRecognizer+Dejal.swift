//
//  NSGestureRecognizer+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

@objc public extension NSGestureRecognizer {
    private struct AssociateKeys {
        static var funcName:UnsafeRawPointer = UnsafeRawPointer(bitPattern: "funcName".hashValue)!
        static var closure:UnsafeRawPointer = UnsafeRawPointer(bitPattern: "closure".hashValue)!
    }
    
    /// 方法名称(用于自定义)
    var funcName: String {
        get {
            if let obj = objc_getAssociatedObject(self, AssociateKeys.funcName) as? String {
                return obj
            }
            
            let string = String(describing: self.classForCoder)
            objc_setAssociatedObject(self, AssociateKeys.funcName, string,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return string
        }
        set {
            objc_setAssociatedObject(self, AssociateKeys.funcName, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 闭包回调
    func addAction(_ closure: @escaping (NSGestureRecognizer) -> Void) {
        objc_setAssociatedObject(self, AssociateKeys.closure, closure,.OBJC_ASSOCIATION_COPY_NONATOMIC)
        target = self
        action = #selector(p_invoke)
    }
    
    @objc private func p_invoke() {
        if let closure = objc_getAssociatedObject(self, AssociateKeys.closure) as? ((NSGestureRecognizer) -> Void) {
            closure(self)
        }
    }
}

public extension NSClickGestureRecognizer {
    
    private struct AssociateKeys {
        static var closure:UnsafeRawPointer = UnsafeRawPointer(bitPattern: "NSClickGestureRecognizer+closure".hashValue)!
    }
    
    /// 闭包回调
    @objc override func addAction(_ closure: @escaping (NSClickGestureRecognizer) -> Void) {
        objc_setAssociatedObject(self, AssociateKeys.closure, closure,.OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.action = #selector(p_invokeClick)
    }
    
    @objc private func p_invokeClick() {
        if let closure = objc_getAssociatedObject(self, AssociateKeys.closure) as? ((NSGestureRecognizer) -> Void) {
            closure(self)
        }
    }
    
    /// NSTextField 富文本点击（类似 iOS 中 UILabel 的效果）
    func didTapAttributedText(linkDic: [String: String], action: @escaping (String, String?) -> Void) {
        // 获取手势识别器所关联的视图，如果不是 NSTextField 则直接返回
       guard let textField = self.view as? NSTextField else { return }
        // 获取富文本内容，这里先判断 textField 是否存在，然后再获取其 attributedStringValue
       let attributedText = textField.attributedStringValue
        // 创建布局管理器、文本容器和文本存储对象
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // 配置布局管理器和文本存储对象
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // 配置文本容器
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = textField.lineBreakMode
        textContainer.maximumNumberOfLines = textField.maximumNumberOfLines
        
        let textFieldSize = textField.bounds.size
        textContainer.size = textFieldSize
        
        // 获取手势发生的位置在文本字段中的坐标
        let locationOfTouchInTextField = self.location(in: textField)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (textFieldSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (textFieldSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInTextField.x - textContainerOffset.x,
                                                     y: locationOfTouchInTextField.y - textContainerOffset.y)
        
        // 获取点击位置对应的字符索引
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)
        
        // 遍历字典，检查点击位置是否在指定的富文本范围内
        linkDic.forEach { e in
            let targetRange: NSRange = (attributedText.string as NSString).range(of: e.key)
            let isContain = NSLocationInRange(indexOfCharacter, targetRange)
            if isContain {
                action(e.key, e.value)
            }
        }
    }
}
