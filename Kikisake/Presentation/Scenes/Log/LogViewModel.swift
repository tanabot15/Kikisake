//  LogViewModel.swift
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

/// LogView内のメインセクション（タブ）
public enum LogMainSection: String, CaseIterable, Identifiable {
    case list
    case timeline
    case collectionBook

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .list: return String(localized: "リスト")
        case .timeline: return String(localized: "タイムライン")
        case .collectionBook: return String(localized: "図鑑")
        }
    }
}

/// リスト表示内のスタイル（カード / コンパクト）
public enum ListDisplayStyle: CaseIterable {
    case card       // リッチカード表示
    case compact    // コンパクトリスト表示
}

/// 飲んだ酒のリスト画面のビジネスロジック・状態管理
@Observable
public final class LogViewModel {
    // 基本検索 & ソート
    public var searchText: String = ""
    public var sortOrder: LogSortOrder = .dateDescending

    // --- メインセクション & リストスタイル状態管理 ---
    public var selectedSection: LogMainSection = .list
    public var listDisplayStyle: ListDisplayStyle = .card

    // --- 図鑑専用シンプルフィルター（category / region / targetElement） ---
    public var collectionCategoryFilter: BeverageCategory? = nil
    public var collectionRegionFilter: String = ""
    public var collectionTargetElementFilter: String = ""

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

    // フラグフィルター
    public var filterCostEffective: Bool? = nil
    public var filterWillingToRepeat: Bool? = nil
    public var filterAgingPotential: Bool? = nil

    // 固有メタデータフィルター
    public var wineTypeFilter: String = "すべて"
    public var sakeSpecificNameFilter: String = "すべて"
    public var beerStyleFilter: String = ""

    public init() {}

    /// リスト表示スタイルをカードとコンパクト間で切り替える
    public func toggleListDisplayStyle() {
        listDisplayStyle = (listDisplayStyle == .card) ? .compact : .card
    }

    /// 現在のリストスタイルに応じたアイコン名を返す
    public var listDisplayStyleIconName: String {
        listDisplayStyle == .card ? "list.bullet" : "rectangle.grid.1x2"
    }

    /// 現在のセクションに応じたフィルター有効状態
    public var hasActiveCurrentSectionFilters: Bool {
        switch selectedSection {
        case .list, .timeline:
            return hasActiveFilters
        case .collectionBook:
            return hasActiveCollectionFilters
        }
    }

    /// 現在のセクションに応じたフィルターリセット
    public func resetCurrentSectionFilters() {
        switch selectedSection {
        case .list, .timeline:
            resetFilters()
        case .collectionBook:
            resetCollectionFilters()
        }
    }

    /// 図鑑フィルターが有効かどうか
    public var hasActiveCollectionFilters: Bool {
        collectionCategoryFilter != nil ||
        !collectionRegionFilter.isEmpty ||
        !collectionTargetElementFilter.isEmpty
    }

    /// 図鑑フィルターをリセットする
    public func resetCollectionFilters() {
        collectionCategoryFilter = nil
        collectionRegionFilter = ""
        collectionTargetElementFilter = ""
    }

    /// すべてのフィルター条件とソートを適用してログを絞り込む
    public func filteredLogs(_ logs: [TastingLog]) -> [TastingLog] {
        let filtered = logs.filter { log in
            guard let item = log.item else { return false }

            if !searchText.isEmpty {
                let nameMatch = item.name.localizedCaseInsensitiveContains(searchText)
                let producerMatch = item.producer.localizedCaseInsensitiveContains(searchText)
                let memoMatch = log.memo.localizedCaseInsensitiveContains(searchText)
                if !nameMatch && !producerMatch && !memoMatch { return false }
            }

            if let category = selectedCategoryFilter {
                if item.category != category { return false }
            }

            if let minRating = selectedRatingFilter {
                if log.rating < minRating { return false }
            }

            if !producerFilter.isEmpty {
                if !item.producer.localizedCaseInsensitiveContains(producerFilter) { return false }
            }

            if !regionFilter.isEmpty {
                if !item.region.localizedCaseInsensitiveContains(regionFilter) { return false }
            }

            if !vintageFilter.isEmpty {
                let vintage = item.vintage ?? ""
                if !vintage.localizedCaseInsensitiveContains(vintageFilter) { return false }
            }

            if let minAbv = minAbv {
                let abv = item.alcoholByVolume ?? 0.0
                if abv < minAbv { return false }
            }

            if let maxPrice = maxPrice {
                let price = item.price ?? 0
                if price > maxPrice { return false }
            }

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

            if let costEffective = filterCostEffective, costEffective, !log.isCostEffective {
                return false
            }
            if let repeatFlag = filterWillingToRepeat, repeatFlag, !log.isWillingToRepeat {
                return false
            }
            if let aging = filterAgingPotential, aging, !log.hasAgingPotential {
                return false
            }

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
        filterCostEffective == true ||
        filterWillingToRepeat == true ||
        filterAgingPotential == true ||
        wineTypeFilter != "すべて" ||
        sakeSpecificNameFilter != "すべて" ||
        !beerStyleFilter.isEmpty ||
        sortOrder != .dateDescending
    }

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
        self.filterCostEffective = nil
        self.filterWillingToRepeat = nil
        self.filterAgingPotential = nil
        self.wineTypeFilter = "すべて"
        self.sakeSpecificNameFilter = "すべて"
        self.beerStyleFilter = ""
        self.sortOrder = .dateDescending
    }
}
