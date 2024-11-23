//
//  TFYProgressMacOSHUD.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import Carbon

/// 自定义热键标识符结构体，用于包装 EventHotKeyID
public struct HotKeyIdentifier: Hashable {
    /// 热键唯一标识符
    let id: UInt32
    /// 热键签名，用于区分不同应用的热键
    let signature: OSType
    
    /// 通过ID和签名初始化
    init(id: UInt32, signature: OSType) {
        self.id = id
        self.signature = signature
    }
    
    /// 通过系统热键ID初始化
    init(eventHotKeyID: EventHotKeyID) {
        self.id = eventHotKeyID.id
        self.signature = eventHotKeyID.signature
    }
}

/// 热键管理器类 - 负责注册和管理全局热键
public class TFYSwiftHotkeyManager {
    /// 存储已注册的热键，键为热键标识符，值为系统热键引用
    private var hotkeys: [HotKeyIdentifier: EventHotKeyRef] = [:]
    /// 用于同步热键操作的串行队列
    private let queue = DispatchQueue(label: "com.tfyswift.hotkeymanager")
    
    /// 初始化热键管理器并设置事件处理
    init() {
        setupEventHandler()
    }
    
    /// 注册新的热键
    /// - Parameters:
    ///   - keyCode: 键码
    ///   - modifiers: 修饰键（如Command、Option等）
    ///   - handler: 热键触发时的回调处理
    func registerHotkey(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        queue.async {
            var hotKeyRef: EventHotKeyRef?
            // 创建热键ID，使用自定义签名
            let hotKeyID = EventHotKeyID(signature: OSType("TFYH".fourCharCode), id: UInt32(self.hotkeys.count))
            let hotKeyIdentifier = HotKeyIdentifier(eventHotKeyID: hotKeyID)
            
            // 注册系统热键
            let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
            
            // 注册成功后保存热键引用和处理器
            if status == noErr, let hotKeyRef = hotKeyRef {
                self.hotkeys[hotKeyIdentifier] = hotKeyRef
                HotkeyHandler.shared.addHandler(hotKeyID: hotKeyIdentifier, handler: handler)
            }
        }
    }
    
    /// 注销所有已注册的热键
    func unregisterAllHotkeys() {
        queue.async {
            for (hotKeyID, hotKeyRef) in self.hotkeys {
                UnregisterEventHotKey(hotKeyRef)
                HotkeyHandler.shared.removeHandler(hotKeyID: hotKeyID)
            }
            self.hotkeys.removeAll()
        }
    }
    
    /// 设置系统事件处理器
    private func setupEventHandler() {
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            // 获取触发的热键ID
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            let hotKeyIdentifier = HotKeyIdentifier(eventHotKeyID: hotKeyID)
            // 调用对应的处理器
            HotkeyHandler.shared.handleHotkey(hotKeyID: hotKeyIdentifier)
            return noErr
        }, 1, &eventSpec, nil, nil)
    }
    
    /// 析构时注销所有热键
    deinit {
        unregisterAllHotkeys()
    }
}

/// 热键处理器单例类 - 管理热键的回调处理
private class HotkeyHandler {
    /// 共享实例
    static let shared = HotkeyHandler()
    /// 存储热键处理器，键为热键标识符，值为处理闭包
    private var handlers: [HotKeyIdentifier: () -> Void] = [:]
    
    /// 添加热键处理器
    func addHandler(hotKeyID: HotKeyIdentifier, handler: @escaping () -> Void) {
        handlers[hotKeyID] = handler
    }
    
    /// 移除热键处理器
    func removeHandler(hotKeyID: HotKeyIdentifier) {
        handlers.removeValue(forKey: hotKeyID)
    }
    
    /// 触发热键处理器
    func handleHotkey(hotKeyID: HotKeyIdentifier) {
        handlers[hotKeyID]?()
    }
}

/// String扩展 - 用于生成四字符代码
private extension String {
    /// 将字符串转换为四字符代码
    var fourCharCode: FourCharCode {
        return utf8.reduce(0) { ($0 << 8) + FourCharCode($1) }
    }
} 
