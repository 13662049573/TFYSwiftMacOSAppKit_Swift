//
//  TFYLayoutManager.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public typealias TFYLayoutBlock = (TFYProgressMacOSHUD) -> Void

public class TFYLayoutManager {
    
    // MARK: - Properties
    private var layouts: [Int: TFYLayoutBlock] = [:]
    private weak var currentHUD: TFYProgressMacOSHUD?
    private weak var currentContainer: NSView?
    private var activeConstraints: [NSLayoutConstraint] = []
    private var isUpdatingLayout = false
    private var isSettingConstraints = false
    
    // MARK: - Public Methods
    public func registerLayout(_ layout: @escaping TFYLayoutBlock, forMode mode: Int) {
        layouts[mode] = layout
    }
    
    public func applyLayout(forMode mode: Int, to hud: TFYProgressMacOSHUD) {
        guard let layout = layouts[mode] else { return }
        layout(hud)
    }
    
    public func setupHUDConstraints(_ hud: TFYProgressMacOSHUD) {
        invalidateLayout()
        
        hud.translatesAutoresizingMaskIntoConstraints = false
        hud.containerView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        let container = hud.containerView
        
        // Status label constraints if exists
        if !hud.statusLabel.stringValue.isEmpty {
            constraints.append(
                hud.statusLabel.topAnchor.constraint(equalTo: hud.customImageView.bottomAnchor, constant: 12)
            )
        }
        
        // Custom image view constraints
        constraints.append(contentsOf: [
            hud.customImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            hud.customImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            hud.customImageView.widthAnchor.constraint(equalToConstant: 32),
            hud.customImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Progress view constraints
        constraints.append(contentsOf: [
            hud.progressView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            hud.progressView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            hud.progressView.widthAnchor.constraint(equalToConstant: 40),
            hud.progressView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Container view constraints
        constraints.append(contentsOf: [
            container.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: hud.centerYAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: hud.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(lessThanOrEqualTo: hud.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate(constraints)
        activeConstraints.append(contentsOf: constraints)
    }
    
    public func setupConstraints(for hud: TFYProgressMacOSHUD) {
        guard let superview = hud.superview else { return }
        
        hud.translatesAutoresizingMaskIntoConstraints = false
        removeExistingConstraints(from: hud)
        
        let constraints = [
            hud.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            hud.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            hud.topAnchor.constraint(equalTo: superview.topAnchor),
            hud.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        activeConstraints.append(contentsOf: constraints)
    }
    
    public func invalidateLayout() {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()
    }
    
    // MARK: - Private Methods
    private func removeExistingConstraints(from view: NSView) {
        view.constraints.forEach { $0.isActive = false }
    }
}
