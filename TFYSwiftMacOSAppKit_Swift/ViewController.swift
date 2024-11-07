//
//  ViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class ViewController: NSViewController {

    lazy var lineView: NSView = {
        let view = NSView(frame: NSRect(x: 200, y: 200, width: 300, height: 300))
        view.chain
            .cornerRadius(30)
            .backgroundColor(.red)
        return view
    }()
    
    lazy var control: NSControl = {
        let control = NSControl(frame: NSRect(x: 400, y: 200, width: 300, height: 300))
        control.chain
            .borderColor(.orange)
            .stringValue("Hello, World!")
            .font(.systemFont(ofSize: 16))
            .backgroundColor(.purple)
            .addTarget(self, action: #selector(onClick))
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(lineView)
        view.addSubview(control)
    }
    
    @objc func onClick() {
        
    }

}

