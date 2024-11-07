//
//  TFYSwiftNSScrollView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSScrollView {
    
    @discardableResult
    func documentView(_ view:NSView) -> Self {
        base.documentView = view
        return self
    }
    
    @discardableResult
    func contentView(_ view:NSClipView) -> Self {
        base.contentView = view
        return self
    }
    
    @discardableResult
    func documentCursor(_ cursor:NSCursor) -> Self {
        base.documentCursor = cursor
        return self
    }
    
    @discardableResult
    func borderType(_ type:NSBorderType) -> Self {
        base.borderType = type
        return self
    }
    
    @discardableResult
    func backgroundColor(_ backgroundColor:NSColor) -> Self {
        base.wantsLayer = true
        base.layer?.backgroundColor = backgroundColor.cgColor
        return self
    }
    
    @discardableResult
    func drawsBackground(_ drawsBackground:Bool) -> Self {
        base.drawsBackground = drawsBackground
        return self
    }
    
    @discardableResult
    func hasVerticalScroller(_ ver:Bool) -> Self {
        base.hasVerticalScroller = ver
        return self
    }
    
    @discardableResult
    func hasHorizontalScroller(_ hor:Bool) -> Self {
        base.hasHorizontalScroller = hor
        return self
    }
    
    @discardableResult
    func verticalScroller(_ scroller:NSScroller) -> Self {
        base.verticalScroller = scroller
        return self
    }
    
    @discardableResult
    func horizontalScroller(_ scroller:NSScroller) -> Self {
        base.horizontalScroller = scroller
        return self
    }
    
    @discardableResult
    func autohidesScrollers(_ suth:Bool) -> Self {
        base.autohidesScrollers = suth
        return self
    }
    
    @discardableResult
    func horizontalLineScroll(_ scroll:CGFloat) -> Self {
        base.horizontalLineScroll = scroll
        return self
    }
    
    @discardableResult
    func verticalLineScroll(_ scroll:CGFloat) -> Self {
        base.verticalLineScroll = scroll
        return self
    }
    
    @discardableResult
    func lineScroll(_ scroll:CGFloat) -> Self {
        base.lineScroll = scroll
        return self
    }
    
    @discardableResult
    func horizontalPageScroll(_ scroll:CGFloat) -> Self {
        base.horizontalPageScroll = scroll
        return self
    }
    
    @discardableResult
    func verticalPageScroll(_ scroll:CGFloat) -> Self {
        base.verticalPageScroll = scroll
        return self
    }
    
    @discardableResult
    func pageScroll(_ scroll:CGFloat) -> Self {
        base.pageScroll = scroll
        return self
    }
    
    @discardableResult
    func scrollerStyle(_ style:NSScroller.Style) -> Self {
        base.scrollerStyle = style
        return self
    }
    
    @discardableResult
    func scrollsDynamically(_ scroll:Bool) -> Self {
        base.scrollsDynamically = scroll
        return self
    }
    
    @discardableResult
    func scrollerKnobStyle(_ style:NSScroller.KnobStyle) -> Self {
        base.scrollerKnobStyle = style
        return self
    }
    
    @discardableResult
    func horizontalScrollElasticity(_ hor:NSScrollView.Elasticity) -> Self {
        base.horizontalScrollElasticity = hor
        return self
    }
    
    @discardableResult
    func verticalScrollElasticity(_ ver:NSScrollView.Elasticity) -> Self {
        base.verticalScrollElasticity = ver
        return self
    }
    
    @discardableResult
    func usesPredominantAxisScrolling(_ user:Bool) -> Self {
        base.usesPredominantAxisScrolling = user
        return self
    }
    
    @discardableResult
    func allowsMagnification(_ all:Bool) -> Self {
        base.allowsMagnification = all
        return self
    }
    
    @discardableResult
    func magnification(_ magen:CGFloat) -> Self {
        base.magnification = magen
        return self
    }
    
    @discardableResult
    func maxMagnification(_ max:CGFloat) -> Self {
        base.maxMagnification = max
        return self
    }
    
    @discardableResult
    func minMagnification(_ min:CGFloat) -> Self {
        base.minMagnification = min
        return self
    }
    
    @discardableResult
    func automaticallyAdjustsContentInsets(_ autom:Bool) -> Self {
        base.automaticallyAdjustsContentInsets = autom
        return self
    }
    
    @discardableResult
    func contentInsets(_ insets:NSEdgeInsets) -> Self {
        base.contentInsets = insets
        return self
    }
    
    @discardableResult
    func scrollerInsets(_ insets:NSEdgeInsets) -> Self {
        base.scrollerInsets = insets
        return self
    }
    
    @discardableResult
    func rulersVisible(_ rulers:Bool) -> Self {
        base.rulersVisible = rulers
        return self
    }
    
    @discardableResult
    func hasHorizontalRuler(_ rulers:Bool) -> Self {
        base.hasHorizontalRuler = rulers
        return self
    }
    
    @discardableResult
    func hasVerticalRuler(_ hasver:Bool) -> Self {
        base.hasVerticalRuler = hasver
        return self
    }
    
    @discardableResult
    func horizontalRulerView(_ hor:NSRulerView) -> Self {
        base.horizontalRulerView = hor
        return self
    }
    
    @discardableResult
    func verticalRulerView(_ ver:NSRulerView) -> Self {
        base.verticalRulerView = ver
        return self
    }
    
    @discardableResult
    func findBarPosition(_ find:NSScrollView.FindBarPosition) -> Self {
        base.findBarPosition = find
        return self
    }
}
