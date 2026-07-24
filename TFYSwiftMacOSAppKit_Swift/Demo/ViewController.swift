//
//  ViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建主Demo控制器
        let mainDemoViewController = MainDemoViewController()
        let demoView = mainDemoViewController.view.chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        // 将主Demo控制器添加为子控制器（AppKit 的 NSViewController 没有 UIKit 那样的 didMove(toParent:) 回调，
        // addChild(_:) + addSubview(_:) 即完成容器关系建立）
        addChild(mainDemoViewController)
        view.addSubview(demoView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: view.topAnchor),
            demoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            demoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            demoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        demoView.setAccessibilityLabel("TFYSwiftMacOSAppKit 演示内容")
        view.setAccessibilityLabel("应用主窗口内容区域")
        view.setAccessibilityChildren([demoView])
    }
}
