//
//  TFYSwiftOpenPanel.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import AppKit
import Foundation

public class TFYSwiftOpenPanel: NSObject {

    static public func openPanelWithTitleMessage(ttMessage:String,
                                   setPrompt:String,
                                   bChooseFiles:Bool,
                                   bSelection:Bool,
                                   bChooseDirc:Bool,
                                   bCreateDirc:Bool,
                                   dirURL:URL,
                                   fileTypes:[String],
                                   completionHandler:@escaping (_ openpanel:NSOpenPanel,_ URLs:[URL]) -> Void) {
        
        let panel:NSOpenPanel = NSOpenPanel()
        panel.prompt = setPrompt
        panel.message = ttMessage
        panel.canChooseDirectories = bChooseDirc
        panel.canChooseFiles = bChooseFiles
        panel.allowsMultipleSelection = bSelection
        panel.allowedFileTypes = fileTypes
        panel.directoryURL = dirURL
        panel.beginSheetModal(for: NSApp.mainWindow!) { result in
            if result == .OK {
                completionHandler(panel,panel.urls)
            } else if result == .cancel {
                completionHandler(panel,panel.urls)
            }
        }
    }
    
    static public func savePanelWithTitleMessage(ttMessage:String,
                                                 prompt:String,
                                                 title:String,
                                                 fileName:String,
                                                 bCreateDirc:Bool,
                                                 bSelectHiddenExtension:Bool,
                                                 dirURL:URL,
                                                 fileTypes:[String],
                                                 completionHandler:@escaping (_ openpanel:NSOpenPanel,_ url:URL?) -> Void) {
        let panel:NSOpenPanel = NSOpenPanel()
        panel.message = ttMessage
        panel.prompt = prompt
        panel.allowedFileTypes = fileTypes
        panel.canCreateDirectories = bCreateDirc
        panel.title = title
        panel.nameFieldStringValue = fileName
        panel.directoryURL = dirURL
        panel.beginSheetModal(for: NSApp.mainWindow!) { result in
            if (result == .OK) {
                completionHandler(panel,panel.url!);
            }else if(result == .cancel) {
                completionHandler(panel,panel.url);
            }
        }
        
    }
    
    static public func savePanelWithAllowedFileTypes(fileTypes:[String],
                                                     frame:NSRect,
                                                     ttMessage:String,
                                                     prompt:String,
                                                     accessoryImage:NSImage,
                                                     completionHandler:@escaping (_ openpanel:NSOpenPanel,_ url:URL?) -> Void) {
        let panel:NSOpenPanel = NSOpenPanel()
        let accessoryView:NSView = NSView(frame: frame)
        let accessoryImageView:NSImageView = NSImageView(frame: accessoryView.frame)
        accessoryImageView.image = accessoryImage
        accessoryImageView.wantsLayer = true
        accessoryImageView.layer?.backgroundColor = NSColor.white.cgColor
        accessoryView.addSubview(accessoryImageView)
        panel.accessoryView = accessoryView
        panel.allowedFileTypes = fileTypes
        panel.canCreateDirectories = true
        panel.beginSheetModal(for: NSApp.mainWindow!) { result in
            if (result == .OK) {
                completionHandler(panel,panel.url!);
            }else if(result == .cancel) {
                completionHandler(panel,panel.url);
            }
        }
    }
}
