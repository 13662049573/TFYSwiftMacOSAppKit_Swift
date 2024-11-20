//
//  TFYLayoutManager.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Type Aliases
typealias TFYLayoutBlock = (TFYProgressMacOSHUD) -> Void

class TFYLayoutManager: NSObject {
    // MARK: - Properties
    private var layouts: [Int: TFYLayoutBlock] = [:]
    private weak var currentHUD: TFYProgressMacOSHUD?
    private weak var currentContainer: NSView?
    private var activeConstraints: [NSLayoutConstraint] = []
    private var isUpdatingLayout: Bool = false
    private var isSettingConstraints: Bool = false
    
    // MARK: - Layout Registration
    func registerLayout(_ layout: @escaping TFYLayoutBlock, for mode: Int) {
        layouts[mode] = layout
    }
    
    func applyLayout(for mode: Int, to hud: TFYProgressMacOSHUD) {
        guard let layout = layouts[mode] else { return }
        layout(hud)
    }
    
    func removeLayout(for mode: Int) {
        layouts.removeValue(forKey: mode)
    }
    
    // MARK: - Constraint Setup
    func setupHUDConstraints(_ hud: TFYProgressMacOSHUD) {
        invalidateLayout()
        
        hud.translatesAutoresizingMaskIntoConstraints = false
        hud.containerView.translatesAutoresizingMaskIntoConstraints = false
        
        var allConstraints: [NSLayoutConstraint] = []
        let container = hud.containerView
        
        // Status label constraints if exists
        if !hud.statusLabel.stringValue.isEmpty {
            allConstraints.append(
                hud.statusLabel.topAnchor.constraint(equalTo: hud.customImageView.bottomAnchor, constant: 12)
            )
        }
        
        // Custom image view constraints
        allConstraints.append(contentsOf: [
            hud.customImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            hud.customImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            hud.customImageView.widthAnchor.constraint(equalToConstant: 32),
            hud.customImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Progress view constraints
        allConstraints.append(contentsOf: [
            hud.progressView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            hud.progressView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            hud.progressView.widthAnchor.constraint(equalToConstant: 40),
            hud.progressView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Container view constraints
        allConstraints.append(contentsOf: [
            container.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: hud.centerYAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: hud.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(lessThanOrEqualTo: hud.trailingAnchor, constant: -40)
        ])
        
        // Activity indicator constraints
        allConstraints.append(contentsOf: [
            hud.activityIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            hud.activityIndicator.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            hud.activityIndicator.widthAnchor.constraint(equalToConstant: 32),
            hud.activityIndicator.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Status label constraints
        allConstraints.append(contentsOf: [
            hud.statusLabel.topAnchor.constraint(equalTo: hud.activityIndicator.bottomAnchor, constant: 12),
            hud.statusLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            hud.statusLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            hud.statusLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate(allConstraints)
        activeConstraints.append(contentsOf: allConstraints)
    }
    
    // 添加新方法
    func setupSubviewsConstraints(_ hud: TFYProgressMacOSHUD) {
        // 确保所有子视图都禁用自动约束转换
        hud.containerView.translatesAutoresizingMaskIntoConstraints = false
        hud.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        hud.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        hud.progressView.translatesAutoresizingMaskIntoConstraints = false
        hud.customImageView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        // 容器视图约束
        constraints.append(contentsOf: [
            hud.containerView.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            hud.containerView.centerYAnchor.constraint(equalTo: hud.centerYAnchor),
            hud.containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            hud.containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        // 活动指示器约束
        constraints.append(contentsOf: [
            hud.activityIndicator.centerXAnchor.constraint(equalTo: hud.containerView.centerXAnchor),
            hud.activityIndicator.topAnchor.constraint(equalTo: hud.containerView.topAnchor, constant: 20),
            hud.activityIndicator.widthAnchor.constraint(equalToConstant: 32),
            hud.activityIndicator.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // 进度视图约束
        constraints.append(contentsOf: [
            hud.progressView.centerXAnchor.constraint(equalTo: hud.containerView.centerXAnchor),
            hud.progressView.topAnchor.constraint(equalTo: hud.containerView.topAnchor, constant: 20),
            hud.progressView.widthAnchor.constraint(equalToConstant: 40),
            hud.progressView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // 自定义图像视图约束
        constraints.append(contentsOf: [
            hud.customImageView.centerXAnchor.constraint(equalTo: hud.containerView.centerXAnchor),
            hud.customImageView.topAnchor.constraint(equalTo: hud.containerView.topAnchor, constant: 20),
            hud.customImageView.widthAnchor.constraint(equalToConstant: 32),
            hud.customImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // 状态标签约束
        constraints.append(contentsOf: [
            hud.statusLabel.topAnchor.constraint(equalTo: hud.activityIndicator.bottomAnchor, constant: 12),
            hud.statusLabel.leadingAnchor.constraint(equalTo: hud.containerView.leadingAnchor, constant: 16),
            hud.statusLabel.trailingAnchor.constraint(equalTo: hud.containerView.trailingAnchor, constant: -16),
            hud.statusLabel.bottomAnchor.constraint(equalTo: hud.containerView.bottomAnchor, constant: -16)
        ])
        
        // 根据当前模式调整约束优先级
        switch hud.mode {
        case .text:
            // 纯文本模式时，调整状态标签的约束
            let topConstraint = hud.statusLabel.topAnchor.constraint(equalTo: hud.containerView.topAnchor, constant: 16)
            topConstraint.priority = .defaultHigh
            constraints.append(topConstraint)
            
        case .customView:
            // 自定义视图模式时，调整图像视图的约束
            let imageTopConstraint = hud.customImageView.topAnchor.constraint(equalTo: hud.containerView.topAnchor, constant: 20)
            imageTopConstraint.priority = .defaultHigh
            constraints.append(imageTopConstraint)
            
        default:
            break
        }
        
        // 激活所有约束
        NSLayoutConstraint.activate(constraints)
        activeConstraints.append(contentsOf: constraints)
    }
    
    func setupConstraints(for hud: TFYProgressMacOSHUD) {
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
    
    func setupAdaptiveLayout(for hud: TFYProgressMacOSHUD) {
        hud.translatesAutoresizingMaskIntoConstraints = false
        hud.containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Container view priorities
        hud.containerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        hud.containerView.setContentCompressionResistancePriority(.required, for: .vertical)
        hud.containerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        hud.containerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        // Status label priorities
        hud.statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        hud.statusLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        hud.statusLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        hud.statusLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    // MARK: - Helper Methods
    func invalidateLayout() {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()
    }
    
    private func removeExistingConstraints(from view: NSView) {
        view.constraints.forEach { $0.isActive = false }
    }
    
    func setupDefaultConstraints(_ hud: TFYProgressMacOSHUD, constraints: inout [NSLayoutConstraint]) {
        let container = hud.containerView
        
        // Base container constraints
        constraints.append(contentsOf: [
            container.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: hud.centerYAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        setupConstraintsBasedOnMode(hud, container: container, constraints: &constraints)
    }
    
    private func setupConstraintsBasedOnMode(_ hud: TFYProgressMacOSHUD, container: NSView, constraints: inout [NSLayoutConstraint]) {
        if !hud.activityIndicator.isHidden {
            setupActivityIndicatorConstraints(hud, container: container, constraints: &constraints)
        } else if !hud.statusLabel.isHidden {
            setupStatusLabelOnlyConstraints(hud, container: container, constraints: &constraints)
        }
    }
    
    private func setupActivityIndicatorConstraints(_ hud: TFYProgressMacOSHUD, container: NSView, constraints: inout [NSLayoutConstraint]) {
        let baseConstraints = [
            hud.activityIndicator.widthAnchor.constraint(equalToConstant: 32),
            hud.activityIndicator.heightAnchor.constraint(equalToConstant: 32),
            hud.activityIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ]
        constraints.append(contentsOf: baseConstraints)
        
        if !hud.statusLabel.isHidden {
            setupActivityIndicatorWithLabelConstraints(hud, container: container, constraints: &constraints)
        } else {
            let centerYConstraint = hud.activityIndicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            centerYConstraint.priority = .required
            constraints.append(centerYConstraint)
        }
    }
    
    private func setupActivityIndicatorWithLabelConstraints(_ hud: TFYProgressMacOSHUD, container: NSView, constraints: inout [NSLayoutConstraint]) {
        let topConstraint = hud.activityIndicator.topAnchor.constraint(equalTo: container.topAnchor, constant: 20)
        topConstraint.priority = .defaultHigh
        
        constraints.append(contentsOf: [
            topConstraint,
            hud.statusLabel.topAnchor.constraint(equalTo: hud.activityIndicator.bottomAnchor, constant: 12),
            hud.statusLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            hud.statusLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            hud.statusLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupStatusLabelOnlyConstraints(_ hud: TFYProgressMacOSHUD, container: NSView, constraints: inout [NSLayoutConstraint]) {
        constraints.append(contentsOf: [
            hud.statusLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            hud.statusLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            hud.statusLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            hud.statusLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
}
