//
//  TFYSwiftTextField.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

@objc public protocol TFYSwiftNotifyingDelegate: NSTextFieldDelegate {
    @objc @MainActor optional func textFieldDidChange(textField:NSTextField)
}

public class TFYSwiftTextField: NSTextField {
    /// 文字是否居中 默认 NO
    @objc public dynamic var isTextAlignmentVerticalCenter: Bool = true {
        didSet {
            (self.cell as? TFYSwiftTextFieldCell)?.isTextAlignmentVerticalCenter = isTextAlignmentVerticalCenter
        }
    }
    /// 修改光标离X轴的距离 默认 0 isTextAlignmentVerticalCenter 为 YES 的时候 使用
    @objc public dynamic var Xcursor: CGFloat = 10 {
        didSet {
            (self.cell as? TFYSwiftTextFieldCell)?.Xcursor = Xcursor
        }
    }
    
    /// 占位符文本颜色
    private var _placeholderColor: NSColor = .placeholderTextColor
    @objc public dynamic var placeholderColor: NSColor {
        get { return _placeholderColor }
        set {
            _placeholderColor = newValue
            updatePlaceholderAttributes()
        }
    }
    
    @objc weak public var delegate_swift: (any TFYSwiftNotifyingDelegate)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForNotifications()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForNotifications()
    }
    
    private func registerForNotifications() {
        autoresizingMask = [.width,.height]
        isBordered = false
        drawsBackground = true
        maximumNumberOfLines = 0
        usesSingleLineMode = true
        cell = TFYSwiftTextFieldCell(textCell: "")
        cell?.lineBreakMode = .byWordWrapping
        cell?.truncatesLastVisibleLine = true
        cell?.usesSingleLineMode = false
        cell?.isBezeled = false
        cell?.isBordered = false
        preferredMaxLayoutWidth = 100
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification(_:)), name: NSControl.textDidChangeNotification, object: self)
    }
    
    @objc private func textDidChangeNotification(_ notification: Notification) {
        delegate_swift?.textFieldDidChange?(textField: self)
    }
    
    public override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        delegate_swift?.textFieldDidChange?(textField: self)
    }
    
    public override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if success {
            if let textView = self.currentEditor() as? NSTextView {
                textView.insertionPointColor = textColor ?? .textColor
            }
        }
        return success
    }
    
    private func updatePlaceholderAttributes() {
        guard let placeholderString = self.placeholderString else { return }
        let attributedString = NSMutableAttributedString(string: placeholderString)
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .paragraphStyle: style
        ]
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: placeholderString.count))
        placeholderAttributedString = attributedString
    }
    
    public override var alignment: NSTextAlignment {
        didSet {
            updatePlaceholderAttributes()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

