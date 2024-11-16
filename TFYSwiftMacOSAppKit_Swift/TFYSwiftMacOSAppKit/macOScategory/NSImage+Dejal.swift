//
//  NSImage+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/9.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import AppKit
import Cocoa
import CoreImage

public extension NSImage {
    /// 图像处理错误枚举
    enum ImageError: Error {
        case contextCreationFailed    // 上下文创建失败
        case imageCreationFailed      // 图像创建失败
        case filterCreationFailed     // 滤镜创建失败
        case kernelCreationFailed     // 内核创建失败
    }
    
    /// 在指定矩形区域内绘制翻转的图像
    /// - Parameters:
    ///   - rect: 绘制区域
    ///   - operation: 合成操作方式
    ///   - fraction: 不透明度 (0.0 - 1.0)
    func drawFlipped(in rect: NSRect, operation: NSCompositingOperation, fraction: CGFloat) {
        // 获取当前图形上下文
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.saveGState() // 保存当前图形状态
        
        // 执行坐标变换以实现图像翻转
        context.translateBy(x: 0, y: rect.maxY)
        context.scaleBy(x: 1, y: -1)
        
        // 调整绘制区域并执行绘制
        let adjustedRect = NSRect(x: rect.origin.x, y: 0, width: rect.width, height: rect.height)
        draw(in: adjustedRect, from: .zero, operation: operation, fraction: fraction)
        
        context.restoreGState() // 恢复之前保存的图形状态
    }
    
    /// 绘制翻转的图像（完全不透明）
    /// - Parameters:
    ///   - rect: 绘制区域
    ///   - operation: 合成操作方式
    func drawFlipped(in rect: NSRect, operation: NSCompositingOperation) {
        drawFlipped(in: rect, operation: operation, fraction: 1.0)
    }
    
    /// 在图像上添加徽章
    /// - Parameters:
    ///   - badge: 要添加的徽章图像
    ///   - alpha: 徽章的透明度
    ///   - scale: 徽章的缩放比例
    func applyBadge(badge: NSImage?, withAlpha alpha: CGFloat, scale: CGFloat) {
        guard let badge = badge else { return }
        let newBadge = badge.copy() as! NSImage
        // 根据缩放比例调整徽章大小
        newBadge.size = NSSize(width: size.width * scale, height: size.height * scale)
        
        // 绘制徽章
        lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        newBadge.draw(at: NSPoint(x: size.width - newBadge.size.width, y: 0),
                     from: .zero,
                     operation: .sourceOver,
                     fraction: alpha)
        unlockFocus()
    }
    
    /// 创建一个带有指定颜色染色的图像副本
    /// - Parameters:
    ///   - tint: 染色的颜色
    ///   - operation: 合成操作方式
    /// - Returns: 染色后的新图像
    func tintedImage(withColor tint: NSColor, operation: NSCompositingOperation = .sourceAtop) -> NSImage {
        let size = self.size
        let bounds = NSRect(origin: .zero, size: size)
        let image = NSImage(size: size)
        
        image.lockFocus()
        draw(at: .zero, from: bounds, operation: .sourceOver, fraction: 1.0)
        tint.setFill()
        NSBezierPath(rect: bounds).fill()
        image.unlockFocus()
        
        return image
    }
    
