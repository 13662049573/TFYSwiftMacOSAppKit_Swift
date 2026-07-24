# TFYSwiftMacOSAppKit

<p align="center">
  <a href="https://cocoapods.org/pods/TFYSwiftMacOSAppKit">
    <img src="https://img.shields.io/cocoapods/v/TFYSwiftMacOSAppKit.svg?style=flat" alt="CocoaPods Version">
  </a>
  <a href="https://cocoapods.org/pods/TFYSwiftMacOSAppKit">
    <img src="https://img.shields.io/cocoapods/p/TFYSwiftMacOSAppKit.svg?style=flat" alt="Platform">
  </a>
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/actions/workflows/macos-build.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/13662049573/TFYSwiftMacOSAppKit_Swift/macos-build.yml?branch=main" alt="CI">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/13662049573/TFYSwiftMacOSAppKit_Swift" alt="License">
  </a>
</p>

<p align="center">
  面向 macOS AppKit 的 Swift 工具库，提供链式编程、自定义控件、分类扩展、HUD、状态栏容器和常用工具能力。
</p>

当前版本：**1.5.0**（详见 [CHANGELOG.md](CHANGELOG.md)）

## 特性概览

- 链式编程：覆盖 `NSView`、`NSButton`、`NSTextField`、`CALayer`、手势识别器及 `NSSwitch` / `NSColorWell` / `NSProgressIndicator` 等。
- 自定义控件：内置 `TFYSwiftTextField`、`TFYSwiftSecureTextField`、`TFYSwiftButton`、`TFYSwiftLabel`、`TFYSwiftTextFieldView`。
- 分类扩展：为 `NSView`、`NSTextField`、`NSTextView`、`NSControl`、`NSImage`、`NSMenu`、`NSPopover`、`NSWindow`、`NSSplitView`、`NSCollectionView`、`NotificationCenter` 等补充高频 API。
- 状态栏能力：提供完整的 `NSStatusItem` + 弹窗窗口解决方案。
- HUD 系统：支持文本、加载、进度、成功、错误、信息、自定义图片与主题动画；无主窗时自动回退附着。
- 工具组件：缓存（压缩 / XOR 混淆）、JSON、GCD、计时器、文件选择面板、网络可达性、日志与加密工具，以及图片拼接能力。
- 双分发支持：同时支持 CocoaPods 和 Swift Package Manager。
- 完整 Demo：工程内置演示 App，覆盖主要功能模块。

## 运行 Demo

仓库内已经提供完整 demo 工程，默认启动后会直接进入主演示窗口，不再自动占用系统状态栏。

1. 打开 [TFYSwiftMacOSAppKit_Swift.xcodeproj](TFYSwiftMacOSAppKit_Swift.xcodeproj)
2. 运行 `TFYSwiftMacOSAppKit_Swift` scheme
3. 在 Demo 中依次查看这些页面：

- `概览`：模块总览与接入入口说明
- `组件控件`：`TFYSwiftButton`、`TFYSwiftTextField`、`TFYSwiftSecureTextField`、`TFYSwiftLabel`、`TFYSwiftTextFieldView`、图片处理与二维码
- `链式调用`：控件、图层、手势、毛玻璃 / Stack、`NSSwitch` / `NSColorWell` / `NSProgressIndicator`、`CAEmitterLayer`、Concurrency / Observable
- `分类扩展`：`NSView` / `NSControl` / `NSTextField` / `NSTextView`，以及 Menu / Popover / Window / SplitView / CollectionView
- `工具类`：网络信息、可达性、Logger、缓存、JSON、定时器、GCD、Async、Once、文件读写、OpenPanel、加密、防抖/节流、倒计时、图片拼接
- `打开/保存`：`TFYSwiftOpenPanel` 全能力矩阵
- `HUD`：主题、位置、动画、进度、不同 HUD 模式，以及 `TFYProgressView` 直接调节预览
- `富文本控件`：`NSControl+Dejal` 与常用控件扩展
- `状态栏`：图片模式 / 自定义视图模式、过渡动画、拖拽检测、pinned、弹窗显示

当前 demo 中新增和重构的页面，容器与主要控件创建都统一使用 `TFYSwiftMacOSAppKit` 自身的链式点语法，便于直接对照库能力学习和接入。

主要 demo 源码位于 [Demo](TFYSwiftMacOSAppKit_Swift/Demo)。

## 安装

### CocoaPods

```ruby
platform :osx, '13.5'
use_frameworks!

target 'YourApp' do
  pod 'TFYSwiftMacOSAppKit', '1.5.0'
end
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift.git", from: "1.5.0")
]
```

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: ["TFYSwiftMacOSAppKit"]
    )
]
```

> SPM 版本以 git tag 为准，请在发布后打上 `1.5.0` 标签。

## 模块结构

- `macOSBase`：链式编程基础协议与通用能力
- `macOSfoundation`：`Array`、`NSString`、`Timer`、`NotificationCenter`、`NSColor` 等扩展
- `macOScategory`：`NSView`、`NSTextField`、`NSControl`、`NSImage`、`NSPopover`、`NSDatePicker`、`NSStepper` 等分类增强
- `macOScontainer/macOSUtils`：缓存、JSON、GCD、定时器、网络工具、文件面板、自定义控件、图片拼接
- `macOScontainer/macOSStatusItem`：状态栏按钮、窗口、容器视图与配置
- `macOSchain`：AppKit 控件、图层、手势识别器的链式 API
- `macOSHUD`：HUD 主体、动画、主题、布局、进度控件

## 使用示例

### 链式调用

```swift
import Cocoa
import TFYSwiftMacOSAppKit

