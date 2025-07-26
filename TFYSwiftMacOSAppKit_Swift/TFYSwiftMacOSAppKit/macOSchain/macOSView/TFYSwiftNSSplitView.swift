//
//  TFYSwiftNSSplitView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSSplitView {
    
    @discardableResult
    func vertical(_ vertical:Bool) -> Self {
        base.isVertical = vertical
        return self
    }
    
    @discardableResult
    func dividerStyle(_ style:NSSplitView.DividerStyle) -> Self {
        base.dividerStyle = style
        return self
    }
    
    @discardableResult
    func autosaveName(_ autosaveName:NSSplitView.AutosaveName) -> Self {
        base.autosaveName = autosaveName
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:(any NSSplitViewDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func drawDivider(_ rect:NSRect) -> Self {
        base.drawDivider(in: rect)
        return self
    }
    
    @discardableResult
    func adjustSubviews() -> Self {
        base.adjustSubviews()
        return self
    }
    
    @discardableResult
    func setPosition(_ position:CGFloat,at:Int) -> Self {
        base.setPosition(position, ofDividerAt: at)
        return self
    }
    
    @discardableResult
    func register_Nib(_ priority:NSLayoutConstraint.Priority,at:Int) -> Self {
        base.setHoldingPriority(priority, forSubviewAt: at)
        return self
    }
    
    @discardableResult
    func addArrangedSubview(_ view:NSView) -> Self {
        base.addArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func register_Nib(_ view:NSView,at:Int) -> Self {
        base.insertArrangedSubview(view, at: at)
        return self
    }
    
    @discardableResult
    func register_Nib(_ view:NSView) -> Self {
        base.removeArrangedSubview(view)
        return self
    }
}
