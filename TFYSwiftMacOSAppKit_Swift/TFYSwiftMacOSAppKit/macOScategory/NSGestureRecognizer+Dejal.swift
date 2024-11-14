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
    func didTapAttributedText(linkDictionary: [String: String], action: @escaping (String?, String?, CGPoint?, Error?) -> Void) {
        guard let textField = self.view as? NSTextField else {
            action(nil, nil, nil, NSError(domain: "CustomError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "The view is not an NSTextField"]))
            return
        }
        textField.isBordered = false
        textField.isEditable = false
        textField.drawsBackground = true
        textField.usesSingleLineMode = true
        textField.cell?.usesSingleLineMode = false
        textField.cell?.truncatesLastVisibleLine = true
        textField.cell?.isBezeled = false
        textField.cell?.isBordered = false
        
        let attributedText = textField.attributedStringValue
        let layoutManager = configureLayoutManager(with: attributedText, for: textField)
        let locationOfTouchInTextContainer = calculateTouchLocation(in: textField, with: layoutManager)

        if let characterIndex = findCharacterIndex(at: locationOfTouchInTextContainer, using: layoutManager),
           let (key, value) = findLink(at: characterIndex, in: linkDictionary, with: attributedText) {
            action(key, value, locationOfTouchInTextContainer, nil)
        } else {
            print("No link found at the location or glyph index not found.")
        }
    }

    private func configureLayoutManager(with attributedText: NSAttributedString, for textField: NSTextField) -> NSLayoutManager {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: textField.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = textField.cell!.lineBreakMode
        return layoutManager
    }

    private func calculateTouchLocation(in textField: NSTextField, with layoutManager: NSLayoutManager) -> CGPoint {
        let locationOfTouchInTextField = self.location(in: textField)
        let textContainer = layoutManager.textContainers.first!
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (textField.bounds.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (textField.bounds.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        return CGPoint(x: locationOfTouchInTextField.x - textContainerOffset.x,
                       y: locationOfTouchInTextField.y - textContainerOffset.y)
    }

    private func findCharacterIndex(at location: CGPoint, using layoutManager: NSLayoutManager) -> Int? {
        guard let textContainer = layoutManager.textContainers.first else { return nil }
        let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        return glyphIndex != NSNotFound ? layoutManager.characterIndexForGlyph(at: glyphIndex) : nil
    }

    private func findLink(at characterIndex: Int, in linkDic: [String: String], with attributedText: NSAttributedString) -> (String, String?)? {
        let nsString = attributedText.string as NSString
        for (key, value) in linkDic {
            let range = nsString.range(of: key)
            if NSLocationInRange(characterIndex, range) {
                return (key, value)
            }
        }
        return nil
    }
}
