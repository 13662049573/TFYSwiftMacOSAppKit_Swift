//
//  TFYSwiftNSClipView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSClipView {
    
    @discardableResult
    func backgroundColor(_ color:NSColor) -> Self {
        base.wantsLayer = true
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func drawsBackground(_ draws:Bool) -> Self {
        base.drawsBackground = draws
        return self
    }
    
    @discardableResult
    func documentView(_ view:NSView) -> Self {
        base.documentView = view
        return self
    }
    
    @discardableResult
    func documentCursor(_ documentCursor:NSCursor) -> Self {
        base.documentCursor = documentCursor
        return self
    }
    
    @discardableResult
    func contentInsets(_ insets:NSEdgeInsets) -> Self {
        base.contentInsets = insets
        return self
    }
    
    @discardableResult
    func scrollToPoint(_ point:NSPoint) -> Self {
        base.scroll(to: point)
        return self
    }
    
}
