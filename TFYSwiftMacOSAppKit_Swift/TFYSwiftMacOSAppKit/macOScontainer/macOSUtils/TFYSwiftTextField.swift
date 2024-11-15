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
    public var isTextAlignmentVerticalCenter:Bool = true {
        didSet {
            (self.cell as! TFYSwiftTextFieldCell).isTextAlignmentVerticalCenter = isTextAlignmentVerticalCenter
        }
    }
    /// 修改光标离X轴的距离 默认 0 isTextAlignmentVerticalCenter 为 YES 的时候 使用
    public var Xcursor:CGFloat = 10 {
        didSet {
            (self.cell as! TFYSwiftTextFieldCell).Xcursor = Xcursor
        }
    }
    
    weak public var delegate_swift: (any TFYSwiftNotifyingDelegate)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForNotifications()
    }
    
    func registerForNotifications() {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(delegate_swift?.textFieldDidChange(textField:)), name: NSControl.textDidChangeNotification, object: self)
    }
    
    public override func textDidChange(_ notification: Notification) {
        self.delegate_swift?.textFieldDidChange?(textField: self)
    }
    
    public override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if success {
            let textView:NSTextView = self.currentEditor() as! NSTextView
            textView.insertionPointColor = textColor
        }
        return success
    }
    
    public override var alignment: NSTextAlignment {
        didSet {
            let placeholderString = self.placeholderString
            if (placeholderString != nil) {
                let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: placeholderString!)
                let style:NSMutableParagraphStyle = (NSParagraphStyle.default as! NSMutableParagraphStyle)
                style.alignment = alignment
                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, placeholderString!.utf16.count))
                placeholderAttributedString = attributedString
            }
        }
    }
}

