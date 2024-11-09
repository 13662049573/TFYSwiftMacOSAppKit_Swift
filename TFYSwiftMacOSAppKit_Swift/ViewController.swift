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
            .frame(CGRect(x: 50, y: 100, width: 300, height: 50))
            .text("用户协议和隐私政策请您务必审值阅读、充分理解 “用户协议” 和 ”隐私政策” 各项条款，包括但不限于：为了向您提供即时通讯、内容分享等服务，我们需要收集您的设备信息、操作日志等个人信息。您可阅读《用户协议》和《隐私政策》了解详细信息。如果您同意，请点击 “同意” 开始接受我们的服务;")
            .textColor(.gray)
            .font(.systemFont(ofSize: 14, weight: .bold))
            .backgroundColor(.white)
            .build
        return labe
    }()
    
    lazy var button: NSButton = {
        let btn = NSButton(frame: NSRect(x: 200, y: 300, width: 400, height: 100))
        btn.chain
            .font(.systemFont(ofSize: 16, weight: .bold))
            .text("弹出界面")
            .wantsLayer(true)
            .textColor(.red)
            .cornerRadius(50)
            .border(2, borderColor: .orange)
            .backgroundColor(.blue)
            .bezelStyle(.smallSquare)
            .addTarget(self, action: #selector(onClick(btn:)));
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        view.addSubview(lablel)
        
        let color = NSColor(hexString: "F46734")
        
        lablel.changeColors(with: [color, .blue], changeTexts: ["《用户协议》","《隐私政策》"])
        lablel.changeFonts(with: [.systemFont(ofSize: 20, weight: .bold)], changeTexts: ["《用户协议》","《隐私政策》"])
        
        lablel.addTapAction(["《用户协议》","《隐私政策》"]) { string, range, int in
            TFYLog("点击了\(string)标签 - {\(range.location) , \(range.length)} - \(int)")
        }
        
    }
    
    @objc func onClick(btn:NSButton) {
        
        let showVc:TFYSwiftHomeController = TFYSwiftHomeController()
        showVc.preferredContentSize = NSSize(width: 400, height: 600)
        TFYStatusItem.sharedInstance.presentStatusItemWithView(itemView: btn, contentViewController: showVc) { item, title, data in
            TFYLog(item,title,data)
        }
    }

}

