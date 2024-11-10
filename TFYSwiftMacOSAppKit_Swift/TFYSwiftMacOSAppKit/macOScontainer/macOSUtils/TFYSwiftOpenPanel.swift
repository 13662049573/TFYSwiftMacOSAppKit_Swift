//
//  TFYSwiftOpenPanel.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYSwiftOpenPanel: NSObject {

    static public func openPanelWithTitleMessage(titleMessage: String,
                                                     setPrompt: String,
                                                     canChooseFilesFlag: Bool,
                                                     allowsMultipleSelectionFlag: Bool,
                                                     canChooseDirectoriesFlag: Bool,
                                                     canCreateDirectoriesFlag: Bool,
                                                     dirURL: URL,
                                                     fileTypes: [String],
                                                     completionHandler: @escaping (_ openpanel: NSOpenPanel, _ URLs: [URL]) -> Void) {
            let panel = createPanel(titleMessage: titleMessage,
                                    prompt: setPrompt,
                                    canChooseFiles: canChooseFilesFlag,
                                    allowsMultipleSelection: allowsMultipleSelectionFlag,
                                    canChooseDirectories: canChooseDirectoriesFlag,
                                    canCreateDirectories: canCreateDirectoriesFlag,
                                    dirURL: dirURL,
                                    fileTypes: fileTypes)
            panel.beginSheetModal(for: NSApp.mainWindow!) { result in
                if result == .OK {
                    completionHandler(panel, panel.urls)
                } else if result == .cancel {
                    completionHandler(panel, panel.urls)
                }
            }
        }

        static public func savePanelWithTitleMessage(titleMessage: String,
                                                     prompt: String,
                                                     title: String,
                                                     fileName: String,
                                                     canCreateDirectoriesFlag: Bool,
                                                     allowsSelectingHiddenExtensionFlag: Bool,
                                                     dirURL: URL,
                                                     fileTypes: [String],
                                                     completionHandler: @escaping (_ openpanel: NSOpenPanel, _ url: URL?) -> Void) {
            let panel = createPanel(titleMessage: titleMessage,
                                    prompt: prompt,
                                    canChooseFiles: true,
                                    allowsMultipleSelection: false,
                                    canChooseDirectories: false,
                                    canCreateDirectories: canCreateDirectoriesFlag,
                                    dirURL: dirURL,
                                    fileTypes: fileTypes)
            panel.title = title
            panel.nameFieldStringValue = fileName
            panel.beginSheetModal(for: NSApp.mainWindow!) { result in
                if result == .OK {
                    completionHandler(panel, panel.url)
                } else if result == .cancel {
                    completionHandler(panel, panel.url ?? nil)
                }
            }
        }

        static public func savePanelWithAllowedFileTypes(fileTypes: [String],
                                                         frame: NSRect,
                                                         titleMessage: String,
                                                         prompt: String,
                                                         accessoryImage: NSImage,
                                                         completionHandler: @escaping (_ openpanel: NSOpenPanel, _ url: URL?) -> Void) {
            let panel = createPanel(titleMessage: titleMessage,
                                    prompt: prompt,
                                    canChooseFiles: true,
                                    allowsMultipleSelection: false,
                                    canChooseDirectories: false,
                                    canCreateDirectories: true,
                                    dirURL: nil,
                                    fileTypes: fileTypes)
            let accessoryView = NSView(frame: frame)
            let accessoryImageView = NSImageView(frame: accessoryView.frame)
            accessoryImageView.image = accessoryImage
            accessoryImageView.wantsLayer = true
            accessoryImageView.layer?.backgroundColor = NSColor.white.cgColor
            accessoryView.addSubview(accessoryImageView)
            panel.accessoryView = accessoryView
            panel.beginSheetModal(for: NSApp.mainWindow!) { result in
                if result == .OK {
                    completionHandler(panel, panel.url)
                } else if result == .cancel {
                    completionHandler(panel, panel.url ?? nil)
                }
            }
        }

        private static func createPanel(titleMessage: String,
                                        prompt: String,
                                        canChooseFiles: Bool,
                                        allowsMultipleSelection: Bool,
                                        canChooseDirectories: Bool,
                                        canCreateDirectories: Bool,
                                        dirURL: URL?,
                                        fileTypes: [String]) -> NSOpenPanel {
            let panel = NSOpenPanel()
            panel.prompt = prompt
            panel.message = titleMessage
            panel.canChooseDirectories = canChooseDirectories
            panel.canChooseFiles = canChooseFiles
            panel.allowsMultipleSelection = allowsMultipleSelection
            panel.allowedFileTypes = fileTypes
            panel.canCreateDirectories = canCreateDirectories
            panel.directoryURL = dirURL
            return panel
        }
}
