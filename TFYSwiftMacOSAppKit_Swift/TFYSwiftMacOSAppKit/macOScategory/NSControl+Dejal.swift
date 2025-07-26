//
//  NSControl+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/8.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSControl {
    
    // MARK: - 私有辅助方法
    
    /// 为文本设置单个属性
    /// - Parameters:
    ///   - attributeKey: 属性键
    ///   - value: 属性值
    ///   - changeText: 要修改的文本，nil则修改全部
    ///   - options: 文本匹配选项
    private func setAttribute(forKey attributeKey: NSAttributedString.Key,
                            value: Any,
                            changeText: String? = nil,
                            options: String.CompareOptions = [.caseInsensitive, .regularExpression]) {
        let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
        let textToSearch = changeText ?? stringValue
        if let textRange = findTextRange(stringValue, forKeyword: textToSearch, options: options) {
            attributedString.addAttribute(attributeKey, value: value, range: textRange)
        }
        self.attributedStringValue = attributedString
    }
    
    /// 查找文本范围
    /// - Parameters:
    ///   - text: 源文本
    ///   - keyword: 要查找的关键词
    ///   - options: 查找选项
    /// - Returns: 文本范围
    private func findTextRange(_ text: String,
                             forKeyword keyword: String,
                             options: String.CompareOptions) -> NSRange? {
        if let range = text.range(of: keyword, options: options) {
            let start = text.distance(from: text.startIndex, to: range.lowerBound)
            let end = text.distance(from: text.startIndex, to: range.upperBound)
            return NSRange(location: start, length: end - start)
        }
        return nil
    }
    
    /// 为多段文本设置属性
    /// - Parameters:
    ///   - attributeKey: 属性键
    ///   - value: 属性值数组
    ///   - changeTexts: 要修改的文本数组
    ///   - options: 文本匹配选项
    private func setAttributes(forKey attributeKey: NSAttributedString.Key,
                             value: [Any],
                             changeTexts: [String]? = nil,
                             options: String.CompareOptions = [.caseInsensitive, .regularExpression]) {
        let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
        let textsToSearch = changeTexts ?? [stringValue]
        let valuesToUse = value
        
        for (index, markContent) in textsToSearch.enumerated() {
            var searchRange = NSRange(location: 0, length: stringValue.utf16.count)
            
            while true {
                guard let range = stringValue.range(of: markContent,
                                                  options: options,
                                                  range: Range(searchRange, in: stringValue)!) else { break }
                
                let start = stringValue.distance(from: stringValue.startIndex, to: range.lowerBound)
                let end = stringValue.distance(from: stringValue.startIndex, to: range.upperBound)
                let nsRange = NSRange(location: start, length: end - start)
                
                let value = valuesToUse.indices.contains(index) ? valuesToUse[index] : valuesToUse.first!
                attributedString.addAttribute(attributeKey, value: value, range: nsRange)
                
                searchRange = NSRange(location: nsRange.upperBound,
                                    length: stringValue.utf16.count - nsRange.upperBound)
            }
        }
        self.attributedStringValue = attributedString
    }
    
    // MARK: - 文本样式修改方法
    
    /// 修改字间距
    /// - Parameters:
    ///   - textSpace: 间距值
    ///   - changeText: 要修改的文本，nil则修改全部
    func changeSpace(with textSpace: CGFloat, changeText: String? = nil) {
        setAttribute(forKey: .kern, value: textSpace, changeText: changeText)
    }
    
    /// 修改行间距
    /// - Parameter textLineSpace: 行间距值
    func changeLineSpace(with textLineSpace: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = textLineSpace
        paragraphStyle.alignment = alignment
        setAttribute(forKey: .paragraphStyle, value: paragraphStyle)
    }
    
    /// 修改字体
    /// - Parameters:
    ///   - textFonts: 字体数组
    ///   - changeTexts: 要修改的文本数组
    func changeFonts(with textFonts: [NSFont], changeTexts: [String]? = nil) {
        setAttributes(forKey: .font, value: textFonts, changeTexts: changeTexts)
    }
    
    /// 修改文本颜色
    /// - Parameters:
    ///   - colors: 颜色数组
    ///   - changeTexts: 要修改的文本数组
    func changeColors(with colors: [NSColor], changeTexts: [String]? = nil) {
        setAttributes(forKey: .foregroundColor, value: colors, changeTexts: changeTexts)
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
    
    /// 修改字距调整
    func changeKern(with textKern: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .kern, value: textKern, changeText: changeText)
    }
    
    /// 修改删除线样式
    func changeStrikethroughStyle(with textStrikethroughStyle: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .strikethroughStyle, value: textStrikethroughStyle, changeText: changeText)
    }
    
    /// 修改删除线颜色
    func changeStrikethroughColor(with textStrikethroughColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey: .strikethroughColor, value: textStrikethroughColor, changeText: changeText)
    }
    
    /// 修改下划线样式
    func changeUnderlineStyle(with textUnderlineStyle: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .underlineStyle, value: textUnderlineStyle, changeText: changeText)
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
    
    /// 修改基线偏移
    func changeBaselineOffset(with textBaselineOffset: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .baselineOffset, value: textBaselineOffset, changeText: changeText)
    }
    
    /// 修改倾斜度
    func changeObliqueness(with textObliqueness: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .obliqueness, value: textObliqueness, changeText: changeText)
    }
    
    /// 修改文本扩展
    func changeExpansions(with textExpansion: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .expansion, value: textExpansion, changeText: changeText)
    }
    
    /// 修改书写方向
    func changeWritingDirection(with textWritingDirection: [NSWritingDirection], changeText: String? = nil) {
        setAttribute(forKey: .writingDirection, value: textWritingDirection, changeText: changeText)
    }
    
    /// 修改垂直字形
    func changeVerticalGlyphForm(with textVerticalGlyphForm: NSNumber, changeText: String? = nil) {
        setAttribute(forKey: .verticalGlyphForm, value: textVerticalGlyphForm, changeText: changeText)
    }
    
    /// 修改CoreText字距
    func changeCTKern(with textCTKern: NSNumber) {
        let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
        attributedString.addAttribute(.kern, value: textCTKern, range: NSRange(0..<stringValue.count))
        self.attributedStringValue = attributedString
    }
    
    /// 修改文本并添加前置图片
    /// - Parameters:
    ///   - text: 要显示的文本
    ///   - frontImages: 前置图片数组
    ///   - imageSpan: 图片间距
    func changeText(text: String, frontImages: [NSImage], imageSpan: CGFloat) {
        let textAttrStr = NSMutableAttributedString()
        
        // 添加图片
        for img in frontImages {
            let attach = NSTextAttachment()
            attach.image = img
            
            // 计算图片尺寸
            let imgH = font!.pointSize
            let imgW = (img.size.width / img.size.height) * imgH
            let textPaddingTop = (font!.capHeight - font!.pointSize) / 2
            
            // 设置图片位置和大小
            attach.bounds = CGRect(x: 0, y: -textPaddingTop, width: imgW, height: imgH)
            
            // 添加图片和空格
            textAttrStr.append(NSAttributedString(attachment: attach))
            textAttrStr.append(NSAttributedString(string: " "))
        }
        
        // 添加文本
        textAttrStr.append(NSAttributedString(string: text))
        
        // 设置图片间距
        if imageSpan != 0 {
            textAttrStr.addAttribute(.kern,
                                   value: imageSpan,
                                   range: NSRange(0..<frontImages.count * 2))
        }
        
        self.attributedStringValue = textAttrStr
    }
}
