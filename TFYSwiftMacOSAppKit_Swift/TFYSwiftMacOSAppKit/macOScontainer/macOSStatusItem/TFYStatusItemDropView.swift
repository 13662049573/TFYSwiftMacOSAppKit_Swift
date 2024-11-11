//
//  TFYStatusItemDropView.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/7.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

// 定义一个协议，用于处理文件接收的回调
protocol ReadFileViewDelegate: AnyObject {
    // 当接收到单个文件时调用此方法
    func receivedFileUrl(_ fileUrl: URL)

    // 当接收到多个文件时调用此方法
    func receivedFileUrlList(_ fileUrls: [URL])
}

public class TFYStatusItemDropView: NSView {
    // 弱引用代理，遵循ReadFileViewDelegate协议
    weak var delegate: ReadFileViewDelegate?
    // 弱引用状态项
    weak var statusItem: TFYStatusItem?

    // 拖拽处理闭包
    public var dropHandler: TFYStatusItemDropHandler?

    // 私有可拖拽类型数组
    private var privateDropTypes: [NSPasteboard.PasteboardType] = []

    // 可拖拽类型的属性，设置新值时更新注册的拖拽类型，获取时返回私有数组
    public var dropTypes: [NSPasteboard.PasteboardType] {
        set {
            // 设置新的可拖拽类型时，更新私有数组并注册这些类型
            privateDropTypes = newValue
            registerForDraggedTypes(privateDropTypes)
        }
        get {
            return privateDropTypes
        }
    }
    
    // 视图被销毁时调用的方法，取消注册拖放类型
    deinit {
        unregisterDraggedTypes()
    }

    // 当文件被拖动到视图区域时触发此方法，用于确定拖动操作的类型
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard
        let sourceDragMask = sender.draggingSourceOperationMask

        // 检查粘贴板中的数据类型是否为文件URL类型
        if pboard.types?.contains(.fileURL) == true {
            // 如果源拖动掩码包含链接操作类型，则返回链接拖动操作类型
            if sourceDragMask.contains(.link) {
                return.link
            // 如果源拖动掩码包含复制操作类型，则返回复制拖动操作类型
            } else if sourceDragMask.contains(.copy) {
                return.copy
            }
        }
        // 如果不满足上述条件，返回无操作类型
        return .private
    }

    public override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let zPasteboard = sender.draggingPasteboard

        // 判断粘贴板中的项目数量是否小于等于1，即是否为单文件
        if zPasteboard.pasteboardItems?.count ?? 0 <= 1 {
            if let urlData = zPasteboard.data(forType:.fileURL) {
                var bookmarkDataIsStaleValue = false
                do {
                    let url = try URL(resolvingBookmarkData: urlData, options: [], relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStaleValue)
                    // 如果有代理并且成功获取到文件URL，则调用代理的receivedFileUrl方法传递单文件URL
                    if let delegate = self.delegate {
                        delegate.receivedFileUrl(url)
                        if dropHandler != nil {
                            dropHandler!(statusItem!,.fileURL,[url])
                        }
                    }
                } catch {
                    // 在这里可以添加对异常的处理逻辑，比如打印错误信息等
                    print("解析URL时出错: \(error)")
                }
            }
        } else {
            // 多文件情况
            if let list = zPasteboard.propertyList(forType:.string) as? [String] {
                var urlList: [URL] = []
                for str in list {
                    var maybeUrl: URL?
                    maybeUrl = URL(fileURLWithPath: str)
                    if let url = maybeUrl {
                        urlList.append(url)
                    }
                }
                // 如果获取到了文件URL列表并且有代理，则调用代理的receivedFileUrlList方法传递文件URL列表
                if urlList.count > 0, let delegate = self.delegate {
                    delegate.receivedFileUrlList(urlList)
                    if dropHandler != nil {
                        dropHandler!(statusItem!,.fileURL,urlList)
                    }
                }
            }
        }
        // 返回表示操作成功的布尔值
        return true
    }
}
