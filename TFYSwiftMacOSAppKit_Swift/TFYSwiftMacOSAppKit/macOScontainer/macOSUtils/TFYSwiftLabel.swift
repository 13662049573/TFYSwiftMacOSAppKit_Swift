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
        super.init(coder: coder)
        setupUI()
    }
    
    fileprivate func setupUI() {
        self.isTextAlignmentVerticalCenter = false
        isEditable = false
        isSelectable = false
        textColor = .black
        font = NSFont.systemFont(ofSize: 15)
    }
    
    private func triggerActionIfNeeded() {
        mouseDownBlock?(self)
    }

    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        triggerActionIfNeeded()
    }
    
    public override func moveDown(_ sender: Any?) {
        super.moveDown(sender)
        triggerActionIfNeeded()
    }
    
    public func actionBlock(block:@escaping actionBlock) {
        self.mouseDownBlock = block
    }
}
