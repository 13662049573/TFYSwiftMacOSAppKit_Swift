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
        let view:NSView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 600))
        self.view = view
    }
    
    lazy var textfiled: NSTextField = {
        let filed = NSTextField(frame: NSRect(x: 20, y: 200, width: self.view.macos_width-40, height: 50))
        filed.chain
            .font(NSFont.systemFont(ofSize: 14, weight: .semibold))
            .wantsLayer(true)
            .backgroundColor(.white)
            .text("sssssssss")
            .textColor(.red)
            .focusRingType(.none)
        return filed
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        view.wantsLayer = true
//        view.layer?.backgroundColor = NSColor.white.cgColor
     
        view.addSubview(textfiled)
        
        let emitterLayer = CAEmitterLayer()
        let cell = CAEmitterCell()
        cell.contents = NSImage(named: "mood_background_1")?.cgImage
        cell.birthRate = 10
        cell.lifetime = 5
        cell.velocity = 100
        cell.scale = 0.5

        emitterLayer.chain
            .emitterCells([cell])
            .birthRate(1.0)
            .lifetime(2.0)
            .emitterPosition(NSPoint(x: 100, y: 100))
            .emitterSize(NSSize(width: 50, height: 50))
            .emitterShape(.line)
            .emitterMode(.surface)
            .renderMode(.additive)
            .velocity(100.0)
            .scale(1.0)
            .spin(2.0)
            .preservesDepth(true)
        
        textfiled.layer?.addSublayer(emitterLayer)
    }
    
}
