//
//  NSControl+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/8.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

private enum TFYButtonAssociatedKeys {
    static var actionHandler: UInt8 = 0
}

@MainActor public extension NSControl {
    
    // MARK: - 私有辅助方法
    
    private var tfyDefaultMatchOptions: String.CompareOptions {
        [.caseInsensitive, .regularExpression]
    }
    
    private var tfyBaseAttributedString: NSAttributedString {
        let current = attributedStringValue
        if current.length > 0 || stringValue.isEmpty {
            return current
        }
        return NSAttributedString(string: stringValue)
    }
    
    private var tfyDefaultFont: NSFont {
        font ?? .systemFont(ofSize: NSFont.systemFontSize)
    }
    
    private func makeMutableAttributedString() -> NSMutableAttributedString {
        NSMutableAttributedString(attributedString: tfyBaseAttributedString)
    }
    
    private func fullRange(in attributedString: NSAttributedString) -> NSRange {
        NSRange(location: 0, length: attributedString.length)
    }
    
    private func matchingRanges(
        in attributedString: NSAttributedString,
        changeText: String?,
        options: String.CompareOptions
    ) -> [NSRange] {
        let content = attributedString.string
        guard !content.isEmpty else { return [] }
        
        guard let changeText, !changeText.isEmpty else {
            return [fullRange(in: attributedString)]
        }
        
        var result: [NSRange] = []
        var searchStartIndex = content.startIndex
        
        while searchStartIndex < content.endIndex,
              let range = content.range(
                of: changeText,
                options: options,
                range: searchStartIndex..<content.endIndex
              ) {
            let nsRange = NSRange(range, in: content)
            guard nsRange.length > 0 else {
                searchStartIndex = content.index(after: range.lowerBound)
                continue
            }
            
            result.append(nsRange)
            
            if range.upperBound >= content.endIndex {
                break
            }
            searchStartIndex = range.upperBound
        }
        
        return result
    }
    
    private func updateAttributedString(_ updates: (NSMutableAttributedString) -> Void) {
        let attributedString = makeMutableAttributedString()
        updates(attributedString)
        self.attributedStringValue = attributedString
    }
    
    private func setAttribute(
        forKey attributeKey: NSAttributedString.Key,
        value: Any,
        changeText: String? = nil,
        options: String.CompareOptions? = nil
    ) {
        setAttributes([attributeKey: value], changeText: changeText, options: options ?? tfyDefaultMatchOptions)
    }
    
    private func setAttributes(
        forKey attributeKey: NSAttributedString.Key,
        values: [Any],
        changeTexts: [String]? = nil,
        options: String.CompareOptions? = nil
    ) {
        guard !values.isEmpty else { return }
        
        let searchOptions = options ?? tfyDefaultMatchOptions
        updateAttributedString { attributedString in
            if let changeTexts, !changeTexts.isEmpty {
                for (index, text) in changeTexts.enumerated() {
                    let attributeValue = values[values.indices.contains(index) ? index : 0]
                    let ranges = matchingRanges(
                        in: attributedString,
                        changeText: text,
                        options: searchOptions
                    )
                    for range in ranges {
                        attributedString.addAttribute(attributeKey, value: attributeValue, range: range)
                    }
                }
            } else {
                let range = fullRange(in: attributedString)
                guard range.length > 0 else { return }
                attributedString.addAttribute(attributeKey, value: values[0], range: range)
            }
        }
    }
    
    private func updateParagraphStyle(
        changeText: String? = nil,
        options: String.CompareOptions? = nil,
        updates: (NSMutableParagraphStyle) -> Void
    ) {
        let searchOptions = options ?? tfyDefaultMatchOptions
        updateAttributedString { attributedString in
            let ranges = matchingRanges(in: attributedString, changeText: changeText, options: searchOptions)
            for range in ranges where range.length > 0 {
                let existingStyle = attributedString.attribute(.paragraphStyle, at: range.location, effectiveRange: nil) as? NSParagraphStyle
                let style = (existingStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
                if existingStyle == nil {
                    style.alignment = self.alignment
                }
                updates(style)
                attributedString.addAttribute(.paragraphStyle, value: style, range: range)
            }
        }
    }
    
    private func makeSpacerAttributedString(spacing: CGFloat, font: NSFont) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        if spacing != 0 {
            attributes[.kern] = spacing
        }
        return NSAttributedString(string: " ", attributes: attributes)
    }
    
