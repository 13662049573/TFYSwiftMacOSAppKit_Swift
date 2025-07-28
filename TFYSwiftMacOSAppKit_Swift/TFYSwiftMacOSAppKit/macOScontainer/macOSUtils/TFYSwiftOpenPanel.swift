//
//  TFYSwiftOpenPanel.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import UniformTypeIdentifiers

/// 文件选择面板错误类型
public enum TFYOpenPanelError: Error, LocalizedError {
    case noMainWindow
    case invalidFileType
    case invalidDirectory
    case userCancelled
    case accessDenied
    
    public var errorDescription: String? {
        switch self {
        case .noMainWindow:
            return "没有主窗口"
        case .invalidFileType:
            return "无效的文件类型"
        case .invalidDirectory:
            return "无效的目录"
        case .userCancelled:
            return "用户取消操作"
        case .accessDenied:
            return "访问被拒绝"
        }
    }
}

/// 文件选择结果
public struct TFYFileSelectionResult {
    public let urls: [URL]
    public let panel: NSOpenPanel
    public let wasCancelled: Bool
    
    public init(urls: [URL], panel: NSOpenPanel, wasCancelled: Bool) {
        self.urls = urls
        self.panel = panel
        self.wasCancelled = wasCancelled
    }
}

/// 文件保存结果
public struct TFYSaveFileResult {
    public let url: URL?
    public let panel: NSOpenPanel
    public let wasCancelled: Bool
    
    public init(url: URL?, panel: NSOpenPanel, wasCancelled: Bool) {
        self.url = url
        self.panel = panel
        self.wasCancelled = wasCancelled
    }
}

/// 文件选择面板配置
public struct TFYOpenPanelConfiguration {
    public var title: String = "选择文件"
    public var prompt: String = "选择"
    public var message: String = "请选择文件"
    public var canChooseFiles: Bool = true
    public var canChooseDirectories: Bool = false
    public var allowsMultipleSelection: Bool = false
    public var canCreateDirectories: Bool = true
    public var showsHiddenFiles: Bool = false
    public var treatsFilePackagesAsDirectories: Bool = false
    public var directoryURL: URL?
    public var allowedContentTypes: [UTType] = []
    public var accessoryView: NSView?
    public var accessoryViewDisclosed: Bool = true
    
    public init() {}
}

/// 文件保存面板配置
public struct TFYSavePanelConfiguration {
    public var title: String = "保存文件"
    public var prompt: String = "保存"
    public var message: String = "请选择保存位置"
    public var nameFieldStringValue: String = ""
    public var canCreateDirectories: Bool = true
    public var allowsSelectingHiddenExtension: Bool = false
    public var directoryURL: URL?
    public var allowedContentTypes: [UTType] = []
    public var accessoryView: NSView?
    public var accessoryViewDisclosed: Bool = true
    
    public init() {}
}

/// 文件选择面板工具类 - 提供完整的文件选择功能封装
/// 支持文件选择、文件保存、自定义视图、过滤器等高级功能
@available(macOS 10.15, *)
public class TFYSwiftOpenPanel: NSObject {

    // MARK: - 常用文件类型
    
    /// 图片文件类型
    public static let imageTypes: [UTType] = [.image, .jpeg, .png, .gif, .bmp, .tiff]
    
    /// 文档文件类型
    public static let documentTypes: [UTType] = [.text, .plainText, .rtf, .rtfd, .pdf]
    
    /// 音频文件类型
    public static let audioTypes: [UTType] = [.audio, .mp3, .wav, .aiff]
    
    /// 视频文件类型
    public static let videoTypes: [UTType] = [.movie, .avi]
    
    /// 所有文件类型
    public static let allTypes: [UTType] = []
    
    // MARK: - 文件选择方法
    
    /// 选择文件（简化版）
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - fileTypes: 文件类型
    ///   - completion: 完成回调
    public static func selectFiles(title: String = "选择文件",
                                  message: String = "请选择文件",
                                  fileTypes: [UTType] = [],
                                  completion: @escaping (TFYFileSelectionResult) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.allowedContentTypes = fileTypes
        
        selectFiles(configuration: config, completion: completion)
    }
    
