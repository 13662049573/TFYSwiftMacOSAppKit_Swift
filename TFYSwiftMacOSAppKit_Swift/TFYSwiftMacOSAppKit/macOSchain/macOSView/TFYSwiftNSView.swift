//
//  TFYSwiftNSView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//  exchangeInstanceMethod

import Cocoa

public extension Chain where Base: NSView {
    
    @discardableResult
    func bounds(_ bounds: NSRect) -> Self {
        base.bounds = bounds
        return self
    }
    
    @discardableResult
    func preparedContentRect(_ preparedContentRect: NSRect) -> Self {
        base.preparedContentRect = preparedContentRect
        return self
    }
    
    @discardableResult
    func frame(_ frame: NSRect) -> Self {
        base.frame = frame
        return self
    }
    
    @discardableResult
    func autoresizingMask(_ autoresizingMask: NSView.AutoresizingMask) -> Self {
        base.autoresizingMask = autoresizingMask
        return self
    }
    
    @discardableResult
    func alphaValue(_ alphaValue:CGFloat) -> Self {
        base.alphaValue = alphaValue
        return self
    }
    
    @discardableResult
    func hidden(_ hidden:Bool) -> Self {
        base.isHidden = hidden
        return self
    }
    
    @discardableResult
    func postsFrameChangedNotifications(_ postsFrameChangedNotifications:Bool) -> Self {
        base.postsFrameChangedNotifications = postsFrameChangedNotifications
        return self
    }
    
    @discardableResult
    func autoresizesSubviews(_ autoresizesSubviews:Bool) -> Self {
        base.autoresizesSubviews = autoresizesSubviews
        return self
    }
    
    @discardableResult
    func frameRotation(_ frameRotation:CGFloat) -> Self {
        base.frameRotation = frameRotation
        return self
    }
    
    @discardableResult
    func frameCenterRotation(_ frameCenterRotation:CGFloat) -> Self {
        base.frameCenterRotation = frameCenterRotation
        return self
    }
    
    @discardableResult
    func boundsRotation(_ boundsRotation:CGFloat) -> Self {
        base.boundsRotation = boundsRotation
        return self
    }
    
    @discardableResult
    func layerContentsPlacement(_ layerContentsPlacement:NSView.LayerContentsPlacement) -> Self {
        base.layerContentsPlacement = layerContentsPlacement
        return self
    }
    
    @discardableResult
    func layerContentsRedrawPolicy(_ layerContentsRedrawPolicy:NSView.LayerContentsRedrawPolicy) -> Self {
        base.layerContentsRedrawPolicy = layerContentsRedrawPolicy
        return self
    }
    
    @discardableResult
    func canDrawConcurrently(_ canDrawConcurrently:Bool) -> Self {
        base.canDrawConcurrently = canDrawConcurrently
        return self
    }
    
    @discardableResult
    func needsDisplay(_ needsDisplay:Bool) -> Self {
        base.needsDisplay = needsDisplay
        return self
    }
    
    @discardableResult
    func wantsRestingTouches(_ wantsRestingTouches:Bool) -> Self {
        base.wantsRestingTouches = wantsRestingTouches
        return self
    }
    
    @discardableResult
    func wantsLayer(_ wantsLayer:Bool) -> Self {
        base.wantsLayer = wantsLayer
        return self
    }
    
    @discardableResult
    func layer(_ layer:CALayer) -> Self {
        base.layer = layer
        return self
    }
    
    @discardableResult
    func canDrawSubviewsIntoLayer(_ canDrawSubviewsIntoLayer:Bool) -> Self {
        base.canDrawSubviewsIntoLayer = canDrawSubviewsIntoLayer
        return self
    }
    
    @discardableResult
    func needsLayout(_ needsLayout:Bool) -> Self {
        base.needsLayout = needsLayout
        return self
    }
    
    @discardableResult
    func layerUsesCoreImageFilters(_ layerUsesCoreImageFilters:Bool) -> Self {
        base.layerUsesCoreImageFilters = layerUsesCoreImageFilters
        return self
    }
    
    @discardableResult
    func backgroundFilters(_ backgroundFilters:[CIFilter]) -> Self {
        base.backgroundFilters = backgroundFilters
        return self
    }
    
    @discardableResult
    func compositingFilter(_ compositingFilter:CIFilter) -> Self {
        base.compositingFilter = compositingFilter
        return self
    }
    
    @discardableResult
    func contentFilters(_ contentFilters:[CIFilter]) -> Self {
        base.contentFilters = contentFilters
        return self
    }
    
