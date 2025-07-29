//
//  UtilsDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa

class UtilsDemoViewController: NSViewController {
    
    private var resultTextView: NSTextView!
    private var cacheManager: TFYSwiftCacheKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUtilsDemo()
        setupCacheManager()
    }
    
    private func setupUtilsDemo() {
        // 创建主容器视图
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 创建标题
        let titleLabel = NSTextField()
        titleLabel.chain
            .text("工具类功能演示")
            .font(.boldSystemFont(ofSize: 20))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 20, y: 20, width: 300, height: 30))
        
        containerView.addSubview(titleLabel)
        
        // 创建按钮区域
        createButtonArea(in: containerView)
        
        // 创建结果显示区域
        createResultArea(in: containerView)
    }
    
    private func createButtonArea(in containerView: NSView) {
        let buttonArea = NSView()
        buttonArea.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonArea)
        
        // 网络工具按钮
        let networkButton = NSButton()
        networkButton.chain
            .frame(NSRect(x: 0, y: 0, width: 120, height: 30))
            .title("网络信息")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(getNetworkInfo))
            
        
        buttonArea.addSubview(networkButton)
        
        // 缓存测试按钮
        let cacheButton = NSButton()
        cacheButton.chain
            .frame(NSRect(x: 130, y: 0, width: 120, height: 30))
            .title("缓存测试")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testCache))
            
        
        buttonArea.addSubview(cacheButton)
        
        // JSON工具按钮
        let jsonButton = NSButton()
        jsonButton.chain
            .frame(NSRect(x: 260, y: 0, width: 120, height: 30))
            .title("JSON工具")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testJsonUtils))
           
        
        buttonArea.addSubview(jsonButton)
        
        // 定时器按钮
        let timerButton = NSButton()
        timerButton.chain
            .frame(NSRect(x: 390, y: 0, width: 120, height: 30))
            .title("定时器")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testTimer))
            
        buttonArea.addSubview(timerButton)
        
        // GCD工具按钮
        let gcdButton = NSButton()
        gcdButton.chain
            .frame(NSRect(x: 520, y: 0, width: 120, height: 30))
            .title("GCD工具")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testGCD))
            
        
        buttonArea.addSubview(gcdButton)
        
        // 文件操作按钮
        let fileButton = NSButton()
        fileButton.chain
            .frame(NSRect(x: 0, y: 40, width: 120, height: 30))
            .title("文件操作")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testFileOperations))
           
        
        buttonArea.addSubview(fileButton)
        
        // 加密工具按钮
        let cryptoButton = NSButton()
        cryptoButton.chain
            .frame(NSRect(x: 130, y: 40, width: 120, height: 30))
            .title("加密工具")
            .font(.systemFont(ofSize: 12))
            .addTarget(self, action: #selector(testCrypto))
           
        
        buttonArea.addSubview(cryptoButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            buttonArea.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
            buttonArea.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonArea.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonArea.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func createResultArea(in containerView: NSView) {
        let resultArea = NSView()
        resultArea.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(resultArea)
        
        // 结果标题
        let resultTitleLabel = NSTextField()
        resultTitleLabel.chain
            .text("测试结果")
            .font(.systemFont(ofSize: 16))
            .textColor(.labelColor)
            .backgroundColor(.clear)
            .bordered(false)
            .editable(false)
            .selectable(false)
            .frame(NSRect(x: 0, y: 0, width: 100, height: 20))
        
        resultArea.addSubview(resultTitleLabel)
        
        // 结果文本框
        resultTextView = NSTextView()
        resultTextView.chain
            .frame(NSRect(x: 0, y: 30, width: 600, height: 300))
            .backgroundColor(.textBackgroundColor)
            .textColor(.textColor)
            .font(.systemFont(ofSize: 12))
            .string("工具类测试结果将显示在这里...\n")
        
        resultArea.addSubview(resultTextView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            resultArea.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 160),
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
            let currentText = self.resultTextView.string
            self.resultTextView.string = currentText + text + "\n"
            
            // 滚动到底部
            let scrollView = self.resultTextView.enclosingScrollView
            scrollView?.documentView?.scroll(NSPoint(x: 0, y: 0))
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
        
        // 创建重复定时器
        let timer = TFYSwiftTimer.repeatingTimer(interval: .seconds(2)) { [weak self] timer in
            self?.appendResult("定时器触发: \(Date())")
        }
        
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
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
        
        // 测试AES加密
        if let encryptedText = TFYSwiftUtils.encrypt(content: originalText, key: key) {
            appendResult("AES加密成功: \(encryptedText)")
            
            if let decryptedText = TFYSwiftUtils.decrypt(content: encryptedText, key: key) {
                appendResult("AES解密成功: \(decryptedText)")
            } else {
                appendResult("AES解密失败")
            }
        } else {
            appendResult("AES加密失败")
        }
    }
} 
