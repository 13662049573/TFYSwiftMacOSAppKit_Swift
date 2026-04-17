//
//  TFYSwiftOpenPanel.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import UniformTypeIdentifiers

// MARK: - 错误类型

/// 文件选择面板错误类型
public enum TFYOpenPanelError: Error, LocalizedError {
    case noMainWindow
    case invalidFileType
    case invalidDirectory
    case userCancelled
    case accessDenied
    case fileNotReadable(URL)
    case fileNotWritable(URL)
    case fileTooLarge(URL, limit: Int64, actual: Int64)
    case fileTooSmall(URL, minimum: Int64, actual: Int64)
    case tooManyFilesSelected(count: Int, limit: Int)
    case bookmarkCreationFailed(underlying: Error)
    case bookmarkResolutionFailed(underlying: Error)
    case bookmarkStale(URL)
    case validationFailed(reason: String)
    case sandboxAccessDenied(URL)

    public var errorDescription: String? {
        switch self {
        case .noMainWindow:
            return "没有可用的主窗口"
        case .invalidFileType:
            return "无效的文件类型"
        case .invalidDirectory:
            return "无效的目录"
        case .userCancelled:
            return "用户取消操作"
        case .accessDenied:
            return "访问被拒绝"
        case .fileNotReadable(let url):
            return "文件不可读: \(url.path)"
        case .fileNotWritable(let url):
            return "文件不可写: \(url.path)"
        case .fileTooLarge(let url, let limit, let actual):
            return "文件过大: \(url.lastPathComponent) (上限 \(limit) 字节, 实际 \(actual) 字节)"
        case .fileTooSmall(let url, let minimum, let actual):
            return "文件过小: \(url.lastPathComponent) (下限 \(minimum) 字节, 实际 \(actual) 字节)"
        case .tooManyFilesSelected(let count, let limit):
            return "选择文件数量超出限制: \(count) > \(limit)"
        case .bookmarkCreationFailed(let underlying):
            return "创建安全作用域书签失败: \(underlying.localizedDescription)"
        case .bookmarkResolutionFailed(let underlying):
            return "解析安全作用域书签失败: \(underlying.localizedDescription)"
        case .bookmarkStale(let url):
            return "书签已失效需要重新创建: \(url.path)"
        case .validationFailed(let reason):
            return "校验失败: \(reason)"
        case .sandboxAccessDenied(let url):
            return "沙盒拒绝访问: \(url.path)"
        }
    }
}

// MARK: - 结果类型

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

    /// 第一个 URL（便利访问）
    public var firstURL: URL? { urls.first }

    /// 是否为成功结果（未取消且至少一个文件）
    public var isSuccess: Bool { !wasCancelled && !urls.isEmpty }
}

/// 文件保存结果
public struct TFYSaveFileResult {
    public let url: URL?
    public let panel: NSSavePanel
    public let wasCancelled: Bool

    public init(url: URL?, panel: NSSavePanel, wasCancelled: Bool) {
        self.url = url
        self.panel = panel
        self.wasCancelled = wasCancelled
    }

    /// 是否为成功结果
    public var isSuccess: Bool { !wasCancelled && url != nil }
}

// MARK: - 配置类型

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
    public var resolvesAliases: Bool = true
    public var directoryURL: URL?
    public var allowedContentTypes: [UTType] = []
    public var accessoryView: NSView?
    public var accessoryViewDisclosed: Bool = true

    /// 自定义文件过滤器（返回 true 通过校验）
    public var fileFilter: ((URL) -> Bool)?

    /// 单文件大小上限（字节）
    public var maxFileSize: Int64?

    /// 单文件大小下限（字节）
    public var minFileSize: Int64?

    /// 选择文件数量上限
    public var maxSelectionCount: Int?

    /// 是否记忆最后访问目录（基于 lastDirectoryKey 持久化到 UserDefaults）
    public var rememberLastDirectory: Bool = false

    /// 记忆 key（rememberLastDirectory 为 true 时使用）
    public var lastDirectoryKey: String?

    /// 选择完成后是否自动创建安全作用域书签
    public var createSecurityScopedBookmark: Bool = false

    public init() {}
}