    /// 选择文件（配置版）
    /// - Parameters:
    ///   - configuration: 配置
    ///   - completion: 完成回调
    public static func selectFiles(configuration: TFYOpenPanelConfiguration,
                                  completion: @escaping (TFYFileSelectionResult) -> Void) {
        guard let mainWindow = NSApp.mainWindow else {
            completion(TFYFileSelectionResult(urls: [], panel: NSOpenPanel(), wasCancelled: true))
            return
        }
        
        let panel = createPanel(configuration: configuration)
        
        panel.beginSheetModal(for: mainWindow) { result in
            let wasCancelled = result != .OK
            let urls = wasCancelled ? [] : panel.urls
            let selectionResult = TFYFileSelectionResult(urls: urls, panel: panel, wasCancelled: wasCancelled)
            completion(selectionResult)
        }
    }
    
    /// 选择单个文件
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - fileTypes: 文件类型
    ///   - completion: 完成回调
    public static func selectFile(title: String = "选择文件",
                                 message: String = "请选择文件",
                                 fileTypes: [UTType] = [],
                                 completion: @escaping (URL?) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.allowedContentTypes = fileTypes
        config.allowsMultipleSelection = false
        
        selectFiles(configuration: config) { result in
            completion(result.wasCancelled ? nil : result.urls.first)
        }
    }
    
    /// 选择目录
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - completion: 完成回调
    public static func selectDirectory(title: String = "选择目录",
                                     message: String = "请选择目录",
                                     completion: @escaping (URL?) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.canChooseFiles = false
        config.canChooseDirectories = true
        config.allowsMultipleSelection = false
        
        selectFiles(configuration: config) { result in
            completion(result.wasCancelled ? nil : result.urls.first)
        }
    }
    
    /// 选择多个文件
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - fileTypes: 文件类型
    ///   - completion: 完成回调
    public static func selectMultipleFiles(title: String = "选择文件",
                                         message: String = "请选择文件",
                                         fileTypes: [UTType] = [],
                                         completion: @escaping ([URL]) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.allowedContentTypes = fileTypes
        config.allowsMultipleSelection = true
        
        selectFiles(configuration: config) { result in
            completion(result.wasCancelled ? [] : result.urls)
        }
    }
    
    // MARK: - 文件保存方法
    
    /// 保存文件（简化版）
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - fileName: 默认文件名
    ///   - fileTypes: 文件类型
    ///   - completion: 完成回调
    public static func saveFile(title: String = "保存文件",
                               message: String = "请选择保存位置",
                               fileName: String = "",
                               fileTypes: [UTType] = [],
                               completion: @escaping (TFYSaveFileResult) -> Void) {
        var config = TFYSavePanelConfiguration()
        config.title = title
        config.message = message
        config.nameFieldStringValue = fileName
        config.allowedContentTypes = fileTypes
        
        saveFile(configuration: config, completion: completion)
    }
    
    /// 保存文件（配置版）
    /// - Parameters:
    ///   - configuration: 配置
    ///   - completion: 完成回调
    public static func saveFile(configuration: TFYSavePanelConfiguration,
                               completion: @escaping (TFYSaveFileResult) -> Void) {
        guard let mainWindow = NSApp.mainWindow else {
            completion(TFYSaveFileResult(url: nil, panel: NSOpenPanel(), wasCancelled: true))
            return
        }
        
        let panel = createSavePanel(configuration: configuration)
        
        panel.beginSheetModal(for: mainWindow) { result in
            let wasCancelled = result != .OK
            let url = wasCancelled ? nil : panel.url
            let saveResult = TFYSaveFileResult(url: url, panel: panel, wasCancelled: wasCancelled)
            completion(saveResult)
        }
    }
    
    // MARK: - 高级功能
    
