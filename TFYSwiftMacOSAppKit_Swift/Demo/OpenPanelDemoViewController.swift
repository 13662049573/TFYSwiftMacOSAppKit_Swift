//
//  OpenPanelDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  TFYSwiftOpenPanel 全功能演示：选择 / 保存 / async / 校验 / 书签 / 兼容 API 等。
//

import Cocoa
import UniformTypeIdentifiers

@available(macOS 10.15, *)
final class OpenPanelDemoViewController: NSViewController {

    private static let lastDirKey = "OpenPanelDemo"

    private var logTextView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI

    private func setupUI() {
        let scrollView = NSScrollView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .hasVerticalScroller(true)
            .hasHorizontalScroller(false)
            .autohidesScrollers(true)
            .build
        view.addSubview(scrollView)

        let document = DemoFlippedDocumentView(frame: .zero).chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scrollView.chain.documentView(document)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            document.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        var y: CGFloat = 16
        let margin: CGFloat = 16
        let contentW = min(920, view.bounds.width > 0 ? view.bounds.width - 32 : 900)

        func addLabel(_ text: String, font: NSFont, color: NSColor = .labelColor, height: CGFloat = 22) {
            let lbl = TFYSwiftLabel().chain
                .text(text)
                .font(font)
                .textColor(color)
                .drawsBackground(false)
                .frame(NSRect(x: margin, y: y, width: contentW, height: height))
                .build
            document.addSubview(lbl)
            y += height + 6
        }

        func addButtons(_ titles: [String], actions: [Selector], perRow: Int = 3) {
            let spacing: CGFloat = 8
            let rowH: CGFloat = 30
            var idx = 0
            while idx < titles.count {
                var x = margin
                for _ in 0..<perRow where idx < titles.count {
                    let title = titles[idx]
                    let w = max(120, CGFloat(title.count) * 8 + 24)
                    let btn = NSButton().chain
                        .frame(NSRect(x: x, y: y, width: min(w, 280), height: rowH))
                        .title(title)
                        .font(.systemFont(ofSize: 11))
                        .bezelStyle(.rounded)
                        .addTarget(self, action: actions[idx])
                        .build
                    document.addSubview(btn)
                    x += btn.frame.width + spacing
                    idx += 1
                }
                y += rowH + spacing
            }
        }

        addLabel("TFYSwiftOpenPanel 全功能演示", font: .boldSystemFont(ofSize: 20), height: 26)
        addLabel(
            "涵盖：基础选择、类型预设、保存与 Result、配置校验与记忆目录、async/await、安全作用域书签、文件信息、Finder  reveal、预览/校验代理、附件视图、旧版兼容 API。日志见下方。",
            font: .systemFont(ofSize: 12),
            color: .secondaryLabelColor,
            height: 44
        )

        // —— 基础选择 ——
        addLabel("1. 基础选择（回调）", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["单选文件", "多选文件", "选择目录", "多选目录"],
            actions: [#selector(demoSelectFile), #selector(demoSelectMultiple), #selector(demoSelectDirectory), #selector(demoSelectDirectories)],
            perRow: 2
        )

        // —— 类型预设 ——
        addLabel("2. 类型预设", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["图片(单)", "图片(多)", "文档(单)", "文档(多)", "音频", "视频", "压缩包", "源代码", "电子表格", "演示文稿"],
            actions: [
                #selector(demoImagesSingle), #selector(demoImagesMulti),
                #selector(demoDocsSingle), #selector(demoDocsMulti),
                #selector(demoAudio), #selector(demoVideo),
                #selector(demoArchive), #selector(demoCode),
                #selector(demoSpreadsheet), #selector(demoPresentation),
            ],
            perRow: 2
        )

        // —— Result / 校验 / 记忆目录 ——
        addLabel("3. Result · 校验 · 记忆目录", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["selectFilesWithResult", "限制最多 2 个", "限制文件大小", "自定义 fileFilter", "记忆目录(读)", "记忆目录(写)"],
            actions: [
                #selector(demoSelectWithResult), #selector(demoMaxCount),
                #selector(demoMaxFileSize), #selector(demoFileFilter),
                #selector(demoRememberOpen), #selector(demoRememberSave),
            ],
            perRow: 2
        )

        // —— 保存 ——
        addLabel("4. 保存面板", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["saveFile 简化", "saveFileWithResult", "nameFieldLabel +扩展名", "链式：选完再存"],
            actions: [#selector(demoSaveSimple), #selector(demoSaveResult), #selector(demoSaveNameExt), #selector(demoChainedOpenThenSave)],
            perRow: 2
        )

        // —— async ——
        addLabel("5. async / await · saveText / saveData", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["async 选文件", "async 保存 URL", "saveText 演示", "selectFilesThrowing"],
            actions: [#selector(demoAsyncSelect), #selector(demoAsyncSave), #selector(demoSaveText), #selector(demoSelectThrowing)],
            perRow: 2
        )

        // —— 书签与最近目录 API ——
        addLabel("6. 安全作用域书签 · lastDirectory", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["目录 + 书签", "解析演示书签", "withSecurityScopedAccess", "清空 lastDirectory 缓存"],
            actions: [#selector(demoDirBookmark), #selector(demoResolveBookmark), #selector(demoScopedAccess), #selector(demoClearLastDirs)],
            perRow: 2
        )

        // —— 工具 ——
        addLabel("7. 校验 · 大小 · Finder", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["validateSelection说明", "选文件显示大小", "在 Finder 中显示"],
            actions: [#selector(demoValidateExplain), #selector(demoFileSizeInfo), #selector(demoReveal)],
            perRow: 3
        )

        // —— 代理与附件 ——
        addLabel("8. 代理 · 附件视图", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["预览代理", "校验代理(仅 .swift)", "打开面板 + 附件"],
            actions: [#selector(demoPreviewDelegate), #selector(demoValidationDelegate), #selector(demoAccessoryOpen)],
            perRow: 3
        )

        // —— 兼容 API ——
        addLabel("9. 兼容 API（openPanelWithTitleMessage 等）", font: .systemFont(ofSize: 15, weight: .semibold))
        addButtons(
            ["openPanelWithTitleMessage", "savePanelWithTitleMessage", "savePanel + 图片附件"],
            actions: [#selector(demoLegacyOpen), #selector(demoLegacySave), #selector(demoLegacySaveAccessory)],
            perRow: 2
        )

        // —— 日志 ——
        addLabel("操作日志", font: .systemFont(ofSize: 14, weight: .semibold))
        let logScroll = NSScrollView().chain
            .frame(NSRect(x: margin, y: y, width: contentW, height: 200))
            .borderType(.bezelBorder)
            .hasVerticalScroller(true)
            .autohidesScrollers(true)
            .build
        document.addSubview(logScroll)
        logTextView = NSTextView().chain
            .frame(NSRect(x: 0, y: 0, width: contentW - 20, height: 200))
            .editable(false)
            .selectable(true)
            .font(.monospacedSystemFont(ofSize: 11, weight: .regular))
            .string("点击上方按钮触发对应 API…\n")
            .build
        logScroll.chain.documentView(logTextView)
        y += 216

        let clearBtn = NSButton().chain
            .frame(NSRect(x: margin, y: y, width: 100, height: 28))
            .title("清空日志")
            .bezelStyle(.rounded)
            .addTarget(self, action: #selector(clearLog))
            .build
        document.addSubview(clearBtn)
        y += 40

        NSLayoutConstraint.activate([
            document.heightAnchor.constraint(equalToConstant: y + 24),
        ])
    }

    private func appendLog(_ text: String) {
        logTextView.string += text + "\n"
        logTextView.scrollToEndOfDocument(nil)
    }

    @objc private func clearLog() {
        logTextView.string = ""
        appendLog("日志已清空")
    }

    // MARK: - 1基础

    @objc private func demoSelectFile() {
        TFYSwiftOpenPanel.selectFile(title: "单选文件", message: "请选择任意文件") { [weak self] url in
            if let url = url { self?.appendLog("单选: \(url.path)") }
            else { self?.appendLog("单选: 取消") }
        }
    }

    @objc private func demoSelectMultiple() {
        TFYSwiftOpenPanel.selectMultipleFiles(title: "多选文件", message: "可多选") { [weak self] urls in
            self?.appendLog("多选: \(urls.count) 个 — \(urls.map(\.lastPathComponent).joined(separator: ", "))")
        }
    }

    @objc private func demoSelectDirectory() {
        TFYSwiftOpenPanel.selectDirectory(title: "目录", message: "选一个文件夹") { [weak self] url in
            self?.appendLog("目录: \(url?.path ?? "取消")")
        }
    }

    @objc private func demoSelectDirectories() {
        TFYSwiftOpenPanel.selectDirectories(title: "多目录", message: "可多选文件夹") { [weak self] urls in
            self?.appendLog("多目录: \(urls.count) — \(urls.map(\.lastPathComponent).joined(separator: ", "))")
        }
    }

    // MARK: - 2 预设

    @objc private func demoImagesSingle() {
        TFYSwiftOpenPanel.selectImages(allowsMultiple: false) { [weak self] in self?.appendLog("图片: \($0.map(\.path))") }
    }
    @objc private func demoImagesMulti() {
        TFYSwiftOpenPanel.selectImages(allowsMultiple: true) { [weak self] in self?.appendLog("图片(多): \($0.count) 个") }
    }
    @objc private func demoDocsSingle() {
        TFYSwiftOpenPanel.selectDocuments(allowsMultiple: false) { [weak self] in self?.appendLog("文档: \($0.first?.path ?? "无")") }
    }
    @objc private func demoDocsMulti() {
        TFYSwiftOpenPanel.selectDocuments(allowsMultiple: true) { [weak self] in self?.appendLog("文档(多): \($0.count)") }
    }
    @objc private func demoAudio() {
        TFYSwiftOpenPanel.selectAudioFiles(allowsMultiple: false) { [weak self] in self?.appendLog("音频: \($0.map(\.lastPathComponent))") }
    }
    @objc private func demoVideo() {
        TFYSwiftOpenPanel.selectVideoFiles(allowsMultiple: false) { [weak self] in self?.appendLog("视频: \($0.map(\.lastPathComponent))") }
    }
    @objc private func demoArchive() {
        TFYSwiftOpenPanel.selectArchives(allowsMultiple: false) { [weak self] in self?.appendLog("压缩包: \($0.map(\.lastPathComponent))") }
    }
    @objc private func demoCode() {
        TFYSwiftOpenPanel.selectCodeFiles(allowsMultiple: true) { [weak self] in self?.appendLog("源码: \($0.count) 个") }
    }
    @objc private func demoSpreadsheet() {
        TFYSwiftOpenPanel.selectSpreadsheets(allowsMultiple: false) { [weak self] in self?.appendLog("表格: \($0.map(\.lastPathComponent))") }
    }
    @objc private func demoPresentation() {
        TFYSwiftOpenPanel.selectFile(title: "演示文稿", message: "选择 .key / .pptx 等", fileTypes: TFYSwiftOpenPanel.presentationTypes) { [weak self] url in
            self?.appendLog("演示文稿: \(url?.path ?? "取消")")
        }
    }

    // MARK: - 3 Result / 校验 / 记忆

    @objc private func demoSelectWithResult() {
        var cfg = TFYOpenPanelConfiguration()
        cfg.title = "WithResult"
        cfg.message = "取消会返回 .userCancelled"
        TFYSwiftOpenPanel.selectFilesWithResult(configuration: cfg) { [weak self] result in
            switch result {
            case .success(let urls):
                self?.appendLog("WithResult 成功: \(urls.count) 个")
            case .failure(let err):
                self?.appendLog("WithResult 失败: \(err.localizedDescription)")
            }
        }
    }

    @objc private func demoMaxCount() {
        var cfg = TFYOpenPanelConfiguration()
        cfg.title = "最多 2 个"
        cfg.allowsMultipleSelection = true
        cfg.maxSelectionCount = 2
        TFYSwiftOpenPanel.selectFilesWithResult(configuration: cfg) { [weak self] result in
            self?.appendLog("maxCount: \(String(describing: result))")
        }
    }

    @objc private func demoMaxFileSize() {
        var cfg = TFYOpenPanelConfiguration()
        cfg.title = "文件大小 ≤ 512KB"
        cfg.maxFileSize = 512 * 1024
        TFYSwiftOpenPanel.selectFilesWithResult(configuration: cfg) { [weak self] result in
            switch result {
            case .success(let urls):
                self?.appendLog("大小校验通过: \(urls.map(\.lastPathComponent))")
            case .failure(let e):
                self?.appendLog("大小/校验: \(e.localizedDescription)")
            }
        }
    }

    @objc private func demoFileFilter() {
        var cfg = TFYOpenPanelConfiguration()
        cfg.title = "仅文件名含 Demo"
        cfg.fileFilter = { $0.lastPathComponent.localizedCaseInsensitiveContains("demo") }
        TFYSwiftOpenPanel.selectFilesWithResult(configuration: cfg) { [weak self] result in
            self?.appendLog("fileFilter: \(String(describing: result))")
        }
    }

    @objc private func demoRememberOpen() {
        var cfg = TFYOpenPanelConfiguration()
        cfg.title = "记忆目录 · 打开"
        cfg.message = "再次打开应回到上次位置"
        cfg.rememberLastDirectory = true
        cfg.lastDirectoryKey = Self.lastDirKey
        TFYSwiftOpenPanel.selectFiles(configuration: cfg) { [weak self] result in
            self?.appendLog("记忆打开: 取消=\(result.wasCancelled) 数量=\(result.urls.count)")
        }
    }

    @objc private func demoRememberSave() {
        var cfg = TFYSavePanelConfiguration()
        cfg.title = "记忆目录 · 保存"
        cfg.nameFieldStringValue = "remember_\(Int(Date().timeIntervalSince1970)).txt"
        cfg.rememberLastDirectory = true
        cfg.lastDirectoryKey = Self.lastDirKey + ".save"
        TFYSwiftOpenPanel.saveFile(configuration: cfg) { [weak self] result in
            self?.appendLog("记忆保存: \(result.url?.path ?? "取消")")
        }
    }

    // MARK: - 4 保存

    @objc private func demoSaveSimple() {
        TFYSwiftOpenPanel.saveFile(title: "保存", message: "选路径", fileName: "demo_save.txt") { [weak self] result in
            guard let url = result.url, !result.wasCancelled else {
                self?.appendLog("保存: 取消")
                return
            }
            if let data = "Hello TFYSwiftOpenPanel".data(using: .utf8) {
                try? data.write(to: url)
            }
            self?.appendLog("已写入: \(url.path)")
        }
    }

    @objc private func demoSaveResult() {
        var cfg = TFYSavePanelConfiguration()
        cfg.title = "saveFileWithResult"
        cfg.nameFieldStringValue = "result.txt"
        TFYSwiftOpenPanel.saveFileWithResult(configuration: cfg) { [weak self] result in
            switch result {
            case .success(let url):
                self?.appendLog("Result 保存路径: \(url.path)")
            case .failure(let e):
                self?.appendLog("Result: \(e.localizedDescription)")
            }
        }
    }

    @objc private func demoSaveNameExt() {
        var cfg = TFYSavePanelConfiguration()
        cfg.title = "文件名标签 + 默认扩展"
        cfg.nameFieldLabel = "导出文件名"
        cfg.nameFieldStringValue = "export"
        cfg.defaultExtension = "md"
        TFYSwiftOpenPanel.saveFile(configuration: cfg) { [weak self] result in
            self?.appendLog("带扩展保存 URL: \(result.url?.path ?? "取消")")
        }
    }

    @objc private func demoChainedOpenThenSave() {
        TFYSwiftOpenPanel.selectFile(title: "先选参考文件", message: "随后将弹出保存") { [weak self] picked in
            self?.appendLog("链式-已选: \(picked?.lastPathComponent ?? "无")")
            TFYSwiftOpenPanel.saveFile(title: "链式保存", message: "保存副本", fileName: "chain_copy.txt") { r in
                self?.appendLog("链式-保存: \(r.url?.path ?? "取消")")
            }
        }
    }

    // MARK: - 5 async

    @objc private func demoAsyncSelect() {
        Task { @MainActor [weak self] in
            let url = await TFYSwiftOpenPanel.selectFile(title: "async 单选", message: "async/await")
            self?.appendLog("async 选文件: \(url?.path ?? "nil")")
        }
    }

    @objc private func demoAsyncSave() {
        Task { @MainActor [weak self] in
            let url = await TFYSwiftOpenPanel.saveFile(title: "async 保存", fileName: "async.txt")
            self?.appendLog("async 保存 URL: \(url?.path ?? "nil")")
        }
    }

    @objc private func demoSaveText() {
        Task { @MainActor [weak self] in
            var cfg = TFYSavePanelConfiguration()
            cfg.title = "saveText"
            cfg.nameFieldStringValue = "notes.txt"
            do {
                let url = try await TFYSwiftOpenPanel.saveText("TFYSwiftOpenPanel.saveText\n\(Date())", configuration: cfg)
                self?.appendLog("saveText 成功: \(url.path)")
            } catch {
                self?.appendLog("saveText 错误: \(error.localizedDescription)")
            }
        }
    }

    @objc private func demoSelectThrowing() {
        Task { @MainActor [weak self] in
            var cfg = TFYOpenPanelConfiguration()
            cfg.title = "Throwing"
            cfg.allowsMultipleSelection = true
            cfg.maxSelectionCount = 3
            do {
                let urls = try await TFYSwiftOpenPanel.selectFilesThrowing(configuration: cfg)
                self?.appendLog("throwing: \(urls.count) 个")
            } catch {
                self?.appendLog("throwing: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 6 书签

    private var lastBookmarkData: Data?

    @objc private func demoDirBookmark() {
        TFYSwiftOpenPanel.selectDirectoryWithBookmark(title: "目录 + 安全书签") { [weak self] result in
            switch result {
            case .success(let pair):
                self?.lastBookmarkData = pair.bookmark
                self?.appendLog("书签长度: \(pair.bookmark.count) bytes, path: \(pair.url.path)")
            case .failure(let e):
                self?.appendLog("书签失败: \(e.localizedDescription)")
            }
        }
    }

    @objc private func demoResolveBookmark() {
        guard let data = lastBookmarkData else {
            appendLog("请先用「目录 + 书签」生成书签")
            return
        }
        do {
            let resolved = try TFYSwiftOpenPanel.resolveSecurityScopedBookmark(data)
            appendLog("解析 URL: \(resolved.url.path), stale=\(resolved.isStale)")
        } catch {
            appendLog("解析失败: \(error.localizedDescription)")
        }
    }

    @objc private func demoScopedAccess() {
        TFYSwiftOpenPanel.selectFile(title: "选文件以尝试作用域访问", message: "沙盒外可能仅用户所选路径可读") { [weak self] url in
            guard let url = url else {
                self?.appendLog("作用域: 取消")
                return
            }
            do {
                let size = try TFYSwiftOpenPanel.withSecurityScopedAccess(to: url) { u -> Int64 in
                    TFYSwiftOpenPanel.fileSize(at: u) ?? -1
                }
                self?.appendLog("作用域内读取大小: \(size)")
            } catch {
                self?.appendLog("作用域访问: \(error.localizedDescription)")
            }
        }
    }

    @objc private func demoClearLastDirs() {
        TFYSwiftOpenPanel.clearAllLastDirectories()
        appendLog("已 clearAllLastDirectories()")
    }

    // MARK: - 7 工具

    @objc private func demoValidateExplain() {
        appendLog("validateSelection(urls, against:) 由 selectFilesWithResult 内部调用；可结合 maxFileSize / maxSelectionCount / fileFilter 使用。")
    }

    @objc private func demoFileSizeInfo() {
        TFYSwiftOpenPanel.selectFile(title: "查看大小", message: "选一个文件") { [weak self] url in
            guard let url = url else { return }
            let raw = TFYSwiftOpenPanel.fileSize(at: url)
            let fmt = TFYSwiftOpenPanel.formattedFileSize(at: url)
            self?.appendLog("大小: \(raw ?? -1) 字节, 格式化: \(fmt)")
        }
    }

    @objc private func demoReveal() {
        TFYSwiftOpenPanel.selectFile(title: "在 Finder 显示", message: "选文件") { [weak self] url in
            guard let url = url else { return }
            TFYSwiftOpenPanel.revealInFinder(url)
            self?.appendLog("已 revealInFinder")
        }
    }

    // MARK: - 8 代理

    @objc private func demoPreviewDelegate() {
        let delegate = TFYSwiftOpenPanel.createPreviewDelegate { url in
            let iv = NSImageView(frame: NSRect(x: 0, y: 0, width: 120, height: 120))
            iv.imageScaling = .scaleProportionallyUpOrDown
            if let img = NSImage(contentsOf: url) {
                iv.image = img
            } else {
                iv.image = NSImage(systemSymbolName: "doc", accessibilityDescription: nil)
            }
            return iv
        }
        TFYSwiftOpenPanel.selectFileWithDelegate(title: "预览代理", message: "选图片可预览", fileTypes: TFYSwiftOpenPanel.imageTypes, delegate: delegate) { [weak self] result in
            self?.appendLog("预览代理: 取消=\(result.wasCancelled) urls=\(result.urls.count)")
        }
    }

    @objc private func demoValidationDelegate() {
        let delegate = TFYSwiftOpenPanel.createValidationDelegate(shouldEnable: { url in
            url.pathExtension.lowercased() == "swift"
        }, validate: { url in
            if url.pathExtension.lowercased() != "swift" {
                throw TFYOpenPanelError.validationFailed(reason: "需要 .swift")
            }
        })
        TFYSwiftOpenPanel.selectFileWithDelegate(title: "仅 Swift", message: "非 .swift 不可选", fileTypes: [.swiftSource], delegate: delegate) { [weak self] result in
            self?.appendLog("校验代理: \(result.urls.first?.lastPathComponent ?? "取消")")
        }
    }

    @objc private func demoAccessoryOpen() {
        let accessory = TFYSwiftLabel().chain
            .text("这是附件视图示例")
            .font(.systemFont(ofSize: 12))
            .alignment(.center)
            .drawsBackground(false)
            .frame(NSRect(x: 0, y: 0, width: 240, height: 40))
            .build
        TFYSwiftOpenPanel.selectFileWithAccessoryView(title: "带附件", message: "见面板底部", fileTypes: [], accessoryView: accessory) { [weak self] result in
            self?.appendLog("附件打开: \(result.urls.first?.path ?? "取消")")
        }
    }

    // MARK: - 9 兼容

    @objc private func demoLegacyOpen() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        TFYSwiftOpenPanel.openPanelWithTitleMessage(
            titleMessage: "兼容 openPanel",
            setPrompt: "选",
            canChooseFilesFlag: true,
            allowsMultipleSelectionFlag: false,
            canChooseDirectoriesFlag: false,
            canCreateDirectoriesFlag: true,
            dirURL: home,
            fileTypes: [.plainText]
        ) { [weak self] panel, urls in
            self?.appendLog("legacy open: panel.title=\(panel.title ?? "") urls=\(urls.count)")
        }
    }

    @objc private func demoLegacySave() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        TFYSwiftOpenPanel.savePanelWithTitleMessage(
            titleMessage: "兼容 savePanel",
            prompt: "保存",
            title: "旧 API保存",
            fileName: "legacy.txt",
            canCreateDirectoriesFlag: true,
            allowsSelectingHiddenExtensionFlag: true,
            dirURL: home,
            fileTypes: [.plainText]
        ) { [weak self] _, url in
            self?.appendLog("legacy save: \(url?.path ?? "取消")")
        }
    }

    @objc private func demoLegacySaveAccessory() {
        let img = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil) ?? NSImage()
        TFYSwiftOpenPanel.savePanelWithAllowedFileTypes(
            fileTypes: [.png],
            frame: NSRect(x: 0, y: 0, width: 100, height: 80),
            titleMessage: "带图附件保存",
            prompt: "保存 PNG",
            accessoryImage: img
        ) { [weak self] _, url in
            self?.appendLog("legacy 附件保存: \(url?.path ?? "取消")")
        }
    }
}