    @discardableResult
    func shadow(_ shadow:NSShadow) -> Self {
        base.shadow = shadow
        return self
    }
    
    @discardableResult
    func postsBoundsChangedNotifications(_ postsBoundsChangedNotifications:Bool) -> Self {
        base.postsBoundsChangedNotifications = postsBoundsChangedNotifications
        return self
    }
    
    @discardableResult
    func toolTip(_ toolTip:String) -> Self {
        base.toolTip = toolTip
        return self
    }
    
    @discardableResult
    func removeToolTip(_ removeToolTip:NSView.ToolTipTag) -> Self {
        base.removeToolTip(removeToolTip)
        return self
    }
    
    @discardableResult
    func addToSuperView(_ view: NSView) -> Self {
        base.addSubview(view)
        return self
    }
    
    @discardableResult
    func addToSublayer(_ layer: CALayer) -> Self {
        layer.addSublayer(base.layer!)
        return self
    }
    
    @discardableResult
    func addSubView(_ view:NSView) -> Self {
        view.addSubview(base)
        return self
    }
    
    @discardableResult
    func addGesture(_ addGesture:NSGestureRecognizer) -> Self {
        base.addGestureRecognizer(addGesture)
        return self
    }
    
    @discardableResult
    func contents(_ contents:Any) -> Self {
        base.layer!.contents = contents
        return self
    }
    
    @discardableResult
    func removeGesture(_ removeGesture:NSGestureRecognizer) -> Self {
        base.removeGestureRecognizer(removeGesture)
        return self
    }
    
    @discardableResult
    func viewWillMoveToWindow(_ toWindow:NSWindow) -> Self {
        base.viewWillMove(toWindow: toWindow)
        return self
    }
    
    @discardableResult
    func viewWillMoveToSuperview(_ toSuperview:NSView) -> Self {
        base.viewWillMove(toSuperview: toSuperview)
        return self
    }
    
    @discardableResult
    func didAddSubview(_ view:NSView) -> Self {
        base.didAddSubview(view)
        return self
    }
    
    @discardableResult
    func willRemoveSubview(_ view:NSView) -> Self {
        base.willRemoveSubview(view)
        return self
    }
    
    @discardableResult
    func replaceSubview(_ oldview:NSView,newView:NSView) -> Self {
        base.replaceSubview(oldview, with: newView)
        return self
    }
    
    @discardableResult
    func userInterfaceLayoutDirection(_ direction:NSUserInterfaceLayoutDirection) -> Self {
        base.userInterfaceLayoutDirection =  direction
        return self
    }
    
    @discardableResult
    func nextKeyView(_ view:NSView) -> Self {
        base.nextKeyView = view
        return self
    }
    
    @discardableResult
    func focusRingType(_ type:NSFocusRingType) -> Self {
        base.focusRingType = type
        return self
    }
    
    @discardableResult
    func additionalSafeAreaInsets(_ insets:NSEdgeInsets) -> Self {
        base.additionalSafeAreaInsets = insets
        return self
    }
    
    @discardableResult
    func allowedTouchTypes(_ type:NSTouch.TouchTypeMask) -> Self {
        base.allowedTouchTypes = type
        return self
    }
    
    @discardableResult
    func resizeSubviewsWithOldSize(_ size:NSSize) -> Self {
        base.resizeSubviews(withOldSize: size)
        return self
    }
    
    @discardableResult
    func resizeWithOldSuperviewSize(_ size:NSSize) -> Self {
        base.resize(withOldSuperviewSize: size)
        return self
    }
    
    @discardableResult
    func shouldRasterize(_ shouldRasterize:Bool) -> Self {
        base.layer?.shouldRasterize = shouldRasterize
        return self
    }
    
    @discardableResult
    func layerOpacity(_ opacity:Float) -> Self {
        base.layer?.opacity = opacity
        return self
    }
    
    @discardableResult
    func opaque(_ opaque:Bool) -> Self {
        base.layer?.isOpaque = opaque
        return self
    }
    
    @discardableResult
    func rasterizationScale(_ scale:CGFloat) -> Self {
        base.layer?.rasterizationScale = scale
        return self
    }
    
    @discardableResult
    func masksToBounds(_ toBounds:Bool) -> Self {
        base.layer?.masksToBounds = toBounds
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius:CGFloat) -> Self {
        base.layer?.cornerRadius = radius
        base.layer?.masksToBounds = true
        return self
    }
    
    @discardableResult
    func border(_ borderWidth:CGFloat,borderColor:NSColor) -> Self {
        base.layer?.borderWidth = borderWidth
        base.layer?.borderColor = borderColor.cgColor
        base.layer?.masksToBounds = true
        return self
    }
    
