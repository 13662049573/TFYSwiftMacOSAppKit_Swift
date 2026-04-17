//
//  NSButton+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/17/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

private enum TFYButtonAssociatedKeys {
    static var actionHandler: UInt8 = 0
}

@MainActor public extension NSButton {
    /// 使用闭包处理按钮点击
    /// - Parameter action: 点击回调
    func onAction(_ action: @escaping (NSButton) -> Void) {
        target = self
        self.action = #selector(tfy_handleButtonAction(_:))
        objc_setAssociatedObject(self, &TFYButtonAssociatedKeys.actionHandler, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }

    @objc private func tfy_handleButtonAction(_ sender: NSButton) {
        let action = objc_getAssociatedObject(self, &TFYButtonAssociatedKeys.actionHandler) as? (NSButton) -> Void
        action?(sender)
    }

    /// 当前是否处于选中状态
    var isOn: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }

    /// 切换按钮状态
    func toggleState() {
        state = state == .on ? .off : .on
    }

    /// 设置带图标的按钮内容
    /// - Parameters:
    ///   - title: 标题
    ///   - image: 图标
    ///   - imagePosition: 图标位置
    func configure(
        title: String,
        image: NSImage? = nil,
        imagePosition: NSControl.ImagePosition = .imageLeading
    ) {
        self.title = title
        self.image = image
        self.imagePosition = imagePosition
    }

    /// 创建复选框按钮
    /// - Parameters:
    ///   - title: 标题
    ///   - checked: 是否选中
    /// - Returns: 创建的按钮
    static func makeCheckbox(title: String, checked: Bool = false) -> NSButton {
        let button = NSButton(checkboxWithTitle: title, target: nil, action: nil)
        button.state = checked ? .on : .off
        return button
    }
}
