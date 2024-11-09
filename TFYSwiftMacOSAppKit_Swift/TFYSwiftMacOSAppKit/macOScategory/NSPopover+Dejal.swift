//
//  NSPopover+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSPopover {
    
    static func create(with controller: NSViewController) -> NSPopover {
        let popover = NSPopover()
        popover.appearance = NSAppearance()
        popover.behavior = .transient
        popover.contentViewController = controller
        return popover
    }

    func show(in view: NSView, preferredEdge: NSRectEdge) {
        if isShown {
            close()
        }
        show(relativeTo: view.bounds, of: view, preferredEdge: preferredEdge)
    }
    
}
