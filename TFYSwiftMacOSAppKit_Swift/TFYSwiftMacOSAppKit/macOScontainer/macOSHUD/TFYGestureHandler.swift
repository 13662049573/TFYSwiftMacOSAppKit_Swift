//
//  TFYGestureHandler.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/19.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// MARK: - Protocols
protocol TFYGestureHandlerDelegate: AnyObject {
    // Required
    func gestureHandler(_ handler: TFYGestureHandler, didRecognizeTapGesture gesture: NSGestureRecognizer)
    func gestureHandler(_ handler: TFYGestureHandler, didRecognizeSwipeGesture gesture: NSGestureRecognizer)
    
    // Optional
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeTapGesture gesture: NSGestureRecognizer) -> Bool
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeSwipeGesture gesture: NSGestureRecognizer) -> Bool
}

// Default implementations for optional methods
extension TFYGestureHandlerDelegate {
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeTapGesture gesture: NSGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureHandler(_ handler: TFYGestureHandler, shouldRecognizeSwipeGesture gesture: NSGestureRecognizer) -> Bool {
        return true
    }
}

class TFYGestureHandler: NSObject {
    // MARK: - Properties
    weak var delegate: TFYGestureHandlerDelegate?
    var gesturesEnabled: Bool = true {
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
    func setupGestures(for view: NSView) {
        targetView = view
        
        if gesturesEnabled {
            addTapGesture(to: view)
            addSwipeGesture(to: view)
        }
    }
    
    func addTapGesture(to view: NSView) {
        if let existingGesture = tapGesture {
            view.removeGestureRecognizer(existingGesture)
        }
        
        let newTapGesture = NSClickGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(newTapGesture)
        tapGesture = newTapGesture
    }
    
    func addSwipeGesture(to view: NSView) {
        if let existingGesture = swipeGesture {
            view.removeGestureRecognizer(existingGesture)
        }
        
        let newSwipeGesture = NSPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        view.addGestureRecognizer(newSwipeGesture)
        swipeGesture = newSwipeGesture
    }
    
    func removeAllGestureRecognizers() {
        if let view = targetView {
            for recognizer in view.gestureRecognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
        
        tapGesture = nil
        swipeGesture = nil
    }
    
    func cleanup() {
        removeAllGestureRecognizers()
        delegate = nil
        targetView = nil
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTapGesture(_ gesture: NSGestureRecognizer) {
        guard gesturesEnabled else { return }
        
        delegate?.gestureHandler(self, didRecognizeTapGesture: gesture)
    }
    
    @objc private func handleSwipeGesture(_ gesture: NSPanGestureRecognizer) {
        guard gesturesEnabled else { return }
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: targetView)
            
            // Check if it's a valid swipe gesture
            if abs(velocity.x) > 500 || abs(velocity.y) > 500 {
                delegate?.gestureHandler(self, didRecognizeSwipeGesture: gesture)
            }
        }
    }
    
    // MARK: - Deinitializer
    deinit {
        cleanup()
    }
}
