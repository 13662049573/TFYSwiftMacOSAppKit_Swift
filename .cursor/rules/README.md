# Swift 通用 Cursor 规则说明

本目录包含适用于 **所有 Swift 语言项目**（iOS / macOS / watchOS / tvOS）的 Cursor 项目规则，遵循 [Cursor 官方规则文档](https://cursor.com/docs/context/rules) 与 [插件构建说明](https://cursor.com/docs/plugins/building)。

## 规则列表

| 文件 | 应用方式 | 说明 |
|------|----------|------|
| `swift-project-context.mdc` | **始终应用** | Swift 项目通用角色、技术栈与原则 |
| `swift-language-style.mdc` | 打开 `**/*.swift` 时 | 命名、类型、可选值、错误处理、协议与泛型 |
| `swift-memory-concurrency.mdc` | 打开 `**/*.swift` 时 | 内存、循环引用、Sendable、MainActor、async/await |
| `swift-ui-frameworks.mdc` | 打开 `**/*.swift` 时 | SwiftUI、UIKit、AppKit 模式与互操作 |
| `swift-apple-platforms.mdc` | 打开 `**/*.swift` 时 | 生命周期、HIG、适配、可访问性、持久化 |
| `swift-apis-testing.mdc` | 打开 `**/*.swift` 时 | API 设计、依赖注入、文档与可测试性 |
| `swift-xcode-spm.mdc` | 打开 `**/*.swift` 时 | Xcode/SPM 项目结构、Target、构建 |

## 在本项目中的使用

- 规则已放在 `.cursor/rules/`，Cursor 会自动识别。
- **始终应用**：仅 `swift-project-context.mdc`，其余按描述或 `**/*.swift` 在相关对话中生效。
- 在 Cursor 中可通过 **Settings → Rules, Commands** 查看、启用或禁用各规则。

## 在其他 Swift 项目中使用（通用项目）

1. **远程规则（推荐）**  
   - 打开 Cursor **Settings → Rules** → Project Rules → **+ Add Rule** → **Remote Rule (GitHub)**。  
   - 填入本仓库的 GitHub 地址，选择同步后即可在任意 Swift 项目中复用这套规则。

2. **复制到新项目**  
   - 将本仓库的 `.cursor/rules/` 目录（含所有 `.mdc` 文件）复制到你的项目根目录下的 `.cursor/rules/`，提交到版本库即可团队共用。

3. **按需裁剪**  
   - 若项目仅用 SwiftUI 或仅用 UIKit，可保留 `swift-project-context.mdc` 与需要的几条，删除或关闭不相关的规则文件。

## 参考

- [Cursor Rules 文档](https://cursor.com/docs/context/rules)
- [Cursor 插件构建](https://cursor.com/docs/plugins/building)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Swift 官方文档](https://docs.swift.org/swift-book/)