/// 文件保存面板配置
public struct TFYSavePanelConfiguration {
    public var title: String = "保存文件"
    public var prompt: String = "保存"
    public var message: String = "请选择保存位置"
    public var nameFieldStringValue: String = ""
    public var nameFieldLabel: String?
    public var canCreateDirectories: Bool = true
    public var allowsSelectingHiddenExtension: Bool = false
    public var isExtensionHidden: Bool = false
    public var allowsOtherFileTypes: Bool = false
    public var showsHiddenFiles: Bool = false
    public var treatsFilePackagesAsDirectories: Bool = false
    public var directoryURL: URL?
    public var allowedContentTypes: [UTType] = []
    public var accessoryView: NSView?
    public var accessoryViewDisclosed: Bool = true

    /// 默认扩展名（无扩展名时自动追加）
    public var defaultExtension: String?

    /// 是否记忆最后访问目录
    public var rememberLastDirectory: Bool = false

    public var lastDirectoryKey: String?

    /// 保存完成后是否自动创建安全作用域书签
    public var createSecurityScopedBookmark: Bool = false

    public init() {}
}

// MARK: - 主类

/// 文件选择面板工具类 - 完整、健壮的 NSOpenPanel/NSSavePanel 封装
///
/// 功能特性：
/// - 同步回调与 async/await 双模式 API
/// - sheet 重入保护（自动等待前一个 sheet 卸下，避免 AppKit EXC_BREAKPOINT）
/// - 主线程安全：所有面板创建均在主线程进行
/// - 自定义校验：文件大小、数量、自定义谓词
/// - 沙盒友好：内置安全作用域书签创建/解析/访问辅助
/// - 最近目录记忆：自动记忆并恢复最后一次访问目录
/// - 丰富的文件类型预设：图片/文档/音频/视频/压缩包/源代码/电子表格/演示文稿
/// - 完整向后兼容
@available(macOS 10.15, *)
public class TFYSwiftOpenPanel: NSObject {

    // MARK: - 常用文件类型预设

    /// 图片文件类型
    public static let imageTypes: [UTType] = {
        var types: [UTType] = [.image, .jpeg, .png, .gif, .bmp, .tiff, .heic, .webP]
        if let svg = UTType(filenameExtension: "svg") { types.append(svg) }
        return types
    }()

    /// 文档文件类型
    public static let documentTypes: [UTType] = [.text, .plainText, .rtf, .rtfd, .pdf, .html, .xml, .epub]

    /// 音频文件类型
    public static let audioTypes: [UTType] = [.audio, .mp3, .wav, .aiff, .midi]

    /// 视频文件类型
    public static let videoTypes: [UTType] = [.movie, .video, .mpeg4Movie, .quickTimeMovie, .avi]

    /// 压缩包文件类型
    public static let archiveTypes: [UTType] = {
        var types: [UTType] = [.zip, .gzip, .bz2, .archive]
        ["7z", "rar", "tar", "xz"].forEach { ext in
            if let t = UTType(filenameExtension: ext) { types.append(t) }
        }
        return types
    }()

    /// 电子表格文件类型
    public static let spreadsheetTypes: [UTType] = [.spreadsheet, .commaSeparatedText, .tabSeparatedText]

    /// 演示文稿文件类型
    public static let presentationTypes: [UTType] = [.presentation]

    /// 源代码文件类型
    public static let codeTypes: [UTType] = [
        .sourceCode, .swiftSource, .objectiveCSource, .objectiveCPlusPlusSource,
        .cSource, .cPlusPlusSource, .cHeader, .javaScript,
        .json, .yaml, .shellScript, .pythonScript, .rubyScript, .perlScript, .phpScript
    ]

    /// 所有文件类型（空数组表示不限制）
    public static let allTypes: [UTType] = []

    // MARK: - 内部常量

    private static let lastDirectoryDefaultsPrefix = "com.tfyswift.openpanel.lastDirectory."

    // MARK: - 文件选择（回调 API）

    /// 选择文件（简化版）
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
    public static func selectFiles(configuration: TFYOpenPanelConfiguration,
                                  completion: @escaping (TFYFileSelectionResult) -> Void) {
        presentOpenPanel(configuration: configuration, attempts: 0, completion: completion)
    }

