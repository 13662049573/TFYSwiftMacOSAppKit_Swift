//
//  NSControl+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/8.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSControl {

    // 通用方法，用于设置属性
    private func setAttribute(forKey attributeKey: NSAttributedString.Key, value: Any, changeText: String? = nil, options: String.CompareOptions = [.caseInsensitive,.regularExpression]) {
        let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
        let textToSearch = changeText ?? stringValue
        if let textRange = findTextRange(stringValue, forKeyword: textToSearch, options: options) {
            attributedString.addAttribute(attributeKey, value: value, range: textRange)
        }
        self.attributedStringValue = attributedString
    }
    
    // 查找文本范围的方法
    private func findTextRange(_ text: String, forKeyword keyword: String, options: String.CompareOptions) -> NSRange? {
        if let range = text.range(of: keyword, options: options) {
            let start = text.distance(from: text.startIndex, to: range.lowerBound)
            let end = text.distance(from: text.startIndex, to: range.upperBound)
            return NSRange(location: start, length: end - start)
        }
        return nil
    }

    // 通用方法，用于设置属性
    private func setAttributes(forKey attributeKey: NSAttributedString.Key, value: [Any], changeTexts: [String]? = nil, options: String.CompareOptions = [.caseInsensitive,.regularExpression]) {
        let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
        let textsToSearch = changeTexts ?? [stringValue]
        let colorsToUse = value
        for (index, markContent) in textsToSearch.enumerated() {
            var searchRange = NSRange(location: 0, length: stringValue.utf16.count)
            while true {
                if let range = stringValue.range(of: markContent, options: [.caseInsensitive,.regularExpression], range: Range(searchRange, in: stringValue)!) {
                    let start = stringValue.distance(from: stringValue.startIndex, to: range.lowerBound)
                    let end = stringValue.distance(from: stringValue.startIndex, to: range.upperBound)
                    let nsRange = NSRange(location: start, length: end - start)
                    attributedString.addAttribute(attributeKey, value: colorsToUse.indices.contains(index) ? colorsToUse[index] : colorsToUse.first!, range: nsRange)
                    searchRange = NSRange(location: nsRange.upperBound, length: stringValue.utf16.count - nsRange.upperBound)
                } else {
                    break
                }
            }
        }
        self.attributedStringValue = attributedString
    }

    // 改变字间距
    func changeSpace(with textSpace: CGFloat, changeText: String? = nil) {
        setAttribute(forKey: NSAttributedString.Key.kern, value: textSpace, changeText: changeText)
    }

    // 改变行间距
    func changeLineSpace(with textLineSpace: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = textLineSpace
        paragraphStyle.alignment = alignment
        setAttribute(forKey:.paragraphStyle, value: paragraphStyle)
    }

    // 改变字体
    func changeFonts(with textFonts: [NSFont], changeTexts: [String]? = nil) {
        setAttributes(forKey:.font, value: textFonts,changeTexts: changeTexts)
    }
    
    // 通用的改变颜色方法，可以传入单个颜色或颜色数组以及可选的文本列表
    func changeColors(with colors: [NSColor], changeTexts: [String]? = nil) {
        setAttributes(forKey:.foregroundColor, value: colors,changeTexts: changeTexts)
    }
    
    // 改变背景颜色
    func changeBackgroundColor(with bgTextColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey:.backgroundColor, value: bgTextColor, changeText: changeText)
    }

    // 改变连字属性
    func changeLigature(with textLigature: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.ligature, value: textLigature, changeText: changeText)
    }

    // 改变字距调整属性
    func changeKern(with textKern: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.kern, value: textKern, changeText: changeText)
    }

    // 改变删除线样式
    func changeStrikethroughStyle(with textStrikethroughStyle: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.strikethroughStyle, value: textStrikethroughStyle, changeText: changeText)
    }

    // 改变删除线颜色
    func changeStrikethroughColor(with textStrikethroughColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey:.strikethroughColor, value: textStrikethroughColor, changeText: changeText)
    }

    // 改变下划线样式
    func changeUnderlineStyle(with textUnderlineStyle: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.underlineStyle, value: textUnderlineStyle, changeText: changeText)
    }

    // 改变下划线颜色
    func changeUnderlineColor(with textUnderlineColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey:.underlineColor, value: textUnderlineColor, changeText: changeText)
    }

    // 改变描边颜色
    func changeStrokeColor(with textStrokeColor: NSColor, changeText: String? = nil) {
        setAttribute(forKey:.strokeColor, value: textStrokeColor, changeText: changeText)
    }

    // 改变描边宽度
    func changeStrokeWidth(with textStrokeWidth: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.strokeWidth, value: textStrokeWidth, changeText: changeText)
    }

    // 改变阴影
    func changeShadow(with textShadow: NSShadow, changeText: String? = nil) {
        setAttribute(forKey:.shadow, value: textShadow, changeText: changeText)
    }

    // 改变文本效果
    func changeTextEffect(with textEffect: String, changeText: String? = nil) {
        setAttribute(forKey:.textEffect, value: textEffect, changeText: changeText)
    }

    // 改变附件
    func changeAttachment(with textAttachment: NSTextAttachment, changeText: String? = nil) {
        setAttribute(forKey:.attachment, value: textAttachment, changeText: changeText)
    }

    // 改变链接
    func changeLink(with textLink: String, changeText: String? = nil) {
        setAttribute(forKey:.link, value: textLink, changeText: changeText)
    }

    // 改变基线偏移
    func changeBaselineOffset(with textBaselineOffset: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.baselineOffset, value: textBaselineOffset, changeText: changeText)
    }

    // 改变倾斜度
    func changeObliqueness(with textObliqueness: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.obliqueness, value: textObliqueness, changeText: changeText)
    }

    // 改变扩展属性
    func changeExpansions(with textExpansion: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.expansion, value: textExpansion, changeText: changeText)
    }

    // 改变书写方向
    func changeWritingDirection(with textWritingDirection: [NSWritingDirection], changeText: String? = nil) {
        setAttribute(forKey:.writingDirection, value: textWritingDirection, changeText: changeText)
    }

    // 改变垂直字形格式
    func changeVerticalGlyphForm(with textVerticalGlyphForm: NSNumber, changeText: String? = nil) {
        setAttribute(forKey:.verticalGlyphForm, value: textVerticalGlyphForm, changeText: changeText)
    }

    // 改变 CT 字距调整
    func changeCTKern(with textCTKern: NSNumber) {
        let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: textCTKern, range: NSRange(0..<stringValue.count))
        self.attributedStringValue = attributedString
    }

    // 改变文本并添加图片
    func changeText(text: String, frontImages: [NSImage], imageSpan: CGFloat) {
        let textAttrStr = NSMutableAttributedString()
        for img in frontImages {
            let attach = NSTextAttachment()
            attach.image = img
            let imgH = font!.pointSize
            let imgW = (img.size.width / img.size.height) * imgH
            let textPaddingTop = (font!.capHeight - font!.pointSize) / 2
            attach.bounds = CGRect(x: 0, y: -textPaddingTop, width: imgW, height: imgH)
            let imgStr = NSAttributedString(attachment: attach)
            textAttrStr.append(imgStr)
            textAttrStr.append(NSAttributedString(string: " "))
        }
        textAttrStr.append(NSAttributedString(string: text))
        if imageSpan != 0 {
            textAttrStr.addAttribute(NSAttributedString.Key.kern, value: imageSpan, range: NSRange(0..<frontImages.count * 2))
        }
        self.attributedStringValue = textAttrStr
    }
}
