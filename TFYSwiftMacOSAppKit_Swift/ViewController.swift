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
    
    private lazy var lablel: TFYSwiftLabel = {
        let labe = TFYSwiftLabel().chain
            .frame(CGRect(x: 0, y: 0, width: 500, height: 100))
            .text("说的可不敢看谁都不敢开始崩溃时刻崩溃是白费口舌吧看《说的几个时刻》，《说的进口关税个》")
            .textColor(.gray)
            .font(.systemFont(ofSize: 14, weight: .bold))
            .borderColor(.orange)
            .borderWidth(2)
            .backgroundColor(.white)
            .build
        return labe
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(lineView)
        view.addSubview(control)
        view.addSubview(lablel)
        
        let color = NSColor.color(withHexString: "#F46734")
        
        
        lablel.changeColors(with: [color, .blue, .green,.yellow], changeTexts: ["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"])
        lablel.changeFonts(with: [.systemFont(ofSize: 8, weight: .bold), .systemFont(ofSize: 14, weight: .bold),.systemFont(ofSize: 25, weight: .semibold)], changeTexts: ["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"])
        
        lablel.addTapAction(["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"]) { string, range, int in
            TFYLog("点击了\(string)标签 - {\(range.location) , \(range.length)} - \(int)")
        }
    
        // 确保你的视图成为第一响应者
        self.view.window?.makeFirstResponder(self.view)
    }
    
    @objc func onClick() {
        
    }

    override func moveDown(_ sender: Any?) {
        
        print("ssssssssss")
    }
}

