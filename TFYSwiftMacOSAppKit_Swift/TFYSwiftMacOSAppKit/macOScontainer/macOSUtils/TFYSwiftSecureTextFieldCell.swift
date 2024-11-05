//
//  TFYSwiftSecureTextFieldCell.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYSwiftSecureTextFieldCell: NSSecureTextFieldCell {

    public var isTextAlignmentVerticalCenter:Bool = true
    public var Xcursor:CGFloat = 10
    
    fileprivate func adjustedFrameToVerticallyCenterText(frame:NSRect) -> NSRect {
        if isTextAlignmentVerticalCenter == false {
            return frame
        }
        let offset = floor(NSHeight(frame)/2 - ((font?.ascender ?? 0.0) + (font?.descender ?? 0.0)))
        return NSInsetRect(frame, Xcursor, offset)
    }
    
    public override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        super.edit(withFrame: adjustedFrameToVerticallyCenterText(frame: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
    public override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: adjustedFrameToVerticallyCenterText(frame: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: adjustedFrameToVerticallyCenterText(frame: cellFrame), in: controlView)
    }
}
