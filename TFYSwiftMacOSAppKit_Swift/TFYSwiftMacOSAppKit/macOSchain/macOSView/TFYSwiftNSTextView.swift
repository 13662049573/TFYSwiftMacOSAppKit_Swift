//
//  TFYSwiftNSTextView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSTextView {
    
    @discardableResult
    func textContainer(_ container:NSTextContainer) -> Self {
        base.textContainer = container
        return self
    }
    
    @discardableResult
    func attributedStringValue(_ attr: NSAttributedString) -> Self {
        base.textStorage?.setAttributedString(attr)
        return self
    }
    
    @discardableResult
    func textContainerInset(_ size:NSSize) -> Self {
        base.textContainerInset = size
        return self
    }
    
    @discardableResult
    func selectedRanges(_ ranges:[NSValue]) -> Self {
        base.selectedRanges = ranges
        return self
    }
    
    @discardableResult
    func selectionGranularity(_ granularity:NSSelectionGranularity) -> Self {
        base.selectionGranularity = granularity
        return self
    }
    
    @discardableResult
    func selectedTextAttributes(_ attr:[NSAttributedString.Key : Any]) -> Self {
        base.selectedTextAttributes = attr
        return self
    }
    
    @discardableResult
    func insertionPointColor(_ color:NSColor) -> Self {
        base.insertionPointColor = color
        return self
    }
    
    @discardableResult
    func markedTextAttributes(_ key:[NSAttributedString.Key : Any]) -> Self {
        base.markedTextAttributes = key
        return self
    }
    
    @discardableResult
    func linkTextAttributes(_ link:[NSAttributedString.Key : Any]) -> Self {
        base.linkTextAttributes = link
        return self
    }
    
    @discardableResult
    func displaysLinkToolTips(_ tips:Bool) -> Self {
        base.displaysLinkToolTips = tips
        return self
    }
    
    @discardableResult
    func acceptsGlyphInfo(_ info:Bool) -> Self {
        base.acceptsGlyphInfo = info
        return self
    }
    
    @discardableResult
    func usesRuler(_ usesRuler:Bool) -> Self {
        base.usesRuler = usesRuler
        return self
    }
    
    @discardableResult
    func usesInspectorBar(_ usesInspectorBar:Bool) -> Self {
        base.usesInspectorBar = usesInspectorBar
        return self
    }
    
    @discardableResult
    func continuousSpellCheckingEnabled(_ spacing:Bool) -> Self {
        base.isContinuousSpellCheckingEnabled = spacing
        return self
    }
    
    @discardableResult
    func grammarCheckingEnabled(_ spacing:Bool) -> Self {
        base.isGrammarCheckingEnabled = spacing
        return self
    }
    
    @discardableResult
    func typingAttributes(_ spacing:[NSAttributedString.Key : Any]) -> Self {
        base.typingAttributes = spacing
        return self
    }
    
    @discardableResult
    func allowsDocumentBackgroundColorChange(_ allows:Bool) -> Self {
        base.allowsDocumentBackgroundColorChange = allows
        return self
    }
    
    @discardableResult
    func defaultParagraphStyle(_ style:NSParagraphStyle) -> Self {
        base.defaultParagraphStyle = style
        return self
    }
    
    @discardableResult
    func allowsImageEditing(_ allows:Bool) -> Self {
        base.allowsImageEditing = allows
        return self
    }
    
    @discardableResult
    func usesRolloverButtonForSelection(_ spacing:Bool) -> Self {
        base.usesRolloverButtonForSelection = spacing
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSTextViewDelegate)) -> Self {
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
    func fieldEditor(_ spacing:Bool) -> Self {
        base.isFieldEditor = spacing
        return self
    }
    
    @discardableResult
    func rulerVisible(_ spacing:Bool) -> Self {
        base.isRulerVisible = spacing
        return self
    }
    
    @discardableResult
    func importsGraphics(_ spacing:Bool) -> Self {
        base.importsGraphics = spacing
        return self
    }
    
    @discardableResult
    func drawsBackground(_ spacing:Bool) -> Self {
        base.drawsBackground = spacing
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color:NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func usesFontPanel(_ spacing:Bool) -> Self {
        base.usesFontPanel = spacing
        return self
    }
    
    @discardableResult
    func allowedInputSourceLocales(_ allows:[String]) -> Self {
        base.allowedInputSourceLocales = allows
        return self
    }
    
    @discardableResult
    func smartInsertDeleteEnabled(_ spacing:Bool) -> Self {
        base.smartInsertDeleteEnabled = spacing
        return self
    }
    
    @discardableResult
    func enabledTextCheckingTypes(_ types:NSTextCheckingTypes) -> Self {
        base.enabledTextCheckingTypes = types
        return self
    }
    
    @discardableResult
    func usesFindPanel(_ panel:Bool) -> Self {
        base.usesFindPanel = panel
        return self
    }
    
    @discardableResult
    func usesFindBar(_ bar:Bool) -> Self {
        base.usesFindBar = bar
        return self
    }
    
    @discardableResult
    func incrementalSearchingEnabled(_ enabled:Bool) -> Self {
        base.isIncrementalSearchingEnabled = enabled
        return self
    }
    
    @discardableResult
    func automaticTextCompletionEnabled(_ spacing:Bool) -> Self {
        base.isAutomaticTextCompletionEnabled = spacing
        return self
    }
    
    @discardableResult
    func allowsCharacterPickerTouchBarItem(_ spacing:Bool) -> Self {
        base.allowsCharacterPickerTouchBarItem = spacing
        return self
    }

}
