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
        
        // 将主Demo控制器添加为子控制器
        addChild(mainDemoViewController)
        view.addSubview(mainDemoViewController.view)
        
        // 设置约束
        mainDemoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainDemoViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            mainDemoViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainDemoViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainDemoViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 通知子控制器已添加（macOS AppKit中不需要这个方法）
        // mainDemoViewController.didMove(toParent: self)
    }
}

