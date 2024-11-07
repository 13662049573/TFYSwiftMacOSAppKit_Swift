//
//  TFYSwiftNSStackView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSStackView {
    
    @discardableResult
    func delegate(_ delegate:(any NSStackViewDelegate)) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func orientation(_ orientation:NSUserInterfaceLayoutOrientation) -> Self {
        base.orientation = orientation
        return self
    }
    
    @discardableResult
    func alignment(_ alignment:NSLayoutConstraint.Attribute) -> Self {
        base.alignment = alignment
        return self
    }
    
    @discardableResult
    func edgeInsets(_ insets:NSEdgeInsets) -> Self {
        base.edgeInsets = insets
        return self
    }
    
    @discardableResult
    func distribution(_ dis:NSStackView.Distribution) -> Self {
        base.distribution = dis
        return self
    }
    
    @discardableResult
    func spacing(_ spacing:CGFloat) -> Self {
        base.spacing = spacing
        return self
    }
    
    @discardableResult
    func setCustomSpacing(_ spacing:CGFloat, after:NSView) -> Self {
        base.setCustomSpacing(spacing, after: after)
        return self
    }
    
    @discardableResult
    func register_Nib(_ view:NSView) -> Self {
        base.addArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func register_Nib(_ view:NSView,at:Int) -> Self {
        base.insertArrangedSubview(view, at: at)
        return self
    }
    
    @discardableResult
    func removeArrangedSubview(_ view:NSView) -> Self {
        base.removeArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func detachesHiddenViews(_ hidd:Bool) -> Self {
        base.detachesHiddenViews = hidd
        return self
    }
}