    /// 获取图像的PNG格式数据
    /// - Returns: PNG格式的数据，如果转换失败则返回nil
    func pngRepresentation() -> Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = size
        return bitmapRep.representation(using: .png, properties: [:])
    }
    
    /// 创建纯色图像
    /// - Parameter color: 要使用的颜色
    /// - Returns: 创建的纯色图像
    static func image(withColor color: NSColor) -> NSImage {
        let size = NSSize(width: 1, height: 1)
        let image = NSImage(size: size)
        
        image.lockFocus()
        color.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        image.unlockFocus()
        
        return image
    }
    
    // MARK: - 二维码生成相关方法
    
    /// 生成基本二维码
    /// - Parameters:
    ///   - string: 要编码的字符串内容
    ///   - size: 生成的二维码大小
    /// - Returns: 生成的二维码图像，如果生成失败则返回nil
    static func generateQRCode(from string: String, size: CGSize) -> NSImage? {
        guard let ciImage = generateCIImage(from: string) else { return nil }
        return createHighResolutionImage(from: ciImage, size: size)
    }
    
    /// 生成带Logo的二维码
    /// - Parameters:
    ///   - string: 要编码的字符串内容
    ///   - size: 二维码大小
    ///   - logoImageName: Logo图像的名称
    ///   - logoSize: Logo的大小
    /// - Returns: 带Logo的二维码图像，如果生成失败则返回nil
    static func generateQRCodeWithLogo(from string: String,
                                     size: CGSize,
                                     logoImageName: NSImage.Name,
                                     logoSize: CGSize) -> NSImage? {
        guard let qrImage = generateQRCode(from: string, size: size),
              let logoImage = NSImage(named: logoImageName) else { return nil }
        return addLogo(to: qrImage, logo: logoImage, logoSize: logoSize)
    }
    
    /// 生成彩色二维码
    /// - Parameters:
    ///   - string: 要编码的字符串内容
    ///   - size: 二维码大小
    ///   - rgbColor: 前景色
    ///   - backgroundColor: 背景色
    /// - Returns: 彩色二维码图像，如果生成失败则返回nil
    static func generateColoredQRCode(from string: String,
                                    size: CGSize,
                                    rgbColor: CIColor,
                                    backgroundColor: CIColor) -> NSImage? {
        guard let ciImage = generateCIImage(from: string),
              let coloredImage = colorizeImage(ciImage,
                                             foregroundColor: rgbColor,
                                             backgroundColor: backgroundColor) else { return nil }
        return createHighResolutionImage(from: coloredImage, size: size)
    }
    
    /// 生成多边形点阵样式的二维码
    /// - Parameters:
    ///   - string: 要编码的字符串内容
    ///   - size: 二维码大小
    /// - Returns: 多边形点阵样式的二维码图像，如果生成失败则返回nil
    static func generateRandomPolygonDotsQRCode(from string: String, size: CGSize) -> NSImage? {
        guard let ciImage = generateCIImage(from: string) else { return nil }
        let polygonDotsImage = applyRandomPolygons(to: ciImage)
        return createHighResolutionImage(from: polygonDotsImage, size: size)
    }
    
    // MARK: - 私有辅助方法
    
    /// 生成CIImage格式的二维码
    private static func generateCIImage(from string: String) -> CIImage? {
        let data = string.data(using: .utf8)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel") // 使用最高级别的错误修正
        return filter?.outputImage
    }
    
    /// 创建高分辨率图像
    private static func createHighResolutionImage(from ciImage: CIImage, size: CGSize) -> NSImage? {
        // 计算缩放比例
        let scale = max(size.width / ciImage.extent.width, size.height / ciImage.extent.height)
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // 创建NSImage
        let rep = NSCIImageRep(ciImage: scaledImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
    
    /// 添加Logo到二维码中心
    private static func addLogo(to image: NSImage, logo: NSImage, logoSize: CGSize) -> NSImage {
        // 计算Logo的位置（居中）
        let logoRect = CGRect(x: (image.size.width - logoSize.width) / 2,
                            y: (image.size.height - logoSize.height) / 2,
                            width: logoSize.width,
                            height: logoSize.height)
        // 绘制Logo
        image.lockFocus()
        logo.draw(in: logoRect)
        image.unlockFocus()
        return image
    }
    
    /// 为二维码添加颜色
    private static func colorizeImage(_ image: CIImage,
                                    foregroundColor: CIColor,
                                    backgroundColor: CIColor) -> CIImage? {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        colorFilter.setValue(image, forKey: "inputImage")
        colorFilter.setValue(foregroundColor, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        return colorFilter.outputImage
    }
    
    /// 应用多边形点阵效果
    private static func applyRandomPolygons(to ciImage: CIImage) -> CIImage {
        // Metal着色器代码，用于创建多边形点阵效果
        let metalCode = """
        #include <metal_stdlib>
        using namespace metal;
        
        // 自定义内核函数，用于生成多边形点阵效果
        kernel vec4 randomPolygonDots(sample_t s, destination dest) {
            const float2 coord = dest.coord();
            const float2 center = float2(floor(coord.x) + 0.5, floor(coord.y) + 0.5);
            const float radius = 0.5;
            const int sides = 6; // 六边形
            
            float angle = 2.0 * M_PI / float(sides);
            float coverage = 0.0;
            
            // 计算多边形覆盖
            for (int i = 0; i < sides; ++i) {
                float2 p = float2(cos(angle * i), sin(angle * i)) * radius + center;
                if (length(coord - p) < radius) {
                    coverage = 1.0;
                    break;
                }
            }
            
            return mix(s, vec4(1.0, 1.0, 1.0, 0.0), coverage);
        }
        """
        
        // 创建并应用Metal内核
        guard let kernel = try? CIKernel(functionName: "randomPolygonDots",
                                       fromMetalLibraryData: metalCode.data(using: .utf8)!) else {
            return ciImage
        }
        
        return kernel.apply(extent: ciImage.extent,
                          roiCallback: { _, rect in rect },
                          arguments: [ciImage])!
    }
}
