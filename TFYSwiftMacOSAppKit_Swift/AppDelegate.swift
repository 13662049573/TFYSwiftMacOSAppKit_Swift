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
        // Repair main menu hierarchy to avoid "Internal inconsistency in menus" (root menu sometimes has no items after load)
        repairMainMenuIfNeeded()

        // Insert code here to initialize your application
        let showVc:TFYSwiftHomeController = TFYSwiftHomeController()
        showVc.preferredContentSize = NSSize(width: 400, height: 600)
        
        let view:NSView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.orange.cgColor

//        // 配置图片和视图控制器
//        TFYStatusItem.shared.configureSafely(with: .init(
//            image: NSImage(named: "mood_analysis_select_5"),
//            viewController: showVc
//        ))

        // 配置自定义视图和视图控制器
        TFYStatusItem.shared.configureSafely(with: .init(
            customView: view,
            viewController: showVc
        ))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    /// Re-sets main menu so AppKit re-syncs the menu bar; helps avoid "Internal inconsistency in menus" when storyboard loads.
    private func repairMainMenuIfNeeded() {
        guard let menu = NSApplication.shared.mainMenu else { return }
        NSApplication.shared.mainMenu = menu
        // Restore system behavior for Services and Window menus (we removed systemMenu from storyboard to fix hierarchy)
        for item in menu.items {
            if item.submenu?.title == "Services" {
                NSApplication.shared.servicesMenu = item.submenu
                break
            }
        }
        for item in menu.items {
            if item.submenu?.title == "Window" {
                NSApplication.shared.windowsMenu = item.submenu
                break
            }
        }
    }
}

