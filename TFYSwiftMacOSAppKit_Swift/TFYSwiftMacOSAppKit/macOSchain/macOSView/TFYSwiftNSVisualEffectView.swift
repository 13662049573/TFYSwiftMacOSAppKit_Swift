//
//  TFYSwiftNSVisualEffectView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSVisualEffectView {
    
    @discardableResult
    func material(_ material: NSVisualEffectView.Material) -> Self {
        base.material = material
        return self
    }
    
    @discardableResult
    func blendingMode(_ blendingMode: NSVisualEffectView.BlendingMode) -> Self {
        base.blendingMode = blendingMode
        return self
    }
    
    @discardableResult
    func state(_ state: NSVisualEffectView.State) -> Self {
        base.state = state
        return self
    }
    
    @discardableResult
    func emphasized(_ emphasized: Bool) -> Self {
        base.isEmphasized = emphasized
        return self
    }
}
