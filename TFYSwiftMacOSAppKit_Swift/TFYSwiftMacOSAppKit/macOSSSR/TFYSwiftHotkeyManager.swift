//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Carbon

// 自定义结构体包装 EventHotKeyID
public struct HotKeyIdentifier: Hashable {
    let id: UInt32
    let signature: OSType
    
    init(id: UInt32, signature: OSType) {
        self.id = id
        self.signature = signature
    }
    
    init(eventHotKeyID: EventHotKeyID) {
        self.id = eventHotKeyID.id
        self.signature = eventHotKeyID.signature
    }
}

public class TFYSwiftHotkeyManager {
    // 使用自定义结构体作为字典的键
    private var hotkeys: [HotKeyIdentifier: EventHotKeyRef] = [:]
    private let queue = DispatchQueue(label: "com.tfyswift.hotkeymanager")
    
    init() {
        setupEventHandler()
    }
    
    // 注册热键
    func registerHotkey(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        queue.async {
            var hotKeyRef: EventHotKeyRef?
            let hotKeyID = EventHotKeyID(signature: OSType("TFYH".fourCharCode), id: UInt32(self.hotkeys.count))
            let hotKeyIdentifier = HotKeyIdentifier(eventHotKeyID: hotKeyID)
            
            let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
            
            if status == noErr, let hotKeyRef = hotKeyRef {
                self.hotkeys[hotKeyIdentifier] = hotKeyRef
                HotkeyHandler.shared.addHandler(hotKeyID: hotKeyIdentifier, handler: handler)
            }
        }
    }
    
    // 注销所有热键
    func unregisterAllHotkeys() {
        queue.async {
            for (hotKeyID, hotKeyRef) in self.hotkeys {
                UnregisterEventHotKey(hotKeyRef)
                HotkeyHandler.shared.removeHandler(hotKeyID: hotKeyID)
            }
            self.hotkeys.removeAll()
        }
    }
    
    // 设置事件处理器
    private func setupEventHandler() {
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            let hotKeyIdentifier = HotKeyIdentifier(eventHotKeyID: hotKeyID)
            HotkeyHandler.shared.handleHotkey(hotKeyID: hotKeyIdentifier)
            return noErr
        }, 1, &eventSpec, nil, nil)
    }
}

// 热键处理器
private class HotkeyHandler {
    static let shared = HotkeyHandler()
    private var handlers: [HotKeyIdentifier: () -> Void] = [:]
    
    func addHandler(hotKeyID: HotKeyIdentifier, handler: @escaping () -> Void) {
        handlers[hotKeyID] = handler
    }
    
    func removeHandler(hotKeyID: HotKeyIdentifier) {
        handlers.removeValue(forKey: hotKeyID)
    }
    
    func handleHotkey(hotKeyID: HotKeyIdentifier) {
        handlers[hotKeyID]?()
    }
}

// 扩展 String 以支持四字符代码
private extension String {
    var fourCharCode: FourCharCode {
        return utf8.reduce(0) { ($0 << 8) + FourCharCode($1) }
    }
} 
