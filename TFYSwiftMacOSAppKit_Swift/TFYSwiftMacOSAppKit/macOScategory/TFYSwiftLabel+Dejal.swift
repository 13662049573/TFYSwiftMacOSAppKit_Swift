//
//  TFYSwiftLabel+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/8.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension TFYSwiftLabel {
    
    private class LabelAttributeModel: NSObject {
        var range: NSRange?
        var str: String?
    }
    
    private struct AssociatedKeys {
        static var hasTapActionEnabled: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "hasTapActionEnabled".hashValue)!
        static var attributeStringModels: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "attributeStringModels".hashValue)!
        static var tapActionBlock: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "tapActionBlock".hashValue)!
        static var isTapEffectEnabled: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "isTapEffectEnabled".hashValue)!
        static var effectDictionary: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "effectDictionary".hashValue)!
    }
    
    // 模拟存储属性 hasTapActionEnabled
    private var hasTapActionEnabled: Bool? {
        get {
            let value = objc_getAssociatedObject(self, AssociatedKeys.hasTapActionEnabled) as? Bool
            return value
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.hasTapActionEnabled, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 模拟存储属性 attributeStringModels
    private var attributeStringModels: [LabelAttributeModel]? {
        get {
            let value = objc_getAssociatedObject(self, AssociatedKeys.attributeStringModels) as? [LabelAttributeModel]
            return value
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.attributeStringModels, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 模拟存储属性 tapActionBlock
    private var tapActionBlock: ((_ str: String, _ range: NSRange, _ index: Int) -> Void)? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.tapActionBlock) as? ((String, NSRange, Int) -> Void)
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.tapActionBlock, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 模拟存储属性 isTapEffectEnabled
    private var isTapEffectEnabled: Bool {
        get {
            if let value = objc_getAssociatedObject(self, AssociatedKeys.isTapEffectEnabled) as? Bool {
                return value
            }
            return true
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.isTapEffectEnabled, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 模拟存储属性 effectDictionary
    private var effectDictionary: [String : NSAttributedString]? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.effectDictionary) as? [String : NSAttributedString]
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.effectDictionary, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 获取字符在字符串中的索引
    var glyphIndexForString: Int? {
        let length = stringValue.count
        let stringRange = NSRange(location: 0, length: length)
        let textStorage = NSTextStorage(attributedString: attributedStringValue)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let glyphRange = layoutManager.glyphRange(forCharacterRange: stringRange, actualCharacterRange: nil)
        return glyphRange.location
    }
    
    // 设置和获取是否启用点击效果
    var isTapEffectEnabledProperty: Bool {
        set {
            isTapEffectEnabled = newValue
        }
        get {
            return isTapEffectEnabled
        }
    }
    
    // 添加点击动作
    func addTapAction(_ strings: [String], tapAction: @escaping ((String, NSRange, Int) -> Void)) {
        getRanges(strings)
        tapActionBlock = tapAction
    }
    
    // 重写鼠标按下事件
    override func mouseDown(with event: NSEvent) {
        if hasTapActionEnabled == false {
            return
        }
        let point = event.locationInWindow
        let localPoint = convert(point, from: nil)
        getTapFrame(localPoint) { string, range, index in
            if let block = self.tapActionBlock {
                block(string, range, index)
            }
            handleTapEffect(true)
        }
    }
    
    // 重写鼠标抬起事件
    override func mouseUp(with event: NSEvent) {
        handleTapEffect(false)
    }
    
    // 重写鼠标拖动事件
    override func mouseDragged(with event: NSEvent) {
        handleTapEffect(false)
    }
    
    // 重写点击测试方法
    override func hitTest(_ point: NSPoint) -> NSView? {
        if hasTapActionEnabled == true {
            let result = getTapFrame(point) { string, range, index in }
            if result {
                return self
            }
        }
        return super.hitTest(point)
    }
    
    // 获取点击框架
    @discardableResult
    private func getTapFrame(_ point: NSPoint, result: ((_ str: String, _ range: NSRange, _ index: Int) -> Void)) -> Bool {
        let framesetter = CTFramesetterCreateWithAttributedString(self.attributedStringValue)
        var path = CGMutablePath()
        path.addRect(bounds, transform: CGAffineTransform.identity)
        var frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        let range = CTFrameGetVisibleStringRange(frame)
        if let attributedText = attributedStringValue as NSAttributedString?, attributedText.length > range.length {
            var m_font: NSFont
            if let nFont = attributedText.attribute(.font, at: 0, effectiveRange: nil) as? NSFont {
                m_font = nFont
            } else if let systemFont = font {
                m_font = systemFont
            } else {
                m_font = NSFont.systemFont(ofSize: 17)
            }
            let lineHeight = floor(NSHeight(bounds) - (m_font.ascender + m_font.descender))
            path = CGMutablePath()
            path.addRect(CGRect(x: 0, y: 0, width: bounds.size.width, height: lineHeight), transform: CGAffineTransform.identity)
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        }
        
        guard let linesAsCFArray = CTFrameGetLines(frame) as? [CTLine] else {
            print("Failed to convert lines as CFArray to Swift array.")
            return false
        }
        
        let count = linesAsCFArray.count
        var origins = [CGPoint](repeating: CGPoint.zero, count: count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)
        let transform = CGAffineTransform(translationX: 0, y: bounds.size.height).scaledBy(x: 1.0, y: -1.0)
        let verticalOffset = 0.0
        for i in 0..<count {
            let linePoint = origins[i]
            let line = linesAsCFArray[i]
            let lineRef = line
            let flippedRect = getLineBounds(lineRef, point: linePoint)
            var rect = flippedRect.applying(transform)
            rect = rect.insetBy(dx: 0, dy: 0)
            rect = rect.offsetBy(dx: 0, dy: CGFloat(verticalOffset))
            if let style = attributedStringValue.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                let lineSpace = style.lineSpacing
                let lineOutSpace = (CGFloat(bounds.size.height) - CGFloat(lineSpace) * CGFloat(count - 1) - CGFloat(rect.size.height) * CGFloat(count)) / 2
                rect.origin.y = lineOutSpace + rect.size.height * CGFloat(i) + lineSpace * CGFloat(i)
            } else {
                let lineOutSpace = (CGFloat(bounds.size.height) - CGFloat(0) * CGFloat(count - 1) - CGFloat(rect.size.height) * CGFloat(count)) / 2
                rect.origin.y = lineOutSpace + rect.size.height * CGFloat(i)
            }
            
            if rect.contains(point) {
                let relativePoint = CGPoint(x: point.x - rect.minX, y: point.y - rect.minY)
                var index = CTLineGetStringIndexForPosition(lineRef, relativePoint)
                var offset: CGFloat = 0.0
                CTLineGetOffsetForStringIndex(lineRef, index, &offset)
                if offset > relativePoint.x {
                    index = index - 1
                }
                guard let linkCount = attributeStringModels?.count else {
                    return false
                }
                for j in 0..<linkCount {
                    let model = attributeStringModels![j]
                    let linkRange = model.range
                    if linkRange != nil && NSLocationInRange(index, linkRange!) {
                        result(model.str!, model.range!, j)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // 获取行边界
    private func getLineBounds(_ line: CTLine, point: CGPoint) -> CGRect {
        var ascent: CGFloat = 0.0
        var descent: CGFloat = 0.0
        var leading: CGFloat = 0.0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        let height = ascent + abs(descent) + leading
        return CGRect(x: point.x, y: point.y, width: CGFloat(width), height: height)
    }
    
    // 获取范围
    private func getRanges(_ strings: [String]) {
        if attributedStringValue.length == 0 {
            return
        }
        isEnabled = true
        hasTapActionEnabled = true
        let totalString = attributedStringValue.string
        attributeStringModels = []
        var array = [LabelAttributeModel]()
        for str in strings {
            let ranges = totalString.exMatchStrRange(str)
            if ranges.count > 0 {
                for i in 0..<ranges.count {
                    let range = ranges[i]
                    let model = LabelAttributeModel()
                    model.range = range
                    model.str = str
                    array.append(model)
                }
            }
        }
        if array.count > 1 {
            for i in 0..<array.count {
                for j in i..<array.count - 1 {
                    if array[j].range!.location > array[j + 1].range!.location {
                        let tmp = array[j]
                        array[j] = array[j + 1]
                        array[j + 1] = tmp
                    }
                }
            }
        }
        for model in array {
            attributeStringModels?.append(model)
        }
    }
    
    // 保存效果字典
    private func saveEffectDicWithRange(_ range: NSRange) {
        effectDictionary = [:]
        let subAttribute = attributedStringValue.attributedSubstring(from: range)
        effectDictionary?[NSStringFromRange(range)] = subAttribute
    }
    
    // 应用点击效果
    private func applyTapEffect(_ status: Bool) {
        guard isTapEffectEnabled, let effectDic = effectDictionary,!effectDic.isEmpty else {
            return
        }
        let attStr = NSMutableAttributedString(attributedString: attributedStringValue)
        let subAtt = NSMutableAttributedString(attributedString: effectDic.values.first!)
        let range = NSRangeFromString(effectDic.keys.first!)
        if status {
            subAtt.addAttribute(.backgroundColor, value: NSColor.lightGray, range: NSMakeRange(0, subAtt.length))
            attStr.replaceCharacters(in: range, with: subAtt)
        } else {
            attStr.replaceCharacters(in: range, with: subAtt)
        }
        attributedStringValue = attStr
    }
    
    // 启动定时器
    func timerStart(interval: Int = 60) {
        var time = interval
        let codeTimer = DispatchSource.makeTimerSource(flags:.init(rawValue: 0), queue: DispatchQueue.global())
        codeTimer.schedule(deadline:.now(), repeating:.milliseconds(1000))
        codeTimer.setEventHandler {
            time -= 1
            DispatchQueue.main.async {
                self.isEnabled = time <= 0
                if time > 0 {
                    self.stringValue = "剩余\(time)s"
                    return
                }
                codeTimer.cancel()
                self.stringValue = "发送验证码"
            }
        }
        codeTimer.resume()
    }
    
    // 处理点击效果
    private func handleTapEffect(_ status: Bool) {
        if isTapEffectEnabled {
            DispatchQueue.main.async {
                self.applyTapEffect(status)
            }
        }
    }
}

public extension String {
    // 将字符串范围转换为 NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    // 将 NSRange 转换为字符串范围
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from..<to
    }
}

public extension String {
    @discardableResult
    func exMatchStrRange(_ matchStr: String) -> [NSRange] {
        var selfStr = self as NSString
        var withStr = Array(repeating: "X", count: (matchStr as NSString).length).joined(separator: "") //辅助字符串
        if matchStr == withStr { withStr = withStr.lowercased() } //临时处理辅助字符串差错
        var allRange = [NSRange]()
        while selfStr.range(of: matchStr).location != NSNotFound {
            let range = selfStr.range(of: matchStr)
            allRange.append(NSRange(location: range.location,length: range.length))
            selfStr = selfStr.replacingCharacters(in: NSMakeRange(range.location, range.length), with: withStr) as NSString
        }
        return allRange
    }
}
