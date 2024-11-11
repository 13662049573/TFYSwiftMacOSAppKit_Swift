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
    
    lazy var textfiled: NSTextField = {
        let filed = NSTextField(frame: NSRect(x: 100, y: 200, width: 300, height: 50))
        filed.chain
            .font(NSFont.systemFont(ofSize: 14, weight: .semibold))
            .wantsLayer(true)
            .backgroundColor(.white)
            .text("sssssssss")
            .textColor(.red)
        return filed
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
     
        view.addSubview(textfiled)
    }
    
}
