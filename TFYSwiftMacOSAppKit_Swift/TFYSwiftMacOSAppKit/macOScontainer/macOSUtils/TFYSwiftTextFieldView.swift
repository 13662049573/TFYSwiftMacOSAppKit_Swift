//
//  TFYSwiftTextFieldView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/22.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYSwiftTextFieldView: NSView {

    /// 当前输入的文本
    public var stringValue: String {
        get { return isPasswordVisible ? plainTextField.stringValue : secureTextField.stringValue }
        set {
            plainTextField.stringValue = newValue
            secureTextField.stringValue = newValue
            plainPassword = newValue
        }
    }
    
    /// 占位符文本
    public var placeholderString: String? {
        didSet {
            plainTextField.placeholderString = placeholderString
            secureTextField.placeholderString = placeholderString
        }
    }
    
    /// 是否可编辑
    public var isEditable: Bool = true {
        didSet {
            plainTextField.isEditable = isEditable
            secureTextField.isEditable = isEditable
        }
    }
    
    /// 是否可选择
    public var isSelectable: Bool = true {
        didSet {
            plainTextField.isSelectable = isSelectable
            secureTextField.isSelectable = isSelectable
        }
    }
    
    // MARK: - Private Properties
    
    private var plainPassword: String = ""
    private var isPasswordVisible = false
    
    private lazy var secureTextField: TFYSwiftSecureTextField = {
        let field = TFYSwiftSecureTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        field.isTextAlignmentVerticalCenter = true
        field.bezelStyle = .roundedBezel
        return field
    }()
    
    private lazy var plainTextField: TFYSwiftTextField = {
        let field = TFYSwiftTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        field.bezelStyle = .roundedBezel
        field.isTextAlignmentVerticalCenter = true
        field.isHidden = true
        return field
    }()
    
    private lazy var toggleButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .inline
        button.isBordered = false
        button.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: nil)
        button.target = self
        button.action = #selector(togglePasswordVisibility)
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        // 添加子视图
        addSubview(secureTextField)
        addSubview(plainTextField)
        addSubview(toggleButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 安全文本框约束
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 普通文本框约束
            plainTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            plainTextField.topAnchor.constraint(equalTo: topAnchor),
            plainTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 切换按钮约束
            toggleButton.leadingAnchor.constraint(equalTo: secureTextField.trailingAnchor, constant: 4),
            toggleButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 20),
            toggleButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        
        // 更新按钮图标
        let imageName = isPasswordVisible ? "eye.slash.fill" : "eye.fill"
        toggleButton.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        
        // 切换文本框显示
        secureTextField.isHidden = isPasswordVisible
        plainTextField.isHidden = !isPasswordVisible
        
        // 同步文本内容
        if isPasswordVisible {
            plainTextField.stringValue = secureTextField.stringValue
        } else {
            secureTextField.stringValue = plainTextField.stringValue
        }
        
        // 使当前显示的文本框成为第一响应者
        if isPasswordVisible {
            window?.makeFirstResponder(plainTextField)
        } else {
            window?.makeFirstResponder(secureTextField)
        }
    }
    
}

extension TFYSwiftTextFieldView: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            // 同步两个文本框的内容
            if textField === plainTextField {
                plainPassword = textField.stringValue
                secureTextField.stringValue = textField.stringValue
            } else if textField === secureTextField {
                plainPassword = textField.stringValue
                plainTextField.stringValue = textField.stringValue
            }
        }
    }
}
