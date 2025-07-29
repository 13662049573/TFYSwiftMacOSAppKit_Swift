//
//  NSView+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public extension NSView {

    var macos_origin:CGPoint {
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin
        }
    }
    
    var macos_x:CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var macos_y:CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var macos_size:CGSize {
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return self.frame.size
        }
    }
    
    var macos_width:CGFloat {
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.width
        }
    }
    
    var macos_height:CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.height
        }
    }
    
    var macos_top:CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    var macos_bottom:CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue - self.frame.size.height
            self.frame = frame
        }
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    var macos_left:CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var macos_right:CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue - self.frame.size.width
            self.frame = frame
        }
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
}

private let defaultTimeInterval: TimeInterval = 60.0
private let buttonTitleFormat: String = "剩余%ld 秒"
private let retainButtonTitle: String = "重新获取"

public extension NSView {
    
    private struct AssociatedObjectKeys {
        static var timeKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "timeKey".hashValue)!
        static var formatKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "formatKey".hashValue)!
        static var stopTimeKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "stopTimeKey".hashValue)!
        static var timerKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "timerKey".hashValue)!
        static var userTimeKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "userTimeKey".hashValue)!
        static var clickHandlerKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "clickHandlerKey".hashValue)!
        static var longPressHandlerKey: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "longPressHandlerKey".hashValue)!
    }

    func removeAllSubviews() {
        while subviews.count > 0 {
            subviews.first?.removeFromSuperview()
        }
    }

    func viewController() -> NSViewController? {
        // 更简洁的获取视图控制器的方式
        if let window = window {
            if let delegate = window.delegate as? NSViewController {
                return delegate
            }
        }
        return nil
    }

    var timeInterval: TimeInterval {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.timeKey, NSNumber(value: newValue),.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let number: NSNumber = objc_getAssociatedObject(self, AssociatedObjectKeys.timeKey) as! NSNumber
            return number.doubleValue
        }
    }

    private var userTimeInterval: TimeInterval {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.userTimeKey, NSNumber(value: newValue),.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let number: NSNumber = objc_getAssociatedObject(self, AssociatedObjectKeys.userTimeKey) as! NSNumber
            return number.doubleValue
        }
    }

    var titleFormat: String? {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.formatKey, newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, AssociatedObjectKeys.formatKey) as? String
        }
    }

    private var stopTime: Int {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.stopTimeKey, NSNumber(integerLiteral: newValue),.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let number: NSNumber = objc_getAssociatedObject(self, AssociatedObjectKeys.stopTimeKey) as! NSNumber
            return number.intValue
        }
    }

    private var timer: DispatchSourceTimer? {
        set {
            objc_setAssociatedObject(self, AssociatedObjectKeys.timerKey, newValue,.OBJC_ASSOCIATION_COPY)
        }
        get {
            return objc_getAssociatedObject(self, AssociatedObjectKeys.timerKey) as? DispatchSourceTimer
        }
    }

    func startOrStopTimer(start: Bool, block: @escaping (String, Int) -> Void) {
        if start {
            // Initialize timeInterval and titleFormat only if they are not set
            timeInterval = timeInterval == 0 ? defaultTimeInterval : timeInterval
            titleFormat = titleFormat ?? buttonTitleFormat

            let globalQueue = DispatchQueue.global(qos: .default)
            timer = DispatchSource.makeTimerSource(queue: globalQueue)
            timer?.schedule(deadline: .now(), repeating: 1.0)
            timer?.setEventHandler { [weak self] in
                guard let self = self else { return }
                if self.timeInterval <= 1 {
                    self.timer?.cancel()
                } else {
                    self.timeInterval -= 1
                    DispatchQueue.main.async {
                        self.stopTime = 1
                        block(String(format: self.titleFormat!, self.timeInterval), 0)
                    }
                }
            }
            timer?.setCancelHandler { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.stopTime = 0
                    block(retainButtonTitle, 1)
                    self.timeInterval = self.userTimeInterval > 0 ? self.userTimeInterval : defaultTimeInterval
                }
            }
            timer?.resume()
        } else {
            timer?.cancel()
        }
    }
    
    func startAnimationWithFadeInDuration(fadeInDuration: TimeInterval) {
        self.alphaValue = 0.0
        // 这里假设没有找到 startAnimation 的实现，我们可以使用另一种动画方式来替代，比如使用隐式动画。
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1) // 设置一个短暂的初始动画时间
        self.layer?.opacity = 0.01
        CATransaction.commit()
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = fadeInDuration
            self.animator().alphaValue = 1.0
        }, completionHandler: nil)
    }
    
    func adjustAutoresizeMasks() -> [NSNumber] {
        return adjustAutoresizingAroundPosition(NSMaxY(self.frame), stickPositionToTop: true)
    }

    func adjustAutoresizingAroundPosition(_ position: CGFloat, stickPositionToTop: Bool) -> [NSNumber] {
        var subviewMasks = [NSNumber]()
        var superview = self
        var oldSuperview = superview

        // Declare position as a variable
        var positionValue = position

        while !superview.isFlipped {
            // Adjust the parent view's mask:
            let mask = superview.autoresizingMask
            subviewMasks.append(NSNumber(value: mask.rawValue))

            // Make it stick to the top and bottom of the window, and change height:
            var newMask = mask
            newMask.insert(.height)
            newMask.remove([.maxYMargin, .minYMargin])
            superview.autoresizingMask = newMask

            let subviews = superview.subviews

            for subview in subviews where subview != oldSuperview {
                let oldSubviewMask = subview.autoresizingMask
                subviewMasks.append(NSNumber(value: oldSuperview.autoresizingMask.rawValue))

                let stickToBottom = !stickPositionToTop && NSMaxY(subview.frame) <= positionValue

                // Adjust subview masks based on position relative to `positionValue`
                var newSubviewMask = oldSubviewMask
                newSubviewMask.remove(.height)
                newSubviewMask.remove(stickToBottom ? .minYMargin : .maxYMargin)
                newSubviewMask.insert(stickToBottom ? .maxYMargin : .minYMargin)
                subview.autoresizingMask = newSubviewMask
            }

            // Move to the parent view and repeat the process
            oldSuperview = superview
            positionValue = NSMaxY(superview.frame)
            superview = superview.superview!
        }

        return subviewMasks
    }
    
    func restoreAutoresizeMasks(_ masks: [NSNumber]) {
        var superview = self
        var oldSuperview = superview
        var enumerator = masks.makeIterator()

        while !superview.isFlipped {
            // Restore the mask for the parent view:
            guard let maskValue = enumerator.next() else {
                fatalError("Mask array exhausted unexpectedly")
            }
            let autoresizingMask = NSView.AutoresizingMask(rawValue: maskValue.uintValue)
            superview.autoresizingMask = autoresizingMask

            // Restore masks for subviews:
            for subview in superview.subviews where subview != oldSuperview {
                guard let subviewMaskValue = enumerator.next() else {
                    fatalError("Mask array exhausted unexpectedly")
                }
                let subviewAutoresizingMask = NSView.AutoresizingMask(rawValue: subviewMaskValue.uintValue)
                subview.autoresizingMask = subviewAutoresizingMask
            }

            // Move to the parent view and repeat the process
            oldSuperview = superview
            superview = superview.superview!
        }
    }
    
    // MARK: - 新增实用方法
    
    /// 设置视图背景颜色
    /// - Parameter color: 背景颜色
    func setBackgroundColor(_ color: NSColor) {
        self.wantsLayer = true
        self.layer?.backgroundColor = color.cgColor
    }
    
    /// 设置视图边框
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - width: 边框宽度
    func setBorder(color: NSColor, width: CGFloat = 1.0) {
        self.wantsLayer = true
        self.layer?.borderColor = color.cgColor
        self.layer?.borderWidth = width
    }
    
    /// 设置视图圆角
    /// - Parameter radius: 圆角半径
    func setCornerRadius(_ radius: CGFloat) {
        self.wantsLayer = true
        self.layer?.cornerRadius = radius
        self.layer?.masksToBounds = true
    }
    
    /// 设置视图阴影
    /// - Parameters:
    ///   - color: 阴影颜色
    ///   - offset: 阴影偏移
    ///   - radius: 阴影半径
    ///   - opacity: 阴影透明度
    func setShadow(color: NSColor = .black, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4, opacity: Float = 0.3) {
        self.wantsLayer = true
        self.layer?.shadowColor = color.cgColor
        self.layer?.shadowOffset = offset
        self.layer?.shadowRadius = radius
        self.layer?.shadowOpacity = opacity
    }
    
    /// 添加点击手势
    /// - Parameter action: 点击回调
    @discardableResult
    func addClickGesture(_ action: @escaping (NSView) -> Void) -> NSClickGestureRecognizer {
        let gesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        self.addGestureRecognizer(gesture)
        
        // 存储回调
        objc_setAssociatedObject(self, AssociatedObjectKeys.clickHandlerKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        return gesture
    }
    
    @objc private func handleClick(_ gesture: NSClickGestureRecognizer) {
        if let action = objc_getAssociatedObject(self, AssociatedObjectKeys.clickHandlerKey) as? (NSView) -> Void {
            action(self)
        }
    }
    
    /// 添加长按手势
    /// - Parameters:
    ///   - action: 长按回调
    ///   - duration: 长按时间
    @discardableResult
    func addLongPressGesture(_ action: @escaping (NSView) -> Void, duration: TimeInterval = 0.5) -> NSPressGestureRecognizer {
        let gesture = NSPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = duration
        self.addGestureRecognizer(gesture)
        
        // 存储回调
        objc_setAssociatedObject(self, AssociatedObjectKeys.longPressHandlerKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        return gesture
    }
    
    @objc private func handleLongPress(_ gesture: NSPressGestureRecognizer) {
        if let action = objc_getAssociatedObject(self, AssociatedObjectKeys.longPressHandlerKey) as? (NSView) -> Void {
            action(self)
        }
    }
    
    /// 添加淡入动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func fadeIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        self.alphaValue = 0.0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().alphaValue = 1.0
        }, completionHandler: completion)
    }
    
    /// 添加淡出动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().alphaValue = 0.0
        }, completionHandler: completion)
    }
    
    /// 添加缩放动画
    /// - Parameters:
    ///   - scale: 缩放比例
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func scale(to scale: CGFloat, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().frame = NSRect(
                x: self.frame.origin.x + (self.frame.size.width * (1 - scale)) / 2,
                y: self.frame.origin.y + (self.frame.size.height * (1 - scale)) / 2,
                width: self.frame.size.width * scale,
                height: self.frame.size.height * scale
            )
        }, completionHandler: completion)
    }
    
    /// 添加移动动画
    /// - Parameters:
    ///   - point: 目标位置
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func move(to point: NSPoint, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().frame.origin = point
        }, completionHandler: completion)
    }
    
    /// 添加旋转动画
    /// - Parameters:
    ///   - angle: 旋转角度（弧度）
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func rotate(by angle: CGFloat, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        self.wantsLayer = true
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().layer?.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        }, completionHandler: completion)
    }
    
    /// 添加震动效果
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        self.layer?.add(animation, forKey: "shake")
    }
    
    /// 添加脉冲效果
    func pulse() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.3
        animation.fromValue = 1.0
        animation.toValue = 1.1
        animation.autoreverses = true
        animation.repeatCount = 1
        self.layer?.add(animation, forKey: "pulse")
    }
    
    /// 添加弹跳效果
    func bounce() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.2, 0.9, 1.1, 1.0]
        animation.duration = 0.5
        self.layer?.add(animation, forKey: "bounce")
    }
    
    /// 设置视图为可拖拽
    /// - Parameter enabled: 是否启用拖拽
    func setDraggable(_ enabled: Bool) {
        if enabled {
            let dragGesture = NSPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
            self.addGestureRecognizer(dragGesture)
        }
    }
    
    @objc private func handleDrag(_ gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.frame.origin.x += translation.x
        self.frame.origin.y += translation.y
        gesture.setTranslation(.zero, in: self.superview)
    }
    
    /// 设置视图为可调整大小
    /// - Parameter enabled: 是否启用调整大小
    func setResizable(_ enabled: Bool) {
        self.autoresizingMask = enabled ? [.width, .height] : []
    }
    
    /// 设置视图为可滚动
    /// - Parameter enabled: 是否启用滚动
    func setScrollable(_ enabled: Bool) {
        if let scrollView = self.superview as? NSScrollView {
            scrollView.hasVerticalScroller = enabled
            scrollView.hasHorizontalScroller = enabled
        }
    }
    
    /// 获取视图的屏幕坐标
    var screenFrame: NSRect {
        guard let window = window else { return .zero }
        let windowFrame = window.frame
        let viewFrameInWindow = convert(frame, to: nil)
        return NSRect(
            x: windowFrame.origin.x + viewFrameInWindow.origin.x,
            y: windowFrame.origin.y + viewFrameInWindow.origin.y,
            width: viewFrameInWindow.size.width,
            height: viewFrameInWindow.size.height
        )
    }
    
    /// 将视图转换为屏幕坐标
    /// - Parameter point: 视图内的点
    /// - Returns: 屏幕坐标
    func convertToScreen(_ point: NSPoint) -> NSPoint {
        guard let window = window else { return point }
        let windowPoint = convert(point, to: nil)
        let screenPoint = window.convertPoint(toScreen: windowPoint)
        return screenPoint
    }
    
    /// 将屏幕坐标转换为视图坐标
    /// - Parameter point: 屏幕坐标
    /// - Returns: 视图坐标
    func convertFromScreen(_ point: NSPoint) -> NSPoint {
        guard let window = window else { return point }
        let windowPoint = window.convertPoint(fromScreen: point)
        let viewPoint = convert(windowPoint, from: nil)
        return viewPoint
    }
    
    /// 获取视图的层级深度
    var depth: Int {
        var depth = 0
        var currentView: NSView? = self
        while let parent = currentView?.superview {
            depth += 1
            currentView = parent
        }
        return depth
    }
    
    /// 获取视图的所有子视图（递归）
    var allSubviews: [NSView] {
        var allViews: [NSView] = []
        for subview in subviews {
            allViews.append(subview)
            allViews.append(contentsOf: subview.allSubviews)
        }
        return allViews
    }
    
    /// 查找指定类型的子视图
    /// - Parameter type: 视图类型
    /// - Returns: 找到的子视图
    func findSubview<T: NSView>(ofType type: T.Type) -> T? {
        for subview in allSubviews {
            if let found = subview as? T {
                return found
            }
        }
        return nil
    }
    
    /// 查找指定标签的子视图
    /// - Parameter tag: 标签值
    /// - Returns: 找到的子视图
    func findSubview(withTag tag: Int) -> NSView? {
        for subview in allSubviews {
            if subview.tag == tag {
                return subview
            }
        }
        return nil
    }
    
    /// 查找指定标识符的子视图
    /// - Parameter identifier: 标识符
    /// - Returns: 找到的子视图
    func findSubview(withIdentifier identifier: NSUserInterfaceItemIdentifier) -> NSView? {
        for subview in allSubviews {
            if subview.identifier == identifier {
                return subview
            }
        }
        return nil
    }
    
    /// 设置视图的自动布局约束
    /// - Parameter constraints: 约束数组
    func setConstraints(_ constraints: [NSLayoutConstraint]) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
    
    /// 移除所有约束
    func removeAllConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
    }
    
    /// 设置视图的优先级
    /// - Parameter priority: 优先级
    func setContentHuggingPriority(_ priority: NSLayoutConstraint.Priority) {
        self.setContentHuggingPriority(priority, for: .horizontal)
        self.setContentHuggingPriority(priority, for: .vertical)
    }
    
    /// 设置视图的压缩阻力优先级
    /// - Parameter priority: 优先级
    func setContentCompressionResistancePriority(_ priority: NSLayoutConstraint.Priority) {
        self.setContentCompressionResistancePriority(priority, for: .horizontal)
        self.setContentCompressionResistancePriority(priority, for: .vertical)
    }
}
