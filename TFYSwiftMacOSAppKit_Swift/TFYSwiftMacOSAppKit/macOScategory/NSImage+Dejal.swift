//
//  NSImage+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import AppKit

public extension NSImage {
    // 绘制翻转的图像在指定矩形区域，指定合成操作和透明度
    func drawFlipped(in rect: NSRect, operation: NSCompositingOperation, fraction: CGFloat) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.saveGState()
        
        // 进行坐标变换实现翻转
        context.translateBy(x: 0, y: rect.maxY)
        context.scaleBy(x: 1, y: -1)
        
        let adjustedRect = NSRect(x: rect.origin.x, y: 0, width: rect.width, height: rect.height)
        self.draw(in: adjustedRect, from:.zero, operation: operation, fraction: fraction)
        
        context.restoreGState()
    }
    
    // 绘制翻转的图像在指定矩形区域，指定合成操作，默认透明度为 1.0
    func drawFlipped(in rect: NSRect, operation: NSCompositingOperation) {
        drawFlipped(in: rect, operation: operation, fraction: 1.0)
    }
    
    // 在图像上应用徽章图像，指定透明度和缩放比例
    func applyBadge(badge: NSImage?, withAlpha alpha: CGFloat, scale: CGFloat) {
        guard let badge = badge else { return }
        let newBadge = badge.copy() as! NSImage
        newBadge.size = NSSize(width: self.size.width * scale, height: self.size.height * scale)
        
        self.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        newBadge.draw(at: NSPoint(x: self.size.width - newBadge.size.width, y: 0), from:.zero, operation:.sourceOver, fraction: alpha)
        self.unlockFocus()
    }
    
    // 使用指定颜色对图像进行染色，指定合成操作为 NSCompositingOperation.sourceAtop
    func tintedImage(withColor tint: NSColor) -> NSImage {
        return tintedImage(withColor: tint, operation:.sourceAtop)
    }
    
    // 使用指定颜色对图像进行染色，指定合成操作
   func tintedImage(withColor tint: NSColor, operation: NSCompositingOperation) -> NSImage {
       let size = self.size
       let bounds = NSRect(x: 0, y: 0, width: size.width, height: size.height)
       let image = NSImage(size: size)
       
       image.lockFocus()
       
       self.draw(at:.zero, from: bounds, operation:.sourceOver, fraction: 1.0)
       // 替换 NSRectFillUsingOperation
       tint.setFill()
       
       let path = NSBezierPath(rect: bounds)
       
       path.fill()
       
       image.unlockFocus()
       
       return image
   }
    
    // 获取图像的 PNG 表示数据
    func pngRepresentation() -> Data? {
        guard let cgRef = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let newRep = NSBitmapImageRep(cgImage: cgRef)
        newRep.size = self.size
        
        return newRep.representation(using:.png, properties: [:])
    }
    
    // 创建一个指定颜色的图像
    static func image(withColor color: NSColor) -> NSImage {
        
        let size = CGSize(width: 1, height: 1)
        // 修改这里的初始化方式，确保 NSImage 有接受这样参数的初始化器或者使用其他合适的初始化方法
        return NSImage(size: NSSize(width: size.width, height: size.height))
    }
}
