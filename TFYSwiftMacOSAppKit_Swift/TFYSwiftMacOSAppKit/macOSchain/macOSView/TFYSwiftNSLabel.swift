//
//  TFYSwiftNSLabel.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: TFYSwiftLabel {
    
    @discardableResult
    func mouseDownBlock(_ block: @escaping (_ label:TFYSwiftLabel) -> Void) -> Chain {
        base.mouseDownBlock = block
        return self
    }
}
