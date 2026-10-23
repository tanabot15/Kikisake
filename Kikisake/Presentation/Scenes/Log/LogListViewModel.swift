//  LogListViewModel.swift
//  Kikisake

import Foundation
import SwiftData

public enum LogSortOrder: String, CaseIterable, Codable {
    case dateDescending = "新しい順"
    case dateAscending = "古い順"
    case ratingDescending = "評価が高い順"
    case ratingAscending = "評価が低い順"

    public var displayName: String { rawValue }
}

/// 飲んだ酒のリスト画面のビジネスロジック・状態管理
@Observable
public final class LogListViewModel {
    public var searchText: String = ""
    public var selectedCategoryFilter: BeverageCategory? = nil
    public var selectedRatingFilter: Double? = nil
    public var sortOrder: LogSortOrder = .dateDescending

    public init() {}

    /// 検索キーワードやフィルター条件に基づいてログをフィルタリングし、ソートを適用する
    public func filteredLogs(_ logs: [TastingLog]) -> [TastingLog] {
        let filtered = logs.filter { log in
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

        return filtered.sorted { log1, log2 in
            switch sortOrder {
            case .dateDescending:
                return log1.date > log2.date
            case .dateAscending:
                return log1.date < log2.date
            case .ratingDescending:
                return log1.rating > log2.rating
            case .ratingAscending:
                return log1.rating < log2.rating
            }
        }
    }

    /// すべてのフィルター条件を初期化する
    public func resetFilters() {
        self.selectedCategoryFilter = nil
        self.selectedRatingFilter = nil
        self.sortOrder = .dateDescending
    }
}
