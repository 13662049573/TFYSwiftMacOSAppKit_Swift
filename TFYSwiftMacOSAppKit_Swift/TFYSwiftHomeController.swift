//
//  TFYSwiftHomeController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

class TFYSwiftHomeController: NSViewController {

    override func loadView() {
        let view:NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1100, height: 720))
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.red.cgColor
        
    }
    
}
