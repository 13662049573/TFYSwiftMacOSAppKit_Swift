# TFYSwiftMacOSAppKit

<div align="center">
  <img src="https://raw.githubusercontent.com/13662049573/TFYSwiftMacOSAppKit_Swift/master/logo.png" alt="TFYSwiftMacOSAppKit Logo" width="200">
</div>

<p align="center">
  <a href="https://cocoapods.org/pods/TFYSwiftMacOSAppKit">
    <img src="https://img.shields.io/cocoapods/v/TFYSwiftMacOSAppKit.svg?style=flat" alt="Version">
  </a>
  <a href="https://cocoapods.org/pods/TFYSwiftMacOSAppKit">
    <img src="https://img.shields.io/cocoapods/l/TFYSwiftMacOSAppKit.svg?style=flat" alt="License">
  </a>
  <a href="https://cocoapods.org/pods/TFYSwiftMacOSAppKit">
    <img src="https://img.shields.io/cocoapods/p/TFYSwiftMacOSAppKit.svg?style=flat" alt="Platform">
  </a>
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5.0">
  </a>
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/stargazers">
    <img src="https://img.shields.io/github/stars/13662049573/TFYSwiftMacOSAppKit_Swift.svg" alt="GitHub stars">
  </a>
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/network">
    <img src="https://img.shields.io/github/forks/13662049573/TFYSwiftMacOSAppKit_Swift.svg" alt="GitHub forks">
  </a>
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/issues">
    <img src="https://img.shields.io/github/issues/13662049573/TFYSwiftMacOSAppKit_Swift.svg" alt="GitHub issues">
  </a>
</p>

<p align="center">🚀 优雅的 macOS 开发工具库 | 链式编程 | 组件化设计 | 高性能</p>

---

## 📋 目录