    private func makeInlineImageAttachment(image: NSImage, font: NSFont) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        
        let imageHeight = max(font.pointSize, 1)
        let imageWidth: CGFloat
        if image.size.height > 0 {
            imageWidth = max((image.size.width / image.size.height) * imageHeight, 1)
        } else {
            imageWidth = imageHeight
        }
        
        let yOffset = (font.capHeight - imageHeight) / 2
        attachment.bounds = CGRect(x: 0, y: yOffset, width: imageWidth, height: imageHeight)
        
        return NSAttributedString(attachment: attachment)
    }
    
    private func appendInlineImages(
        _ images: [NSImage],
        to attributedString: NSMutableAttributedString,
        font: NSFont,
        spacing: CGFloat,
        includeTrailingSpacer: Bool
    ) {
        guard !images.isEmpty else { return }
        
        for (index, image) in images.enumerated() {
            attributedString.append(makeInlineImageAttachment(image: image, font: font))
            let shouldAddSpacer = index < images.count - 1 || includeTrailingSpacer
            if shouldAddSpacer {
                attributedString.append(makeSpacerAttributedString(spacing: spacing, font: font))
            }
        }
    }
    
    // MARK: - 文本样式修改方法
    
    /// 修改字间距
    /// - Parameters:
    ///   - textSpace: 间距值
    ///   - changeText: 要修改的文本，nil 则修改全部
    func changeSpace(with textSpace: CGFloat, changeText: String? = nil) {
        setAttribute(forKey: .kern, value: textSpace, changeText: changeText)
    }
    
    /// 修改行间距
    /// - Parameters:
    ///   - textLineSpace: 行间距值
    ///   - changeText: 要修改的文本，nil 则修改全部
    func changeLineSpace(with textLineSpace: CGFloat, changeText: String? = nil) {
        updateParagraphStyle(changeText: changeText) { style in
            style.lineSpacing = textLineSpace
        }
    }
    
    /// 修改段落间距
    /// - Parameters:
    ///   - paragraphSpacing: 段后间距
    ///   - changeText: 要修改的文本，nil 则修改全部
    func changeParagraphSpacing(with paragraphSpacing: CGFloat, changeText: String? = nil) {
        updateParagraphStyle(changeText: changeText) { style in
            style.paragraphSpacing = paragraphSpacing
        }
    }
    
    /// 修改段前间距
    /// - Parameters:
    ///   - paragraphSpacingBefore: 段前间距
    ///   - changeText: 要修改的文本，nil 则修改全部
    func changeParagraphSpacingBefore(with paragraphSpacingBefore: CGFloat, changeText: String? = nil) {
        updateParagraphStyle(changeText: changeText) { style in
            style.paragraphSpacingBefore = paragraphSpacingBefore
        }
    }
    
    /// 修改行高倍数
    /// - Parameters:
    ///   - lineHeightMultiple: 行高倍数
    ///   - changeText: 要修改的文本，nil 则修改全部
    func changeLineHeightMultiple(with lineHeightMultiple: CGFloat, changeText: String? = nil) {
        updateParagraphStyle(changeText: changeText) { style in
            style.lineHeightMultiple = lineHeightMultiple
        }
    }
    
    /// 修改文本对齐方式
    /// - Parameters:
    ///   - textAlignment: 对齐方式
    ///   - changeText: 要修改的文本，nil 则修改全部
    func changeTextAlignment(with textAlignment: NSTextAlignment, changeText: String? = nil) {
        updateParagraphStyle(changeText: changeText) { style in
            style.alignment = textAlignment
        }
    }
    
    /// 修改字体
    /// - Parameters:
    ///   - textFonts: 字体数组
    ///   - changeTexts: 要修改的文本数组
    func changeFonts(with textFonts: [NSFont], changeTexts: [String]? = nil) {
        setAttributes(forKey: .font, values: textFonts, changeTexts: changeTexts)
    }
    
    /// 修改文本颜色
    /// - Parameters:
    ///   - colors: 颜色数组
    ///   - changeTexts: 要修改的文本数组
    func changeColors(with colors: [NSColor], changeTexts: [String]? = nil) {
        setAttributes(forKey: .foregroundColor, values: colors, changeTexts: changeTexts)
    }
    
    /// 修改背景颜色
    /// - Parameters:
    ///   - bgTextColor: 背景颜色
    ///   - changeText: 要修改的文本
    func changeBackgroundColor(with bgTextColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey: .backgroundColor, value: bgTextColor, changeText: changeText)
    }
    
    // MARK: - 文本装饰效果
    
    /// 修改连字属性
    func changeLigature(with textLigature: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .ligature, value: textLigature, changeText: changeText)
    }
    
    /// 修改连字属性
    func changeLigature(enabled: Bool, changeText: String? = nil) {
        changeLigature(with: NSNumber(value: enabled ? 1 : 0), changeText: changeText)
    }
    
    /// 修改字距调整
    func changeKern(with textKern: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .kern, value: textKern, changeText: changeText)
    }
    
    /// 修改删除线样式
    func changeStrikethroughStyle(with textStrikethroughStyle: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .strikethroughStyle, value: textStrikethroughStyle, changeText: changeText)
    }
    
    /// 修改删除线样式
    func changeStrikethroughStyle(with style: NSUnderlineStyle, changeText: String? = nil) {
        changeStrikethroughStyle(with: NSNumber(value: style.rawValue), changeText: changeText)
    }
    
    /// 修改删除线颜色
    func changeStrikethroughColor(with textStrikethroughColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey: .strikethroughColor, value: textStrikethroughColor, changeText: changeText)
    }
    
    /// 修改下划线样式
    func changeUnderlineStyle(with textUnderlineStyle: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .underlineStyle, value: textUnderlineStyle, changeText: changeText)
    }
    
    /// 修改下划线样式
    func changeUnderlineStyle(with style: NSUnderlineStyle, changeText: String? = nil) {
        changeUnderlineStyle(with: NSNumber(value: style.rawValue), changeText: changeText)
    }
    
    /// 修改下划线颜色
    func changeUnderlineColor(with textUnderlineColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey: .underlineColor, value: textUnderlineColor, changeText: changeText)
    }
    
    // MARK: - 文本特效
    
    /// 修改描边颜色
    func changeStrokeColor(with textStrokeColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey: .strokeColor, value: textStrokeColor, changeText: changeText)
    }
    
    /// 修改描边宽度
    func changeStrokeWidth(with textStrokeWidth: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .strokeWidth, value: textStrokeWidth, changeText: changeText)
    }
    
    /// 修改描边宽度
    func changeStrokeWidth(with textStrokeWidth: CGFloat, changeText: String? = nil) {
        changeStrokeWidth(with: NSNumber(value: Double(textStrokeWidth)), changeText: changeText)
    }
    
    /// 修改阴影效果
    func changeShadow(with textShadow: NSShadow, changeText: String? = nil) {
        setAttribute(forKey: .shadow, value: textShadow, changeText: changeText)
    }
    
    /// 修改文本效果
    func changeTextEffect(with textEffect: String, changeText: String? = nil) {
        setAttribute(forKey: .textEffect, value: textEffect, changeText: changeText)
    }
    
    // MARK: - 高级文本属性
    
    /// 修改文本附件
    func changeAttachment(with textAttachment: NSTextAttachment, changeText: String? = nil) {
        setAttribute(forKey: .attachment, value: textAttachment, changeText: changeText)
    }
    
    /// 修改链接属性
    func changeLink(with textLink: String, changeText: String? = nil) {
        setAttribute(forKey: .link, value: textLink, changeText: changeText)
    }
    
    /// 修改链接属性
    func changeLink(with textLink: URL, changeText: String? = nil) {
        setAttribute(forKey: .link, value: textLink, changeText: changeText)
    }
    
    /// 修改基线偏移
    func changeBaselineOffset(with textBaselineOffset: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .baselineOffset, value: textBaselineOffset, changeText: changeText)
    }
    
    /// 修改基线偏移
    func changeBaselineOffset(with textBaselineOffset: CGFloat, changeText: String? = nil) {
        changeBaselineOffset(with: NSNumber(value: Double(textBaselineOffset)), changeText: changeText)
    }
    
    /// 修改倾斜度
    func changeObliqueness(with textObliqueness: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .obliqueness, value: textObliqueness, changeText: changeText)
    }
    
    /// 修改倾斜度
    func changeObliqueness(with textObliqueness: CGFloat, changeText: String? = nil) {
        changeObliqueness(with: NSNumber(value: Double(textObliqueness)), changeText: changeText)
    }
    
    /// 修改文本扩展
    func changeExpansions(with textExpansion: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .expansion, value: textExpansion, changeText: changeText)
    }
    
    /// 修改文本扩展
    func changeExpansions(with textExpansion: CGFloat, changeText: String? = nil) {
        changeExpansions(with: NSNumber(value: Double(textExpansion)), changeText: changeText)
    }
    
    /// 修改书写方向
    func changeWritingDirection(with textWritingDirection: [NSWritingDirection], changeText: String? = nil) {
        let values = textWritingDirection.map(\.rawValue)
        setAttribute(forKey: .writingDirection, value: values, changeText: changeText)
    }
    
    /// 修改书写方向
    func changeWritingDirectionValues(with textWritingDirection: [Int], changeText: String? = nil) {
        setAttribute(forKey: .writingDirection, value: textWritingDirection, changeText: changeText)
    }
    
    /// 修改垂直字形
    func changeVerticalGlyphForm(with textVerticalGlyphForm: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .verticalGlyphForm, value: textVerticalGlyphForm, changeText: changeText)
    }
    
    /// 修改垂直字形
    func changeVerticalGlyphForm(enabled: Bool, changeText: String? = nil) {
        changeVerticalGlyphForm(with: NSNumber(value: enabled ? 1 : 0), changeText: changeText)
    }
    
    /// 修改 CoreText 字距
    func changeCTKern(with textCTKern: NSNumber) {
        setAttribute(forKey: .kern, value: textCTKern)
    }
    
    /// 修改 CoreText 字距
    func changeCTKern(with textCTKern: CGFloat) {
        changeCTKern(with: NSNumber(value: Double(textCTKern)))
    }
    
    /// 移除指定文本属性
    /// - Parameters:
    ///   - keys: 要移除的属性键
    ///   - changeText: 要修改的文本，nil 则修改全部
    ///   - options: 文本匹配选项
    func removeAttributes(
        _ keys: [NSAttributedString.Key],
        changeText: String? = nil,
        options: String.CompareOptions? = nil
    ) {
        guard !keys.isEmpty else { return }
        
        let searchOptions = options ?? tfyDefaultMatchOptions
        updateAttributedString { attributedString in
            let ranges = matchingRanges(in: attributedString, changeText: changeText, options: searchOptions)
            for range in ranges where range.length > 0 {
                for key in keys {
                    attributedString.removeAttribute(key, range: range)
                }
            }
        }
    }
    
    /// 重置富文本样式，仅保留纯文本内容
    func resetTextAttributes() {
        let plainText = attributedStringValue.string.isEmpty ? stringValue : attributedStringValue.string
        attributedStringValue = NSAttributedString(string: plainText)
    }
    
    /// 修改文本并添加前置图片
    /// - Parameters:
    ///   - text: 要显示的文本
    ///   - frontImages: 前置图片数组
    ///   - imageSpan: 图片间距
    func changeText(text: String, frontImages: [NSImage], imageSpan: CGFloat) {
        setText(text, prefixImages: frontImages, imageSpan: imageSpan)
    }
    
    /// 设置文本并附加前后置图片
    /// - Parameters:
    ///   - text: 文本内容
    ///   - prefixImages: 前置图片
    ///   - suffixImages: 后置图片
    ///   - imageSpan: 图片和文本之间的间距
    ///   - textAttributes: 文本属性
    func setText(
        _ text: String,
        prefixImages: [NSImage] = [],
        suffixImages: [NSImage] = [],
        imageSpan: CGFloat = 0,
        textAttributes: [NSAttributedString.Key: Any] = [:]
    ) {
        let currentFont = (textAttributes[.font] as? NSFont) ?? tfyDefaultFont
        var resolvedAttributes = textAttributes
        resolvedAttributes[.font] = currentFont
        
        let attributedString = NSMutableAttributedString()
        appendInlineImages(
            prefixImages,
            to: attributedString,
            font: currentFont,
            spacing: imageSpan,
            includeTrailingSpacer: !text.isEmpty || !suffixImages.isEmpty
        )
        
        if !text.isEmpty {
            attributedString.append(NSAttributedString(string: text, attributes: resolvedAttributes))
        }
        
        if !suffixImages.isEmpty {
            if !text.isEmpty {
                attributedString.append(makeSpacerAttributedString(spacing: imageSpan, font: currentFont))
            }
            appendInlineImages(
                suffixImages,
                to: attributedString,
                font: currentFont,
                spacing: imageSpan,
                includeTrailingSpacer: false
            )
        }
        
        self.attributedStringValue = attributedString
    }
    
    // MARK: - 新增实用方法
    
    /// 统一设置一组文本属性
    /// - Parameters:
    ///   - attributes: 属性字典
    ///   - changeText: 要修改的文本，nil 则修改全部
    ///   - options: 文本匹配选项
    func setAttributes(
        _ attributes: [NSAttributedString.Key: Any],
        changeText: String? = nil,
        options: String.CompareOptions? = nil
    ) {
        guard !attributes.isEmpty else { return }
        
        let searchOptions = options ?? tfyDefaultMatchOptions
        updateAttributedString { attributedString in
            let ranges = matchingRanges(in: attributedString, changeText: changeText, options: searchOptions)
            for range in ranges where range.length > 0 {
                attributedString.addAttributes(attributes, range: range)
            }
        }
    }
    
    /// 设置富文本样式
    /// - Parameters:
    ///   - text: 文本内容
    ///   - font: 字体
    ///   - color: 颜色
    ///   - alignment: 对齐方式
    func setAttributedText(_ text: String, font: NSFont, color: NSColor, alignment: NSTextAlignment = .left) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        self.attributedStringValue = NSAttributedString(string: text, attributes: attributes)
    }
    
    /// 设置富文本样式
    /// - Parameters:
    ///   - text: 文本内容
    ///   - attributes: 文本属性
    func setAttributedText(_ text: String, attributes: [NSAttributedString.Key: Any]) {
        self.attributedStringValue = NSAttributedString(string: text, attributes: attributes)
    }
    
    /// 设置圆角边框
    /// - Parameters:
    ///   - cornerRadius: 圆角半径
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    func setRoundedBorder(cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: NSColor = .clear) {
        self.wantsLayer = true
        self.layer?.cornerRadius = cornerRadius
        self.layer?.borderWidth = borderWidth
        self.layer?.borderColor = borderColor.cgColor
        self.layer?.masksToBounds = cornerRadius > 0
    }
    
    /// 设置阴影效果
    /// - Parameters:
    ///   - shadowColor: 阴影颜色
    ///   - shadowOffset: 阴影偏移
    ///   - shadowRadius: 阴影半径
    ///   - shadowOpacity: 阴影透明度
    func setShadow(
        shadowColor: NSColor = .black,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowRadius: CGFloat = 4,
        shadowOpacity: Float = 0.3
    ) {
        self.wantsLayer = true
        self.layer?.masksToBounds = false
        self.layer?.shadowColor = shadowColor.cgColor
        self.layer?.shadowOffset = shadowOffset
        self.layer?.shadowRadius = shadowRadius
        self.layer?.shadowOpacity = shadowOpacity
    }
    
    /// 动画修改透明度
    /// - Parameters:
    ///   - alpha: 目标透明度
    ///   - duration: 动画时长
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    func animateAlpha(
        to alpha: CGFloat,
        duration: TimeInterval = 0.25,
        delay: TimeInterval = 0,
        completion: (@Sendable () -> Void)? = nil
    ) {
        let animations = {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                context.allowsImplicitAnimation = true
                self.animator().alphaValue = alpha
            }, completionHandler: {
                completion?()
            })
        }
        
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                animations()
            }
        } else {
            animations()
        }
    }
    
    /// 添加淡入淡出动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - delay: 延迟时间
    func addFadeAnimation(duration: TimeInterval = 0.3, delay: TimeInterval = 0) {
        animateAlpha(to: 0.0, duration: duration, delay: delay) {
            Task { @MainActor in
                self.animateAlpha(to: 1.0, duration: duration)
            }
        }
    }
    
    /// 获取当前文本的尺寸
    /// - Parameter maxSize: 最大尺寸限制
    /// - Returns: 文本尺寸
    func textSize(
        maxSize: NSSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
    ) -> NSSize {
        let rect = self.attributedStringValue.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return NSSize(width: ceil(rect.width), height: ceil(rect.height))
    }
    
    /// 当前文本去除空白后的内容
    var trimmedStringValue: String {
        stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 检查文本是否为空或只包含空白字符
    var isEmptyOrWhitespace: Bool {
        trimmedStringValue.isEmpty
    }
    
    /// 清除文本内容
    func clearText() {
        self.attributedStringValue = NSAttributedString(string: "")
    }
    
    /// 设置占位符文本
    /// - Parameters:
    ///   - placeholder: 占位符文本
    ///   - color: 占位符颜色
    func setPlaceholder(_ placeholder: String, color: NSColor = .placeholderTextColor) {
        guard let textField = self as? NSTextField else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textField.alignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: textField.font ?? .systemFont(ofSize: NSFont.systemFontSize),
            .paragraphStyle: paragraphStyle
        ]
        textField.placeholderAttributedString = NSAttributedString(string: placeholder, attributes: attributes)
    }
}

