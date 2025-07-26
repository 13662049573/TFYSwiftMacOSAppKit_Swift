//
//  TFYSwiftTextFieldView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by apple on 2024/11/22.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public class TFYSwiftTextFieldView: NSView {
    // MARK: - Properties
    
    private var plainPassword: String = ""
    private var isPasswordVisible: Bool = true
    
    var placeholderString: String = "" {
        didSet {
            let placeholder = msSetPlaceholder(placeholderString, color: NSColor.gray)
            plainTextField.placeholderAttributedString = placeholder
            secureTextField.placeholderAttributedString = placeholder
        }
    }
    
    var isEditable: Bool = true {
        didSet {
            plainTextField.isEditable = isEditable
            secureTextField.isEditable = isEditable
        }
    }
    
    var isSelectable: Bool = true {
        didSet {
            plainTextField.isSelectable = isSelectable
            secureTextField.isSelectable = isSelectable
        }
    }
    
    var stringValue: String {
        get {
            return isPasswordVisible ? plainTextField.stringValue : secureTextField.stringValue
        }
        set {
            let value = newValue
            plainTextField.stringValue = value
            secureTextField.stringValue = value
            plainPassword = value
        }
    }
   
    private lazy var secureTextField: TFYSwiftSecureTextField = {
        let text = TFYSwiftSecureTextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.delegate_swift = self;
        text.Xcursor = 10
        text.isTextAlignmentVerticalCenter = true
        text.lineBreakMode = .byTruncatingTail;
        text.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        text.textColor = .black
        text.isBordered = false
        text.focusRingType = .none
        text.bezelStyle = .roundedBezel
        return text
    }()
    
    private lazy var plainTextField: TFYSwiftTextField = {
        let text = TFYSwiftTextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.delegate_swift = self;
        text.Xcursor = 10
        text.isTextAlignmentVerticalCenter = true
        text.lineBreakMode = .byTruncatingTail;
        text.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        text.textColor = .black
        text.isBordered = false
        text.focusRingType = .none
        text.bezelStyle = .roundedBezel
        text.isHidden = true
        return text
    }()
    
    private lazy var toggleButton: NSButton = {
        let btn = NSButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isBordered = false
        btn.bezelStyle = .regularSquare
        btn.imagePosition = .imageOnly
        btn.imageScaling = .scaleProportionallyDown
        btn.image = NSImage(systemSymbolName: "eye.slash.fill", accessibilityDescription: nil)
        btn.target = self
        btn.action = #selector(togglePasswordVisibility(_:))
        return btn
    }()
    
    var changeBlock: ((String) -> Void)?
    
    // MARK: - Initialization
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 4
        layer?.borderColor = NSColor.gray.cgColor
        layer?.borderWidth = 1
        
        addSubview(secureTextField)
        addSubview(plainTextField)
        addSubview(toggleButton)
        
        setupConstraints()
        
        isPasswordVisible = true
        isEditable = true
        isSelectable = true
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            plainTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            plainTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            plainTextField.topAnchor.constraint(equalTo: topAnchor),
            plainTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            toggleButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 35),
            toggleButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func msSetPlaceholder(_ placeholder: String, color: NSColor) -> NSAttributedString {
        let font = NSFont.systemFont(ofSize: 14, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                return style
            }()
        ]
        return NSAttributedString(string: placeholder, attributes: attributes)
    }
    
    // MARK: - Actions
    @objc private func togglePasswordVisibility(_ sender: NSButton) {
        isPasswordVisible.toggle()
        
        let symbolName = isPasswordVisible ? "eye.fill" : "eye.slash.fill"
        toggleButton.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
            
        // Toggle text fields
        secureTextField.isHidden = isPasswordVisible
        plainTextField.isHidden = !isPasswordVisible
        
        // Sync text content
        if isPasswordVisible {
            plainTextField.stringValue = secureTextField.stringValue
            window?.makeFirstResponder(plainTextField)
        } else {
            secureTextField.stringValue = plainTextField.stringValue
            window?.makeFirstResponder(secureTextField)
        }
    }
}

// MARK: - NSTextFieldDelegate
extension TFYSwiftTextFieldView: TFYSwiftSecureTextDelegate,TFYSwiftNotifyingDelegate {
    
    public func securetextFieldDidChange(textField: NSSecureTextField) {
        plainPassword = textField.stringValue
        plainTextField.stringValue = textField.stringValue
        changeBlock?(textField.stringValue)
    }
    
    public func textFieldDidChange(textField: NSTextField) {
        plainPassword = textField.stringValue
        secureTextField.stringValue = textField.stringValue
        changeBlock?(textField.stringValue)
    }
}