let button = NSButton().chain
    .title("立即执行")
    .font(.systemFont(ofSize: 14, weight: .semibold))
    .textColor(.white)
    .backgroundColor(.systemBlue)
    .bordered(false)
    .frame(NSRect(x: 20, y: 20, width: 120, height: 36))
    .build
```

### 容器创建

```swift
let cardView = NSView().chain
    .wantsLayer(true)
    .backgroundColor(.windowBackgroundColor)
    .cornerRadius(18)
    .translatesAutoresizingMaskIntoConstraints(false)
    .build
```

### 自定义文本框

```swift
let textField = TFYSwiftTextField().chain
    .frame(NSRect(x: 20, y: 20, width: 240, height: 36))
    .placeholderString("请输入内容")
    .placeholderColor(.systemOrange)
    .maxLength(12)
    .focusEffect(true)
    .textChangeHandler { text in
        print("输入变化:", text)
    }
    .build
```

### 密码容器控件

```swift
let passwordField = TFYSwiftTextFieldView().chain
    .frame(NSRect(x: 20, y: 20, width: 260, height: 40))
    .placeholderString("请输入密钥")
    .fieldTextColor(.labelColor)
    .passwordVisible(false)
    .textChangeHandler { text in
        print("密码长度:", text.count)
    }
    .build
```

### NSTextView 扩展桥接

```swift
let textView = NSTextView().chain
    .font(.systemFont(ofSize: 13))
    .wraps(true)
    .lineSpacing(3)
    .string("点击 HUD 关键词")
    .clickableTexts(["HUD": "Progress HUD"]) { key, value, _ in
        print(key, value)
    }
    .build
```

### HUD

```swift
TFYProgressMacOSHUD.showSuccess("保存成功")
TFYProgressMacOSHUD.showError("请求失败")
TFYProgressMacOSHUD.showLoading("正在加载...")
TFYProgressMacOSHUD.showProgress(0.65, status: "处理中")
```

### 缓存

```swift
var config = TFYCacheConfig.default()
config.enableObfuscation = false // XOR 混淆（非安全加密）；旧名 enableEncryption 已 deprecated
_ = TFYSwiftCacheKit.shared.updateConfig(config)

TFYSwiftCacheKit.shared.setCache("hello", forKey: "greeting") { result in
    print(result)
}

TFYSwiftCacheKit.shared.getCache(String.self, forKey: "greeting") { result in
    print(result)
}
```

### Async 与 Once

```swift
TFYSwiftAsync.async(on: .global()) {
    print("后台任务")
} mainCallback: {
    print("回到主线程")
}

DispatchQueue.once(token: "com.tfy.demo.once") {
    print("这个 block 只执行一次")
}
```

### JSON

```swift
struct User: Codable {
    let id: Int
    let name: String
}

let json = try TFYSwiftJsonUtils.toJson(User(id: 1, name: "TFY"))
let user = try TFYSwiftJsonUtils.toModel(User.self, from: json)
print(json, user)
```

### 状态栏项

```swift
let contentViewController = NSViewController()
contentViewController.preferredContentSize = NSSize(width: 240, height: 160)

let configuration = TFYStatusItemWindowConfiguration.defaultConfiguration()
configuration.setPresentationTransition(.fade)

try TFYStatusItem.shared.configure(with: .init(
    image: NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil),
    viewController: contentViewController,
    windowConfiguration: configuration
))

TFYStatusItem.shared.showStatusItemWindow()
```

## 本地验证

仓库已经补齐 SwiftPM smoke 测试和 GitHub Actions。你可以直接运行：

```bash
swift build
swift run TFYSwiftMacOSAppKitSmoke
xcodebuild \
  -project TFYSwiftMacOSAppKit_Swift.xcodeproj \
  -scheme TFYSwiftMacOSAppKit_Swift \
  -destination 'platform=macOS' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

CI 配置文件位于 [.github/workflows/macos-build.yml](.github/workflows/macos-build.yml)。

## 版本说明

完整变更记录见 [CHANGELOG.md](CHANGELOG.md)。

### 1.5.0（当前）

- 线程安全与正确性：`Chain.async` 主队列化、CacheKit 加锁 / 防死锁、HUD 窗口回退附着、StatusItem 主线程断言
- API 诚实化：缓存混淆改名、废弃假生命周期通知名；`TFYSwiftAsync` 文件名修正
- Demo 扩面：Menu / Popover / Window / Split / Collection、Switch / ColorWell / Progress / Emitter、Reachability / Logger
- SmokeTests 路径修复，SPM / CI 可再次跑通

### 1.4.x（摘要）

- 缓存、定时器、状态栏、手势、图片与文本扩展稳定性增强
- `TFYSwiftGCD.syncInMainQueue` 主线程安全、`TFYSwiftTextFieldView` API 补齐
- 补齐 SwiftPM、SmokeTests、GitHub Actions 与 Demo 链式风格统一

## 系统要求

- macOS 13.5+
- Swift 5.0+
- Xcode 15+ 推荐

## 发布检查清单

1. 确认 `TFYSwiftMacOSAppKit.podspec`、`README.md`、`Package.swift` 注释、`MainDemoViewController.releaseVersion` 均为同一版本
2. `swift build` && `swift run TFYSwiftMacOSAppKitSmoke` && Demo scheme 构建通过
3. `git tag 1.5.0 && git push origin 1.5.0`
4. `pod trunk push TFYSwiftMacOSAppKit.podspec`（如需 CocoaPods 上架）

## License

MIT