    /// 选择文件并自定义代理
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - fileTypes: 文件类型
    ///   - delegate: 自定义代理
    ///   - completion: 完成回调
    public static func selectFileWithDelegate(title: String = "选择文件",
                                            message: String = "请选择文件",
                                            fileTypes: [UTType] = [],
                                            delegate: NSOpenSavePanelDelegate,
                                            completion: @escaping (TFYFileSelectionResult) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.allowedContentTypes = fileTypes
        config.allowsMultipleSelection = false
        
        let panel = createPanel(configuration: config)
        panel.delegate = delegate
        
        guard let mainWindow = NSApp.mainWindow else {
            completion(TFYFileSelectionResult(urls: [], panel: panel, wasCancelled: true))
            return
        }
        
        panel.beginSheetModal(for: mainWindow) { result in
            let wasCancelled = result != .OK
            let urls = wasCancelled ? [] : panel.urls
            let selectionResult = TFYFileSelectionResult(urls: urls, panel: panel, wasCancelled: wasCancelled)
            completion(selectionResult)
        }
    }
    
    /// 选择文件并自定义视图
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - fileTypes: 文件类型
    ///   - accessoryView: 自定义视图
    ///   - completion: 完成回调
    public static func selectFileWithAccessoryView(title: String = "选择文件",
                                                 message: String = "请选择文件",
                                                 fileTypes: [UTType] = [],
                                                 accessoryView: NSView,
                                                 completion: @escaping (TFYFileSelectionResult) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.allowedContentTypes = fileTypes
        config.accessoryView = accessoryView
        
        selectFiles(configuration: config, completion: completion)
    }
    
    // MARK: - 便利方法
    
    /// 选择图片文件
    /// - Parameters:
    ///   - allowsMultiple: 是否允许多选
    ///   - completion: 完成回调
    public static func selectImages(allowsMultiple: Bool = false,
                                   completion: @escaping ([URL]) -> Void) {
        let title = allowsMultiple ? "选择图片" : "选择图片"
        let message = allowsMultiple ? "请选择图片文件" : "请选择图片文件"
        
        if allowsMultiple {
            selectMultipleFiles(title: title, message: message, fileTypes: imageTypes, completion: completion)
        } else {
            selectFile(title: title, message: message, fileTypes: imageTypes) { url in
                completion(url != nil ? [url!] : [])
            }
        }
    }
    
    /// 选择文档文件
    /// - Parameters:
    ///   - allowsMultiple: 是否允许多选
    ///   - completion: 完成回调
    public static func selectDocuments(allowsMultiple: Bool = false,
                                     completion: @escaping ([URL]) -> Void) {
        let title = allowsMultiple ? "选择文档" : "选择文档"
        let message = allowsMultiple ? "请选择文档文件" : "请选择文档文件"
        
        if allowsMultiple {
            selectMultipleFiles(title: title, message: message, fileTypes: documentTypes, completion: completion)
        } else {
            selectFile(title: title, message: message, fileTypes: documentTypes) { url in
                completion(url != nil ? [url!] : [])
            }
        }
    }
    
    /// 选择音频文件
    /// - Parameters:
    ///   - allowsMultiple: 是否允许多选
    ///   - completion: 完成回调
    public static func selectAudioFiles(allowsMultiple: Bool = false,
                                       completion: @escaping ([URL]) -> Void) {
        let title = allowsMultiple ? "选择音频" : "选择音频"
        let message = allowsMultiple ? "请选择音频文件" : "请选择音频文件"
        
        if allowsMultiple {
            selectMultipleFiles(title: title, message: message, fileTypes: audioTypes, completion: completion)
        } else {
            selectFile(title: title, message: message, fileTypes: audioTypes) { url in
                completion(url != nil ? [url!] : [])
            }
        }
    }
    
