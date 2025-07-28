//
//  NSColor+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/8.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

/// 颜色错误类型
public enum NSColorError: Error, LocalizedError {
    case invalidHexString(String)
    case invalidRGBValues(String)
    case invalidHSBValues(String)
    case invalidCMYKValues(String)
    case invalidColorSpace(String)
    case conversionFailed(String)
    case outOfRange(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidHexString(let hex):
            return "无效的十六进制颜色字符串: \(hex)"
        case .invalidRGBValues(let values):
            return "无效的RGB颜色值: \(values)"
        case .invalidHSBValues(let values):
            return "无效的HSB颜色值: \(values)"
        case .invalidCMYKValues(let values):
            return "无效的CMYK颜色值: \(values)"
        case .invalidColorSpace(let space):
            return "无效的颜色空间: \(space)"
        case .conversionFailed(let reason):
            return "颜色转换失败: \(reason)"
        case .outOfRange(let range):
            return "值超出范围: \(range)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidHexString:
            return "十六进制字符串格式不正确或包含无效字符"
        case .invalidRGBValues:
            return "RGB值必须在0-255范围内"
        case .invalidHSBValues:
            return "HSB值超出有效范围"
        case .invalidCMYKValues:
            return "CMYK值必须在0-100范围内"
        case .invalidColorSpace:
            return "不支持的颜色空间类型"
        case .conversionFailed:
            return "颜色空间转换过程中发生错误"
        case .outOfRange:
            return "颜色分量值超出有效范围"
        }
    }
}

/// 颜色空间类型
public enum ColorSpace {
    case sRGB
    case displayP3
    case genericGamma22Gray
    case genericGamma22GrayColorSpace
    case adobeRGB1998
    case sRGBExtended
    case genericXYZ
    case genericLab
    case acesccLinear
    case acescct
    case itur_709
    case itur_2020
    case rommrgb
    case dciP3
    case proPhotoRGB
}

// 扩展 NSColor，添加自定义方法
public extension NSColor {
    
    // MARK: - 十六进制颜色创建
    
