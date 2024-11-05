//
//  TFYSwiftLabel.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public typealias actionBlock = (_ label:TFYSwiftLabel) -> Void
public typealias mouseDownBlock = (_ label:TFYSwiftLabel) -> Void

public class TFYSwiftLabel: TFYSwiftTextField {
    
    public var mouseDownBlock:mouseDownBlock?
    
    public override var isFlipped: Bool {
        return true
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        autoresizingMask = [.width,.height]
        isBordered = false
        isEditable = false
        drawsBackground = true
        backgroundColor = .clear
        font = NSFont.systemFont(ofSize: 15)
        textColor = .black
        maximumNumberOfLines = 1
        usesSingleLineMode = true
    }
    
    public override func moveDown(_ sender: Any?) {
        super.moveDown(sender)
        if mouseDownBlock != nil {
            mouseDownBlock!(self)
        }
    }
    
    public func actionBlock(block:@escaping actionBlock) {
        self.mouseDownBlock = block
    }
}