    /// 选择视频文件
    /// - Parameters:
    ///   - allowsMultiple: 是否允许多选
    ///   - completion: 完成回调
    public static func selectVideoFiles(allowsMultiple: Bool = false,
                                       completion: @escaping ([URL]) -> Void) {
        let title = allowsMultiple ? "选择视频" : "选择视频"
        let message = allowsMultiple ? "请选择视频文件" : "请选择视频文件"
        
        if allowsMultiple {
            selectMultipleFiles(title: title, message: message, fileTypes: videoTypes, completion: completion)
        } else {
            selectFile(title: title, message: message, fileTypes: videoTypes) { url in
                completion(url != nil ? [url!] : [])
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 创建文件选择面板
    /// - Parameter configuration: 配置
    /// - Returns: 文件选择面板
    private static func createPanel(configuration: TFYOpenPanelConfiguration) -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.title = configuration.title
        panel.prompt = configuration.prompt
        panel.message = configuration.message
        panel.canChooseFiles = configuration.canChooseFiles
        panel.canChooseDirectories = configuration.canChooseDirectories
        panel.allowsMultipleSelection = configuration.allowsMultipleSelection
        panel.canCreateDirectories = configuration.canCreateDirectories
        panel.showsHiddenFiles = configuration.showsHiddenFiles
        panel.treatsFilePackagesAsDirectories = configuration.treatsFilePackagesAsDirectories
        panel.directoryURL = configuration.directoryURL
        panel.allowedContentTypes = configuration.allowedContentTypes
        
        if let accessoryView = configuration.accessoryView {
            panel.accessoryView = accessoryView
            panel.isAccessoryViewDisclosed = configuration.accessoryViewDisclosed
        }
        
        return panel
    }
    
    /// 创建文件保存面板
    /// - Parameter configuration: 配置
    /// - Returns: 文件保存面板
    private static func createSavePanel(configuration: TFYSavePanelConfiguration) -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.title = configuration.title
        panel.prompt = configuration.prompt
        panel.message = configuration.message
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = configuration.canCreateDirectories
        panel.directoryURL = configuration.directoryURL
        panel.allowedContentTypes = configuration.allowedContentTypes
        panel.nameFieldStringValue = configuration.nameFieldStringValue
        
        if let accessoryView = configuration.accessoryView {
            panel.accessoryView = accessoryView
            panel.isAccessoryViewDisclosed = configuration.accessoryViewDisclosed
        }
        
        return panel
    }
}

// MARK: - 代理协议扩展

@available(macOS 10.15, *)
public extension TFYSwiftOpenPanel {
    
    /// 创建带预览功能的代理
    /// - Parameter previewHandler: 预览处理器
    /// - Returns: 代理对象
    static func createPreviewDelegate(previewHandler: @escaping (URL) -> NSView?) -> NSOpenSavePanelDelegate {
        return PreviewDelegate(previewHandler: previewHandler)
    }
}

// MARK: - 预览代理实现（可选使用）

@available(macOS 10.15, *)
private class PreviewDelegate: NSObject, NSOpenSavePanelDelegate {
    private let previewHandler: (URL) -> NSView?
    
    init(previewHandler: @escaping (URL) -> NSView?) {
        self.previewHandler = previewHandler
        super.init()
    }
    
    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        return true
    }
    
    func panel(_ sender: Any, validate url: URL) throws {
        // 可以在这里添加验证逻辑
    }
    
    func panel(_ sender: Any, didChangeToDirectoryURL url: URL?) {
        // 目录改变时的处理
    }
    
    func panel(_ sender: Any, willExpand expanding: Bool) {
        // 面板展开/收缩时的处理
    }
}

// MARK: - 兼容性方法（保持向后兼容）

@available(macOS 10.15, *)
public extension TFYSwiftOpenPanel {
    