- [✨ 亮点特性](#-亮点特性)
- [🌟 功能展示](#-功能展示)
- [📦 模块架构](#-模块架构)
- [🔧 核心组件](#-核心组件)
- [🚀 快速开始](#-快速开始)
- [📚 详细文档](#-详细文档)
- [🎯 最佳实践](#-最佳实践)
- [🤝 参与贡献](#-参与贡献)
- [📄 开源协议](#-开源协议)
- [👨‍💻 作者](#-作者)

---

## ✨ 亮点特性

- 🎯 **原生 Swift 开发**：完全使用 Swift 5.0 编写，类型安全，性能优异
- 🔗 **链式编程**：优雅的点语法，让代码更简洁直观
- 📦 **模块化设计**：六大核心模块，按需引入，灵活组合
- 🎨 **UI 组件增强**：提供丰富的 UI 控件扩展，支持自定义样式
- 🛠 **开发效率提升**：快速实现复杂功能，减少重复代码
- 💡 **智能提示**：完善的代码注释和类型推断，编码更轻松
- 🔒 **内存安全**：自动内存管理，避免内存泄漏
- 📱 **现代化设计**：支持 macOS 12.0+，紧跟 Apple 最新技术
- 🎭 **动画系统**：强大的动画引擎，支持多种动画效果
- 🌈 **主题管理**：动态主题切换，支持浅色/深色模式
- 📊 **进度指示器**：丰富的进度显示组件
- 🎪 **状态栏集成**：完整的状态栏项管理解决方案

---

## 🌟 功能展示

### 🎨 优雅的链式语法

```swift
// 传统写法
let textField = NSTextField()
textField.placeholderString = "请输入..."
textField.textColor = .black
textField.backgroundColor = .white
textField.isBordered = true

// TFYSwiftMacOSAppKit 链式写法
let textField = TFYSwiftTextField()
textField.chain
    .placeholderString("请输入...")
    .textColor(.black)
    .backgroundColor(.white)
    .bordered(true)
    .isTextAlignmentVerticalCenter(true)  // 独特的垂直居中支持
    .Xcursor(10)                          // 自定义光标位置
```

### 🎪 强大的 HUD 系统

```swift
// 基础 HUD 显示
TFYProgressMacOSHUD.showSuccess("操作成功！")
TFYProgressMacOSHUD.showError("操作失败！")
TFYProgressMacOSHUD.showInfo("提示信息")
TFYProgressMacOSHUD.showMessage("自定义消息")

// 进度 HUD
TFYProgressMacOSHUD.showProgress(0.5, status: "正在处理...")
TFYProgressMacOSHUD.showProgressWithStyle(.ring, progress: 0.7)

// 自定义主题
TFYProgressMacOSHUD.shared.configureTheme(.customBlue)
```

### 🎭 丰富的动画效果

```swift
// 视图动画
view.chain
    .backgroundColor(.systemBlue)
    .cornerRadius(8)
    .masksToBounds(true)
    .addAnimation(duration: 0.3) { 
        // 添加动画效果
    }

// 手势动画
view.chain
    .addClickGesture { gesture in
        print("点击事件")
    }
    .addPanGesture { gesture in
        print("拖动事件")
    }
```

### 🎪 状态栏项管理

```swift
// 创建状态栏项
let statusItem = TFYStatusItem.shared
try statusItem.configure(with: .init(
    image: NSImage(systemSymbolName: "star.fill"),
    viewController: contentViewController
))

// 显示/隐藏窗口
statusItem.showStatusItemWindow()
statusItem.dismissStatusItemWindow()
```

### ⚡ 异步任务管理

```swift
// 异步执行
TFYSwiftAsync.async {
    // 后台任务
} mainCallback: {
    // 主线程回调
}

// 延迟执行
TFYSwiftAsync.asyncDelay(seconds: 2.0) {
    print("2秒后执行")
}
```

### 🗄️ 缓存系统

```swift
// 内存缓存
TFYSwiftCacheKit.shared.setObject("value", forKey: "key")

// 磁盘缓存
TFYSwiftCacheKit.shared.setObject(data, forKey: "image", toDisk: true)

// 获取缓存
let value = TFYSwiftCacheKit.shared.object(forKey: "key")
```

---

## 📦 模块架构

```
TFYSwiftMacOSAppKit
├── 📁 macOSBase          # 核心基础组件
│   ├── TFYSwiftChain.swift      # 链式编程核心
│   ├── TFYSwiftHasFont.swift    # 字体管理
│   └── TFYSwiftHasText.swift    # 文本管理
├── 📁 macOSfoundation   # Foundation 增强
│   ├── Array+Dejal.swift        # 数组扩展
│   ├── Bundle+Dejal.swift       # Bundle 扩展
│   ├── NSColor+Dejal.swift      # 颜色扩展
│   ├── NSString+Dejal.swift     # 字符串扩展
│   └── Timer+Dejal.swift        # 定时器扩展
├── 📁 macOScategory     # 实用分类扩展
│   ├── NSControl+Dejal.swift    # 控件扩展
│   ├── NSImage+Dejal.swift      # 图片扩展
│   ├── NSMenu+Dejal.swift       # 菜单扩展
│   ├── NSView+Dejal.swift       # 视图扩展
│   └── NSTextField+Dejal.swift  # 文本框扩展
├── 📁 macOScontainer    # 容器组件集合
│   ├── 📁 macOSStatusItem      # 状态栏项管理
│   │   ├── TFYStatusItem.swift              # 状态栏项核心
│   │   ├── TFYStatusItemWindow.swift        # 状态栏窗口
│   │   ├── TFYStatusItemWindowController.swift # 窗口控制器
│   │   └── TFYStatusItemContainerView.swift # 容器视图
│   └── 📁 macOSUtils           # 工具组件
│       ├── TFYSwiftUtils.swift      # 网络工具
│       ├── TFYSwiftTimer.swift      # 定时器工具
│       ├── TFYSwiftAsync.swift      # 异步工具
│       ├── TFYSwiftCacheKit.swift   # 缓存工具
│       ├── TFYSwiftTextField.swift  # 自定义文本框
│       ├── TFYSwiftButton.swift     # 自定义按钮
│       └── TFYSwiftLabel.swift      # 自定义标签
├── 📁 macOSchain        # 链式编程支持
│   ├── 📁 macOSView            # 视图链式扩展
│   │   ├── TFYSwiftNSView.swift         # 基础视图
│   │   ├── TFYSwiftNSButton.swift       # 按钮
│   │   ├── TFYSwiftNSTextField.swift    # 文本框
│   │   ├── TFYSwiftNSImageView.swift    # 图片视图
│   │   └── TFYSwiftNSScrollView.swift   # 滚动视图
│   ├── 📁 macOSGesture         # 手势链式扩展
│   │   ├── TFYSwiftNSGestureRecognizer.swift # 手势识别器
│   │   ├── TFYSwiftNSClickGestureRecognizer.swift # 点击手势
│   │   └── TFYSwiftNSPanGestureRecognizer.swift # 拖动手势
│   └── 📁 macOSCALayer         # 图层链式扩展
│       ├── TFYSwiftCALayer.swift        # 基础图层
│       ├── TFYSwiftCAGradientLayer.swift # 渐变图层
│       └── TFYSwiftCAShapeLayer.swift   # 形状图层
└── 📁 macOSHUD          # 界面交互组件
    ├── TFYProgressMacOSHUD.swift        # HUD 核心类
    ├── TFYProgressIndicator.swift       # 进度指示器
    ├── TFYProgressView.swift            # 进度视图
    ├── TFYAnimationEnhancer.swift      # 动画增强器
    ├── TFYLayoutManager.swift           # 布局管理器
    └── TFYThemeManager.swift            # 主题管理器
```

---

## 🔧 核心组件

### 🎪 HUD 系统 (macOSHUD)

**功能特性：**
- ✅ 多种 HUD 模式：成功、错误、信息、加载、进度
- ✅ 丰富的动画效果：淡入淡出、缩放、滑动、旋转
- ✅ 动态主题切换：浅色、深色、自定义主题
- ✅ 自适应布局：根据内容自动调整大小
- ✅ 进度显示：环形、条形、饼图等多种样式
- ✅ 位置控制：顶部、底部、居中、自定义位置

**使用示例：**
```swift
// 基础 HUD
TFYProgressMacOSHUD.showSuccess("操作成功！")
TFYProgressMacOSHUD.showError("操作失败！")
TFYProgressMacOSHUD.showInfo("提示信息")

// 进度 HUD
TFYProgressMacOSHUD.showProgress(0.5, status: "正在处理...")
TFYProgressMacOSHUD.showProgressWithStyle(.ring, progress: 0.7)

// 自定义配置
TFYProgressMacOSHUD.shared.configureAnimation(.bounce)
TFYProgressMacOSHUD.shared.configureTheme(.customBlue)
```

### 🎪 状态栏项系统 (macOSStatusItem)

**功能特性：**
- ✅ 完整的状态栏项生命周期管理
- ✅ 自定义窗口和内容视图
- ✅ 拖拽检测和事件处理
- ✅ 窗口位置和样式配置
- ✅ 主题适配和动画效果
- ✅ 内存安全和错误处理

**使用示例：**
```swift
// 创建状态栏项
let config = TFYStatusItem.StatusItemConfiguration(
    image: NSImage(systemSymbolName: "star.fill"),
    viewController: contentViewController,
    windowConfiguration: windowConfig
)

try TFYStatusItem.shared.configure(with: config)

// 控制显示
TFYStatusItem.shared.showStatusItemWindow()
TFYStatusItem.shared.dismissStatusItemWindow()
```

### ⚡ 异步任务系统 (macOSUtils)

**功能特性：**
- ✅ 异步任务管理：支持队列和优先级
- ✅ 延迟执行：精确的时间控制
- ✅ 防抖节流：性能优化工具
- ✅ 错误处理：完善的异常管理
- ✅ 内存管理：自动资源释放

**使用示例：**
```swift
// 异步执行
TFYSwiftAsync.async {
    // 后台任务
} mainCallback: {
    // 主线程回调
}

// 延迟执行
TFYSwiftAsync.asyncDelay(seconds: 2.0) {
    print("2秒后执行")
}

// 防抖执行
TFYSwiftAsync.debounce(seconds: 0.5) {
    print("防抖执行")
}
```

### 🗄️ 缓存系统 (macOSUtils)

**功能特性：**
- ✅ 内存缓存：快速访问
- ✅ 磁盘缓存：持久化存储
- ✅ 缓存策略：LRU、FIFO、自定义
- ✅ 缓存统计：使用情况监控
- ✅ 自动清理：过期数据管理

**使用示例：**
```swift
// 设置缓存
TFYSwiftCacheKit.shared.setObject("value", forKey: "key")
TFYSwiftCacheKit.shared.setObject(data, forKey: "image", toDisk: true)

// 获取缓存
let value = TFYSwiftCacheKit.shared.object(forKey: "key")
let image = TFYSwiftCacheKit.shared.object(forKey: "image")

// 清理缓存
TFYSwiftCacheKit.shared.clearMemory()
TFYSwiftCacheKit.shared.clearDisk()
```

### 🎨 UI 组件系统 (macOSchain)

**功能特性：**
- ✅ 链式编程：优雅的 API 设计
- ✅ 手势支持：点击、拖动、缩放等
- ✅ 动画效果：丰富的动画库
- ✅ 自定义控件：文本框、按钮、标签等
- ✅ 布局管理：自动布局支持

**使用示例：**
```swift
// 视图链式配置
view.chain
    .backgroundColor(.systemBlue)
    .cornerRadius(8)
    .masksToBounds(true)
    .addClickGesture { gesture in
        print("点击事件")
    }

// 文本框链式配置
textField.chain
    .placeholderString("请输入...")
    .textColor(.black)
    .backgroundColor(.white)
    .bordered(true)
    .isTextAlignmentVerticalCenter(true)
```

---

## 🚀 快速开始

### 📦 安装

#### CocoaPods 安装

```ruby
# 完整安装
pod 'TFYSwiftMacOSAppKit'

# 按需安装
pod 'TFYSwiftMacOSAppKit/macOSBase'      # 仅安装基础组件
pod 'TFYSwiftMacOSAppKit/macOSchain'     # 仅安装链式编程支持
pod 'TFYSwiftMacOSAppKit/macOSHUD'       # 仅安装 HUD 组件
pod 'TFYSwiftMacOSAppKit/macOScontainer' # 仅安装容器组件
```

#### Swift Package Manager 安装

```swift
// 在 Package.swift 中添加依赖
dependencies: [
    .package(url: "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift.git", from: "1.2.0")
]
```

### 📝 导入

```swift
import TFYSwiftMacOSAppKit
```

### 🎯 基础使用

```swift
import Cocoa
import TFYSwiftMacOSAppKit

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建链式配置的文本框
        let textField = TFYSwiftTextField()
        textField.chain
            .placeholderString("请输入内容...")
            .textColor(.labelColor)
            .backgroundColor(.controlBackgroundColor)
            .bordered(true)
            .isTextAlignmentVerticalCenter(true)
            .frame(NSRect(x: 20, y: 20, width: 200, height: 30))
        
        view.addSubview(textField)
        
        // 显示 HUD
        TFYProgressMacOSHUD.showSuccess("初始化完成！")
    }
}
```

---

## 📚 详细文档

### 📖 API 文档

访问我们的 [Wiki](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki) 获取完整的 API 文档：

- [基础组件 API](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/基础组件)
- [HUD 系统 API](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/HUD-系统)
- [状态栏项 API](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/状态栏项)
- [链式编程 API](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/链式编程)
- [工具类 API](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/工具类)

### 🎯 使用教程

- [快速入门指南](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/快速入门)
- [HUD 使用教程](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/HUD-使用教程)
- [状态栏项教程](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/状态栏项教程)
- [链式编程最佳实践](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/链式编程最佳实践)

### 📝 示例代码

- [基础示例](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/tree/master/Examples/Basic)
- [HUD 示例](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/tree/master/Examples/HUD)
- [状态栏项示例](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/tree/master/Examples/StatusItem)
- [动画示例](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/tree/master/Examples/Animation)

### ❓ 常见问题

- [FAQ](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/FAQ)
- [故障排除](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/故障排除)
- [性能优化](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki/性能优化)

---

## 🎯 最佳实践

### 1. 🎨 UI 控件优化

```swift
// 文本框优化
textField.chain
    .isTextAlignmentVerticalCenter(true)  // 文字垂直居中
    .Xcursor(10)                          // 自定义光标位置
    .placeholderColor(.secondaryLabelColor)  // 占位符颜色
    .drawsBackground(false)               // 透明背景

// 标签优化
label.chain
    .textColor(.labelColor)               // 自适应文本颜色
    .font(.systemFont(ofSize: 14))        // 系统字体
    .alignment(.center)                   // 居中对齐
```

### 2. 🎭 手势支持

```swift
view.chain
    .addClickGesture { gesture in
        print("点击事件")
    }
    .addPanGesture { gesture in
        print("拖动事件")
    }
    .addPinchGesture { gesture in
        print("缩放事件")
    }
```

### 3. 🎪 动画效果

```swift
view.layer?.chain
    .backgroundColor(.systemBlue)
    .cornerRadius(8)
    .masksToBounds(true)
    .addAnimation(duration: 0.3) { 
        // 添加动画效果
    }
```

### 4. 🎪 HUD 最佳实践

```swift
// 配置全局 HUD 设置
TFYProgressMacOSHUD.shared.configureAnimation(.fade)
TFYProgressMacOSHUD.shared.configureTheme(.system)

// 显示进度时提供状态信息
TFYProgressMacOSHUD.showProgress(0.5, status: "正在处理数据...")

// 使用适当的 HUD 类型
TFYProgressMacOSHUD.showSuccess("保存成功！")
TFYProgressMacOSHUD.showError("网络连接失败")
TFYProgressMacOSHUD.showInfo("请检查网络设置")
```

### 5. 🎪 状态栏项最佳实践

```swift
// 创建状态栏项时提供完整的配置
let config = TFYStatusItem.StatusItemConfiguration(
    image: NSImage(systemSymbolName: "star.fill"),
    viewController: contentViewController,
    windowConfiguration: windowConfig
)

// 处理错误情况
do {
    try TFYStatusItem.shared.configure(with: config)
} catch {
    print("状态栏项配置失败: \(error)")
}
```

### 6. ⚡ 异步任务最佳实践

```swift
// 使用适当的队列
TFYSwiftAsync.async(on: .global(qos: .userInitiated)) {
    // 用户发起的任务
} mainCallback: {
    // 主线程更新 UI
}

// 处理长时间运行的任务
let workItem = TFYSwiftAsync.async {
    // 长时间运行的任务
}
workItem.cancel() // 需要时取消任务
```

---

## 🤝 参与贡献

我们欢迎所有形式的贡献！无论是报告 bug、提出新功能建议，还是提交代码，我们都非常感激。

### 📋 贡献指南

1. **Fork 本项目**
2. **创建特性分支** (`git checkout -b feature/AmazingFeature`)
3. **提交更改** (`git commit -m 'Add some AmazingFeature'`)
4. **推送到分支** (`git push origin feature/AmazingFeature`)
5. **提交 Pull Request**

### 🐛 报告 Bug

如果您发现了 bug，请：

1. 检查 [Issues](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/issues) 是否已经报告
2. 创建新的 Issue，包含：
   - 详细的 bug 描述
   - 复现步骤
   - 期望行为
   - 实际行为
   - 环境信息（macOS 版本、Xcode 版本等）

### 💡 功能建议

如果您有新功能建议，请：

1. 检查 [Issues](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/issues) 是否已经提出
2. 创建新的 Issue，包含：
   - 功能描述
   - 使用场景
   - 预期 API 设计
   - 实现建议

### 📝 代码贡献

如果您想贡献代码，请：

1. 遵循项目的代码风格
2. 添加适当的注释和文档
3. 编写测试用例
4. 确保所有测试通过
5. 更新相关文档

### 🏆 贡献者

感谢所有为这个项目做出贡献的开发者！

[![Contributors](https://contributors-img.web.app/image?repo=13662049573/TFYSwiftMacOSAppKit_Swift)](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/graphs/contributors)

---

## 📄 开源协议

本项目基于 MIT 协议开源，详见 [LICENSE](LICENSE) 文件。

**MIT 协议要点：**
- ✅ 可以自由使用、修改、分发
- ✅ 可以用于商业项目
- ✅ 需要保留版权声明
- ✅ 不承担任何责任

---

## 👨‍💻 作者

**田风有** (田风有) - [420144542@qq.com](mailto:420144542@qq.com)

### 📞 联系方式

- 📧 **邮箱**: 420144542@qq.com
- 🐦 **GitHub**: [@13662049573](https://github.com/13662049573)
- 💬 **QQ 群**: 欢迎加入我们的开发者交流群

### 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

特别感谢：
- Apple 提供的优秀开发平台
- Swift 社区的技术支持
- 所有使用和反馈的用户

---

## 📊 项目统计

<p align="center">
  <img src="https://img.shields.io/github/stars/13662049573/TFYSwiftMacOSAppKit_Swift.svg" alt="GitHub stars">
  <img src="https://img.shields.io/github/forks/13662049573/TFYSwiftMacOSAppKit_Swift.svg" alt="GitHub forks">
  <img src="https://img.shields.io/github/issues/13662049573/TFYSwiftMacOSAppKit_Swift.svg" alt="GitHub issues">
  <img src="https://img.shields.io/github/last-commit/13662049573/TFYSwiftMacOSAppKit_Swift.svg" alt="GitHub last commit">
</p>

---

<p align="center">如果这个项目对你有帮助，请给一个 ⭐️ 支持一下！</p>

<p align="center">
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift">
    <img src="https://img.shields.io/badge/支持-点赞-brightgreen.svg" alt="支持项目">
  </a>
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/issues">
    <img src="https://img.shields.io/badge/反馈-issues-blue.svg" alt="issues">
  </a>
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/pulls">
    <img src="https://img.shields.io/badge/贡献-PR-green.svg" alt="Pull Requests">
  </a>
</p>

---

<div align="center">
  <sub>Built with ❤️ by the TFYSwiftMacOSAppKit team</sub>
</div>