    /// 选择单个文件
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

    /// 选择多个目录
    public static func selectDirectories(title: String = "选择目录",
                                        message: String = "请选择目录",
                                        completion: @escaping ([URL]) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.canChooseFiles = false
        config.canChooseDirectories = true
        config.allowsMultipleSelection = true
        selectFiles(configuration: config) { result in
            completion(result.wasCancelled ? [] : result.urls)
        }
    }

    /// 选择多个文件
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

    /// 选择文件，返回 Result<[URL], TFYOpenPanelError>
    public static func selectFilesWithResult(configuration: TFYOpenPanelConfiguration,
                                            completion: @escaping (Result<[URL], TFYOpenPanelError>) -> Void) {
        selectFiles(configuration: configuration) { result in
            if result.wasCancelled {
                completion(.failure(.userCancelled))
                return
            }
            do {
                try validateSelection(result.urls, against: configuration)
                completion(.success(result.urls))
            } catch let error as TFYOpenPanelError {
                completion(.failure(error))
            } catch {
                completion(.failure(.validationFailed(reason: error.localizedDescription)))
            }
        }
    }

    // MARK: - 文件选择（async/await API）

    /// 选择文件（async）
    @available(macOS 10.15, *)
    public static func selectFiles(configuration: TFYOpenPanelConfiguration) async -> TFYFileSelectionResult {
        await withCheckedContinuation { continuation in
            selectFiles(configuration: configuration) { result in
                continuation.resume(returning: result)
            }
        }
    }

    /// 选择单个文件（async）
    @available(macOS 10.15, *)
    public static func selectFile(title: String = "选择文件",
                                 message: String = "请选择文件",
                                 fileTypes: [UTType] = []) async -> URL? {
        await withCheckedContinuation { continuation in
            selectFile(title: title, message: message, fileTypes: fileTypes) { url in
                continuation.resume(returning: url)
            }
        }
    }

    /// 选择多个文件（async）
    @available(macOS 10.15, *)
    public static func selectMultipleFiles(title: String = "选择文件",
                                          message: String = "请选择文件",
                                          fileTypes: [UTType] = []) async -> [URL] {
        await withCheckedContinuation { continuation in
            selectMultipleFiles(title: title, message: message, fileTypes: fileTypes) { urls in
                continuation.resume(returning: urls)
            }
        }
    }

    /// 选择目录（async）
    @available(macOS 10.15, *)
    public static func selectDirectory(title: String = "选择目录",
                                      message: String = "请选择目录") async -> URL? {
        await withCheckedContinuation { continuation in
            selectDirectory(title: title, message: message) { url in
                continuation.resume(returning: url)
            }
        }
    }

    /// 选择文件并校验（throws）
    @available(macOS 10.15, *)
    public static func selectFilesThrowing(configuration: TFYOpenPanelConfiguration) async throws -> [URL] {
        try await withCheckedThrowingContinuation { continuation in
            selectFilesWithResult(configuration: configuration) { result in
                continuation.resume(with: result.mapError { $0 as Error })
            }
        }
    }

    // MARK: - 文件保存（回调 API）

    /// 保存文件（简化版）
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
    ///
    /// NSSavePanel() 必须在主线程创建；如果上一个 sheet 仍未卸下，
    /// 同步创建 + beginSheetModal 会在 AppKit 内部命中断言（EXC_BREAKPOINT）。
    /// 同时，沙盒 App 必须拥有 com.apple.security.files.user-selected.read-write 权限，
    /// 否则 NSRemoteSavePanel 在初始化时也会触发同一断言。
    public static func saveFile(configuration: TFYSavePanelConfiguration,
                               completion: @escaping (TFYSaveFileResult) -> Void) {
        presentSavePanel(configuration: configuration, attempts: 0, completion: completion)
    }

