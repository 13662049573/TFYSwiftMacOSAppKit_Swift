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

public extension NSImage {
    
    // Generate a basic QR code
    static func generateQRCode(from string: String, size: CGSize) -> NSImage? {
        guard let ciImage = generateCIImage(from: string) else { return nil }
        return createHighResolutionImage(from: ciImage, size: size)
    }

    // Generate a QR code with a logo
    static func generateQRCodeWithLogo(from string: String, size: CGSize, logoImageName: String, logoSize: CGSize) -> NSImage? {
        guard let qrImage = generateQRCode(from: string, size: size),
              let logoImage = NSImage(named: logoImageName) else { return nil }
        
        return addLogo(to: qrImage, logo: logoImage, logoSize: logoSize)
    }

    // Generate a colored QR code
    static func generateColoredQRCode(from string: String, size: CGSize, rgbColor: CIColor, backgroundColor: CIColor) -> NSImage? {
        guard let ciImage = generateCIImage(from: string),
              let coloredImage = colorizeImage(ciImage, foregroundColor: rgbColor, backgroundColor: backgroundColor) else { return nil }
        return createHighResolutionImage(from: coloredImage, size: size)
    }

    // Generate a QR code with random polygon dots
    static func generateRandomPolygonDotsQRCode(from string: String, size: CGSize) -> NSImage? {
        guard let ciImage = generateCIImage(from: string) else { return nil }
        let polygonDotsImage = applyRandomPolygons(to: ciImage)
        return createHighResolutionImage(from: polygonDotsImage, size: size)
    }
    
    // Generate a QR code with an image pattern
    static func generateQRCodeWithImagePattern(from string: String, size: CGSize, patternImage: NSImage) -> NSImage? {
        guard let qrCIImage = generateCIImage(from: string),
              let patternCIImage = CIImage(data: patternImage.tiffRepresentation!) else { return nil }
        let patternedQRImage = applyImagePattern(to: qrCIImage, with: patternCIImage)
        return createHighResolutionImage(from: patternedQRImage, size: size)
    }

    // Private: Generate CIImage from string
    private static func generateCIImage(from string: String) -> CIImage? {
        let data = string.data(using: .utf8)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        return filter?.outputImage
    }

    // Private: Create high-resolution NSImage from CIImage
    private static func createHighResolutionImage(from ciImage: CIImage, size: CGSize) -> NSImage? {
        let scale = max(size.width / ciImage.extent.width, size.height / ciImage.extent.height)
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        let rep = NSCIImageRep(ciImage: scaledImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }

    // Private: Add logo to QR code
    private static func addLogo(to image: NSImage, logo: NSImage, logoSize: CGSize) -> NSImage {
        let logoRect = CGRect(x: (image.size.width - logoSize.width) / 2, y: (image.size.height - logoSize.height) / 2, width: logoSize.width, height: logoSize.height)
        image.lockFocus()
        logo.draw(in: logoRect)
        image.unlockFocus()
        return image
    }

    // Private: Colorize QR code
    private static func colorizeImage(_ image: CIImage, foregroundColor: CIColor, backgroundColor: CIColor) -> CIImage? {
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(image, forKey: "inputImage")
        colorFilter?.setValue(foregroundColor, forKey: "inputColor0")
        colorFilter?.setValue(backgroundColor, forKey: "inputColor1")
        return colorFilter?.outputImage
    }

    // Private: Apply random polygons to QR code using Metal
    private static func applyRandomPolygons(to ciImage: CIImage) -> CIImage {
        let metalCode = """
        #include <metal_stdlib>
        using namespace metal;
        kernel vec4 randomPolygonDots(sample_t s, destination dest) {
            const float2 coord = dest.coord();
            const float2 center = float2(floor(coord.x) + 0.5, floor(coord.y) + 0.5);
            const float distance = length(coord - center);
            const float radius = 0.5; // Adjust radius for size of the polygon
            const int sides = 6; // Number of sides for the polygon, can be randomized

            float angle = 2.0 * M_PI / float(sides);
            float coverage = 0.0;
            for (int i = 0; i < sides; ++i) {
                float2 p = float2(cos(angle * i), sin(angle * i)) * radius + center;
                if (length(coord - p) < radius) {
                    coverage = 1.0;
                    break;
                }
            }
            return mix(s, vec4(1.0, 1.0, 1.0, 0.0), coverage); // Mix original sample and background
        }
        """
        guard let kernel = try? CIKernel(functionName: "randomPolygonDots", fromMetalLibraryData: metalCode.data(using: .utf8)!) else {
            return ciImage // Return original if kernel creation fails
        }
        return kernel.apply(extent: ciImage.extent, roiCallback: { _, rect in rect }, arguments: [ciImage])!
    }
    
    // Private: Apply an image pattern to QR code
    private static func applyImagePattern(to qrImage: CIImage, with patternImage: CIImage) -> CIImage {
        let blendFilter = CIFilter(name: "CIBlendWithMask", parameters: [
            "inputImage": patternImage,
            "inputBackgroundImage": qrImage,
            "inputMaskImage": qrImage
        ])
        return blendFilter?.outputImage ?? qrImage
    }
}
