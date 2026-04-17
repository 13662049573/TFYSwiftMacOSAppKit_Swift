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
        // flipped：与 frame 的 y 向下递增一致，避免标题区落在视图下方
        self.view = DemoFlippedDocumentView(frame: NSRect(x: 0, y: 0, width: 400, height: 600))
    }
    
    lazy var textfiled: TFYSwiftLabel = {
        TFYSwiftLabel().chain
            .frame(NSRect(x: 20, y: 200, width: self.view.macos_width - 40, height: 50))
            .font(NSFont.systemFont(ofSize: 14, weight: .semibold))
            .wantsLayer(true)
            .backgroundColor(.white)
            .text("sssssssss")
            .textColor(.red)
            .focusRingType(.none)
            .build
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        view.wantsLayer = true
//        view.layer?.backgroundColor = NSColor.white.cgColor
     
        view.addSubview(textfiled)
        
        let emitterLayer = CAEmitterLayer()
        let cell = CAEmitterCell()
        // Use a system symbol image as the emitter particle; avoids a missing-asset crash
        let particleImage: NSImage
        if let sym = NSImage(systemSymbolName: "sparkle", accessibilityDescription: nil) {
            particleImage = sym
        } else {
            particleImage = NSImage(size: NSSize(width: 8, height: 8), flipped: false) { rect in
                NSColor.systemYellow.setFill()
                NSBezierPath(ovalIn: rect).fill()
                return true
            }
        }
        cell.contents = particleImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
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