    /// 使用十六进制字符串创建颜色
    /// - Parameters:
    ///   - hexString: 十六进制字符串（支持 #、0x、0X 前缀）
    ///   - alpha: 透明度，默认为1.0
    /// - Throws: NSColorError.invalidHexString 如果十六进制字符串无效
    convenience init(hexString: String, alpha: CGFloat = 1.0) throws {
        // 清理十六进制字符串
        let cleanHex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = cleanHex.hasPrefix("#") ? String(cleanHex.dropFirst()) : cleanHex
        
        // 验证十六进制字符串
        guard hexString.count == 6 || hexString.count == 8 else {
            throw NSColorError.invalidHexString(hexString)
        }
        
        // 解析十六进制值
         let value = hexString.hexValue
         let (r, g, b) = (value >> 16, (value >> 8) % 256, value % 256)
        
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: alpha)
    }
    
    /// 使用十六进制字符串创建颜色（安全版本）
    /// - Parameters:
    ///   - hexString: 十六进制字符串
    ///   - alpha: 透明度，默认为1.0
    /// - Returns: 颜色对象，如果解析失败则返回nil
    convenience init?(safeHexString: String, alpha: CGFloat = 1.0) {
        do {
            try self.init(hexString: safeHexString, alpha: alpha)
        } catch {
            return nil
        }
    }
    
    /// 使用十六进制整数创建颜色
    /// - Parameters:
    ///   - hex: 十六进制整数
    ///   - alpha: 透明度，默认为1.0
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    // MARK: - RGB颜色创建
    
    /// 使用RGB值创建颜色
    /// - Parameters:
    ///   - r: 红色分量 (0-255)
    ///   - g: 绿色分量 (0-255)
    ///   - b: 蓝色分量 (0-255)
    ///   - alpha: 透明度，默认为1.0
    /// - Throws: NSColorError.invalidRGBValues 如果RGB值无效
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0) throws {
        guard r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255 else {
            throw NSColorError.invalidRGBValues("R: \(r), G: \(g), B: \(b)")
        }
        
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: alpha)
    }
    
    /// 使用RGB值创建颜色（安全版本）
    /// - Parameters:
    ///   - r: 红色分量 (0-255)
    ///   - g: 绿色分量 (0-255)
    ///   - b: 蓝色分量 (0-255)
    ///   - alpha: 透明度，默认为1.0
    /// - Returns: 颜色对象，如果RGB值无效则返回nil
    convenience init?(safeR: Int, g: Int, b: Int, alpha: CGFloat = 1.0) {
        do {
            try self.init(r: safeR, g: g, b: b, alpha: alpha)
        } catch {
            return nil
        }
    }
    
    // MARK: - HSB颜色创建
    
    /// 使用HSB值创建颜色
    /// - Parameters:
    ///   - h: 色相 (0-360)
    ///   - s: 饱和度 (0-100)
    ///   - b: 亮度 (0-100)
    ///   - alpha: 透明度，默认为1.0
    /// - Throws: NSColorError.invalidHSBValues 如果HSB值无效
    convenience init(h: CGFloat, s: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) throws {
        guard h >= 0 && h <= 360 && s >= 0 && s <= 100 && b >= 0 && b <= 100 else {
            throw NSColorError.invalidHSBValues("H: \(h), S: \(s), B: \(b)")
        }
        
        self.init(hue: h / 360.0,
                  saturation: s / 100.0,
                  brightness: b / 100.0,
                   alpha: alpha)
    }
    
    /// 使用HSB值创建颜色（安全版本）
    /// - Parameters:
    ///   - h: 色相 (0-360)
    ///   - s: 饱和度 (0-100)
    ///   - b: 亮度 (0-100)
    ///   - alpha: 透明度，默认为1.0
    /// - Returns: 颜色对象，如果HSB值无效则返回nil
    convenience init?(safeH: CGFloat, s: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        do {
            try self.init(h: safeH, s: s, b: b, alpha: alpha)
        } catch {
            return nil
        }
    }
    
    // MARK: - CMYK颜色创建
    
    /// 使用CMYK值创建颜色
    /// - Parameters:
    ///   - c: 青色 (0-100)
    ///   - m: 洋红色 (0-100)
    ///   - y: 黄色 (0-100)
    ///   - k: 黑色 (0-100)
    ///   - alpha: 透明度，默认为1.0
    /// - Throws: NSColorError.invalidCMYKValues 如果CMYK值无效
    convenience init(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat, alpha: CGFloat = 1.0) throws {
        guard c >= 0 && c <= 100 && m >= 0 && m <= 100 && y >= 0 && y <= 100 && k >= 0 && k <= 100 else {
            throw NSColorError.invalidCMYKValues("C: \(c), M: \(m), Y: \(y), K: \(k)")
        }
        
        let cmyk = [c / 100.0, m / 100.0, y / 100.0, k / 100.0]
        self.init(colorSpace: NSColorSpace.genericCMYK, components: cmyk, count: 4)
        self.withAlphaComponent(alpha)
    }
    
    // MARK: - 颜色空间创建
    
    /// 使用指定颜色空间创建颜色
    /// - Parameters:
    ///   - colorSpace: 颜色空间类型
    ///   - components: 颜色分量数组
    ///   - alpha: 透明度，默认为1.0
    /// - Returns: 颜色对象
    static func color(with colorSpace: ColorSpace, components: [CGFloat], alpha: CGFloat = 1.0) -> NSColor {
        let space: NSColorSpace
        switch colorSpace {
        case .sRGB:
            space = NSColorSpace.sRGB
        case .displayP3:
            space = NSColorSpace.displayP3
        case .genericGamma22Gray:
            space = NSColorSpace.genericGamma22Gray
        case .genericGamma22GrayColorSpace:
            space = NSColorSpace.genericGamma22Gray
        case .adobeRGB1998:
            space = NSColorSpace.adobeRGB1998
        case .sRGBExtended:
            space = NSColorSpace.sRGB
        case .genericXYZ:
            space = NSColorSpace.genericRGB
        case .genericLab:
            space = NSColorSpace.genericRGB
        case .acesccLinear:
            space = NSColorSpace.sRGB
        case .acescct:
            space = NSColorSpace.sRGB
        case .itur_709:
            space = NSColorSpace.sRGB
        case .itur_2020:
            space = NSColorSpace.sRGB
        case .rommrgb:
            space = NSColorSpace.sRGB
        case .dciP3:
            space = NSColorSpace.displayP3
        case .proPhotoRGB:
            space = NSColorSpace.adobeRGB1998
        }
        
        let color = NSColor(colorSpace: space, components: components, count: components.count)
        return color.withAlphaComponent(alpha)
    }
    
    // MARK: - 颜色属性
    
    /// 获取颜色的十六进制字符串表示
    var hexString: String {
        guard let rgbColor = self.usingColorSpace(.sRGB) else {
            return "#000000"
        }
        
        let r = Int(round(rgbColor.redComponent * 255))
        let g = Int(round(rgbColor.greenComponent * 255))
        let b = Int(round(rgbColor.blueComponent * 255))
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    /// 获取颜色的RGB分量
    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        guard let rgbColor = self.usingColorSpace(.sRGB) else {
            return (0, 0, 0)
        }
        return (rgbColor.redComponent, rgbColor.greenComponent, rgbColor.blueComponent)
    }
    
    /// 获取颜色的HSB分量
    var hsbComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        guard let hsbColor = self.usingColorSpace(.sRGB) else {
            return (0, 0, 0)
        }
        return (hsbColor.hueComponent, hsbColor.saturationComponent, hsbColor.brightnessComponent)
    }
    
    /// 获取颜色的CMYK分量
    var cmykComponents: (cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black: CGFloat) {
        guard let cmykColor = self.usingColorSpace(.genericCMYK) else {
            return (0, 0, 0, 0)
        }
        let components = cmykColor.cgColor.components ?? [0, 0, 0, 0]
        return (components[0], components[1], components[2], components[3])
    }
    
    /// 获取颜色的亮度
    var brightness: CGFloat {
        let components = rgbComponents
        return (components.red * 299 + components.green * 587 + components.blue * 114) / 1000
    }
    
    /// 判断颜色是否为深色
    var isDark: Bool {
        return brightness < 0.5
    }
    
    /// 判断颜色是否为浅色
    var isLight: Bool {
        return brightness >= 0.5
    }
    
    // MARK: - 颜色操作
    
    /// 调整颜色亮度
    /// - Parameter factor: 亮度调整因子 (-1.0 到 1.0)
    /// - Returns: 调整后的颜色
    func adjustedBrightness(by factor: CGFloat) -> NSColor {
        let components = hsbComponents
        let newBrightness = max(0, min(1, components.brightness + factor))
        return NSColor(hue: components.hue,
                      saturation: components.saturation,
                      brightness: newBrightness,
                      alpha: alphaComponent)
    }
    
    /// 调整颜色饱和度
    /// - Parameter factor: 饱和度调整因子 (-1.0 到 1.0)
    /// - Returns: 调整后的颜色
    func adjustedSaturation(by factor: CGFloat) -> NSColor {
        let components = hsbComponents
        let newSaturation = max(0, min(1, components.saturation + factor))
        return NSColor(hue: components.hue,
                      saturation: newSaturation,
                      brightness: components.brightness,
                      alpha: alphaComponent)
    }
    
    /// 调整颜色色相
    /// - Parameter factor: 色相调整因子 (-1.0 到 1.0)
    /// - Returns: 调整后的颜色
    func adjustedHue(by factor: CGFloat) -> NSColor {
        let components = hsbComponents
        let newHue = (components.hue + factor).truncatingRemainder(dividingBy: 1.0)
        return NSColor(hue: newHue,
                      saturation: components.saturation,
                      brightness: components.brightness,
                      alpha: alphaComponent)
    }
    
    /// 混合两个颜色
    /// - Parameters:
    ///   - other: 要混合的颜色
    ///   - ratio: 混合比例 (0.0 到 1.0)
    /// - Returns: 混合后的颜色
    func blended(with other: NSColor, ratio: CGFloat) -> NSColor {
        let components1 = rgbComponents
        let components2 = other.rgbComponents
        
        let r = components1.red * (1 - ratio) + components2.red * ratio
        let g = components1.green * (1 - ratio) + components2.green * ratio
        let b = components1.blue * (1 - ratio) + components2.blue * ratio
        let a = alphaComponent * (1 - ratio) + other.alphaComponent * ratio
        
        return NSColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 获取颜色的互补色
    var complementary: NSColor {
        let components = hsbComponents
        let newHue = (components.hue + 0.5).truncatingRemainder(dividingBy: 1.0)
        return NSColor(hue: newHue,
                      saturation: components.saturation,
                      brightness: components.brightness,
                      alpha: alphaComponent)
    }
    
    /// 获取颜色的反色
    var inverted: NSColor {
        let components = rgbComponents
        return NSColor(red: 1 - components.red,
                      green: 1 - components.green,
                      blue: 1 - components.blue,
                      alpha: alphaComponent)
    }
    
    // MARK: - 预设颜色
    
    /// 获取随机颜色
    static var random: NSColor {
        return NSColor(red: CGFloat.random(in: 0...1),
                      green: CGFloat.random(in: 0...1),
                      blue: CGFloat.random(in: 0...1),
                      alpha: 1.0)
    }
    
    /// 获取随机颜色（指定饱和度范围）
    /// - Parameters:
    ///   - minSaturation: 最小饱和度
    ///   - maxSaturation: 最大饱和度
    ///   - minBrightness: 最小亮度
    ///   - maxBrightness: 最大亮度
    /// - Returns: 随机颜色
    static func random(hue: ClosedRange<CGFloat> = 0...1,
                      saturation: ClosedRange<CGFloat> = 0.5...1,
                      brightness: ClosedRange<CGFloat> = 0.5...1) -> NSColor {
        return NSColor(hue: CGFloat.random(in: hue),
                      saturation: CGFloat.random(in: saturation),
                      brightness: CGFloat.random(in: brightness),
                      alpha: 1.0)
    }
    
    // MARK: - 系统颜色适配
    
    /// 获取适配深色模式的动态颜色
    /// - Parameters:
    ///   - lightColor: 浅色模式下的颜色
    ///   - darkColor: 深色模式下的颜色
    /// - Returns: 动态颜色
    static func dynamicColor(light: NSColor, dark: NSColor) -> NSColor {
        if #available(macOS 10.14, *) {
            return NSColor(name: nil) { appearance in
                return appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
            }
        } else {
            return light
        }
    }
    
    /// 获取系统强调色
    static var systemAccent: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.controlAccentColor
        } else {
            return NSColor.systemBlue
        }
    }
    
    /// 获取系统背景色
    static var systemBackground: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.controlBackgroundColor
        } else {
            return NSColor.white
        }
    }
    
    /// 获取系统前景色
    static var systemForeground: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.labelColor
        } else {
            return NSColor.black
        }
    }
    
    // MARK: - 高级颜色功能
    
    /// 获取颜色的对比度
    /// - Parameter other: 要比较的颜色
    /// - Returns: 对比度值
    func contrastRatio(with other: NSColor) -> CGFloat {
        let luminance1 = self.luminance
        let luminance2 = other.luminance
        
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// 获取颜色的亮度（用于对比度计算）
    var luminance: CGFloat {
        let components = rgbComponents
        let r = components.red <= 0.03928 ? components.red / 12.92 : pow((components.red + 0.055) / 1.055, 2.4)
        let g = components.green <= 0.03928 ? components.green / 12.92 : pow((components.green + 0.055) / 1.055, 2.4)
        let b = components.blue <= 0.03928 ? components.blue / 12.92 : pow((components.blue + 0.055) / 1.055, 2.4)
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    /// 检查颜色对比度是否满足WCAG标准
    /// - Parameters:
    ///   - other: 要比较的颜色
    ///   - level: WCAG级别
    /// - Returns: 是否满足标准
    func meetsWCAGContrast(with other: NSColor, level: WCAGLevel = .AA) -> Bool {
        let ratio = contrastRatio(with: other)
        return ratio >= level.minimumRatio
    }
    
    /// 获取最佳对比色（黑或白）
    /// - Returns: 最佳对比色
    func bestContrastColor() -> NSColor {
        let black = NSColor.black
        let white = NSColor.white
        
        let contrastWithBlack = contrastRatio(with: black)
        let contrastWithWhite = contrastRatio(with: white)
        
        return contrastWithBlack > contrastWithWhite ? black : white
    }
    
    /// 生成颜色调色板
    /// - Parameter count: 调色板颜色数量
    /// - Returns: 调色板颜色数组
    func generatePalette(count: Int) -> [NSColor] {
        var palette: [NSColor] = [self]
        
        for i in 1..<count {
            let hue = (hsbComponents.hue + CGFloat(i) / CGFloat(count)).truncatingRemainder(dividingBy: 1.0)
            let color = NSColor(hue: hue,
                              saturation: hsbComponents.saturation,
                              brightness: hsbComponents.brightness,
                              alpha: alphaComponent)
            palette.append(color)
        }
        
        return palette
    }
    
    /// 生成单色调色板
    /// - Parameter count: 调色板颜色数量
    /// - Returns: 单色调色板
    func generateMonochromaticPalette(count: Int) -> [NSColor] {
        var palette: [NSColor] = [self]
        
        for i in 1..<count {
            let brightness = max(0.1, min(0.9, hsbComponents.brightness + CGFloat(i - count/2) * 0.1))
            let color = NSColor(hue: hsbComponents.hue,
                              saturation: hsbComponents.saturation,
                              brightness: brightness,
                              alpha: alphaComponent)
            palette.append(color)
        }
        
        return palette
    }
    
    /// 生成互补色调色板
    /// - Parameter count: 调色板颜色数量
    /// - Returns: 互补色调色板
    func generateComplementaryPalette(count: Int) -> [NSColor] {
        var palette: [NSColor] = [self]
        let complementary = self.complementary
        
        for i in 1..<count {
            let ratio = CGFloat(i) / CGFloat(count - 1)
            let color = self.blended(with: complementary, ratio: ratio)
            palette.append(color)
        }
        
        return palette
    }
    
    /// 获取颜色的温度（暖色/冷色）
    var temperature: ColorTemperature {
        let components = hsbComponents
        let hue = components.hue * 360
        
        switch hue {
        case 0..<60, 300..<360:
            return .warm
        case 180..<240:
            return .cool
        default:
            return .neutral
        }
    }
    
    /// 获取颜色的情感属性
    var emotion: ColorEmotion {
        let components = hsbComponents
        let hue = components.hue * 360
        let saturation = components.saturation
        let brightness = components.brightness
        
        if brightness < 0.3 {
            return .mysterious
        } else if brightness > 0.8 && saturation < 0.3 {
            return .calm
        } else if saturation > 0.8 && brightness > 0.7 {
            return .energetic
        } else if hue >= 0 && hue < 60 {
            return .warm
        } else if hue >= 60 && hue < 180 {
            return .fresh
        } else if hue >= 180 && hue < 300 {
            return .cool
        } else {
            return .passionate
        }
    }
}

// MARK: - 辅助类型

/// WCAG对比度级别
public enum WCAGLevel {
    case AA
    case AAA
    
    var minimumRatio: CGFloat {
        switch self {
        case .AA:
            return 4.5
        case .AAA:
            return 7.0
        }
    }
}

/// 颜色温度
public enum ColorTemperature {
    case warm
    case cool
    case neutral
}

/// 颜色情感
public enum ColorEmotion {
    case warm
    case cool
    case fresh
    case passionate
    case calm
    case energetic
    case mysterious
}

// MARK: - 使用示例和最佳实践

/*
 
 // MARK: - 基础使用示例
 
 // 1. 使用十六进制字符串创建颜色
let redColor = try NSColor(hexString: "#FF0000")
let blueColor = NSColor(safeHexString: "0x0000FF", alpha: 0.8)
let greenColor = NSColor(hex: 0x00FF00)

// 2. 使用RGB值创建颜色
let purpleColor = try NSColor(r: 128, g: 0, b: 128)
let orangeColor = NSColor(safeR: 255, g: 165, b: 0, alpha: 0.9)

// 3. 使用HSB值创建颜色
let pinkColor = try NSColor(h: 330, s: 100, b: 100)
let cyanColor = NSColor(safeH: 180, s: 100, b: 100, alpha: 0.7)
 
 // 4. 使用CMYK值创建颜色
 let brownColor = try NSColor(c: 0, m: 50, y: 100, k: 50)
 
 // MARK: - 颜色属性使用
 
 // 5. 获取颜色属性
 let color = NSColor.red
 print("十六进制: \(color.hexString)")
 print("RGB: \(color.rgbComponents)")
 print("HSB: \(color.hsbComponents)")
 print("亮度: \(color.brightness)")
 print("是否为深色: \(color.isDark)")
 
 // MARK: - 颜色操作
 
 // 6. 调整颜色
 let adjustedColor = color.adjustedBrightness(by: 0.2)
 let saturatedColor = color.adjustedSaturation(by: -0.3)
 let hueShiftedColor = color.adjustedHue(by: 0.1)
 
 // 7. 混合颜色
 let blendedColor = NSColor.red.blended(with: NSColor.blue, ratio: 0.5)
 let complementaryColor = color.complementary
 let invertedColor = color.inverted
 
 // MARK: - 预设颜色
 
 // 8. 随机颜色
 let randomColor = NSColor.random
 let vibrantRandomColor = NSColor.random(saturation: 0.8...1.0, brightness: 0.7...1.0)
 
 // 9. 动态颜色
 let dynamicColor = NSColor.dynamicColor(light: .white, dark: .black)
 let systemAccentColor = NSColor.systemAccent
 let systemBackgroundColor = NSColor.systemBackground
 
 // MARK: - 错误处理
 
 // 10. 错误处理示例
 do {
     let invalidColor = try NSColor(hexString: "invalid")
 } catch NSColorError.invalidHexString {
     print("无效的十六进制字符串")
 } catch {
     print("其他错误: \(error)")
 }
 
 // 11. 安全创建
if let safeColor = NSColor(safeHexString: "FF0000") {
    print("成功创建颜色: \(safeColor)")
} else {
    print("创建颜色失败")
}
 
 // MARK: - 高级用法
 
 // 12. 颜色空间
 let p3Color = NSColor.color(with: .displayP3, components: [1.0, 0.5, 0.3])
 let labColor = NSColor.color(with: .genericLab, components: [50, 20, 30])
 
 // 13. 颜色渐变
 func createGradientColors(from startColor: NSColor, to endColor: NSColor, steps: Int) -> [NSColor] {
     var colors: [NSColor] = []
     for i in 0..<steps {
         let ratio = CGFloat(i) / CGFloat(steps - 1)
         colors.append(startColor.blended(with: endColor, ratio: ratio))
     }
     return colors
 }
 
 // 14. 颜色主题
 struct ColorTheme {
     let primary: NSColor
     let secondary: NSColor
     let accent: NSColor
     let background: NSColor
     let text: NSColor
     
     static let light = ColorTheme(
         primary: NSColor(hex: 0x007AFF),
         secondary: NSColor(hex: 0x5856D6),
         accent: NSColor(hex: 0xFF3B30),
         background: .white,
         text: .black
     )
     
     static let dark = ColorTheme(
         primary: NSColor(hex: 0x0A84FF),
         secondary: NSColor(hex: 0x5E5CE6),
         accent: NSColor(hex: 0xFF453A),
         background: .black,
         text: .white
     )
 }
 
 // 15. 性能优化 - 颜色缓存
 class ColorCache {
     private static var cache: [String: NSColor] = [:]
     
     static func color(for hexString: String) -> NSColor {
         if let cachedColor = cache[hexString] {
             return cachedColor
         }
         
         if let color = NSColor(hexString: hexString) {
             cache[hexString] = color
             return color
         }
         
         return .black
     }
     
     static func clearCache() {
         cache.removeAll()
     }
 }
 
 */
