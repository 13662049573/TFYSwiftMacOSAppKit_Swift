//
//  NSSearchField+Dejal.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by admin on 4/17/26.
//  Copyright © 2026 TFYSwift. All rights reserved.
//

import Cocoa

@MainActor public extension NSSearchField {
    /// 当前搜索内容去除空白后的值
    var trimmedSearchText: String {
        stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 清空搜索内容
    func clearSearch() {
        stringValue = ""
    }

    /// 设置最近搜索记录
    /// - Parameter searches: 搜索记录数组
    func setRecentSearches(_ searches: [String]) {
        recentSearches = searches
    }

    /// 设置最近搜索记录数量上限
    /// - Parameter limit: 最大记录数
    func limitRecentSearches(to limit: Int) {
        guard limit >= 0 else { return }
        if recentSearches.count > limit {
            recentSearches = Array(recentSearches.prefix(limit))
        }
        maximumRecents = limit
    }

    /// 添加一条搜索记录（自动去重并保持上限）
    /// - Parameter text: 搜索文本
    func addRecentSearch(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        var searches = recentSearches
        searches.removeAll { $0 == text }
        searches.insert(text, at: 0)
        if maximumRecents > 0, searches.count > maximumRecents {
            searches = Array(searches.prefix(maximumRecents))
        }
        recentSearches = searches
    }
}
