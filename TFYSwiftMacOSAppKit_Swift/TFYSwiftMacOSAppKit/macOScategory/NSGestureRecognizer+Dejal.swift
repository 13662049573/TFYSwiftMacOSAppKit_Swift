//
//  NSGestureRecognizer+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

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
    
    // NSTextField 富文本点击（类似 iOS 中 UILabel 的效果）
    func didTapAttributedText(linkDic: [String: String], action: @escaping (String, String?, CGPoint) -> Void) {
        // 确保视图是 NSTextField 类型
        guard let textField = self.view as? NSTextField else { return }
        // 获取文本字段的富文本内容
        let attributedText = textField.attributedStringValue

        // 设置文本字段的一些属性
        textField.usesSingleLineMode = true
        textField.cell?.usesSingleLineMode = false
        textField.cell?.truncatesLastVisibleLine = true
        textField.cell?.isBezeled = false
        textField.cell?.isBordered = false

        // 创建布局管理器、文本容器和文本存储对象
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText)

        // 将文本容器添加到布局管理器中，并将布局管理器添加到文本存储对象中
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // 设置文本容器的一些属性
        textContainer.lineFragmentPadding = 5.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        // 计算富文本的自然大小，并设置文本容器的大小
        let naturalSize = attributedText.size()
        textContainer.size = CGSize(width: naturalSize.width + 5.0, height: naturalSize.height + 5.0)

        // 检查文本容器是否正确关联到布局管理器
        if !layoutManager.textContainers.contains(textContainer) {
            print("Text container not properly associated with layout manager!")
            // 可以考虑在此处添加适当的错误处理或重新关联的逻辑
        }

        // 获取触摸点在文本字段中的位置
        let locationOfTouchInTextField = self.location(in: textField)
        // 获取文本边界框
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        // 获取文本字段的边界大小
        let textFieldBoundsSize = textField.bounds.size
        // 计算文本容器的偏移量
        let textContainerOffset = CGPoint(x: (textFieldBoundsSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (textFieldBoundsSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        // 计算触摸点在文本容器中的位置
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInTextField.x - textContainerOffset.x,
                                                     y: locationOfTouchInTextField.y - textContainerOffset.y)

        // 尝试更准确地计算 glyphIndex
        var glyphIndex: Int?
        for index in 0..<layoutManager.numberOfGlyphs {
            let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: index, length: 1), in: textContainer)
            if glyphRect.contains(locationOfTouchInTextContainer) {
                glyphIndex = index
                break
            }
        }
        // 如果没有找到合适的 glyphIndex，默认为 0
        glyphIndex = glyphIndex ?? 0

        // 计算正确的字符索引
        var characterIndex = 0
        let offsetInTextContainer = locationOfTouchInTextContainer
        layoutManager.lineFragmentUsedRect(forGlyphAt: glyphIndex!, effectiveRange: nil)
        while glyphIndex! > 0 {
            glyphIndex! -= 1
            layoutManager.characterIndexForGlyph(at: glyphIndex!)
            let characterRange = layoutManager.characterRange(forGlyphRange: NSRange(location: glyphIndex!, length: 1), actualGlyphRange: nil)
            let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex!, length: 1), in: textContainer)
            if offsetInTextContainer.x >= glyphRect.origin.x && offsetInTextContainer.x < glyphRect.origin.x + glyphRect.size.width && offsetInTextContainer.y >= glyphRect.origin.y && offsetInTextContainer.y < glyphRect.origin.y + glyphRect.size.height {
                characterIndex = characterRange.location
                break
            }
        }

        // 预处理特殊字符
        let preprocessedText = preprocessSpecialCharacters(attributedText)

        // 遍历链接字典，检查触摸点是否在特定的链接范围内
        for (key, value) in linkDic {
            let targetRange = (preprocessedText.string as NSString).range(of: key)
            if characterIndex >= targetRange.location && characterIndex < targetRange.location + targetRange.length {
                action(key, value, locationOfTouchInTextField)
            }
        }
    }

    func preprocessSpecialCharacters(_ attributedText: NSAttributedString) -> NSAttributedString {
        // 如果需要，可以添加更全面的特殊字符处理逻辑
        return attributedText
    }
}