    /// 兼容性方法：打开面板
    /// - Parameters:
    ///   - titleMessage: 标题消息
    ///   - setPrompt: 提示文本
    ///   - canChooseFilesFlag: 是否可以选择文件
    ///   - allowsMultipleSelectionFlag: 是否允许多选
    ///   - canChooseDirectoriesFlag: 是否可以选择目录
    ///   - canCreateDirectoriesFlag: 是否可以创建目录
    ///   - dirURL: 目录URL
    ///   - fileTypes: 文件类型
    ///   - completionHandler: 完成回调
    static func openPanelWithTitleMessage(titleMessage: String,
                                                     setPrompt: String,
                                                     canChooseFilesFlag: Bool,
                                                     allowsMultipleSelectionFlag: Bool,
                                                     canChooseDirectoriesFlag: Bool,
                                                     canCreateDirectoriesFlag: Bool,
                                                     dirURL: URL,
                                                     fileTypes: [UTType],
                                                     completionHandler: @escaping (_ openpanel: NSOpenPanel, _ URLs: [URL]) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = titleMessage
        config.prompt = setPrompt
        config.message = titleMessage
        config.canChooseFiles = canChooseFilesFlag
        config.allowsMultipleSelection = allowsMultipleSelectionFlag
        config.canChooseDirectories = canChooseDirectoriesFlag
        config.canCreateDirectories = canCreateDirectoriesFlag
        config.directoryURL = dirURL
        config.allowedContentTypes = fileTypes
        
        selectFiles(configuration: config) { result in
            completionHandler(result.panel, result.urls)
        }
    }
    
    /// 兼容性方法：保存面板
    /// - Parameters:
    ///   - titleMessage: 标题消息
    ///   - prompt: 提示文本
    ///   - title: 标题
    ///   - fileName: 文件名
    ///   - canCreateDirectoriesFlag: 是否可以创建目录
    ///   - allowsSelectingHiddenExtensionFlag: 是否可以选择隐藏扩展名
    ///   - dirURL: 目录URL
    ///   - fileTypes: 文件类型
    ///   - completionHandler: 完成回调
    static func savePanelWithTitleMessage(titleMessage: String,
                                                     prompt: String,
                                                     title: String,
                                                     fileName: String,
                                                     canCreateDirectoriesFlag: Bool,
                                                     allowsSelectingHiddenExtensionFlag: Bool,
                                                     dirURL: URL,
                                                     fileTypes: [UTType],
                                                     completionHandler: @escaping (_ openpanel: NSOpenPanel, _ url: URL?) -> Void) {
        var config = TFYSavePanelConfiguration()
        config.title = title
        config.prompt = prompt
        config.message = titleMessage
        config.nameFieldStringValue = fileName
        config.canCreateDirectories = canCreateDirectoriesFlag
        config.allowsSelectingHiddenExtension = allowsSelectingHiddenExtensionFlag
        config.directoryURL = dirURL
        config.allowedContentTypes = fileTypes
        
        saveFile(configuration: config) { result in
            completionHandler(result.panel, result.url)
        }
    }
    
    /// 兼容性方法：带附件视图的保存面板
    /// - Parameters:
    ///   - fileTypes: 文件类型
    ///   - frame: 框架
    ///   - titleMessage: 标题消息
    ///   - prompt: 提示文本
    ///   - accessoryImage: 附件图片
    ///   - completionHandler: 完成回调
    static func savePanelWithAllowedFileTypes(fileTypes: [UTType],
                                                         frame: NSRect,
                                                         titleMessage: String,
                                                         prompt: String,
                                                         accessoryImage: NSImage,
                                                         completionHandler: @escaping (_ openpanel: NSOpenPanel, _ url: URL?) -> Void) {
        var config = TFYSavePanelConfiguration()
        config.title = titleMessage
        config.prompt = prompt
        config.message = titleMessage
        config.allowedContentTypes = fileTypes
        
        // 创建附件视图
            let accessoryView = NSView(frame: frame)
            let accessoryImageView = NSImageView(frame: accessoryView.frame)
            accessoryImageView.image = accessoryImage
            accessoryImageView.wantsLayer = true
            accessoryImageView.layer?.backgroundColor = NSColor.white.cgColor
            accessoryView.addSubview(accessoryImageView)
        config.accessoryView = accessoryView
        
        saveFile(configuration: config) { result in
            completionHandler(result.panel, result.url)
        }
        }
}
