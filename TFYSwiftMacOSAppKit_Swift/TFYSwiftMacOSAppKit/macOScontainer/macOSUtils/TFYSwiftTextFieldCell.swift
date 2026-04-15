//
//  TFYSwiftTextFieldCell.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

public class TFYSwiftTextFieldCell: NSTextFieldCell {
    /// 文字是否居中 默认 NO
    @objc public dynamic var isTextAlignmentVerticalCenter: Bool = false
    /// 修改光标离X轴的距离 默认 0 isTextAlignmentVerticalCenter 为 YES 的时候 使用
    @objc public dynamic var Xcursor: CGFloat = 0
    
    public override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let drawingRect = super.drawingRect(forBounds: rect)
        return adjustedRect(forBounds: drawingRect, controlView: controlView)
    }
    
    public override func select(withFrame rect: NSRect, in controlView: NSView?, editor textObj: NSText?, delegate: Any?, start selStart: Int, length selLength: Int) {
        let adjustedRect = adjustedRect(forBounds: rect, controlView: controlView)
        super.select(withFrame: adjustedRect, in: controlView!, editor: textObj!, delegate: delegate, start: selStart, length: selLength)
    }
    
    /// 基于当前可用宽度计算真实文本尺寸，兼容单行、省略和多行换行场景。
    private func textSize(forBounds rect: NSRect, in controlView: NSView?) -> NSSize {
        guard attributedStringValue.length > 0 else {
            return .zero
        }
        
        let textField = controlView as? NSTextField
        let usesSingleLineMode = textField?.cell?.usesSingleLineMode ?? textField?.usesSingleLineMode ?? false
        let maximumNumberOfLines = textField?.maximumNumberOfLines ?? 0
        
        let measuringWidth: CGFloat
        if usesSingleLineMode || maximumNumberOfLines == 1 {
            measuringWidth = .greatestFiniteMagnitude
        } else if let textField, textField.preferredMaxLayoutWidth > 0 {
            measuringWidth = textField.preferredMaxLayoutWidth
        } else {
            measuringWidth = max(rect.width, 0)
        }
        
        if measuringWidth <= 0 || measuringWidth == .greatestFiniteMagnitude {
            let naturalSize = attributedStringValue.size()
            return NSSize(width: ceil(naturalSize.width), height: ceil(naturalSize.height))
        }
        
        let options: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingRect = attributedStringValue.boundingRect(
            with: NSSize(width: measuringWidth, height: .greatestFiniteMagnitude),
            options: options
        ).integral
        
        return NSSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }
    
    private func adjustedRect(forBounds rect: NSRect, controlView: NSView?) -> NSRect {
        var adjustedRect = rect
        
        guard isTextAlignmentVerticalCenter else {
            return adjustedRect
        }
        
        let textSize = textSize(forBounds: adjustedRect, in: controlView)
        let heightDelta = adjustedRect.height - textSize.height
        if heightDelta > 0 {
            adjustedRect.origin.y += heightDelta / 2
            adjustedRect.size.height -= heightDelta
        }
        
        if Xcursor > 0 {
            adjustedRect.origin.x += Xcursor
            adjustedRect.size.width = max(0, adjustedRect.width - Xcursor)
        }
        
        return adjustedRect
    }
}