    /// 保存文件，返回 Result
    public static func saveFileWithResult(configuration: TFYSavePanelConfiguration,
                                         completion: @escaping (Result<URL, TFYOpenPanelError>) -> Void) {
        saveFile(configuration: configuration) { result in
            if result.wasCancelled {
                completion(.failure(.userCancelled))
                return
            }
            guard let url = result.url else {
                completion(.failure(.userCancelled))
                return
            }
            completion(.success(url))
        }
    }

    // MARK: - 文件保存（async/await API）

    /// 保存文件（async）
    @available(macOS 10.15, *)
    public static func saveFile(configuration: TFYSavePanelConfiguration) async -> TFYSaveFileResult {
        await withCheckedContinuation { continuation in
            saveFile(configuration: configuration) { result in
                continuation.resume(returning: result)
            }
        }
    }

    /// 保存文件（async 简化版）
    @available(macOS 10.15, *)
    public static func saveFile(title: String = "保存文件",
                               message: String = "请选择保存位置",
                               fileName: String = "",
                               fileTypes: [UTType] = []) async -> URL? {
        await withCheckedContinuation { continuation in
            saveFile(title: title, message: message, fileName: fileName, fileTypes: fileTypes) { result in
                continuation.resume(returning: result.url)
            }
        }
    }

    /// 写入数据到用户选择的位置（async throws）
    @available(macOS 10.15, *)
    public static func saveData(_ data: Data,
                               configuration: TFYSavePanelConfiguration) async throws -> URL {
        let result = await saveFile(configuration: configuration)
        if result.wasCancelled { throw TFYOpenPanelError.userCancelled }
        guard let url = result.url else { throw TFYOpenPanelError.userCancelled }
        try data.write(to: url, options: [.atomic])
        return url
    }

    /// 写入字符串到用户选择的位置（async throws）
    @available(macOS 10.15, *)
    public static func saveText(_ text: String,
                               encoding: String.Encoding = .utf8,
                               configuration: TFYSavePanelConfiguration) async throws -> URL {
        guard let data = text.data(using: encoding) else {
            throw TFYOpenPanelError.validationFailed(reason: "字符串编码失败")
        }
        return try await saveData(data, configuration: configuration)
    }

    // MARK: - 高级功能

    /// 选择文件并自定义代理
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

