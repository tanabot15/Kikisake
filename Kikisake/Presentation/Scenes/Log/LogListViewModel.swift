//
//  LogListViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

/// 飲んだ酒のリスト画面のビジネスロジック・状態管理
@Observable
public final class LogListViewModel {
    public var searchText: String = ""
    public var selectedCategoryFilter: BeverageCategory? = nil
    public var selectedRatingFilter: Double? = nil

    public init() {}

    /// 検索キーワードやフィルター条件に基づいてログをフィルタリングする
    public func filteredLogs(_ logs: [TastingLog]) -> [TastingLog] {
        logs.filter { log in
            let matchesSearch: Bool = {
                if searchText.isEmpty { return true }
                let nameMatch = log.item?.name.localizedCaseInsensitiveContains(searchText) ?? false
                let producerMatch = log.item?.producer.localizedCaseInsensitiveContains(searchText) ?? false
                let memoMatch = log.memo.localizedCaseInsensitiveContains(searchText)
                return nameMatch || producerMatch || memoMatch
            }()

            let matchesCategory: Bool = {
                guard let category = selectedCategoryFilter else { return true }
                return log.item?.category == category
            }()

            let matchesRating: Bool = {
                guard let minRating = selectedRatingFilter else { return true }
                return log.rating >= minRating
            }()

            return matchesSearch && matchesCategory && matchesRating
        }
    }
}
