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
        showMainWindowIfNeeded()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showMainWindowIfNeeded()
        }
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
    
    private func showMainWindowIfNeeded() {
        let targetWindow: NSWindow?
        
        if let existingWindow = NSApp.windows.first(where: { !$0.isMiniaturized }) {
            targetWindow = existingWindow
        } else if let controller = NSStoryboard.main?.instantiateInitialController() as? NSWindowController {
            controller.showWindow(self)
            targetWindow = controller.window
        } else {
            targetWindow = nil
        }
        
        guard let window = targetWindow else { return }
        window.title = "TFYSwiftMacOSAppKit Demo"
        window.setContentSize(NSSize(width: 1280, height: 860))
        window.minSize = NSSize(width: 1120, height: 760)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
