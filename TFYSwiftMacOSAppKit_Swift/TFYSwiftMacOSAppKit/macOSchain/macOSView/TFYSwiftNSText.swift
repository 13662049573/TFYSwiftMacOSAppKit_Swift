//
//  TFYSwiftNSText.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSText {
    
    @discardableResult
    func string(_ string:String) -> Self {
        base.string = string
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSTextDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func editable(_ editable:Bool) -> Self {
        base.isEditable = editable
        return self
    }
    
    @discardableResult
    func selectable(_ selectable:Bool) -> Self {
        base.isSelectable = selectable
        return self
    }
    
    @discardableResult
    func richText(_ richText:Bool) -> Self {
        base.isRichText = richText
        return self
    }
    
    @discardableResult
    func fieldEditor(_ fieldEditor:Bool) -> Self {
        base.isFieldEditor = fieldEditor
        return self
    }
    
    @discardableResult
    func importsGraphics(_ phics:Bool) -> Self {
        base.importsGraphics = phics
        return self
    }
    
    @discardableResult
    func usesFontPanel(_ panel:Bool) -> Self {
        base.usesFontPanel = panel
        return self
    }
    
    @discardableResult
    func drawsBackground(_ draws:Bool) -> Self {
        base.drawsBackground = draws
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color:NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func selectedRange(_ range:NSRange) -> Self {
        base.selectedRange = range
        return self
    }
    
    @discardableResult
    func font(_ font:NSFont) -> Self {
        base.font = font
        return self
    }
    
    @discardableResult
    func textColor(_ color:NSColor) -> Self {
        base.textColor = color
        return self
    }
    
    @discardableResult
    func alignment(_ alignment:NSTextAlignment) -> Self {
        base.alignment = alignment
        return self
    }
    
    @discardableResult
    func baseWritingDirection(_ spacing:NSWritingDirection) -> Self {
        base.baseWritingDirection = spacing
        return self
    }
    
    @discardableResult
    func maxSize(_ max:NSSize) -> Self {
        base.maxSize = max
        return self
    }
    
    @discardableResult
    func minSize(_ min:NSSize) -> Self {
        base.minSize = min
        return self
    }
    
    @discardableResult
    func horizontallyResizable(_ hor:Bool) -> Self {
        base.isHorizontallyResizable = hor
        return self
    }
    
    @discardableResult
    func verticallyResizable(_ ver:Bool) -> Self {
        base.isVerticallyResizable = ver
        return self
    }
    
    @discardableResult
    func replaceCharacters(_ range:NSRange,with:String) -> Self {
        base.replaceCharacters(in: range, with: with)
        return self
    }
    
    @discardableResult
    func replaceCharacters(_ ranges:NSRange,rtf:Data) -> Self {
        base.replaceCharacters(in: ranges, withRTF: rtf)
        return self
    }
    
    @discardableResult
    func replaceCharacters(_ range:NSRange,rtfd:Data) -> Self {
        base.replaceCharacters(in: range, withRTFD: rtfd)
        return self
    }
    
    @discardableResult
    func columnSpacing(_ range:NSRange) -> Self {
        base.scrollRangeToVisible(range)
        return self
    }
    
    @discardableResult
    func setTextColor(_ color:NSColor,range:NSRange) -> Self {
        base.setTextColor(color, range: range)
        return self
    }
    
    @discardableResult
    func setFont(_ font:NSFont,range:NSRange) -> Self {
        base.setFont(font, range: range)
        return self
    }
    
    @discardableResult
    func sizeToFit() -> Self {
        base.sizeToFit()
        return self
    }
    
    @discardableResult
    func copy(spacing:Any) -> Self {
        base.copy(spacing)
        return self
    }
    
    @discardableResult
    func copyFont(_ spacing:Any) -> Self {
        base.copyFont(spacing)
        return self
    }
    
    @discardableResult
    func copyRuler(_ spacing:Any) -> Self {
        base.copyRuler(spacing)
        return self
    }
    
    @discardableResult
    func cut(_ spacing:Any) -> Self {
        base.cut(spacing)
        return self
    }
    
    @discardableResult
    func delete(_ spacing:Any) -> Self {
        base.delete(spacing)
        return self
    }
    
    @discardableResult
    func paste(_ spacing:Any) -> Self {
        base.paste(spacing)
        return self
    }
    
    @discardableResult
    func pasteFont(_ spacing:Any) -> Self {
        base.pasteFont(spacing)
        return self
    }
    
    @discardableResult
    func pasteRuler(_ spacing:Any) -> Self {
        base.pasteRuler(spacing)
        return self
    }
    
    @discardableResult
    func selectAll(_ spacing:Any) -> Self {
        base.selectAll(spacing)
        return self
    }
    
    @discardableResult
    func changeFont(_ spacing:Any) -> Self {
        base.changeFont(spacing)
        return self
    }
    
    @discardableResult
    func alignLeft(_ spacing:Any) -> Self {
        base.alignLeft(spacing)
        return self
    }
    
    @discardableResult
    func alignRight(_ spacing:Any) -> Self {
        base.alignRight(spacing)
        return self
    }
    
    @discardableResult
    func alignCenter(_ spacing:Any) -> Self {
        base.alignCenter(spacing)
        return self
    }
    
    @discardableResult
    func `subscript`(_ spacing:Any) -> Self {
        base.subscript(spacing)
        return self
    }
    
    @discardableResult
    func underline(_ spacing:Any) -> Self {
        base.underline(spacing)
        return self
    }
    
    @discardableResult
    func unscript(_ spacing:Any) -> Self {
        base.unscript(spacing)
        return self
    }
    
    @discardableResult
    func showGuessPanel(_ spacing:Any) -> Self {
        base.showGuessPanel(spacing)
        return self
    }
    
    @discardableResult
    func checkSpelling(_ spacing:Any) -> Self {
        base.checkSpelling(spacing)
        return self
    }
    
    @discardableResult
    func toggleRuler(_ spacing:Any) -> Self {
        base.toggleRuler(spacing)
        return self
    }

}
