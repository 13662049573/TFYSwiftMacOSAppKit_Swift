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
        case invalidImageData         // 无效的图像数据
        case unsupportedFormat        // 不支持的格式
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
    
    /// 获取图像的JPEG格式数据
    /// - Parameter compressionFactor: 压缩因子 (0.0 - 1.0)
    /// - Returns: JPEG格式的数据，如果转换失败则返回nil
    func jpegRepresentation(compressionFactor: CGFloat = 0.8) -> Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = size
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: compressionFactor])
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
    
    /// 创建渐变图像
    /// - Parameters:
    ///   - colors: 颜色数组
    ///   - size: 图像尺寸
    ///   - direction: 渐变方向
    /// - Returns: 渐变图像
    static func gradientImage(colors: [NSColor], size: NSSize, direction: NSGradient.DrawingOptions = .drawsBeforeStartingLocation) -> NSImage {
        let image = NSImage(size: size)
        let gradient = NSGradient(colors: colors)!
        
        image.lockFocus()
        gradient.draw(in: NSRect(origin: .zero, size: size), angle: 0)
        image.unlockFocus()
        
        return image
    }
    
    // MARK: - 图像处理新方法
    
    /// 调整图像大小
    /// - Parameter newSize: 新尺寸
    /// - Returns: 调整后的图像
    func resized(to newSize: NSSize) -> NSImage {
        let image = NSImage(size: newSize)
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: newSize), from: .zero, operation: .copy, fraction: 1.0)
        image.unlockFocus()
        return image
    }
    
    /// 裁剪图像
    /// - Parameter rect: 裁剪区域
    /// - Returns: 裁剪后的图像
    func cropped(to rect: NSRect) -> NSImage {
        let image = NSImage(size: rect.size)
        image.lockFocus()
        draw(in: NSRect(origin: .zero, size: rect.size), from: rect, operation: .copy, fraction: 1.0)
        image.unlockFocus()
        return image
    }
    
    /// 旋转图像
    /// - Parameter angle: 旋转角度（弧度）
    /// - Returns: 旋转后的图像
    func rotated(by angle: CGFloat) -> NSImage {
        let transform = NSAffineTransform()
        transform.rotate(byRadians: angle)
        
        let bounds = NSRect(origin: .zero, size: size)
        let rotatedBounds = transformedRect(bounds, by: transform)
        
        let image = NSImage(size: rotatedBounds.size)
        image.lockFocus()
        
        let context = NSGraphicsContext.current!
        context.saveGraphicsState()
        context.cgContext.translateBy(x: rotatedBounds.width / 2, y: rotatedBounds.height / 2)
        context.cgContext.rotate(by: angle)
        context.cgContext.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        draw(in: bounds, from: .zero, operation: .copy, fraction: 1.0)
        
        context.restoreGraphicsState()
        image.unlockFocus()
        
        return image
    }
    
    /// 应用模糊效果
    /// - Parameter radius: 模糊半径
    /// - Returns: 模糊后的图像
    func blurred(radius: CGFloat) -> NSImage? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
        
        blurFilter.setValue(ciImage, forKey: "inputImage")
        blurFilter.setValue(radius, forKey: "inputRadius")
        
        guard let outputImage = blurFilter.outputImage else { return nil }
        
        let rep = NSCIImageRep(ciImage: outputImage)
        let image = NSImage(size: size)
        image.addRepresentation(rep)
        
        return image
    }
    
    /// 应用黑白效果
    /// - Returns: 黑白图像
    func blackAndWhite() -> NSImage? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorMonochrome") else { return nil }
        
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        filter.setValue(1.0, forKey: "inputIntensity")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let rep = NSCIImageRep(ciImage: outputImage)
        let image = NSImage(size: size)
        image.addRepresentation(rep)
        
        return image
    }
    
    /// 保存图像到文件
    /// - Parameters:
    ///   - url: 保存路径
    ///   - format: 图像格式
    ///   - properties: 保存属性
    /// - Throws: 保存错误
    func save(to url: URL, format: NSBitmapImageRep.FileType, properties: [NSBitmapImageRep.PropertyKey: Any] = [:]) throws {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ImageError.invalidImageData
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = size
        
        guard let data = bitmapRep.representation(using: format, properties: properties) else {
            throw ImageError.unsupportedFormat
        }
        
        try data.write(to: url)
    }
    
    /// 从文件加载图像
    /// - Parameter url: 文件路径
    /// - Returns: 加载的图像，如果失败则返回nil
    static func load(from url: URL) -> NSImage? {
        return NSImage(contentsOf: url)
    }
    
    /// 从数据创建图像
    /// - Parameter data: 图像数据
    /// - Returns: 创建的图像，如果失败则返回nil
    static func load(from data: Data) -> NSImage? {
        return NSImage(data: data)
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
    ///   - logoImage: Logo图像
    ///   - logoSize: Logo的大小
    /// - Returns: 带Logo的二维码图像，如果生成失败则返回nil
    static func generateQRCodeWithLogo(from string: String,
                                     size: CGSize,
                                     logoImage: NSImage,
                                     logoSize: CGSize) -> NSImage? {
        guard let qrImage = generateQRCode(from: string, size: size) else { return nil }
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
    
    // MARK: - 新增实用方法
    
    /// 获取图像的平均颜色
    /// - Returns: 平均颜色
    func averageColor() -> NSColor? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        guard let context = CGContext(data: nil,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return nil }
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var totalRed: Int = 0
        var totalGreen: Int = 0
        var totalBlue: Int = 0
        var totalAlpha: Int = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                totalRed += Int(buffer[pixelIndex])
                totalGreen += Int(buffer[pixelIndex + 1])
                totalBlue += Int(buffer[pixelIndex + 2])
                totalAlpha += Int(buffer[pixelIndex + 3])
            }
        }
        
        let pixelCount = width * height
        let averageRed = CGFloat(totalRed) / CGFloat(pixelCount) / 255.0
        let averageGreen = CGFloat(totalGreen) / CGFloat(pixelCount) / 255.0
        let averageBlue = CGFloat(totalBlue) / CGFloat(pixelCount) / 255.0
        let averageAlpha = CGFloat(totalAlpha) / CGFloat(pixelCount) / 255.0
        
        return NSColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: averageAlpha)
    }
    
    /// 创建圆形图像
    /// - Returns: 圆形图像
    func circularImage() -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        
        let path = NSBezierPath(ovalIn: NSRect(origin: .zero, size: size))
        path.addClip()
        
        draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1.0)
        
        image.unlockFocus()
        return image
    }
    
    /// 创建圆角图像
    /// - Parameter cornerRadius: 圆角半径
    /// - Returns: 圆角图像
    func roundedImage(cornerRadius: CGFloat) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        
        let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: cornerRadius, yRadius: cornerRadius)
        path.addClip()
        
        draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1.0)
        
        image.unlockFocus()
        return image
    }
    
    /// 添加边框
    /// - Parameters:
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    /// - Returns: 带边框的图像
    func addBorder(width borderWidth: CGFloat, color borderColor: NSColor) -> NSImage {
        let newSize = NSSize(width: size.width + borderWidth * 2, height: size.height + borderWidth * 2)
        let image = NSImage(size: newSize)
        
        image.lockFocus()
        borderColor.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: newSize)).fill()
        
        draw(in: NSRect(x: borderWidth, y: borderWidth, width: size.width, height: size.height),
             from: .zero, operation: .copy, fraction: 1.0)
        
        image.unlockFocus()
        return image
    }
    
    /// 创建缩略图
    /// - Parameter maxSize: 最大尺寸
    /// - Returns: 缩略图
    func thumbnail(maxSize: NSSize) -> NSImage {
        let scale = min(maxSize.width / size.width, maxSize.height / size.height)
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)
        return resized(to: newSize)
    }
    
    /// 检查图像是否为透明
    var isTransparent: Bool {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
        return cgImage.alphaInfo != .none && cgImage.alphaInfo != .noneSkipLast
    }
    
    /// 获取图像的文件大小（以字节为单位）
    /// - Parameter format: 图像格式
    /// - Returns: 文件大小
    func fileSize(format: NSBitmapImageRep.FileType = .png) -> Int? {
        guard let data = representation(for: format) else { return nil }
        return data.count
    }
    
    /// 获取图像的表示形式
    /// - Parameter format: 图像格式
    /// - Returns: 图像数据
    func representation(for format: NSBitmapImageRep.FileType) -> Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = size
        return bitmapRep.representation(using: format, properties: [:])
    }
    
    /// 计算NSRect经过NSAffineTransform变换后的新rect
    private func transformedRect(_ rect: NSRect, by transform: NSAffineTransform) -> NSRect {
        let points = [
            NSPoint(x: rect.minX, y: rect.minY),
            NSPoint(x: rect.maxX, y: rect.minY),
            NSPoint(x: rect.minX, y: rect.maxY),
            NSPoint(x: rect.maxX, y: rect.maxY)
        ].map { transform.transform($0) }
        let xs = points.map { $0.x }
        let ys = points.map { $0.y }
        return NSRect(x: xs.min()!, y: ys.min()!, width: xs.max()! - xs.min()!, height: ys.max()! - ys.min()!)
    }
}
