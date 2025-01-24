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
        var newRect = super.drawingRect(forBounds: rect)
        
        if isTextAlignmentVerticalCenter {
            let textSize = cell(withFrame: rect, in: controlView)
            let heightDelta = newRect.size.height - textSize.height
            if heightDelta > 0 {
                newRect.size.height -= heightDelta
                newRect.origin.y += heightDelta / 2
            }
            if Xcursor > 0 {
                newRect.origin.x += Xcursor
                newRect.size.width -= Xcursor
            }
        }
        
        return newRect
    }
    
    public override func select(withFrame rect: NSRect, in controlView: NSView?, editor textObj: NSText?, delegate: Any?, start selStart: Int, length selLength: Int) {
        var aRect = rect
        if isTextAlignmentVerticalCenter {
            let textSize = cell(withFrame: rect, in: controlView)
            let heightDelta = rect.size.height - textSize.height
            if heightDelta > 0 {
                aRect.size.height -= heightDelta
                aRect.origin.y += heightDelta / 2
            }
            if Xcursor > 0 {
                aRect.origin.x += Xcursor
                aRect.size.width -= Xcursor
            }
        }
        super.select(withFrame: aRect, in: controlView!, editor: textObj!, delegate: delegate, start: selStart, length: selLength)
    }
    
    private func cell(withFrame rect: NSRect, in controlView: NSView?) -> NSSize {
        let str = self.attributedStringValue
        let size = str.size()
        return size
    }
}
