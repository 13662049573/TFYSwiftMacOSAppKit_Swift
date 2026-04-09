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
        
        // 将主Demo控制器添加为子控制器
        addChild(mainDemoViewController)
        view.addSubview(demoView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: view.topAnchor),
            demoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            demoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            demoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 通知子控制器已添加（macOS AppKit中不需要这个方法）
        // mainDemoViewController.didMove(toParent: self)
    }
}
