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
    public private(set) var isPasswordVisible: Bool = false
    
    public var placeholderString: String = "" {
        didSet {
            updatePlaceholder()
        }
    }

    public var placeholderColor: NSColor = .gray {
        didSet {
            updatePlaceholder()
        }
    }
    
    public var isEditable: Bool = true {
        didSet {
            plainTextField.isEditable = isEditable
            secureTextField.isEditable = isEditable
        }
    }
    
    public var isSelectable: Bool = true {
        didSet {
            plainTextField.isSelectable = isSelectable
            secureTextField.isSelectable = isSelectable
        }
    }

    public var fieldFont: NSFont = .systemFont(ofSize: 14, weight: .regular) {
        didSet {
            plainTextField.font = fieldFont
            secureTextField.font = fieldFont
            updatePlaceholder()
        }
    }

    public var fieldTextColor: NSColor = .black {
        didSet {
            plainTextField.textColor = fieldTextColor
            secureTextField.textColor = fieldTextColor
        }
    }

    public var showsVisibilityToggle: Bool = true {
        didSet {
            toggleButton.isHidden = !showsVisibilityToggle
        }
    }
    
    public var stringValue: String {
        get {
            return isPasswordVisible ? plainTextField.stringValue : secureTextField.stringValue
        }
        set {
            syncTextFields(with: newValue)
        }
    }
   
    private lazy var secureTextField: TFYSwiftSecureTextField = {
        let text = TFYSwiftSecureTextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.delegate_swift = self;
        text.Xcursor = 10
        text.isTextAlignmentVerticalCenter = true
        text.lineBreakMode = .byTruncatingTail;
        text.font = fieldFont
        text.textColor = fieldTextColor
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
        text.font = fieldFont
        text.textColor = fieldTextColor
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
        btn.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: nil)
        btn.target = self
        btn.action = #selector(togglePasswordVisibility(_:))
        return btn
    }()
    
    public var changeBlock: ((String) -> Void)?
    
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
        updatePlaceholder()
        showsVisibilityToggle = true
        applyVisibilityState(makeFirstResponder: false)
        
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
    
    private func makePlaceholder(_ placeholder: String, color: NSColor) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: fieldFont,
            .foregroundColor: color,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                return style
            }()
        ]
        return NSAttributedString(string: placeholder, attributes: attributes)
    }

    private func updatePlaceholder() {
        let placeholder = makePlaceholder(placeholderString, color: placeholderColor)
        plainTextField.placeholderAttributedString = placeholder
        secureTextField.placeholderAttributedString = placeholder
    }

    private func syncTextFields(with value: String) {
        plainPassword = value
        plainTextField.stringValue = value
        secureTextField.stringValue = value
    }

    private func applyVisibilityState(makeFirstResponder: Bool) {
        toggleButton.image = NSImage(
            systemSymbolName: isPasswordVisible ? "eye.slash.fill" : "eye.fill",
            accessibilityDescription: nil
        )

        secureTextField.isHidden = isPasswordVisible
        plainTextField.isHidden = !isPasswordVisible

        guard makeFirstResponder else { return }
        if isPasswordVisible {
            window?.makeFirstResponder(plainTextField)
        } else {
            window?.makeFirstResponder(secureTextField)
        }
    }

    public func setPasswordVisible(_ visible: Bool) {
        isPasswordVisible = visible
        applyVisibilityState(makeFirstResponder: window != nil)
    }

    public func togglePasswordVisibility() {
        setPasswordVisible(!isPasswordVisible)
    }

    public func setChangeHandler(_ handler: @escaping (String) -> Void) {
        changeBlock = handler
    }
    
    // MARK: - Actions
    @objc private func togglePasswordVisibility(_ sender: NSButton) {
        togglePasswordVisibility()
    }
}

// MARK: - NSTextFieldDelegate
extension TFYSwiftTextFieldView: TFYSwiftSecureTextDelegate,TFYSwiftNotifyingDelegate {
    
    public func securetextFieldDidChange(textField: NSSecureTextField) {
        syncTextFields(with: textField.stringValue)
        changeBlock?(textField.stringValue)
    }
    
    public func textFieldDidChange(textField: NSTextField) {
        syncTextFields(with: textField.stringValue)
        changeBlock?(textField.stringValue)
    }
}