        presentOpenPanel(configuration: config, attempts: 0, delegate: delegate, completion: completion)
    }

    /// 选择文件并自定义视图
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
    public static func selectImages(allowsMultiple: Bool = false,
                                   completion: @escaping ([URL]) -> Void) {
        if allowsMultiple {
            selectMultipleFiles(title: "选择图片", message: "请选择图片文件", fileTypes: imageTypes, completion: completion)
        } else {
            selectFile(title: "选择图片", message: "请选择图片文件", fileTypes: imageTypes) { url in
                completion(url.map { [$0] } ?? [])
            }
        }
    }

    /// 选择文档文件
    public static func selectDocuments(allowsMultiple: Bool = false,
                                      completion: @escaping ([URL]) -> Void) {
        if allowsMultiple {
            selectMultipleFiles(title: "选择文档", message: "请选择文档文件", fileTypes: documentTypes, completion: completion)
        } else {
            selectFile(title: "选择文档", message: "请选择文档文件", fileTypes: documentTypes) { url in
                completion(url.map { [$0] } ?? [])
            }
        }
    }

    /// 选择音频文件
    public static func selectAudioFiles(allowsMultiple: Bool = false,
                                       completion: @escaping ([URL]) -> Void) {
        if allowsMultiple {
            selectMultipleFiles(title: "选择音频", message: "请选择音频文件", fileTypes: audioTypes, completion: completion)
        } else {
            selectFile(title: "选择音频", message: "请选择音频文件", fileTypes: audioTypes) { url in
                completion(url.map { [$0] } ?? [])
            }
        }
    }

    /// 选择视频文件
    public static func selectVideoFiles(allowsMultiple: Bool = false,
                                       completion: @escaping ([URL]) -> Void) {
        if allowsMultiple {
            selectMultipleFiles(title: "选择视频", message: "请选择视频文件", fileTypes: videoTypes, completion: completion)
        } else {
            selectFile(title: "选择视频", message: "请选择视频文件", fileTypes: videoTypes) { url in
                completion(url.map { [$0] } ?? [])
            }
        }
    }

    /// 选择压缩包
    public static func selectArchives(allowsMultiple: Bool = false,
                                     completion: @escaping ([URL]) -> Void) {
        if allowsMultiple {
            selectMultipleFiles(title: "选择压缩包", message: "请选择压缩文件", fileTypes: archiveTypes, completion: completion)
        } else {
            selectFile(title: "选择压缩包", message: "请选择压缩文件", fileTypes: archiveTypes) { url in
                completion(url.map { [$0] } ?? [])
            }
        }
    }

    /// 选择源代码文件
    public static func selectCodeFiles(allowsMultiple: Bool = true,
                                      completion: @escaping ([URL]) -> Void) {
        if allowsMultiple {
            selectMultipleFiles(title: "选择源代码", message: "请选择源代码文件", fileTypes: codeTypes, completion: completion)
        } else {
            selectFile(title: "选择源代码", message: "请选择源代码文件", fileTypes: codeTypes) { url in
                completion(url.map { [$0] } ?? [])
            }
        }
    }

    /// 选择电子表格
    public static func selectSpreadsheets(allowsMultiple: Bool = false,
                                         completion: @escaping ([URL]) -> Void) {
        if allowsMultiple {
            selectMultipleFiles(title: "选择电子表格", message: "请选择电子表格", fileTypes: spreadsheetTypes, completion: completion)
        } else {
            selectFile(title: "选择电子表格", message: "请选择电子表格", fileTypes: spreadsheetTypes) { url in
                completion(url.map { [$0] } ?? [])
            }
        }
    }

    // MARK: - 安全作用域书签（沙盒持久化访问）

    /// 创建安全作用域书签
    /// - Parameters:
    ///   - url: 需要持久化访问的 URL
    ///   - readOnly: 是否为只读书签
    /// - Returns: 书签数据，可保存到 UserDefaults 或文件
    public static func createSecurityScopedBookmark(for url: URL, readOnly: Bool = false) throws -> Data {
        let options: URL.BookmarkCreationOptions = readOnly
            ? [.withSecurityScope, .securityScopeAllowOnlyReadAccess]
            : [.withSecurityScope]
        do {
            return try url.bookmarkData(options: options,
                                        includingResourceValuesForKeys: nil,
                                        relativeTo: nil)
        } catch {
            throw TFYOpenPanelError.bookmarkCreationFailed(underlying: error)
        }
    }

    /// 解析安全作用域书签
    /// - Returns: (URL, 是否过期需要重建)
    public static func resolveSecurityScopedBookmark(_ data: Data) throws -> (url: URL, isStale: Bool) {
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data,
                              options: [.withSecurityScope],
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            return (url, isStale)
        } catch {
            throw TFYOpenPanelError.bookmarkResolutionFailed(underlying: error)
        }
    }

    /// 在安全作用域内执行闭包（自动 start/stop accessing）
    public static func withSecurityScopedAccess<T>(to url: URL, _ body: (URL) throws -> T) throws -> T {
        let didStart = url.startAccessingSecurityScopedResource()
        defer {
            if didStart { url.stopAccessingSecurityScopedResource() }
        }
        return try body(url)
    }

    /// 通过书签数据执行闭包
    public static func withBookmark<T>(_ data: Data, _ body: (URL) throws -> T) throws -> T {
        let resolved = try resolveSecurityScopedBookmark(data)
        if resolved.isStale {
            throw TFYOpenPanelError.bookmarkStale(resolved.url)
        }
        return try withSecurityScopedAccess(to: resolved.url, body)
    }

    /// 选择目录并立即创建安全作用域书签
    public static func selectDirectoryWithBookmark(title: String = "选择目录",
                                                  message: String = "请选择目录",
                                                  completion: @escaping (Result<(url: URL, bookmark: Data), TFYOpenPanelError>) -> Void) {
        var config = TFYOpenPanelConfiguration()
        config.title = title
        config.message = message
        config.canChooseFiles = false
        config.canChooseDirectories = true
        config.allowsMultipleSelection = false
        config.createSecurityScopedBookmark = true

        selectFiles(configuration: config) { result in
            if result.wasCancelled {
                completion(.failure(.userCancelled))
                return
            }
            guard let url = result.urls.first else {
                completion(.failure(.userCancelled))
                return
            }
            do {
                let bookmark = try createSecurityScopedBookmark(for: url)
                completion(.success((url, bookmark)))
            } catch let error as TFYOpenPanelError {
                completion(.failure(error))
            } catch {
                completion(.failure(.bookmarkCreationFailed(underlying: error)))
            }
        }
    }

    // MARK: - 最近目录记忆

    /// 获取最近目录
    public static func lastDirectory(forKey key: String) -> URL? {
        let fullKey = lastDirectoryDefaultsPrefix + key
        guard let path = UserDefaults.standard.string(forKey: fullKey) else { return nil }
        let url = URL(fileURLWithPath: path)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue else {
            return nil
        }
        return url
    }

    /// 设置最近目录
    public static func setLastDirectory(_ url: URL?, forKey key: String) {
        let fullKey = lastDirectoryDefaultsPrefix + key
        if let url = url {
            UserDefaults.standard.set(url.path, forKey: fullKey)
        } else {
            UserDefaults.standard.removeObject(forKey: fullKey)
        }
    }

    /// 清空所有最近目录
    public static func clearAllLastDirectories() {
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(lastDirectoryDefaultsPrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - 校验工具

    /// 校验选择结果是否符合配置约束
    public static func validateSelection(_ urls: [URL],
                                        against configuration: TFYOpenPanelConfiguration) throws {
        if let limit = configuration.maxSelectionCount, urls.count > limit {
            throw TFYOpenPanelError.tooManyFilesSelected(count: urls.count, limit: limit)
        }
        for url in urls {
            try validateSingleFile(url, against: configuration)
        }
    }

    private static func validateSingleFile(_ url: URL,
                                          against configuration: TFYOpenPanelConfiguration) throws {
        let fm = FileManager.default
        guard fm.isReadableFile(atPath: url.path) else {
            throw TFYOpenPanelError.fileNotReadable(url)
        }

        if configuration.maxFileSize != nil || configuration.minFileSize != nil {
            let attrs = try? fm.attributesOfItem(atPath: url.path)
            let size = (attrs?[.size] as? NSNumber)?.int64Value ?? 0
            if let maxSize = configuration.maxFileSize, size > maxSize {
                throw TFYOpenPanelError.fileTooLarge(url, limit: maxSize, actual: size)
            }
            if let minSize = configuration.minFileSize, size < minSize {
                throw TFYOpenPanelError.fileTooSmall(url, minimum: minSize, actual: size)
            }
        }

        if let filter = configuration.fileFilter, !filter(url) {
            throw TFYOpenPanelError.validationFailed(reason: "自定义过滤器拒绝: \(url.lastPathComponent)")
        }
    }

    // MARK: - 文件信息工具

    /// 获取文件大小（字节）
    public static func fileSize(at url: URL) -> Int64? {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attrs?[.size] as? NSNumber)?.int64Value
    }

    /// 格式化文件大小
    public static func formattedFileSize(at url: URL) -> String {
        guard let size = fileSize(at: url) else { return "0 字节" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    /// 在 Finder 中显示文件
    public static func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// 在 Finder 中显示一组文件
    public static func revealInFinder(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }

    // MARK: - 私有实现

    /// 创建文件选择面板
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
        panel.resolvesAliases = configuration.resolvesAliases

        // 优先使用配置目录；否则尝试恢复最近目录
        if let dir = configuration.directoryURL {
            panel.directoryURL = dir
        } else if configuration.rememberLastDirectory,
                  let key = configuration.lastDirectoryKey,
                  let last = lastDirectory(forKey: key) {
            panel.directoryURL = last
        }

        if !configuration.allowedContentTypes.isEmpty {
            panel.allowedContentTypes = configuration.allowedContentTypes
        }

        if let accessoryView = configuration.accessoryView {
            panel.accessoryView = accessoryView
            panel.isAccessoryViewDisclosed = configuration.accessoryViewDisclosed
        }

        return panel
    }

    /// 创建文件保存面板
    private static func createSavePanel(configuration: TFYSavePanelConfiguration) -> NSSavePanel {
        let panel = NSSavePanel()
        panel.title = configuration.title
        panel.prompt = configuration.prompt
        panel.message = configuration.message
        panel.canCreateDirectories = configuration.canCreateDirectories
        panel.allowsOtherFileTypes = configuration.allowsOtherFileTypes
        panel.isExtensionHidden = configuration.isExtensionHidden
        panel.showsHiddenFiles = configuration.showsHiddenFiles
        panel.treatsFilePackagesAsDirectories = configuration.treatsFilePackagesAsDirectories
        panel.nameFieldStringValue = configuration.nameFieldStringValue

        if let label = configuration.nameFieldLabel {
            panel.nameFieldLabel = label
        }

        if let dir = configuration.directoryURL {
            panel.directoryURL = dir
        } else if configuration.rememberLastDirectory,
                  let key = configuration.lastDirectoryKey,
                  let last = lastDirectory(forKey: key) {
            panel.directoryURL = last
        }

        if !configuration.allowedContentTypes.isEmpty {
            panel.allowedContentTypes = configuration.allowedContentTypes
        }

        if let accessoryView = configuration.accessoryView {
            panel.accessoryView = accessoryView
        }

        return panel
    }

    /// 寻找当前可用于呈现 sheet 的窗口
    private static func availablePresentingWindow() -> NSWindow? {
        NSApp.mainWindow ?? NSApp.keyWindow ?? NSApp.windows.first { $0.isVisible }
    }

    /// 主线程派发
    private static func dispatchOnMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            DispatchQueue.main.async(execute: work)
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }

    /// 展示打开面板（带 sheet 重入保护）
    private static func presentOpenPanel(configuration: TFYOpenPanelConfiguration,
                                         attempts: Int,
                                         delegate: NSOpenSavePanelDelegate? = nil,
                                         completion: @escaping (TFYFileSelectionResult) -> Void) {
        let work: () -> Void = {
            let presentingWindow = availablePresentingWindow()

            // 若目标窗口仍挂着 sheet，等下一拍再试，避免在 AppKit 卸载旧 sheet 期间
            // 创建新的 NSOpenPanel 触发断言。最多重试 ~1s。
            if let window = presentingWindow,
               window.attachedSheet != nil,
               attempts < 20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    presentOpenPanel(configuration: configuration,
                                     attempts: attempts + 1,
                                     delegate: delegate,
                                     completion: completion)
                }
                return
            }

            let panel = createPanel(configuration: configuration)
            if let delegate = delegate {
                panel.delegate = delegate
            }

            let finish: (NSApplication.ModalResponse) -> Void = { response in
                let wasCancelled = response != .OK
                let urls = wasCancelled ? [] : panel.urls

                // 自动记忆目录
                if !wasCancelled,
                   configuration.rememberLastDirectory,
                   let key = configuration.lastDirectoryKey,
                   let firstURL = urls.first {
                    let dir = firstURL.hasDirectoryPath ? firstURL : firstURL.deletingLastPathComponent()
                    setLastDirectory(dir, forKey: key)
                }

                let result = TFYFileSelectionResult(urls: urls, panel: panel, wasCancelled: wasCancelled)
                completion(result)
            }

            if let presentingWindow = presentingWindow {
                panel.beginSheetModal(for: presentingWindow, completionHandler: finish)
                return
            }

            let response = panel.runModal()
            finish(response)
        }

        dispatchOnMain(work)
    }

    /// 展示保存面板（带 sheet 重入保护）
    private static func presentSavePanel(configuration: TFYSavePanelConfiguration,
                                         attempts: Int,
                                         completion: @escaping (TFYSaveFileResult) -> Void) {
        let work: () -> Void = {
            let presentingWindow = availablePresentingWindow()

            if let window = presentingWindow,
               window.attachedSheet != nil,
               attempts < 20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    presentSavePanel(configuration: configuration,
                                     attempts: attempts + 1,
                                     completion: completion)
                }
                return
            }

            let panel = createSavePanel(configuration: configuration)

            let finish: (NSApplication.ModalResponse) -> Void = { response in
                let wasCancelled = response != .OK
                var url = wasCancelled ? nil : panel.url

                // 自动追加默认扩展名
                if let originalURL = url,
                   let ext = configuration.defaultExtension,
                   !ext.isEmpty,
                   originalURL.pathExtension.isEmpty {
                    url = originalURL.appendingPathExtension(ext)
                }

                // 自动记忆目录
                if let savedURL = url,
                   configuration.rememberLastDirectory,
                   let key = configuration.lastDirectoryKey {
                    setLastDirectory(savedURL.deletingLastPathComponent(), forKey: key)
                }

                completion(TFYSaveFileResult(url: url, panel: panel, wasCancelled: wasCancelled))
            }

            if let presentingWindow = presentingWindow {
                panel.beginSheetModal(for: presentingWindow, completionHandler: finish)
                return
            }

            let response = panel.runModal()
            finish(response)
        }

        dispatchOnMain(work)
    }
}

