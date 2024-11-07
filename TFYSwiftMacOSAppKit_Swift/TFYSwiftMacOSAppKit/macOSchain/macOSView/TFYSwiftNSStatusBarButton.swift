//
//  TFYSwiftNSStatusBarButton.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSStatusBarButton {
    
    @discardableResult
    func appearsDisabled(_ appar: Bool) -> Self {
        base.appearsDisabled = appar
        return self
    }
}
