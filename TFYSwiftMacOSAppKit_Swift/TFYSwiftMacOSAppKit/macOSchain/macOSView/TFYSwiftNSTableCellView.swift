//
//  TFYSwiftNSTableCellView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension Chain where Base: NSTableCellView {
    
    @discardableResult
    func objectValue(_ value:Any) -> Self {
        base.objectValue = value
        return self
    }
    
    @discardableResult
    func backgroundStyle(_ style:NSView.BackgroundStyle) -> Self {
        base.backgroundStyle = style
        return self
    }
    
    @discardableResult
    func rowSizeStyle(_ style:NSTableView.RowSizeStyle) -> Self {
        base.rowSizeStyle = style
        return self
    }
    
    @discardableResult
    func textField(_ textField:NSTextField) -> Self {
        base.textField = textField
        return self
    }
    
    @discardableResult
    func imageView(_ imageView:NSImageView) -> Self {
        base.imageView = imageView
        return self
    }
}