@MainActor public extension NSButton {
    /// 使用闭包处理按钮点击
    /// - Parameter action: 点击回调
    func onAction(_ action: @escaping (NSButton) -> Void) {
        target = self
        self.action = #selector(tfy_handleButtonAction(_:))
        objc_setAssociatedObject(self, &TFYButtonAssociatedKeys.actionHandler, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }

    @objc private func tfy_handleButtonAction(_ sender: NSButton) {
        let action = objc_getAssociatedObject(self, &TFYButtonAssociatedKeys.actionHandler) as? (NSButton) -> Void
        action?(sender)
    }

    /// 当前是否处于选中状态
    var isOn: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }

    /// 切换按钮状态
    func toggleState() {
        state = state == .on ? .off : .on
    }

    /// 设置带图标的按钮内容
    /// - Parameters:
    ///   - title: 标题
    ///   - image: 图标
    ///   - imagePosition: 图标位置
    func configure(
        title: String,
        image: NSImage? = nil,
        imagePosition: NSControl.ImagePosition = .imageLeading
    ) {
        self.title = title
        self.image = image
        self.imagePosition = imagePosition
    }

    /// 创建复选框按钮
    /// - Parameters:
    ///   - title: 标题
    ///   - checked: 是否选中
    /// - Returns: 创建的按钮
    static func makeCheckbox(title: String, checked: Bool = false) -> NSButton {
        let button = NSButton(checkboxWithTitle: title, target: nil, action: nil)
        button.state = checked ? .on : .off
        return button
    }
}

