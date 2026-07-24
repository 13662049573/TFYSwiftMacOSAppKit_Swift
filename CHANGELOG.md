# Changelog

本项目版本号遵循 [Semantic Versioning](https://semver.org/)。

## [1.5.0] - 2026-07-24

### 修复与稳定性

- `Chain.async` 改为在主队列执行，避免后台线程触碰 AppKit
- `TFYSwiftCacheKit`：配置读写加锁、同步 API 防重入死锁、写入失败回滚内存缓存、回调统一回主线程
- `TFYProgressMacOSHUD`：无 `mainWindow` 时回退到 `keyWindow` / 可见窗口，并支持延迟附着
- `TFYStatusItem`：公开入口增加主线程断言
- 网络接口探测优先 `en0`，并补充备用接口回退

### API 调整（兼容保留）

- 缓存「加密」更名为 `enableObfuscation`（XOR 混淆）；`enableEncryption` 保留为 deprecated 别名
- 错误的自定义应用生命周期通知名标记 deprecated，请改用系统 `NSApplication` 通知
- `getNotificationStatistics()` 标记 deprecated（此前返回占位数据）
- 文件重命名：`TFYSwiftAsynce.swift` → `TFYSwiftAsync.swift`（类型名不变）
- `NSDatePicker+Dejal` / `NSStepper+Dejal` 归入 `macOScategory`

### Demo 与工程

- 分类扩展页补充 Menu / Popover / Window / SplitView / CollectionView
- 链式页补充 NSSwitch / NSColorWell / NSProgressIndicator / CAEmitterLayer
- 工具页补充 `TFYNetworkReachability`、`TFYLogger`
- 状态栏 Demo 在销毁时 `reset()`，避免菜单栏残留
- 恢复并完善 `SmokeTests/TFYSwiftMacOSAppKitSmoke`，修复 SPM / CI 路径失效问题

### 分发

- CocoaPods / README / Package 注释统一至 **1.5.0**

## [1.4.5] - 先前版本

参见历史 README「版本说明」条目（1.4.3 及后续补丁）。
