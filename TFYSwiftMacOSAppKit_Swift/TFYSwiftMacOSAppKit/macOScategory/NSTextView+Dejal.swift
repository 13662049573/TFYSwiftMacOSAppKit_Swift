//
//  NSTextView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/14.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

extension NSTextView {
    // 关联键结构，用于存储属性的键
    private struct AssociatedKeys {
        static let clickableTextsKey = UnsafeRawPointer(bitPattern: UInt(abs("clickableTextsKey".hashValue)))! // 可点击文本的键
        static let tapCallbackKey = UnsafeRawPointer(bitPattern: UInt(abs("tapCallbackKey".hashValue)))! // 点击回调的键
    }
    
    // 存储可点击文本及其关联数据的属性
    var clickableTexts: [String: Any] {
        get {
            (objc_getAssociatedObject(self, AssociatedKeys.clickableTextsKey) as? [String: Any]) ?? [:]
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.clickableTextsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 点击事件的回调
    var tapCallback: ((String, Any, Int) -> Void)? {
        get {
            objc_getAssociatedObject(self, AssociatedKeys.tapCallbackKey) as? ((String, Any, Int) -> Void)
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.tapCallbackKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    // 设置手势识别器以检测点击
    func setupClickDetection() {
        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(handleTextClick(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    // Setup the text view for automatic line wrapping
    private func setupAutomaticLineWrapping() {
        guard let textContainer = self.textContainer else { return }
        textContainer.widthTracksTextView = true
        textContainer.containerSize = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        self.textContainer?.lineBreakMode = .byWordWrapping
    }
    
    // 处理点击事件并调用回调
    @objc private func handleTextClick(_ sender: NSClickGestureRecognizer) {
        let location = sender.location(in: self)
        guard let layoutManager = self.layoutManager, let textContainer = self.textContainer else { return }
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if characterIndex < textStorage?.length ?? 0 {
            var currentIndex = 0
            for (key, value) in clickableTexts {
                let range = (self.string as NSString).range(of: key)
                if NSLocationInRange(characterIndex, range) {
                    tapCallback?(key, value, currentIndex) // 调用回调
                    return
                }
                currentIndex += 1
            }
        }
    }
}

extension NSTextView {
    // NSTextView 富文本点击处理
    func didTapAttributedText(linkDictionary: [String: String], action: @escaping (String?, String?, CGPoint?) -> Void) {
        let attributedText = self.attributedString()
        let layoutManager = configureLayoutManager(for: self, with: attributedText)

        // 假设 lastMouseDownEvent 是最近一次鼠标点击事件
        if let event = self.window?.currentEvent, event.type == .leftMouseDown {
            let locationOfTouchInTextContainer = calculateTouchLocation(event: event, with: layoutManager)

            if let characterIndex = findCharacterIndex(at: locationOfTouchInTextContainer, using: layoutManager),
               let (key, value) = findLink(at: characterIndex, in: linkDictionary, with: attributedText) {
                action(key, value, locationOfTouchInTextContainer)
            } else {
                action(nil, nil, nil)
            }
        }
    }

    private func configureLayoutManager(for textView: NSTextView, with attributedText: NSAttributedString) -> NSLayoutManager {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: textView.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byWordWrapping
        return layoutManager
    }

    private func calculateTouchLocation(event: NSEvent, with layoutManager: NSLayoutManager) -> CGPoint {
        let locationOfTouchInWindow = event.locationInWindow
        let locationOfTouchInTextView = self.convert(locationOfTouchInWindow, from: nil)
        let textContainer = layoutManager.textContainers.first!
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (self.bounds.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (self.bounds.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        return CGPoint(x: locationOfTouchInTextView.x - textContainerOffset.x,
                       y: locationOfTouchInTextView.y - textContainerOffset.y)
    }

    private func findCharacterIndex(at location: CGPoint, using layoutManager: NSLayoutManager) -> Int? {
        guard let textContainer = layoutManager.textContainers.first else { return nil }
        let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        return glyphIndex != NSNotFound ? layoutManager.characterIndexForGlyph(at: glyphIndex) : nil
    }

    private func findLink(at characterIndex: Int, in linkDictionary: [String: String], with attributedText: NSAttributedString) -> (String, String?)? {
        let nsString = attributedText.string as NSString
        for (key, value) in linkDictionary {
            let range = nsString.range(of: key)
            if NSLocationInRange(characterIndex, range) {
                return (key, value)
            }
        }
        return nil
    }
}