// MARK: - 代理协议扩展

@available(macOS 10.15, *)
public extension TFYSwiftOpenPanel {

    /// 创建带预览功能的代理
    static func createPreviewDelegate(previewHandler: @escaping (URL) -> NSView?) -> NSOpenSavePanelDelegate {
        return PreviewDelegate(previewHandler: previewHandler)
    }

    /// 创建基于谓词的校验代理
    static func createValidationDelegate(shouldEnable: @escaping (URL) -> Bool,
                                        validate: ((URL) throws -> Void)? = nil) -> NSOpenSavePanelDelegate {
        return ValidationDelegate(shouldEnable: shouldEnable, validate: validate)
    }
}

// MARK: - 预览代理实现

@available(macOS 10.15, *)
private class PreviewDelegate: NSObject, NSOpenSavePanelDelegate {
    private let previewHandler: (URL) -> NSView?

    init(previewHandler: @escaping (URL) -> NSView?) {
        self.previewHandler = previewHandler
        super.init()
    }

    func panel(_ sender: Any, shouldEnable url: URL) -> Bool { true }
    func panel(_ sender: Any, validate url: URL) throws {}
    func panel(_ sender: Any, didChangeToDirectoryURL url: URL?) {}
    func panel(_ sender: Any, willExpand expanding: Bool) {}
}

