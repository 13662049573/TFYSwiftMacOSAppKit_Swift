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
        static let textChangeHandlerKey = UnsafeRawPointer(bitPattern: UInt(abs("textChangeHandlerKey".hashValue)))! // 文本变化回调的键
        static let selectionChangeHandlerKey = UnsafeRawPointer(bitPattern: UInt(abs("selectionChangeHandlerKey".hashValue)))! // 选择变化回调的键
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
    
    // 文本变化回调
    var textChangeHandler: ((String) -> Void)? {
        get {
            objc_getAssociatedObject(self, AssociatedKeys.textChangeHandlerKey) as? ((String) -> Void)
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.textChangeHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    // 选择变化回调
    var selectionChangeHandler: ((NSRange) -> Void)? {
        get {
            objc_getAssociatedObject(self, AssociatedKeys.selectionChangeHandlerKey) as? ((NSRange) -> Void)
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.selectionChangeHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
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
    
    // MARK: - 新增实用方法
    
    /// 设置文本变化监听
    /// - Parameter handler: 文本变化回调
    func setTextChangeHandler(_ handler: @escaping (String) -> Void) {
        self.textChangeHandler = handler
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: NSText.didChangeNotification, object: self)
    }
    
    @objc private func handleTextDidChange() {
        textChangeHandler?(string)
    }
    
    /// 设置选择变化监听
    /// - Parameter handler: 选择变化回调
    func setSelectionChangeHandler(_ handler: @escaping (NSRange) -> Void) {
        self.selectionChangeHandler = handler
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectionDidChange), name: NSTextView.didChangeSelectionNotification, object: self)
    }
    
    @objc private func handleSelectionDidChange() {
        selectionChangeHandler?(selectedRange())
    }
    
    /// 设置文本视图样式
    /// - Parameters:
    ///   - backgroundColor: 背景颜色
    ///   - textColor: 文本颜色
    ///   - font: 字体
    func setStyle(backgroundColor: NSColor? = nil, textColor: NSColor? = nil, font: NSFont? = nil) {
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let textColor = textColor {
            self.textColor = textColor
        }
        if let font = font {
            self.font = font
        }
    }
    
    /// 设置文本视图为只读
    /// - Parameter readOnly: 是否只读
    func setReadOnly(_ readOnly: Bool) {
        self.isEditable = !readOnly
        self.isSelectable = !readOnly
        if readOnly {
            self.backgroundColor = NSColor.controlBackgroundColor
        }
    }
    
    /// 设置文本视图为自动换行
    /// - Parameter wraps: 是否自动换行
    func setWraps(_ wraps: Bool) {
        self.textContainer?.widthTracksTextView = wraps
        if wraps {
            self.textContainer?.containerSize = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        }
    }
    
    /// 设置文本视图的行间距
    /// - Parameter lineSpacing: 行间距
    func setLineSpacing(_ lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
        self.typingAttributes = attributes
    }
    
    /// 设置文本视图的字间距
    /// - Parameter characterSpacing: 字间距
    func setCharacterSpacing(_ characterSpacing: CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [.kern: characterSpacing]
        self.typingAttributes = attributes
    }
    
    /// 设置文本视图的对齐方式
    /// - Parameter alignment: 对齐方式
    func setAlignment(_ alignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
        self.typingAttributes = attributes
    }
    
    /// 设置文本视图的字体
    /// - Parameter font: 字体
    func setFont(_ font: NSFont) {
        self.font = font
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        self.typingAttributes = attributes
    }
    
    /// 设置文本视图的文本颜色
    /// - Parameter color: 文本颜色
    func setTextColor(_ color: NSColor) {
        self.textColor = color
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        self.typingAttributes = attributes
    }
    
    /// - Parameter borderColor: 边框颜色
    func setBorder(_ borderColor: NSColor) {
        self.wantsLayer = true
        self.layer?.borderColor = borderColor.cgColor
        self.layer?.borderWidth = 1.0
    }
    
    /// 获取当前光标位置
    var cursorPosition: Int {
        return selectedRange().location
    }
    
    /// 设置光标位置
    /// - Parameter position: 光标位置
    func setCursorPosition(_ position: Int) {
        let range = NSRange(location: position, length: 0)
        setSelectedRange(range)
    }
    
    /// 获取选中的文本
    var selectedText: String {
        let range = selectedRange()
        return (string as NSString).substring(with: range)
    }
    
    /// 选择所有文本
    func selectAllText() {
        let range = NSRange(location: 0, length: string.count)
        setSelectedRange(range)
    }
    
    /// 取消选择
    func deselectText() {
        let range = NSRange(location: selectedRange().location, length: 0)
        setSelectedRange(range)
    }
    
    /// 获取文本长度
    var textLength: Int {
        return string.count
    }
    
    /// 检查文本是否为空
    var isEmpty: Bool {
        return string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 清除文本
    func clearText() {
        self.string = ""
    }
    
    /// 在光标位置插入文本
    /// - Parameter text: 要插入的文本
    func insertText(_ text: String) {
        let range = selectedRange()
        let attributedString = NSAttributedString(string: text)
        textStorage?.insert(attributedString, at: range.location)
        setSelectedRange(NSRange(location: range.location + text.count, length: 0))
    }
    
    /// 替换选中的文本
    /// - Parameter text: 要替换的文本
    func replaceSelectedText(_ text: String) {
        let range = selectedRange()
        let attributedString = NSAttributedString(string: text)
        textStorage?.replaceCharacters(in: range, with: attributedString)
        setSelectedRange(NSRange(location: range.location, length: text.count))
    }
    
    /// 删除选中的文本
    func deleteSelectedText() {
        let range = selectedRange()
        textStorage?.deleteCharacters(in: range)
        setSelectedRange(NSRange(location: range.location, length: 0))
    }
    
    /// 复制选中的文本
    func copySelectedText() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(selectedText, forType: .string)
    }
    
    /// 剪切选中的文本
    func cutSelectedText() {
        copySelectedText()
        deleteSelectedText()
    }
    
    /// 粘贴文本
    func pasteText() {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string) {
            insertText(text)
        }
    }
    
    /// 撤销操作
    func undo() {
        undoManager?.undo()
    }
    
    /// 重做操作
    func redo() {
        undoManager?.redo()
    }
    
    /// 查找文本
    /// - Parameters:
    ///   - searchText: 要查找的文本
    ///   - options: 查找选项
    /// - Returns: 找到的范围
    func findText(_ searchText: String, options: NSString.CompareOptions = []) -> NSRange {
        return (string as NSString).range(of: searchText, options: options)
    }
    
    /// 替换文本
    /// - Parameters:
    ///   - searchText: 要查找的文本
    ///   - replaceText: 要替换的文本
    ///   - options: 查找选项
    /// - Returns: 是否找到并替换
    func replaceText(_ searchText: String, with replaceText: String, options: NSString.CompareOptions = []) -> Bool {
        let range = findText(searchText, options: options)
        if range.location != NSNotFound {
            let attributedString = NSAttributedString(string: replaceText)
            textStorage?.replaceCharacters(in: range, with: attributedString)
            return true
        }
        return false
    }
    
    /// 替换所有匹配的文本
    /// - Parameters:
    ///   - searchText: 要查找的文本
    ///   - replaceText: 要替换的文本
    ///   - options: 查找选项
    /// - Returns: 替换的次数
    func replaceAllText(_ searchText: String, with replaceText: String, options: NSString.CompareOptions = []) -> Int {
        var count = 0
        var range = findText(searchText, options: options)
        while range.location != NSNotFound {
            let attributedString = NSAttributedString(string: replaceText)
            textStorage?.replaceCharacters(in: range, with: attributedString)
            count += 1
            range = findText(searchText, options: options)
        }
        return count
    }
    
    /// 获取指定位置的字符
    /// - Parameter index: 字符索引
    /// - Returns: 字符
    func character(at index: Int) -> Character? {
        guard index >= 0 && index < string.count else { return nil }
        return string[string.index(string.startIndex, offsetBy: index)]
    }
    
    /// 获取指定位置的单词
    /// - Parameter index: 字符索引
    /// - Returns: 单词
    func word(at index: Int) -> String? {
        guard index >= 0 && index < string.count else { return nil }
        let nsString = string as NSString
        let range = nsString.rangeOfCharacter(from: .whitespaces, options: .backwards, range: NSRange(location: 0, length: index))
        let startIndex = range.location == NSNotFound ? 0 : range.location + 1
        let endRange = nsString.rangeOfCharacter(from: .whitespaces, options: [], range: NSRange(location: index, length: string.count - index))
        let endIndex = endRange.location == NSNotFound ? string.count : endRange.location
        return nsString.substring(with: NSRange(location: startIndex, length: endIndex - startIndex))
    }
    
    /// 获取指定位置的行
    /// - Parameter index: 字符索引
    /// - Returns: 行文本
    func line(at index: Int) -> String? {
        guard index >= 0 && index < string.count else { return nil }
        let nsString = string as NSString
        let lineRange = nsString.lineRange(for: NSRange(location: index, length: 0))
        return nsString.substring(with: lineRange)
    }
    
    /// 滚动到指定位置
    /// - Parameter index: 字符索引
    func scrollToCharacter(_ index: Int) {
        guard let layoutManager = layoutManager, let textContainer = textContainer else { return }
        let glyphIndex = layoutManager.glyphIndexForCharacter(at: index)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
        scrollToVisible(glyphRect)
    }
    
    /// 滚动到顶部
    func scrollToTop() {
        scrollToCharacter(0)
    }
    
    /// 滚动到底部
    func scrollToBottom() {
        scrollToCharacter(string.count - 1)
    }
    
    /// 获取可见文本范围
    var visibleTextRange: NSRange {
        guard let layoutManager = layoutManager, let textContainer = textContainer else { return NSRange() }
        let visibleRect = bounds
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
    }
    
    /// 保存文本到文件
    /// - Parameter url: 文件URL
    /// - Throws: 保存错误
    func saveToFile(_ url: URL) throws {
        try string.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// 从文件加载文本
    /// - Parameter url: 文件URL
    /// - Throws: 加载错误
    func loadFromFile(_ url: URL) throws {
        let text = try String(contentsOf: url, encoding: .utf8)
        self.string = text
    }
    
    /// 获取文本的统计信息
    var textStatistics: (characters: Int, words: Int, lines: Int, paragraphs: Int) {
        let characters = string.count
        let words = string.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let lines = string.components(separatedBy: .newlines).count
        let paragraphs = string.components(separatedBy: "\n\n").count
        return (characters, words, lines, paragraphs)
    }
    
    /// 设置文本视图的焦点
    func setFocus() {
        window?.makeFirstResponder(self)
    }
    
    /// 检查文本视图是否有焦点
    var hasFocus: Bool {
        return window?.firstResponder == self
    }
    
    /// 设置文本视图的占位符
    /// - Parameter placeholder: 占位符文本
    func setPlaceholder(_ placeholder: String) {
        // NSTextView 没有直接的占位符属性，可以通过重写绘制方法实现
        objc_setAssociatedObject(self, "placeholder", placeholder, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        needsDisplay = true
    }
    
    /// 获取占位符文本
    var placeholder: String? {
        return objc_getAssociatedObject(self, "placeholder") as? String
    }
    
    /// 设置文本视图的最小高度
    /// - Parameter minHeight: 最小高度
    func setMinHeight(_ minHeight: CGFloat) {
        self.minSize = NSSize(width: minSize.width, height: minHeight)
    }
    
    /// 设置文本视图的最大高度
    /// - Parameter maxHeight: 最大高度
    func setMaxHeight(_ maxHeight: CGFloat) {
        self.maxSize = NSSize(width: maxSize.width, height: maxHeight)
    }
    
    
}
