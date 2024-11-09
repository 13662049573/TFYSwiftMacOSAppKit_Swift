//
//  AppDelegate.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let showVc:TFYSwiftHomeController = TFYSwiftHomeController()
        showVc.preferredContentSize = NSSize(width: 400, height: 600)
        
        let view:NSView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.orange.cgColor
        TFYStatusItem.sharedInstance.presentStatusItemWithView(itemView: view, contentViewController: showVc) { item, title, data in
            TFYLog(item, title, data)
        }
        
//        TFYStatusItem.sharedInstance.presentStatusItemWithImage(itemImage: NSImage(named: "mood_analysis_select_5")!, contentViewController: showVc)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

