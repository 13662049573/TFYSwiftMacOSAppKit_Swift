//
//  TFYSwiftStatusItemDropView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

public class TFYSwiftStatusItemDropView: NSView {

    public var statusItem:TFYSwiftStatusItem?
    public var dropHandler:TFYStatusItemDropHandler?
    public var dropTypes:[NSPasteboard.PasteboardType] {
        set {
            self.privateDropTypes = newValue
            self.registerForDraggedTypes(self.privateDropTypes)
        }
        get {
            return self.privateDropTypes
        }
    }
    public var privateDropTypes:[NSPasteboard.PasteboardType] = []
    
    public func dropTypeInPasteboardTypes(pasteboardTypes:[NSPasteboard.PasteboardType]) -> String? {
        for type in dropTypes {
            if pasteboardTypes.contains(type) {
                return type.rawValue
            }
        }
        return nil
    }
    
    public override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        let pboard:NSPasteboard = sender.draggingPasteboard
        if (dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!) != nil) {
            return .copy
        } else {
            return .private
        }
    }
    
    public override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        let pboard:NSPasteboard = sender.draggingPasteboard
        let type:String? = dropTypeInPasteboardTypes(pasteboardTypes: pboard.types!)
        if type != nil {
            let items = pboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: type!))
            if dropHandler != nil {
                dropHandler!!(statusItem!,type!,items)
                return true
            }
        }
        return false
    }
}