// MARK: - 校验代理实现

@available(macOS 10.15, *)
private class ValidationDelegate: NSObject, NSOpenSavePanelDelegate {
    private let shouldEnableHandler: (URL) -> Bool
    private let validateHandler: ((URL) throws -> Void)?

    init(shouldEnable: @escaping (URL) -> Bool, validate: ((URL) throws -> Void)?) {
        self.shouldEnableHandler = shouldEnable
        self.validateHandler = validate
        super.init()
    }

    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        shouldEnableHandler(url)
    }

    func panel(_ sender: Any, validate url: URL) throws {
        try validateHandler?(url)
    }
}

// MARK: - 兼容性方法（保持向后兼容）

@available(macOS 10.15, *)
public extension TFYSwiftOpenPanel {

    /// 兼容性方法：打开面板
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
    static func savePanelWithTitleMessage(titleMessage: String,
                                         prompt: String,
                                         title: String,
                                         fileName: String,
                                         canCreateDirectoriesFlag: Bool,
                                         allowsSelectingHiddenExtensionFlag: Bool,
                                         dirURL: URL,
                                         fileTypes: [UTType],
                                         completionHandler: @escaping (_ panel: NSSavePanel, _ url: URL?) -> Void) {
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
    static func savePanelWithAllowedFileTypes(fileTypes: [UTType],
                                             frame: NSRect,
                                             titleMessage: String,
                                             prompt: String,
                                             accessoryImage: NSImage,
                                             completionHandler: @escaping (_ panel: NSSavePanel, _ url: URL?) -> Void) {
        DispatchQueue.main.async {
            var config = TFYSavePanelConfiguration()
            config.title = titleMessage
            config.prompt = prompt
            config.message = titleMessage
            config.allowedContentTypes = fileTypes

            let accessoryView = NSView(frame: frame)
            let accessoryImageView = NSImageView(frame: accessoryView.bounds)
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
}
