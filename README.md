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
</p>

<p align="center">🚀 优雅的 macOS 开发工具库 | 链式编程 | 组件化设计 | 高性能</p>

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

## 🌟 功能展示

### 优雅的链式语法

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

### 强大的自定义控件

```swift
// 自定义文本框示例
let customField = TFYSwiftTextField()
customField.chain
    .placeholderString("搜索...")
    .placeholderColor(.gray)
    .textColor(.systemBlue)
    .backgroundColor(.windowBackgroundColor)
    .bordered(false)
    .bezeled(false)
    .isTextAlignmentVerticalCenter(true)
    .delegate_swift(self)

// 事件响应
extension YourViewController: TFYSwiftNotifyingDelegate {
    func textFieldDidChange(textField: NSTextField) {
        // 实时获取输入内容
        print("输入内容：\(textField.stringValue)")
    }
}
```

### 状态栏扩展

```swift
// 快速创建状态栏项
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
statusItem.chain
    .button { button in
        button.chain
            .image(NSImage(named: "icon"))
            .toolTip("状态栏提示")
    }
    .menu { menu in
        menu.chain
            .addItem("设置")
            .addSeparator()
            .addItem("退出")
    }
```

## 📦 模块架构

```
TFYSwiftMacOSAppKit
├── macOSBase          # 核心基础组件
├── macOSfoundation   # Foundation 增强
├── macOScategory     # 实用分类扩展
├── macOScontainer    # 容器组件集合
├── macOSchain        # 链式编程支持
└── macOSHUD          # 界面交互组件
```

## 🚀 快速开始

### 安装

```ruby
# 完整安装
pod 'TFYSwiftMacOSAppKit'

# 按需安装
pod 'TFYSwiftMacOSAppKit/macOSBase'      # 仅安装基础组件
pod 'TFYSwiftMacOSAppKit/macOSchain'     # 仅安装链式编程支持
```

### 导入

```swift
import TFYSwiftMacOSAppKit
```

## 🎯 最佳实践

### 1. UI 控件优化

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

### 2. 手势支持

```swift
view.chain
    .addClickGesture { gesture in
        print("点击事件")
    }
    .addPanGesture { gesture in
        print("拖动事件")
    }
```

### 3. 动画效果

```swift
view.layer?.chain
    .backgroundColor(.systemBlue)
    .cornerRadius(8)
    .masksToBounds(true)
    .addAnimation(duration: 0.3) { 
        // 添加动画效果
    }
```

## 📚 详细文档

访问我们的 [Wiki](https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/wiki) 获取更多信息：

- 完整的 API 文档
- 使用教程和最佳实践
- 示例代码和项目模板
- 常见问题解答

## 🤝 参与贡献

1. Fork 本项目
2. 创建新的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 📄 开源协议

本项目基于 MIT 协议开源，详见 [LICENSE](LICENSE) 文件。

## 👨‍💻 作者

田风有 (420144542@qq.com)

## 💫 致谢

感谢所有为这个项目做出贡献的开发者！

---

<p align="center">如果这个项目对你有帮助，请给一个 ⭐️ 支持一下！</p>

<p align="center">
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift">
    <img src="https://img.shields.io/badge/支持-点赞-brightgreen.svg" alt="支持项目">
  </a>
  <a href="https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift/issues">
    <img src="https://img.shields.io/badge/反馈-issues-blue.svg" alt="issues">
  </a>
</p>
