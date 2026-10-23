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
    // 基本検索 & ソート
    public var searchText: String = ""
    public var sortOrder: LogSortOrder = .dateDescending

    // --- 表示形式の状態管理 ---
    public var isCompactView: Bool = false // ✨ デフォルトはfalse（リッチカード表示）

    // --- 高機能フィルタープロパティ ---
    public var selectedCategoryFilter: BeverageCategory? = nil
    public var selectedRatingFilter: Double? = nil

    // 基本属性フィルター
    public var producerFilter: String = ""
    public var regionFilter: String = ""
    public var vintageFilter: String = ""
    
    // 数値範囲フィルター
    public var minAbv: Double? = nil
    public var maxPrice: Int? = nil

    // テイスティングデータフィルター
    public var aromaTagFilter: String = ""
    public var appearanceNoteFilter: String = ""
    public var balanceTagFilter: String = ""

    // 固有メタデータフィルター
    public var wineTypeFilter: String = "すべて"
    public var sakeSpecificNameFilter: String = "すべて"
    public var beerStyleFilter: String = ""

    public init() {}

    /// すべてのフィルター条件とソートを適用してログを絞り込む
    public func filteredLogs(_ logs: [TastingLog]) -> [TastingLog] {
        let filtered = logs.filter { log in
            guard let item = log.item else { return false }

            // 1. メインキーワード検索 (銘柄名、生産者、メモ)
            if !searchText.isEmpty {
                let nameMatch = item.name.localizedCaseInsensitiveContains(searchText)
                let producerMatch = item.producer.localizedCaseInsensitiveContains(searchText)
                let memoMatch = log.memo.localizedCaseInsensitiveContains(searchText)
                if !nameMatch && !producerMatch && !memoMatch { return false }
            }

            // 2. 酒種 (カテゴリ)
            if let category = selectedCategoryFilter {
                if item.category != category { return false }
            }

            // 3. 評価 (最低スコア)
            if let minRating = selectedRatingFilter {
                if log.rating < minRating { return false }
            }

            // 4. 生産者
            if !producerFilter.isEmpty {
                if !item.producer.localizedCaseInsensitiveContains(producerFilter) { return false }
            }

            // 5. 生産地
            if !regionFilter.isEmpty {
                if !item.region.localizedCaseInsensitiveContains(regionFilter) { return false }
            }

            // 6. ヴィンテージ
            if !vintageFilter.isEmpty {
                let vintage = item.vintage ?? ""
                if !vintage.localizedCaseInsensitiveContains(vintageFilter) { return false }
            }

            // 7. アルコール度数 (最低度数)
            if let minAbv = minAbv {
                let abv = item.alcoholByVolume ?? 0.0
                if abv < minAbv { return false }
            }

            // 8. 価格 (上限価格)
            if let maxPrice = maxPrice {
                let price = item.price ?? 0
                if price > maxPrice { return false }
            }

            // 9. テイスティングデータ (香りタグ、外観、バランス表現)
            if !aromaTagFilter.isEmpty {
                let hasTag = log.aromaTags.contains { $0.localizedCaseInsensitiveContains(aromaTagFilter) }
                if !hasTag { return false }
            }
            if !appearanceNoteFilter.isEmpty {
                if !log.appearanceNotes.localizedCaseInsensitiveContains(appearanceNoteFilter) { return false }
            }
            if !balanceTagFilter.isEmpty {
                let hasBalanceTag = log.balanceTags.contains { $0.localizedCaseInsensitiveContains(balanceTagFilter) }
                if !hasBalanceTag { return false }
            }

            // 10. 酒種固有のメタデータ (JSONデコードによる判定)
            if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                switch item.category {
                case .wine:
                    if wineTypeFilter != "すべて",
                       let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                        if meta.wineType != wineTypeFilter { return false }
                    }
                case .sake:
                    if sakeSpecificNameFilter != "すべて",
                       let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                        if meta.specificName != sakeSpecificNameFilter { return false }
                    }
                case .beer:
                    if !beerStyleFilter.isEmpty,
                       let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                        if !meta.beerStyle.localizedCaseInsensitiveContains(beerStyleFilter) { return false }
                    }
                }
            } else {
                if wineTypeFilter != "すべて" || sakeSpecificNameFilter != "すべて" || !beerStyleFilter.isEmpty {
                    return false
                }
            }

            return true
        }

        // ソート処理
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

    /// デフォルト状態から何等かのフィルター条件が追加されているか
    public var hasActiveFilters: Bool {
        selectedCategoryFilter != nil ||
        selectedRatingFilter != nil ||
        !producerFilter.isEmpty ||
        !regionFilter.isEmpty ||
        !vintageFilter.isEmpty ||
        minAbv != nil ||
        maxPrice != nil ||
        !aromaTagFilter.isEmpty ||
        !appearanceNoteFilter.isEmpty ||
        !balanceTagFilter.isEmpty ||
        wineTypeFilter != "すべて" ||
        sakeSpecificNameFilter != "すべて" ||
        !beerStyleFilter.isEmpty ||
        sortOrder != .dateDescending
    }

    /// すべてのフィルター条件を初期化する
    public func resetFilters() {
        self.selectedCategoryFilter = nil
        self.selectedRatingFilter = nil
        self.producerFilter = ""
        self.regionFilter = ""
        self.vintageFilter = ""
        self.minAbv = nil
        self.maxPrice = nil
        self.aromaTagFilter = ""
        self.appearanceNoteFilter = ""
        self.balanceTagFilter = ""
        self.wineTypeFilter = "すべて"
        self.sakeSpecificNameFilter = "すべて"
        self.beerStyleFilter = ""
        self.sortOrder = .dateDescending
    }
}
