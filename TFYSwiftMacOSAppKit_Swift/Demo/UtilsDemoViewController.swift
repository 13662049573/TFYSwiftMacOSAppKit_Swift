//
//  UtilsDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

final class UtilsDemoViewController: NSViewController {
    
    private var resultTextView: NSTextView!
    private var previewImageView: NSImageView!
    private var previewInfoLabel: TFYSwiftLabel!
    private var cacheManager: TFYSwiftCacheKit?
    private var compressionSwitch: NSButton!
    private var encryptionSwitch: NSButton!
    private var activeTimer: TFYSwiftTimer?
    private var countDownTimer: TFYSwiftCountDownTimer?
    private var onceExecutionCount = 0
    private lazy var logDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    deinit {
        activeTimer?.cancel()
        countDownTimer?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUtilsDemo()
        setupCacheManager()
    }
    
    private func setupUtilsDemo() {
        // flipped：本页标题、按钮区、结果区均按「y 向下递增」摆放，默认 NSView 为 y 向上会导致标题沉底、按钮行序颠倒。
        let containerView = DemoFlippedDocumentView(frame: .zero).chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        view.addSubview(containerView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 创建标题
        let titleLabel = TFYSwiftLabel().chain
            .text("工具类功能演示")
            .font(.boldSystemFont(ofSize: 20))
            .textColor(.labelColor)
            .drawsBackground(false)
            .frame(NSRect(x: 20, y: 20, width: 300, height: 30))
            .build
        containerView.addSubview(titleLabel)
        
        let subtitleLabel = TFYSwiftLabel().chain
            .text("这一页集中验证网络、缓存、JSON、定时器、GCD、文件面板、加密与图片拼接能力；右侧会展示最近一次可视化结果。")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .drawsBackground(false)
            .frame(NSRect(x: 20, y: 52, width: 900, height: 18))
            .build
        containerView.addSubview(subtitleLabel)
        
        // 创建按钮区域
        createButtonArea(in: containerView)
        
        // 创建结果显示区域
        createResultArea(in: containerView)
    }
    
    private func createButtonArea(in containerView: NSView) {
        let buttonArea = DemoFlippedDocumentView(frame: .zero).chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        containerView.addSubview(buttonArea)
        
        // 网络工具按钮
        let networkButton = NSButton().chain
            .frame(NSRect(x: 0, y: 0, width: 120, height: 30))
            .title("网络信息")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(getNetworkInfo))
            .build
        buttonArea.addSubview(networkButton)
        
        // 缓存测试按钮
        let cacheButton = NSButton().chain
            .frame(NSRect(x: 130, y: 0, width: 120, height: 30))
            .title("缓存测试")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testCache))
            .build
        buttonArea.addSubview(cacheButton)
        
        // JSON工具按钮
        let jsonButton = NSButton().chain
            .frame(NSRect(x: 260, y: 0, width: 120, height: 30))
            .title("JSON工具")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testJsonUtils))
            .build
        buttonArea.addSubview(jsonButton)
        
        // 定时器按钮
        let timerButton = NSButton().chain
            .frame(NSRect(x: 390, y: 0, width: 120, height: 30))
            .title("定时器")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testTimer))
            .build
        buttonArea.addSubview(timerButton)
        
        // GCD工具按钮
        let gcdButton = NSButton().chain
            .frame(NSRect(x: 520, y: 0, width: 120, height: 30))
            .title("GCD工具")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testGCD))
            .build
        buttonArea.addSubview(gcdButton)
        
        // 文件操作按钮
        let fileButton = NSButton().chain
            .frame(NSRect(x: 0, y: 40, width: 120, height: 30))
            .title("文件操作")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testFileOperations))
            .build
        buttonArea.addSubview(fileButton)
        
        // 打开/保存文件（TFYSwiftOpenPanel）
        let openPanelButton = NSButton().chain
            .frame(NSRect(x: 130, y: 40, width: 120, height: 30))
            .title("打开/保存文件")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testOpenPanel))
            .build
        buttonArea.addSubview(openPanelButton)
        
        // 加密工具按钮
        let cryptoButton = NSButton().chain
            .frame(NSRect(x: 260, y: 40, width: 120, height: 30))
            .title("加密工具")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testCrypto))
            .build
        buttonArea.addSubview(cryptoButton)
        
        let clearButton = NSButton().chain
            .frame(NSRect(x: 390, y: 40, width: 120, height: 30))
            .title("清空日志")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(clearResults))
            .build
        buttonArea.addSubview(clearButton)
        
        let debounceButton = NSButton().chain
            .frame(NSRect(x: 520, y: 40, width: 120, height: 30))
            .title("防抖/节流")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testDebounceAndThrottle))
            .build
        buttonArea.addSubview(debounceButton)
        
        let jsonFileButton = NSButton().chain
            .frame(NSRect(x: 0, y: 80, width: 120, height: 30))
            .title("JSON文件")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testJsonFileIO))
            .build
        buttonArea.addSubview(jsonFileButton)
        
        let countDownButton = NSButton().chain
            .frame(NSRect(x: 130, y: 80, width: 120, height: 30))
            .title("倒计时")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testCountDownTimer))
            .build
        buttonArea.addSubview(countDownButton)
        
        let stitchButton = NSButton().chain
            .frame(NSRect(x: 260, y: 80, width: 120, height: 30))
            .title("图片拼接")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testImageStitching))
            .build
        buttonArea.addSubview(stitchButton)
        
        let clearCacheButton = NSButton().chain
            .frame(NSRect(x: 390, y: 80, width: 120, height: 30))
            .title("清理缓存")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(clearCaches))
            .build
        buttonArea.addSubview(clearCacheButton)
        
        let expiredCacheButton = NSButton().chain
            .frame(NSRect(x: 520, y: 80, width: 120, height: 30))
            .title("清理过期缓存")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(cleanExpiredCaches))
            .build
        buttonArea.addSubview(expiredCacheButton)

        let asyncButton = NSButton().chain
            .frame(NSRect(x: 0, y: 120, width: 120, height: 30))
            .title("异步任务")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testAsyncUtilities))
            .build
        buttonArea.addSubview(asyncButton)

        let onceButton = NSButton().chain
            .frame(NSRect(x: 130, y: 120, width: 120, height: 30))
            .title("Once 执行")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testDispatchOnce))
            .build
        buttonArea.addSubview(onceButton)

        let helperLabel = TFYSwiftLabel().chain
            .text("新增演示：TFYSwiftAsync 后台任务/延迟回调/可取消任务，以及 DispatchQueue.once 只执行一次能力。")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .wraps(true)
            .maximumNumberOfLines(0)
            .drawsBackground(false)
            .frame(NSRect(x: 270, y: 122, width: 560, height: 28))
            .build
        buttonArea.addSubview(helperLabel)

        // 第四行按钮
        let aesGCMButton = NSButton().chain
            .frame(NSRect(x: 0, y: 160, width: 120, height: 30))
            .title("AES-GCM加密")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testAESGCM))
            .build
        buttonArea.addSubview(aesGCMButton)

        let versionButton = NSButton().chain
            .frame(NSRect(x: 130, y: 160, width: 120, height: 30))
            .title("版本比较")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testVersionCompare))
            .build
        buttonArea.addSubview(versionButton)

        let ipButton = NSButton().chain
            .frame(NSRect(x: 260, y: 160, width: 120, height: 30))
            .title("IP验证")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testIPValidation))
            .build
        buttonArea.addSubview(ipButton)

        let arrayButton = NSButton().chain
            .frame(NSRect(x: 390, y: 160, width: 120, height: 30))
            .title("数组扩展")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testArrayExtensions))
            .build
        buttonArea.addSubview(arrayButton)

        let stringExtButton = NSButton().chain
            .frame(NSRect(x: 520, y: 160, width: 120, height: 30))
            .title("字符串扩展")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testStringExtensions))
            .build
        buttonArea.addSubview(stringExtButton)

        compressionSwitch = NSButton().chain
            .frame(NSRect(x: 660, y: 163, width: 130, height: 24))
            .setButtonType(.switch)
            .title("压缩缓存")
            .state(.on)
            .font(.systemFont(ofSize: 12))
            .build
        buttonArea.addSubview(compressionSwitch)

        encryptionSwitch = NSButton().chain
            .frame(NSRect(x: 800, y: 163, width: 130, height: 24))
            .setButtonType(.switch)
            .title("加密缓存")
            .state(.off)
            .font(.systemFont(ofSize: 12))
            .build
        buttonArea.addSubview(encryptionSwitch)

        // 设置约束
        NSLayoutConstraint.activate([
            buttonArea.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 86),
            buttonArea.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonArea.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonArea.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func createResultArea(in containerView: NSView) {
        let resultArea = DemoFlippedDocumentView(frame: .zero).chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        containerView.addSubview(resultArea)
        
        // 结果标题
        let resultTitleLabel = TFYSwiftLabel().chain
            .text("运行日志")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .drawsBackground(false)
            .frame(NSRect(x: 0, y: 0, width: 100, height: 20))
            .build
        resultArea.addSubview(resultTitleLabel)
        
        let previewTitleLabel = TFYSwiftLabel().chain
            .text("实时预览")
            .font(.systemFont(ofSize: 16, weight: .medium))
            .textColor(.labelColor)
            .drawsBackground(false)
            .frame(NSRect(x: 790, y: 0, width: 120, height: 20))
            .build
        resultArea.addSubview(previewTitleLabel)
        
        let resultScrollView = NSScrollView().chain
            .frame(NSRect(x: 0, y: 30, width: 760, height: 360))
            .borderType(.bezelBorder)
            .hasVerticalScroller(true)
            .autohidesScrollers(true)
            .build
        resultArea.addSubview(resultScrollView)
        
        resultTextView = NSTextView().chain
            .frame(NSRect(x: 0, y: 0, width: 760, height: 360))
            .editable(false)
            .selectable(true)
            .backgroundColor(.textBackgroundColor)
            .textColor(.textColor)
            .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .string("工具类测试结果将显示在这里...\n")
            .build
        resultScrollView.chain.documentView(resultTextView)
        
        let previewContainer = DemoFlippedDocumentView(frame: .zero).chain
            .frame(NSRect(x: 790, y: 30, width: 360, height: 360))
            .wantsLayer(true)
            .backgroundColor(.windowBackgroundColor)
            .cornerRadius(16)
            .borderWidth(1)
            .borderColor(.separatorColor)
            .build
        resultArea.addSubview(previewContainer)
        
        previewImageView = NSImageView().chain
            .frame(NSRect(x: 18, y: 92, width: 324, height: 240))
            .imageScaling(.scaleProportionallyUpOrDown)
            .wantsLayer(true)
            .backgroundColor(.textBackgroundColor)
            .cornerRadius(12)
            .build
        previewContainer.addSubview(previewImageView)
        
        previewInfoLabel = TFYSwiftLabel().chain
            .text("最近一次可视结果会显示在这里。\n优先展示图片缓存、拼接结果和最近保存的图片产物。")
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .drawsBackground(false)
            .frame(NSRect(x: 18, y: 18, width: 324, height: 58))
            .build
        previewContainer.addSubview(previewInfoLabel)
        updatePreview(
            image: NSImage(systemSymbolName: "wrench.and.screwdriver.fill", accessibilityDescription: nil)?
                .tintedImage(withColor: .systemBlue),
            title: "工具页已就绪",
            details: "点击左侧按钮运行工具能力，右侧会跟随更新可视化结果。"
        )
        
        // 设置约束
        NSLayoutConstraint.activate([
            resultArea.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 310),
            resultArea.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            resultArea.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            resultArea.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupCacheManager() {
        cacheManager = TFYSwiftCacheKit.shared
    }
    
    private func appendResult(_ text: String) {
        DispatchQueue.main.async {
            let timestamp = self.logDateFormatter.string(from: Date())
            let currentText = self.resultTextView.string
            self.resultTextView.string = currentText + "[\(timestamp)] " + text + "\n"
            self.resultTextView.scrollToEndOfDocument(nil)
        }
    }
    
    private func updatePreview(image: NSImage?, title: String, details: String) {
        DispatchQueue.main.async {
            self.previewImageView.image = image
            self.previewInfoLabel.stringValue = "\(title)\n\(details)"
        }
    }
    
    private func makeDemoImages() -> [NSImage] {
        let symbols: [(String, NSColor)] = [
            ("swift", .systemOrange),
            ("shippingbox.fill", .systemBlue),
            ("externaldrive.fill", .systemGreen),
            ("clock.arrow.circlepath", .systemPink),
            ("sparkles", .systemPurple),
            ("checkmark.seal.fill", .systemTeal)
        ]
        
        return symbols.map { symbolName, color in
            let baseImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) ?? NSImage.image(withColor: color)
            return baseImage
                .resized(to: NSSize(width: 84, height: 84))
                .tintedImage(withColor: color)
                .roundedImage(cornerRadius: 20)
        }
    }
    
    // MARK: - Action Methods
    @objc private func getNetworkInfo() {
        appendResult("=== 网络信息测试 ===")
        
        TFYSwiftUtils.getWiFiInfo { networkInfo in
            let result = """
            网络信息:
            WiFi名称: \(networkInfo.name ?? "未知")
            IP地址: \(networkInfo.ip ?? "未知")
            MAC地址: \(networkInfo.macAddress ?? "未知")
            """
            self.appendResult(result)
        }
        
        // 测试IP地址获取
        let ipAddress = TFYSwiftUtils.getIPAddress(preferIPv4: true)
        appendResult("当前IP地址: \(ipAddress)")
        
        // 测试WiFi名称获取
        if let wifiName = TFYSwiftUtils.getWiFiName() {
            appendResult("WiFi名称: \(wifiName)")
        } else {
            appendResult("无法获取WiFi名称")
        }
    }
    
    @objc private func testCache() {
        appendResult("=== 缓存测试 ===")
        
        guard let cacheManager = cacheManager else {
            appendResult("缓存管理器未初始化")
            return
        }

        let compressionOn = compressionSwitch?.state == .on
        let encryptionOn = encryptionSwitch?.state == .on
        var newConfig = cacheManager.getCurrentConfig()
        newConfig.enableCompression = compressionOn
        newConfig.enableEncryption = encryptionOn
        cacheManager.updateConfig(newConfig)
        appendResult("缓存配置：压缩=\(compressionOn ? "开" : "关")，加密=\(encryptionOn ? "开" : "关")")
        
        // 测试字符串缓存
        let testString = "测试字符串数据"
        cacheManager.setCache(testString, forKey: "test_string") { result in
            switch result {
            case .success:
                self.appendResult("字符串缓存设置成功")
                
                // 读取缓存
                cacheManager.getCache(String.self, forKey: "test_string") { getResult in
                    switch getResult {
                    case .success(let cachedString):
                        self.appendResult("字符串缓存读取成功: \(cachedString)")
                    case .failure(let error):
                        self.appendResult("字符串缓存读取失败: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.appendResult("字符串缓存设置失败: \(error.localizedDescription)")
            }
        }
        
        // 测试自定义对象缓存
        struct TestUser: Codable {
            let id: Int
            let name: String
            let email: String
        }
        
        let testUser = TestUser(id: 1, name: "张三", email: "zhangsan@example.com")
        cacheManager.setCache(testUser, forKey: "test_user") { result in
            switch result {
            case .success:
                self.appendResult("用户对象缓存设置成功")
                
                // 读取缓存
                cacheManager.getCache(TestUser.self, forKey: "test_user") { getResult in
                    switch getResult {
                    case .success(let cachedUser):
                        self.appendResult("用户对象缓存读取成功: \(cachedUser.name)")
                    case .failure(let error):
                        self.appendResult("用户对象缓存读取失败: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.appendResult("用户对象缓存设置失败: \(error.localizedDescription)")
            }
        }
        
        // 测试图片缓存
        if let testImage = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil) {
            cacheManager.cacheImage(testImage, forKey: "test_image") { result in
                switch result {
                case .success:
                    self.appendResult("图片缓存设置成功")
                    
                    // 读取缓存
                    cacheManager.getCachedImage(forKey: "test_image") { getResult in
                        switch getResult {
                        case .success(let cachedImage):
                            self.appendResult("图片缓存读取成功，尺寸: \(cachedImage.size)")
                            self.updatePreview(
                                image: cachedImage,
                                title: "缓存图片读取成功",
                                details: "TFYSwiftCacheKit 已完成图片缓存回读，尺寸 \(Int(cachedImage.size.width)) x \(Int(cachedImage.size.height))。"
                            )
                        case .failure(let error):
                            self.appendResult("图片缓存读取失败: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    self.appendResult("图片缓存设置失败: \(error.localizedDescription)")
                }
            }
        }
        
        // 获取缓存统计
        let stats = cacheManager.statistics
        appendResult("缓存统计: 命中率 \(String(format: "%.2f%%", stats.hitRate * 100))")
        appendResult("总请求数: \(stats.totalRequests), 命中数: \(stats.totalHits)")
        
        // 获取缓存大小
        cacheManager.getCacheSize { result in
            switch result {
            case .success(let size):
                let sizeInMB = Double(size) / (1024 * 1024)
                self.appendResult("当前缓存大小: \(String(format: "%.2f", sizeInMB)) MB")
            case .failure(let error):
                self.appendResult("获取缓存大小失败: \(error.localizedDescription)")
            }
        }
        
        if let previewImage = NSImage(systemSymbolName: "externaldrive.fill", accessibilityDescription: nil)?.tintedImage(withColor: .systemBlue) {
            updatePreview(image: previewImage, title: "缓存能力已触发", details: "已执行字符串、对象和图片缓存读写；详细结果请查看左侧日志。")
        }
    }
    
    @objc private func testJsonUtils() {
        appendResult("=== JSON工具测试 ===")
        
        // 测试对象转JSON
        let testObject = [
            "name": "测试对象",
            "age": 25,
            "isActive": true,
            "tags": ["swift", "macos", "development"]
        ] as [String : Any]
        
        do {
            let jsonString = try TFYSwiftJsonUtils.toJsonString(testObject)
            appendResult("对象转JSON成功: \(jsonString)")
            
            // 测试JSON转对象
            let parsedObject = try TFYSwiftJsonUtils.toDictionary(from: jsonString)
            appendResult("JSON转对象成功: \(parsedObject)")
        } catch {
            appendResult("JSON转换失败: \(error)")
        }
        
        // 测试JSON字符串解析
        let jsonString = """
        {
            "user": {
                "id": 123,
                "name": "张三",
                "email": "zhangsan@example.com"
            },
            "settings": {
                "theme": "dark",
                "notifications": true
            }
        }
        """
        
        do {
            let parsed = try TFYSwiftJsonUtils.toDictionary(from: jsonString)
            appendResult("JSON字符串解析成功")
            if let user = parsed["user"] as? [String: Any] {
                appendResult("用户信息: \(user)")
            }
        } catch {
            appendResult("JSON字符串解析失败: \(error)")
        }
        
        // 测试JSON验证
        let isValid = TFYSwiftJsonUtils.isValidJSON(jsonString)
        appendResult("JSON格式验证: \(isValid ? "有效" : "无效")")
        
        // 测试JSON格式化
        do {
            _ = try TFYSwiftJsonUtils.formatJSON(jsonString)
            appendResult("JSON格式化成功")
        } catch {
            appendResult("JSON格式化失败: \(error)")
        }
        
        // 测试JSON路径查询
        do {
            let parsed = try TFYSwiftJsonUtils.toDictionary(from: jsonString)
            if let userName = TFYSwiftJsonUtils.getValue(from: parsed, path: "user.name") as? String {
                appendResult("通过路径获取用户名: \(userName)")
            }
            if let userId = TFYSwiftJsonUtils.getValue(from: parsed, path: "user.id") as? Int {
                appendResult("通过路径获取用户ID: \(userId)")
            }
        } catch {
            appendResult("JSON路径查询失败: \(error)")
        }
        
        // 测试JSON构建器
        do {
            let jsonBuilder = TFYSwiftJsonUtils.builder()
                .set("name", "构建器测试")
                .set("version", 1.0)
                .set("features", ["链式调用", "类型安全", "易于使用"])
                .setIf("debug", true, condition: true)
            
            let builtJson = try jsonBuilder.buildJsonString()
            appendResult("JSON构建器测试成功: \(builtJson)")
        } catch {
            appendResult("JSON构建器测试失败: \(error)")
        }
    }
    
    @objc private func testTimer() {
        appendResult("=== 定时器测试 ===")
        activeTimer?.cancel()
        
        // 创建重复定时器
        let timer = TFYSwiftTimer.repeatingTimer(interval: .seconds(2)) { [weak self] timer in
            self?.appendResult("定时器触发: \(Date())")
        }
        activeTimer = timer
        
        // 启动定时器
        do {
            try timer.start()
            appendResult("定时器已启动，间隔2秒")
        } catch {
            appendResult("定时器启动失败: \(error)")
        }
        
        // 10秒后停止定时器
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            timer.stop()
            self.appendResult("定时器已停止")
            self.activeTimer = nil
        }
    }
    
    @objc private func testGCD() {
        appendResult("=== GCD工具测试 ===")
        
        // 测试主线程执行
        TFYSwiftGCD.asyncInMainQueue {
            self.appendResult("在主线程执行")
        }
        
        // 测试后台线程执行
        TFYSwiftGCD.asyncInGlobalQueue {
            self.appendResult("在后台线程执行")
        }
        
        // 测试延迟执行
        TFYSwiftGCD.asyncAfter(seconds: 1.0) {
            self.appendResult("延迟1秒后执行")
        }
        
        // 测试并发执行
        let group = TFYSwiftGCD.createGroup()
        
        for i in 1...3 {
            TFYSwiftGCD.async(in: group, queue: .global()) {
                self.appendResult("并发任务 \(i) 执行")
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        TFYSwiftGCD.notify(group: group) {
            self.appendResult("所有并发任务完成")
        }
    }
    
    @objc private func testFileOperations() {
        appendResult("=== 文件操作测试 ===")
        
        // 获取文档目录
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let testFilePath = documentsPath.appendingPathComponent("test_file.txt")
        
        // 写入文件
        let testContent = "这是一个测试文件\n创建时间: \(Date())"
        do {
            try testContent.write(to: testFilePath, atomically: true, encoding: .utf8)
            appendResult("文件写入成功: \(testFilePath.path)")
        } catch {
            appendResult("文件写入失败: \(error)")
        }
        
        // 读取文件
        do {
            let content = try String(contentsOf: testFilePath, encoding: .utf8)
            appendResult("文件读取成功: \(content)")
        } catch {
            appendResult("文件读取失败: \(error)")
        }
        
        // 检查文件是否存在
        let exists = FileManager.default.fileExists(atPath: testFilePath.path)
        appendResult("文件是否存在: \(exists)")
        
        // 获取文件属性
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: testFilePath.path)
            appendResult("文件大小: \(attributes[.size] ?? "未知")")
            appendResult("创建时间: \(attributes[.creationDate] ?? "未知")")
        } catch {
            appendResult("获取文件属性失败: \(error)")
        }
    }
    
    @objc private func testCrypto() {
        appendResult("=== 加密工具测试 ===")
        
        let originalText = "这是一个需要加密的文本"
        let key = "test_key_123"
        
        // 测试SHA256（使用NSString的扩展方法）
        let sha256Hash = originalText.sha256
        appendResult("SHA256哈希: \(sha256Hash)")
        
        // 测试SHA1（使用NSString的扩展方法）
        if let sha1Hash = originalText.sha1String {
            appendResult("SHA1哈希: \(sha1Hash)")
        } else {
            appendResult("SHA1哈希计算失败")
        }
        
        // 测试SHA256（使用NSString的扩展方法）
        if let sha256String = originalText.sha256String {
            appendResult("SHA256字符串: \(sha256String)")
        } else {
            appendResult("SHA256字符串计算失败")
        }
        
        // 测试HMAC-SHA256
        let hmacSha256 = originalText.hmacSHA256String(key: key)
        appendResult("HMAC-SHA256: \(hmacSha256 ?? "计算失败")")
        
        // 测试Base64编码
        if let base64Encoded = originalText.data(using: .utf8)?.base64EncodedString() {
            appendResult("Base64编码: \(base64Encoded)")
            
            // 测试Base64解码
            if let decodedData = Data(base64Encoded: base64Encoded),
               let decodedString = String(data: decodedData, encoding: .utf8) {
                appendResult("Base64解码: \(decodedString)")
            }
        }
        
        // 测试AES-GCM加密（现代安全方式）
        if let encryptedText = TFYSwiftUtils.encryptAESGCM(content: originalText, key: key) {
            appendResult("AES-GCM加密成功: \(encryptedText)")
            
            if let decryptedText = TFYSwiftUtils.decryptAESGCM(content: encryptedText, key: key) {
                appendResult("AES-GCM解密成功: \(decryptedText)")
            } else {
                appendResult("AES-GCM解密失败")
            }
        } else {
            appendResult("AES-GCM加密失败")
        }
    }
    
    @objc private func testOpenPanel() {
        appendResult("=== 打开/保存文件（TFYSwiftOpenPanel）===")
        guard #available(macOS 10.15, *) else {
            appendResult("需要 macOS 10.15+")
            return
        }
        TFYSwiftOpenPanel.selectFile(title: "选择文件", message: "请选择一个文件") { [weak self] url in
            if let url = url {
                self?.appendResult("已选择文件: \(url.path)")
            } else {
                self?.appendResult("用户取消选择文件")
            }
            self?.runSavePanelDemo()
        }
    }
    
    private func runSavePanelDemo() {
        guard #available(macOS 10.15, *) else { return }
        let defaultName = "demo_\(Int(Date().timeIntervalSince1970)).txt"
        TFYSwiftOpenPanel.saveFile(title: "保存文件", message: "请选择保存位置", fileName: defaultName) { [weak self] result in
            if result.wasCancelled {
                self?.appendResult("用户取消保存")
                return
            }
            guard let url = result.url else {
                self?.appendResult("未获取到保存 URL")
                return
            }
            self?.appendResult("已选择保存位置: \(url.path)")
            do {
                try "TFYSwiftOpenPanel 保存演示\n时间: \(Date())".write(to: url, atomically: true, encoding: .utf8)
                self?.appendResult("文件已写入成功")
            } catch {
                self?.appendResult("文件写入失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func clearResults() {
        resultTextView.string = "工具类测试结果将显示在这里...\n"
        appendResult("日志已清空")
    }
    
    @objc private func testDebounceAndThrottle() {
        appendResult("=== 防抖 / 节流测试 ===")
        appendResult("连续触发 5 次 debounce，预期只执行最后 1 次")
        
        for index in 1...5 {
            TFYSwiftTimer.debounce(interval: .milliseconds(250), identifier: "utils-demo-debounce") { [weak self] in
                self?.appendResult("debounce 最终执行，来自第 \(index) 次触发")
            }
        }
        
        appendResult("连续触发 5 次 throttle，预期只执行第 1 次")
        for index in 1...5 {
            TFYSwiftTimer.throttle(interval: .milliseconds(400), identifier: "utils-demo-throttle") { [weak self] in
                self?.appendResult("throttle 执行，来自第 \(index) 次触发")
            }
        }
    }
    
    @objc private func testJsonFileIO() {
        appendResult("=== JSON 文件读写测试 ===")
        
        struct DemoProfile: Codable {
            let id: Int
            let name: String
            let tags: [String]
        }
        
        let profile = DemoProfile(id: 7, name: "TFY Demo", tags: ["macOS", "AppKit", "Utilities"])
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("tfy_demo_profile.json")
        
        do {
            try TFYSwiftJsonUtils.saveToFile(profile, filePath: fileURL.path)
            appendResult("JSON 已写入临时目录: \(fileURL.path)")
            
            let loadedProfile = try TFYSwiftJsonUtils.loadFromFile(DemoProfile.self, filePath: fileURL.path)
            appendResult("JSON 读取成功: \(loadedProfile.name) / tags: \(loadedProfile.tags.joined(separator: ", "))")
        } catch {
            appendResult("JSON 文件读写失败: \(error.localizedDescription)")
        }
    }
    
    @objc private func testCountDownTimer() {
        appendResult("=== 倒计时测试 ===")
        countDownTimer?.cancel()
        
        let timer = TFYSwiftCountDownTimer(interval: .seconds(1), times: 5) { [weak self] timer, leftTimes in
            let progressText = String(format: "%.0f%%", timer.progress * 100)
            self?.appendResult("倒计时剩余: \(leftTimes) 秒，进度: \(progressText)")
            if leftTimes == 0 {
                self?.appendResult("倒计时结束")
                self?.countDownTimer = nil
            }
        }
        
        countDownTimer = timer
        timer.start()
        appendResult("倒计时已启动，总时长 5 秒")
    }
    
    @objc private func testImageStitching() {
        appendResult("=== 图片拼接测试 ===")
        
        let demoImages = makeDemoImages()
        let gridSize = CGSize(width: 320, height: 320)
        let horizontalSize = CGSize(width: 520, height: 120)
        
        if let stitchedGrid = TFYStitchImage.createNineGrid(images: demoImages, size: gridSize, gap: 10, cornerRadius: 18) {
            updatePreview(
                image: stitchedGrid,
                title: "TFYStitchImage 九宫格拼接",
                details: "共 \(demoImages.count) 张示例图，输出尺寸 \(Int(gridSize.width)) x \(Int(gridSize.height))。"
            )
            
            let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("tfy_stitch_grid_demo.png")
            do {
                try stitchedGrid.save(to: exportURL, format: .png)
                appendResult("九宫格拼接成功，已导出到: \(exportURL.path)")
            } catch {
                appendResult("九宫格结果导出失败: \(error.localizedDescription)")
            }
        } else {
            appendResult("九宫格拼接失败")
        }
        
        if let horizontal = TFYStitchImage.createHorizontal(images: demoImages.prefix(4).map { $0 }, size: horizontalSize, gap: 8) {
            appendResult("横向拼接成功，尺寸: \(Int(horizontal.size.width)) x \(Int(horizontal.size.height))")
        } else {
            appendResult("横向拼接失败")
        }
    }
    
    @objc private func clearCaches() {
        appendResult("=== 缓存清理 ===")
        cacheManager?.clearMemoryCache()
        appendResult("内存缓存已触发清理")
        
        cacheManager?.clearDiskCache { [weak self] result in
            switch result {
            case .success:
                self?.appendResult("磁盘缓存已清理完成")
                self?.updatePreview(
                    image: NSImage(systemSymbolName: "trash.fill", accessibilityDescription: nil)?.tintedImage(withColor: .systemRed),
                    title: "缓存已清理",
                    details: "内存缓存和磁盘缓存已执行清理，可重新点击“缓存测试”验证行为。"
                )
            case .failure(let error):
                self?.appendResult("磁盘缓存清理失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func cleanExpiredCaches() {
        appendResult("=== 过期缓存清理 ===")
        cacheManager?.cleanExpiredCache { [weak self] result in
            switch result {
            case .success:
                self?.appendResult("过期缓存清理完成")
            case .failure(let error):
                self?.appendResult("过期缓存清理失败: \(error.localizedDescription)")
            }
        }
    }

    @objc private func testAsyncUtilities() {
        appendResult("=== TFYSwiftAsync 测试 ===")
        appendResult("提交后台任务、延迟任务以及 3 次可取消任务，预期仅最后 1 次 cancellable 会真正执行。")

        TFYSwiftAsync.async(on: .global()) { [weak self] in
            self?.appendResult("后台任务开始，模拟执行 0.4 秒")
            Thread.sleep(forTimeInterval: 0.4)
        } mainCallback: { [weak self] in
            self?.appendResult("后台任务完成，已回到主线程")
            self?.updatePreview(
                image: NSImage(systemSymbolName: "bolt.circle.fill", accessibilityDescription: nil)?.tintedImage(withColor: .systemYellow),
                title: "TFYSwiftAsync 已执行",
                details: "已演示 async / delay / cancellable 三类调用，详细时序请查看左侧日志。"
            )
        }

        TFYSwiftAsync.asyncDelay(seconds: 0.6, on: .main) { [weak self] in
            self?.appendResult("延迟任务完成，来自 asyncDelay(seconds: 0.6)")
        }

        for index in 1...3 {
            TFYSwiftAsync.asyncCancellable(identifier: "utils-demo.async.cancellable", on: .global()) { [weak self] in
                self?.appendResult("可取消任务最终执行：第 \(index) 次提交生效")
            }
        }
    }

    @objc private func testDispatchOnce() {
        appendResult("=== DispatchQueue.once 测试 ===")
        let previousCount = onceExecutionCount

        DispatchQueue.once(token: "tfy.utils.demo.once") { [weak self] in
            guard let self else { return }
            self.onceExecutionCount += 1
            self.appendResult("once block 首次执行成功，累计执行 \(self.onceExecutionCount) 次")
            self.updatePreview(
                image: NSImage(systemSymbolName: "checkmark.seal.fill", accessibilityDescription: nil)?.tintedImage(withColor: .systemGreen),
                title: "DispatchQueue.once 已触发",
                details: "同一个 token 在当前进程内只会执行一次，再次点击按钮不会重复进入 block。"
            )
        }

        if previousCount == onceExecutionCount {
            appendResult("同一个 token 已经执行过，当前点击不会再次运行 once block")
        }
    }

    @objc private func testAESGCM() {
        appendResult("=== AES-GCM 加密测试 ===")
        guard #available(macOS 10.15, *) else {
            appendResult("需要 macOS 10.15+")
            return
        }
        let original = "Hello, TFYSwiftMacOSAppKit! 这是需要加密的内容。"
        let key = "tfy-demo-secret-key-2024"
        appendResult("原文: \(original)")

        guard let encrypted = TFYSwiftUtils.encryptAESGCM(content: original, key: key) else {
            appendResult("AES-GCM 加密失败")
            return
        }
        appendResult("加密结果 (Base64): \(encrypted)")

        guard let decrypted = TFYSwiftUtils.decryptAESGCM(content: encrypted, key: key) else {
            appendResult("AES-GCM 解密失败")
            return
        }
        appendResult("解密还原: \(decrypted)")
        appendResult("往返一致: \(original == decrypted ? "✅" : "❌")")
        updatePreview(
            image: NSImage(systemSymbolName: "lock.shield.fill", accessibilityDescription: nil)?.tintedImage(withColor: .systemIndigo),
            title: "AES-GCM 加密往返成功",
            details: "原文 → 加密 → 解密，三段内容已在日志中打印。"
        )
    }

    @objc private func testVersionCompare() {
        appendResult("=== 版本号比较测试 ===")
        let pairs: [(String, String)] = [
            ("1.2.3", "1.2.4"),
            ("2.0.0", "1.9.9"),
            ("1.0",   "1.0.0"),
            ("3.10.0", "3.9.9"),
            ("1.0.0", "1.0.0")
        ]
        for (current, latest) in pairs {
            let result = current.compare(latest, options: .numeric)
            let verdict: String
            switch result {
            case .orderedAscending:  verdict = "有新版本 ↑"
            case .orderedDescending: verdict = "当前版本更新 ↓"
            case .orderedSame:       verdict = "已是最新 ✅"
            }
            appendResult("当前 \(current) vs 最新 \(latest) → \(verdict)")
        }
        updatePreview(
            image: NSImage(systemSymbolName: "arrow.up.circle.fill", accessibilityDescription: nil)?.tintedImage(withColor: .systemGreen),
            title: "版本比较完成",
            details: "使用 String.compare(_:options: .numeric) 进行语义版本大小比较。"
        )
    }

    @objc private func testIPValidation() {
        appendResult("=== IP 地址验证测试 ===")
        let addresses = [
            "192.168.1.1",
            "10.0.0.255",
            "256.0.0.1",
            "0.0.0.0",
            "999.999.999.999",
            "172.16.254.1",
            "not.an.ip",
            "::1",
            "127.0.0.1"
        ]
        for ip in addresses {
            let valid = TFYSwiftUtils.isValidIP(ipAddress: ip)
            appendResult("\(ip.padding(toLength: 20, withPad: " ", startingAt: 0)) → \(valid ? "✅ 有效" : "❌ 无效")")
        }
        updatePreview(
            image: NSImage(systemSymbolName: "network", accessibilityDescription: nil)?.tintedImage(withColor: .systemTeal),
            title: "IP 验证完成",
            details: "TFYSwiftUtils.isValidIP(ipAddress:) 对 \(addresses.count) 个地址进行了格式检查。"
        )
    }

    @objc private func testArrayExtensions() {
        appendResult("=== Array+Dejal 扩展测试 ===")

        let nums = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3]
        appendResult("原始数组: \(nums)")

        let deduped = nums.removingDuplicates()
        appendResult("去重 (removingDuplicates): \(deduped)")

        let small = [1, 2, 3]
        let perms = small.permutations()
        appendResult("排列组合 [1,2,3].permutations() 共 \(perms.count) 种: \(perms.prefix(6).map { "\($0)" }.joined(separator: ", "))")

        let subs = small.subsets()
        appendResult("子集 [1,2,3].subsets() 共 \(subs.count) 个: \(subs.map { "\($0)" }.joined(separator: ", "))")

        let chunks = nums.chunked(into: 3)
        appendResult("分块 chunked(into: 3): \(chunks)")

        let safeVal = nums.object(atSafeIndex: 2)
        let safeNil = nums.object(atSafeIndex: 100)
        appendResult("安全下标 object(atSafeIndex: 2) = \(safeVal.map { "\($0)" } ?? "nil"), object(atSafeIndex: 100) = \(safeNil.map { "\($0)" } ?? "nil")")

        updatePreview(
            image: NSImage(systemSymbolName: "list.bullet.rectangle.fill", accessibilityDescription: nil)?.tintedImage(withColor: .systemOrange),
            title: "Array 扩展演示完成",
            details: "已展示 removingDuplicates / permutations / subsets / chunked / safe subscript 五项能力。"
        )
    }

    @objc private func testStringExtensions() {
        appendResult("=== NSString+Dejal 扩展测试 ===")

        let sample = "Hello TFYSwiftMacOSAppKit"
        appendResult("原始字符串: \(sample)")
        appendResult("sha256 (CryptoKit): \(sample.sha256)")
        appendResult("sha256String (CC): \(sample.sha256String ?? "nil")")
        appendResult("sha1String: \(sample.sha1String ?? "nil")")
        appendResult("shortHash: \(sample.shortHash)")
        appendResult("base64Encoded: \(sample.base64Encoded)")
        appendResult("urlEncoded: \(sample.urlEncoded)")
        appendResult("isBlank: \(sample.isBlank), \" \".isBlank: \(" ".isBlank)")

        let currentTime = String.getCurrentTime()
        appendResult("getCurrentTime(): \(currentTime)")
        appendResult("getCurrentTimestamp(): \(String.getCurrentTimestamp())")
        appendResult("getCurrentTimestamp(ms): \(String.getCurrentTimestamp(isMilliseconds: true))")

        let a = "kitten"
        let b = "sitting"
        appendResult("levenshteinDistance(\"\(a)\", \"\(b)\"): \(a.levenshteinDistance(to: b))")

        let email = "test@example.com"
        appendResult("isValidEmail(\"\(email)\"): \(email.isValidEmail)")

        updatePreview(
            image: NSImage(systemSymbolName: "textformat.abc", accessibilityDescription: nil)?.tintedImage(withColor: .systemPurple),
            title: "字符串扩展演示完成",
            details: "已展示 sha256/sha1/base64/url编码/时间获取/编辑距离等 String+Dejal 能力。"
        )
    }
}