@MainActor public extension NSSegmentedControl {
    /// 所有分段标题
    var segmentTitles: [String] {
        (0..<segmentCount).map { label(forSegment: $0) ?? "" }
    }

    /// 批量设置标题
    /// - Parameter titles: 标题数组
    func setSegmentTitles(_ titles: [String]) {
        segmentCount = titles.count
        for (index, title) in titles.enumerated() {
            setLabel(title, forSegment: index)
        }
    }

    /// 取消全部选中状态
    func deselectAllSegments() {
        selectedSegment = -1
    }

    /// 选中下一个分段
    /// - Parameter wrapping: 是否循环
    func selectNextSegment(wrapping: Bool = true) {
        guard segmentCount > 0 else { return }
        let nextIndex = selectedSegment + 1
        if nextIndex < segmentCount {
            selectedSegment = nextIndex
        } else if wrapping {
            selectedSegment = 0
        }
    }
}

@MainActor public extension NSSearchField {
    /// 当前搜索内容去除空白后的值
    var trimmedSearchText: String {
        stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 清空搜索内容
    func clearSearch() {
        stringValue = ""
    }

    /// 设置最近搜索记录
    /// - Parameter searches: 搜索记录数组
    func setRecentSearches(_ searches: [String]) {
        recentSearches = searches
    }
}
