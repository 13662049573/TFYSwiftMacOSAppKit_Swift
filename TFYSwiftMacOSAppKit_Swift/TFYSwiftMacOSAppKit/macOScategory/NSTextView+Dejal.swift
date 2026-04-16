//
//  NSTextView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/14.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

private enum TFYTextViewAssociatedKeys {
    static var clickableTexts: UInt8 = 0
    static var tapCallback: UInt8 = 0
    static var textChangeHandler: UInt8 = 0
    static var selectionChangeHandler: UInt8 = 0
    static var placeholder: UInt8 = 0
    static var observerBag: UInt8 = 0
}

private final class TFYTextViewObserverBag {
    var clickGesture: NSClickGestureRecognizer?
    var textChangeObserver: NSObjectProtocol?
    var selectionChangeObserver: NSObjectProtocol?

    deinit {
        if let textChangeObserver {
            NotificationCenter.default.removeObserver(textChangeObserver)
        }
        if let selectionChangeObserver {
            NotificationCenter.default.removeObserver(selectionChangeObserver)
        }
    }
}

private func textViewObserverBag(for textView: NSTextView) -> TFYTextViewObserverBag {
    if let bag = objc_getAssociatedObject(textView, &TFYTextViewAssociatedKeys.observerBag) as? TFYTextViewObserverBag {
        return bag
    }

    let bag = TFYTextViewObserverBag()
    objc_setAssociatedObject(textView, &TFYTextViewAssociatedKeys.observerBag, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return bag
}

private func tfyTextViewMatchingRanges(of searchText: String, in text: String) -> [NSRange] {
    guard !searchText.isEmpty, !text.isEmpty else { return [] }
    
    var ranges: [NSRange] = []
    var searchStartIndex = text.startIndex
    
    while searchStartIndex < text.endIndex,
          let range = text.range(of: searchText, range: searchStartIndex..<text.endIndex) {
        let nsRange = NSRange(range, in: text)
        guard nsRange.length > 0 else {
            searchStartIndex = text.index(after: range.lowerBound)
            continue
        }
        
        ranges.append(nsRange)
        
        if range.upperBound >= text.endIndex {
            break
        }
        searchStartIndex = range.upperBound
    }
    
    return ranges
}

public extension NSTextView {
    private func mergeTypingAttributes(_ attributes: [NSAttributedString.Key: Any]) {
        var mergedAttributes = typingAttributes
        for (key, value) in attributes {
            mergedAttributes[key] = value
        }
        typingAttributes = mergedAttributes
    }

    private func updateTypingParagraphStyle(_ updates: (NSMutableParagraphStyle) -> Void) {
        let existingStyle = (typingAttributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
        let paragraphStyle = existingStyle ?? NSMutableParagraphStyle()
        if existingStyle == nil {
            paragraphStyle.alignment = alignment
        }
        updates(paragraphStyle)
        mergeTypingAttributes([.paragraphStyle: paragraphStyle])
    }

    var clickableTexts: [String: Any] {
        get {
            (objc_getAssociatedObject(self, &TFYTextViewAssociatedKeys.clickableTexts) as? [String: Any]) ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &TFYTextViewAssociatedKeys.clickableTexts, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var tapCallback: ((String, Any, Int) -> Void)? {
        get {
            objc_getAssociatedObject(self, &TFYTextViewAssociatedKeys.tapCallback) as? ((String, Any, Int) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &TFYTextViewAssociatedKeys.tapCallback, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    var textChangeHandler: ((String) -> Void)? {
        get {
            objc_getAssociatedObject(self, &TFYTextViewAssociatedKeys.textChangeHandler) as? ((String) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &TFYTextViewAssociatedKeys.textChangeHandler, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    var selectionChangeHandler: ((NSRange) -> Void)? {
        get {
            objc_getAssociatedObject(self, &TFYTextViewAssociatedKeys.selectionChangeHandler) as? ((NSRange) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &TFYTextViewAssociatedKeys.selectionChangeHandler, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    func setupClickDetection() {
        let bag = textViewObserverBag(for: self)
        if let clickGesture = bag.clickGesture {
            removeGestureRecognizer(clickGesture)
        }

        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(handleTextClick(_:)))
        addGestureRecognizer(tapGesture)
        bag.clickGesture = tapGesture
    }

    func setClickableTexts(_ texts: [String: Any], handler: @escaping (String, Any, Int) -> Void) {
        clickableTexts = texts
        tapCallback = handler
        setupClickDetection()
    }

    func setupAutomaticLineWrapping() {
        guard let textContainer else { return }
        textContainer.widthTracksTextView = true
        textContainer.containerSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        textContainer.lineBreakMode = .byWordWrapping
    }

    @objc private func handleTextClick(_ sender: NSClickGestureRecognizer) {
        let location = sender.location(in: self)
        guard let layoutManager, let textContainer else { return }
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if characterIndex < textStorage?.length ?? 0 {
            for (currentIndex, key) in clickableTexts.keys.sorted().enumerated() {
                guard let value = clickableTexts[key] else { continue }
                for range in tfyTextViewMatchingRanges(of: key, in: string) {
                    if NSLocationInRange(characterIndex, range) {
                        tapCallback?(key, value, currentIndex)
                        return
                    }
                }
            }
        }
    }

    func setTextChangeHandler(_ handler: @escaping (String) -> Void) {
        textChangeHandler = handler
        let bag = textViewObserverBag(for: self)
        if let textChangeObserver = bag.textChangeObserver {
            NotificationCenter.default.removeObserver(textChangeObserver)
        }
        bag.textChangeObserver = NotificationCenter.default.addObserver(
            forName: NSText.didChangeNotification,
            object: self,
            queue: .main
        ) { [weak self] _ in
            self?.handleTextDidChange()
        }
    }

    @objc private func handleTextDidChange() {
        textChangeHandler?(string)
    }

    func setSelectionChangeHandler(_ handler: @escaping (NSRange) -> Void) {
        selectionChangeHandler = handler
        let bag = textViewObserverBag(for: self)
        if let selectionChangeObserver = bag.selectionChangeObserver {
            NotificationCenter.default.removeObserver(selectionChangeObserver)
        }
        bag.selectionChangeObserver = NotificationCenter.default.addObserver(
            forName: NSTextView.didChangeSelectionNotification,
            object: self,
            queue: .main
        ) { [weak self] _ in
            self?.handleSelectionDidChange()
        }
    }

    @objc private func handleSelectionDidChange() {
        selectionChangeHandler?(selectedRange())
    }

    func setStyle(backgroundColor: NSColor? = nil, textColor: NSColor? = nil, font: NSFont? = nil) {
        if let backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let textColor {
            self.textColor = textColor
        }
        if let font {
            self.font = font
        }
    }

    func setReadOnly(_ readOnly: Bool) {
        isEditable = !readOnly
        isSelectable = !readOnly
        if readOnly {
            backgroundColor = NSColor.controlBackgroundColor
        }
    }

    func setWraps(_ wraps: Bool) {
        textContainer?.widthTracksTextView = wraps
        if wraps {
            textContainer?.containerSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
            textContainer?.lineBreakMode = .byWordWrapping
        }
    }

    func setLineSpacing(_ lineSpacing: CGFloat) {
        updateTypingParagraphStyle { paragraphStyle in
            paragraphStyle.lineSpacing = lineSpacing
        }
    }

    func setCharacterSpacing(_ characterSpacing: CGFloat) {
        mergeTypingAttributes([.kern: characterSpacing])
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        updateTypingParagraphStyle { paragraphStyle in
            paragraphStyle.alignment = alignment
        }
    }

    func setFont(_ font: NSFont) {
        self.font = font
        mergeTypingAttributes([.font: font])
    }

    func setTextColor(_ color: NSColor) {
        textColor = color
        mergeTypingAttributes([.foregroundColor: color])
    }

    func setBorder(_ borderColor: NSColor) {
        wantsLayer = true
        layer?.borderColor = borderColor.cgColor
        layer?.borderWidth = 1.0
    }

    var cursorPosition: Int {
        selectedRange().location
    }

    func setCursorPosition(_ position: Int) {
        let safePosition = max(0, min(position, string.count))
        setSelectedRange(NSRange(location: safePosition, length: 0))
    }

    var selectedText: String {
        guard let range = Range(selectedRange(), in: string) else { return "" }
        return String(string[range])
    }

    func selectAllText() {
        setSelectedRange(NSRange(location: 0, length: string.count))
    }

    func deselectText() {
        setSelectedRange(NSRange(location: selectedRange().location, length: 0))
    }

    var textLength: Int {
        string.count
    }

    var isEmpty: Bool {
        string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func clearText() {
        string = ""
    }

    func insertText(_ text: String) {
        let range = selectedRange()
        let attributedString = NSAttributedString(string: text)
        textStorage?.insert(attributedString, at: range.location)
        setSelectedRange(NSRange(location: range.location + text.count, length: 0))
    }

    func replaceSelectedText(_ text: String) {
        let range = selectedRange()
        let attributedString = NSAttributedString(string: text)
        textStorage?.replaceCharacters(in: range, with: attributedString)
        setSelectedRange(NSRange(location: range.location, length: text.count))
    }

    func deleteSelectedText() {
        let range = selectedRange()
        textStorage?.deleteCharacters(in: range)
        setSelectedRange(NSRange(location: range.location, length: 0))
    }

    func copySelectedText() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(selectedText, forType: .string)
    }

    func cutSelectedText() {
        copySelectedText()
        deleteSelectedText()
    }

    func pasteText() {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string) {
            insertText(text)
        }
    }

    func undo() {
        undoManager?.undo()
    }

    func redo() {
        undoManager?.redo()
    }

    func findText(_ searchText: String, options: NSString.CompareOptions = []) -> NSRange {
        (string as NSString).range(of: searchText, options: options)
    }

    func replaceText(_ searchText: String, with replaceText: String, options: NSString.CompareOptions = []) -> Bool {
        let range = findText(searchText, options: options)
        if range.location != NSNotFound {
            let attributedString = NSAttributedString(string: replaceText)
            textStorage?.replaceCharacters(in: range, with: attributedString)
            return true
        }
        return false
    }

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

    func character(at index: Int) -> Character? {
        guard index >= 0 && index < string.count else { return nil }
        return string[string.index(string.startIndex, offsetBy: index)]
    }

    func word(at index: Int) -> String? {
        guard index >= 0 && index < string.count else { return nil }
        let nsString = string as NSString
        let range = nsString.rangeOfCharacter(from: .whitespaces, options: .backwards, range: NSRange(location: 0, length: index))
        let startIndex = range.location == NSNotFound ? 0 : range.location + 1
        let endRange = nsString.rangeOfCharacter(from: .whitespaces, options: [], range: NSRange(location: index, length: string.count - index))
        let endIndex = endRange.location == NSNotFound ? string.count : endRange.location
        return nsString.substring(with: NSRange(location: startIndex, length: endIndex - startIndex))
    }

    func line(at index: Int) -> String? {
        guard index >= 0 && index < string.count else { return nil }
        let nsString = string as NSString
        let lineRange = nsString.lineRange(for: NSRange(location: index, length: 0))
        return nsString.substring(with: lineRange)
    }

    func scrollToCharacter(_ index: Int) {
        guard index >= 0 && index < string.count else { return }
        guard let layoutManager, let textContainer else { return }
        let glyphIndex = layoutManager.glyphIndexForCharacter(at: index)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
        scrollToVisible(glyphRect)
    }

    func scrollToTop() {
        scrollToCharacter(0)
    }

    func scrollToBottom() {
        guard !string.isEmpty else { return }
        scrollToCharacter(string.count - 1)
    }

    var visibleTextRange: NSRange {
        guard let layoutManager, let textContainer else { return NSRange() }
        let glyphRange = layoutManager.glyphRange(forBoundingRect: bounds, in: textContainer)
        return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
    }

    func saveToFile(_ url: URL) throws {
        try string.write(to: url, atomically: true, encoding: .utf8)
    }

    func loadFromFile(_ url: URL) throws {
        string = try String(contentsOf: url, encoding: .utf8)
    }

    var textStatistics: (characters: Int, words: Int, lines: Int, paragraphs: Int) {
        let characters = string.count
        let words = string.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let lines = string.components(separatedBy: .newlines).count
        let paragraphs = string.components(separatedBy: "\n\n").count
        return (characters, words, lines, paragraphs)
    }

    func setFocus() {
        window?.makeFirstResponder(self)
    }

    var hasFocus: Bool {
        window?.firstResponder == self
    }

    func setPlaceholder(_ placeholder: String) {
        objc_setAssociatedObject(self, &TFYTextViewAssociatedKeys.placeholder, placeholder, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        needsDisplay = true
    }

    var placeholder: String? {
        objc_getAssociatedObject(self, &TFYTextViewAssociatedKeys.placeholder) as? String
    }

    func setMinHeight(_ minHeight: CGFloat) {
        minSize = NSSize(width: minSize.width, height: minHeight)
    }

    func setMaxHeight(_ maxHeight: CGFloat) {
        maxSize = NSSize(width: maxSize.width, height: maxHeight)
    }

    /// 追加纯文本
    /// - Parameter text: 追加的内容
    func appendText(_ text: String) {
        setSelectedRange(NSRange(location: textLength, length: 0))
        insertText(text)
    }

    /// 追加一行文本
    /// - Parameter text: 追加的文本
    func appendLine(_ text: String) {
        appendText((string.isEmpty ? "" : "\n") + text)
    }

    /// 获取所有匹配文本范围
    /// - Parameters:
    ///   - searchText: 查找文本
    ///   - options: 查找选项
    /// - Returns: 匹配范围数组
    func ranges(of searchText: String, options: NSString.CompareOptions = []) -> [NSRange] {
        let content = string as NSString
        var ranges: [NSRange] = []
        var searchRange = NSRange(location: 0, length: content.length)
        
        while searchRange.location < content.length {
            let foundRange = content.range(of: searchText, options: options, range: searchRange)
            guard foundRange.location != NSNotFound, foundRange.length > 0 else { break }
            ranges.append(foundRange)
            let nextLocation = foundRange.location + foundRange.length
            searchRange = NSRange(location: nextLocation, length: content.length - nextLocation)
        }
        
        return ranges
    }
}
