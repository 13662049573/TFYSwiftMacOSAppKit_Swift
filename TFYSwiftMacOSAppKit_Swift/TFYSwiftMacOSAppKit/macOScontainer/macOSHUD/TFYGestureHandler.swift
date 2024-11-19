//
//  TFYGestureHandler.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Gesture Handler Delegate Protocol
public protocol TFYGestureHandlerDelegate: AnyObject {
    func gestureHandler(_ handler: TFYGestureHandler, didRecognizeTapGesture gesture: NSGestureRecognizer)
    func gestureHandler(_ handler: TFYGestureHandler, didRecognizeSwipeGesture gesture: NSGestureRecognizer)
    
    // Optional methods
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeTapGesture gesture: NSGestureRecognizer) -> Bool
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeSwipeGesture gesture: NSGestureRecognizer) -> Bool
}

// Make optional methods actually optional
public extension TFYGestureHandlerDelegate {
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeTapGesture gesture: NSGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeSwipeGesture gesture: NSGestureRecognizer) -> Bool {
        return true
    }
}

public class TFYGestureHandler: NSObject {
    
    // MARK: - Properties
    public weak var delegate: TFYGestureHandlerDelegate?
    public var gesturesEnabled: Bool = true {
        didSet {
            if let targetView = targetView {
                if gesturesEnabled {
                    addTapGesture(to: targetView)
                    addSwipeGesture(to: targetView)
                } else {
                    removeAllGestureRecognizers()
                }
            }
        }
    }
    
    private var tapGesture: NSClickGestureRecognizer?
    private var swipeGesture: NSPanGestureRecognizer?
    private weak var targetView: NSView?
    
    // MARK: - Initialization
    override init() {
        super.init()
        gesturesEnabled = true
    }
    
    // MARK: - Public Methods
    public func setupGestures(for view: NSView) {
        targetView = view
        
        if gesturesEnabled {
            addTapGesture(to: view)
            addSwipeGesture(to: view)
        }
    }
    
    public func addTapGesture(to view: NSView) {
        if let existingGesture = tapGesture {
            view.removeGestureRecognizer(existingGesture)
        }
        
        let gesture = NSClickGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(gesture)
        tapGesture = gesture
    }
    
    public func addSwipeGesture(to view: NSView) {
        if let existingGesture = swipeGesture {
            view.removeGestureRecognizer(existingGesture)
        }
        
        let gesture = NSPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        view.addGestureRecognizer(gesture)
        swipeGesture = gesture
    }
    
    public func removeAllGestureRecognizers() {
        guard let view = targetView else { return }
        
        view.gestureRecognizers.forEach { view.removeGestureRecognizer($0) }
        tapGesture = nil
        swipeGesture = nil
    }
    
    public func cleanup() {
        removeAllGestureRecognizers()
        delegate = nil
        targetView = nil
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTapGesture(_ gesture: NSGestureRecognizer) {
        guard gesturesEnabled else { return }
        
        if delegate?.gestureHandler(self, shouldRecognizeTapGesture: gesture) ?? true {
            delegate?.gestureHandler(self, didRecognizeTapGesture: gesture)
        }
    }
    
    @objc private func handleSwipeGesture(_ gesture: NSPanGestureRecognizer) {
        guard gesturesEnabled else { return }
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: targetView)
            
            // Check if it's a valid swipe gesture (minimum velocity threshold)
            if abs(velocity.x) > 500 || abs(velocity.y) > 500 {
                if delegate?.gestureHandler(self, shouldRecognizeSwipeGesture: gesture) ?? true {
                    delegate?.gestureHandler(self, didRecognizeSwipeGesture: gesture)
                }
            }
        }
    }
    
    // MARK: - Cleanup
    deinit {
        cleanup()
    }
}