    @discardableResult
    func borderWidth(_ borderWidth:CGFloat) -> Self {
        base.layer?.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    func borderColor(_ borderColor:NSColor) -> Self {
        base.layer?.borderColor = borderColor.cgColor
        return self
    }
    
    @discardableResult
    func zPosition(_ zPosition:CGFloat) -> Self {
        base.layer?.zPosition = zPosition
        return self
    }
    
    @discardableResult
    func anchorPoint(_ anchorPoint:CGPoint) -> Self {
        base.layer?.anchorPoint = anchorPoint
        return self
    }
    
    @discardableResult
    func shadowlayer(_ shadowOffset:CGSize,shadowRadius:CGFloat,shadowColor:NSColor,shadowOpacity:Float) -> Self {
        base.layer?.shadowOffset = shadowOffset
        base.layer?.shadowRadius = shadowRadius
        base.layer?.shadowColor = shadowColor.cgColor
        base.layer?.shadowOpacity = shadowOpacity
        return self
    }
    
    @discardableResult
    func shadowColor(_ shadowColor:CGColor) -> Self {
        base.layer?.shadowColor = shadowColor
        return self
    }
    
    @discardableResult
    func shadowOpacity(_ shadowOpacity:Float) -> Self {
        base.layer?.shadowOpacity = shadowOpacity
        return self
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset:CGSize) -> Self {
        base.layer?.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func shadowRadius(_ shadowRadius:CGFloat) -> Self {
        base.layer?.shadowRadius = shadowRadius
        return self
    }
    
    @discardableResult
    func transform(_ transform:CATransform3D) -> Self {
        base.layer?.transform = transform
        return self
    }
    
    @discardableResult
    func setFrameOrigin(_ origin:NSPoint) -> Self {
        base.setFrameOrigin(origin)
        return self
    }
    
    @discardableResult
    func removeFormSuperView() -> Self {
        base.removeFromSuperview()
        return self
    }
    
    @discardableResult
    func setFrameSize(_ size:NSSize) -> Self {
        base.setFrameSize(size)
        return self
    }
    
    @discardableResult
    func setBoundsOrigin(_ origin:NSPoint) -> Self {
        base.setBoundsOrigin(origin)
        return self
    }
    
    @discardableResult
    func setBoundsSize(_ size:NSSize) -> Self {
        base.setBoundsSize(size)
        return self
    }
    
    @discardableResult
    func translateOriginToPoint(_ topoint:NSPoint) -> Self {
        base.translateOrigin(to: topoint)
        return self
    }
    
    @discardableResult
    func scaleUnitSquareToSize(_ size:NSSize) -> Self {
        base.scaleUnitSquare(to: size)
        return self
    }
    
    @discardableResult
    func display() -> Self {
        base.display()
        return self
    }
    
    @discardableResult
    func displayIfNeeded() -> Self {
        base.displayIfNeeded()
        return self
    }
    
    @discardableResult
    func displayIfNeededIgnoringOpacity() -> Self {
        base.displayIfNeededIgnoringOpacity()
        return self
    }
    
    @discardableResult
    func displayRect(_ rect:NSRect) -> Self {
        base.display(rect)
        return self
    }
    
    @discardableResult
    func displayIfNeededInRect(_ rect:NSRect) -> Self {
        base.displayIfNeeded(rect)
        return self
    }
    
    @discardableResult
    func displayRectIgnoringOpacity(_ rect:NSRect) -> Self {
        base.displayIgnoringOpacity(rect)
        return self
    }
    
    @discardableResult
    func displayIfNeededInRectIgnoringOpacity(_ rect:NSRect) -> Self {
        base.displayIfNeededIgnoringOpacity(rect)
        return self
    }
    
    @discardableResult
    func drawRect(_ rect:NSRect) -> Self {
        base.draw(rect)
        return self
    }
    
    @discardableResult
    func nextResponder(_ resp:NSResponder) -> Self {
        base.nextResponder = resp
        return self
    }
    
    @discardableResult
    func menu(_ menu:NSMenu) -> Self {
        base.menu = menu
        return self
    }
    
    @discardableResult
    func updateLayer() -> Self {
        base.updateLayer()
        return self
    }
    
    @discardableResult
    func clipsToBounds(_ clipsToBounds:Bool) -> Self {
        base.clipsToBounds = clipsToBounds
        return self
    }
    
    @discardableResult
    func backgroundColor(_ backgroundColor:NSColor) -> Self {
        base.wantsLayer = true
        base.layer?.backgroundColor = backgroundColor.cgColor
        return self
    }
}
