//
//  ViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class ViewController: NSViewController {

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
    
    lazy var button: NSButton = {
        let btn = NSButton(frame: NSRect(x: 200, y: 300, width: 400, height: 160))
        btn.chain
            .font(.systemFont(ofSize: 16, weight: .bold))
            .textColor(.red)
            .borderColor(.white)
            .cornerRadius(80)
            .focusRingType(.none)
            .borderColor(.blue)
            .borderWidth(2)
            .addTarget(self, action: #selector(onClick))
            .backgroundColor(.blue);
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        view.addSubview(lablel)
        
        let color = NSColor(hexString: "F46734")
        
        lablel.changeColors(with: [color, .blue, .green,.yellow], changeTexts: ["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"])
        lablel.changeFonts(with: [.systemFont(ofSize: 35, weight: .bold), .systemFont(ofSize: 14, weight: .bold),.systemFont(ofSize: 12, weight: .semibold)], changeTexts: ["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"])
        
        lablel.addTapAction(["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"]) { string, range, int in
            TFYLog("点击了\(string)标签 - {\(range.location) , \(range.length)} - \(int)")
        }

    }
    
    @objc func onClick() {
        TFYLog("点击了====NSControl")
    }

}

