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

## 特性概览

- 链式编程：覆盖 `NSView`、`NSButton`、`NSTextField`、`CALayer`、手势识别器等常见 AppKit 对象。
- 自定义控件：内置 `TFYSwiftTextField`、`TFYSwiftSecureTextField`、`TFYSwiftButton`、`TFYSwiftLabel`。
- 分类扩展：为 `NSView`、`NSTextField`、`NSControl`、`NSImage`、`NotificationCenter` 等补充高频 API。
- 状态栏能力：提供完整的 `NSStatusItem` + 弹窗窗口解决方案。
- HUD 系统：支持文本、加载、进度、成功、错误、信息、自定义图片与主题动画。
- 工具组件：缓存、JSON、GCD、计时器、文件选择面板、网络与加密工具。
- 双分发支持：同时支持 CocoaPods 和 Swift Package Manager。
- 完整 Demo：工程内置演示 App，覆盖主要功能模块。

## 运行 Demo

仓库内已经提供完整 demo 工程，默认启动后会直接进入主演示窗口，不再自动占用系统状态栏。

1. 打开 [TFYSwiftMacOSAppKit_Swift.xcodeproj](/Users/tianfengyou/Desktop/github/TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit_Swift.xcodeproj)
2. 运行 `TFYSwiftMacOSAppKit_Swift` scheme
3. 在 Demo 中依次查看这些页面：

- `概览`：模块总览与接入入口说明
- `组件控件`：`TFYSwiftButton`、`TFYSwiftTextField`、`TFYSwiftSecureTextField`、`TFYSwiftLabel`、图片处理与二维码
- `链式调用`：控件、图层、手势的链式 API
- `分类扩展`：`NSView+Dejal`、`NSControl+Dejal`、`NSTextField+Dejal`、`NotificationCenter+Dejal`
- `工具类`：网络信息、缓存、JSON、定时器、GCD、文件读写、OpenPanel、加密、防抖/节流、倒计时
- `HUD`：主题、位置、动画、进度、不同 HUD 模式
- `状态栏`：图片模式 / 自定义视图模式、过渡动画、拖拽检测、pinned、弹窗显示

主要 demo 源码位于 [Demo](/Users/tianfengyou/Desktop/github/TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit_Swift/Demo)。

## 安装

### CocoaPods

```ruby
platform :osx, '12.4'
use_frameworks!

target 'YourApp' do
  pod 'TFYSwiftMacOSAppKit', '1.3.0'
end
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift.git", from: "1.3.0")
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

## 模块结构

- `macOSBase`：链式编程基础协议与通用能力
- `macOSfoundation`：`Array`、`NSString`、`Timer`、`NotificationCenter`、`NSColor` 等扩展
- `macOScategory`：`NSView`、`NSTextField`、`NSControl`、`NSImage`、`NSPopover` 等分类增强
- `macOScontainer/macOSUtils`：缓存、JSON、GCD、定时器、网络工具、文件面板、自定义控件
- `macOScontainer/macOSStatusItem`：状态栏按钮、窗口、容器视图与配置
- `macOSchain`：AppKit 控件、图层、手势识别器的链式 API
- `macOSHUD`：HUD 主体、动画、主题、布局、进度控件

## 使用示例

### 链式调用

```swift
import Cocoa
import TFYSwiftMacOSAppKit

let button = NSButton()
button.chain
    .title("立即执行")
    .font(.systemFont(ofSize: 14, weight: .semibold))
    .textColor(.white)
    .backgroundColor(.systemBlue)
    .bordered(false)
    .frame(NSRect(x: 20, y: 20, width: 120, height: 36))
```

### 自定义文本框

```swift
let textField = TFYSwiftTextField(frame: NSRect(x: 20, y: 20, width: 240, height: 36))
textField.placeholderString = "请输入内容"
textField.placeholderColor = .systemOrange
textField.setMaxLength(12)
textField.addFocusEffect()
textField.setTextChangeHandler { text in
    print("输入变化:", text)
}
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
TFYSwiftCacheKit.shared.setCache("hello", forKey: "greeting") { result in
    print(result)
}

TFYSwiftCacheKit.shared.getCache(String.self, forKey: "greeting") { result in
    print(result)
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
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project TFYSwiftMacOSAppKit_Swift.xcodeproj \
  -scheme TFYSwiftMacOSAppKit_Swift \
  -sdk macosx \
  -configuration Debug \
  build CODE_SIGNING_ALLOWED=NO
```

CI 配置文件位于 [macos-build.yml](/Users/tianfengyou/Desktop/github/TFYSwiftMacOSAppKit_Swift/.github/workflows/macos-build.yml)。

## 版本说明

`1.3.0` 版本重点包含：

- 核心库稳定性增强，修复缓存、定时器、状态栏、文本扩展中的多个隐性问题
- 补齐 SwiftPM、SmokeTests、GitHub Actions
- 升级内置 Demo，覆盖更多真实使用场景
- 更新 README 与安装说明，统一 CocoaPods / SwiftPM / Demo 入口

## 系统要求

- macOS 12.4+
- Swift 5.0+
- Xcode 15+ 推荐

## License

MIT
