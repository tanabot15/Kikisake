//
//  LogViewModel.swift
//  Kikisake
//

import Foundation
import SwiftData

public enum LogSortOrder: String, CaseIterable, Codable {
    case dateDescending = "新しい順"
    case dateAscending = "古い順"
    case ratingDescending = "評価が高い順"
    case ratingAscending = "評価が低い順"

    public var displayName: String { rawValue }
}

/// Main tab sections inside LogView.
public enum LogMainSection: String, CaseIterable, Identifiable {
    case list
    case timeline
    case collectionBook

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .list: String(localized: "リスト")
        case .timeline: String(localized: "タイムライン")
        case .collectionBook: String(localized: "図鑑")
        }
    }
}

/// Display style for the log list tab.
public enum ListDisplayStyle: CaseIterable {
    case card
    case compact
}

/// State and filtering logic for tasting logs and collection filters.
@Observable
public final class LogViewModel {
    public var searchText: String = ""
    public var sortOrder: LogSortOrder = .dateDescending

    public var selectedSection: LogMainSection = .list
    public var listDisplayStyle: ListDisplayStyle = .card

    // Collection book filters
    public var collectionCategoryFilter: BeverageCategory? = nil
    public var collectionRegionFilter: String = ""
    public var collectionTargetElementFilter: String = ""

    // Log filters
    public var selectedCategoryFilter: BeverageCategory? = nil
    public var selectedRatingFilter: Double? = nil
    public var producerFilter: String = ""
    public var regionFilter: String = ""
    public var vintageFilter: String = ""
    public var minAbv: Double? = nil
    public var maxPrice: Int? = nil
    public var aromaTagFilter: String = ""
    public var appearanceNoteFilter: String = ""
    public var balanceTagFilter: String = ""
    public var filterCostEffective: Bool? = nil
    public var filterWillingToRepeat: Bool? = nil
    public var filterAgingPotential: Bool? = nil
    public var wineTypeFilter: String = "すべて"
    public var sakeSpecificNameFilter: String = "すべて"
    public var beerStyleFilter: String = ""

    public init() {}

    public func toggleListDisplayStyle() {
        listDisplayStyle = (listDisplayStyle == .card) ? .compact : .card
    }

    public var listDisplayStyleIconName: String {
        listDisplayStyle == .card ? "list.bullet" : "rectangle.grid.1x2"
    }

    public var hasActiveCurrentSectionFilters: Bool {
        switch selectedSection {
        case .list, .timeline:
            hasActiveFilters
        case .collectionBook:
            hasActiveCollectionFilters
        }
    }

    public func resetCurrentSectionFilters() {
        switch selectedSection {
        case .list, .timeline:
            resetFilters()
        case .collectionBook:
            resetCollectionFilters()
        }
    }

    public var hasActiveCollectionFilters: Bool {
        collectionCategoryFilter != nil ||
        !collectionRegionFilter.isEmpty ||
        !collectionTargetElementFilter.isEmpty
    }

    public func resetCollectionFilters() {
        collectionCategoryFilter = nil
        collectionRegionFilter = ""
        collectionTargetElementFilter = ""
    }

    public func filteredLogs(_ logs: [TastingLog]) -> [TastingLog] {
        let filtered = logs.filter { log in
            guard let item = log.item else { return false }
            return matchesSearch(item: item, log: log) &&
                   matchesBasicFilters(item: item, log: log) &&
                   matchesTastingFilters(log: log) &&
                   matchesSpecificMetadata(item: item)
        }

        return filtered.sorted(by: sortComparator)
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
        selectedCategoryFilter = nil
        selectedRatingFilter = nil
        producerFilter = ""
        regionFilter = ""
        vintageFilter = ""
        minAbv = nil
        maxPrice = nil
        aromaTagFilter = ""
        appearanceNoteFilter = ""
        balanceTagFilter = ""
        filterCostEffective = nil
        filterWillingToRepeat = nil
        filterAgingPotential = nil
        wineTypeFilter = "すべて"
        sakeSpecificNameFilter = "すべて"
        beerStyleFilter = ""
        sortOrder = .dateDescending
    }

    // MARK: - Private Helpers

    private func matchesSearch(item: BeverageItem, log: TastingLog) -> Bool {
        guard !searchText.isEmpty else { return true }
        return item.name.localizedCaseInsensitiveContains(searchText) ||
               item.producer.localizedCaseInsensitiveContains(searchText) ||
               log.memo.localizedCaseInsensitiveContains(searchText)
    }

    private func matchesBasicFilters(item: BeverageItem, log: TastingLog) -> Bool {
        if let category = selectedCategoryFilter, item.category != category {
            return false
        }
        if let minRating = selectedRatingFilter, log.rating < minRating {
            return false
        }
        if !producerFilter.isEmpty, !item.producer.localizedCaseInsensitiveContains(producerFilter) {
            return false
        }
        if !regionFilter.isEmpty, !item.region.localizedCaseInsensitiveContains(regionFilter) {
            return false
        }
        if !vintageFilter.isEmpty {
            let vintage = item.vintage ?? ""
            if !vintage.localizedCaseInsensitiveContains(vintageFilter) { return false }
        }
        if let minAbv, (item.alcoholByVolume ?? 0.0) < minAbv {
            return false
        }
        if let maxPrice, (item.price ?? 0) > maxPrice {
            return false
        }
        return true
    }

    private func matchesTastingFilters(log: TastingLog) -> Bool {
        if !aromaTagFilter.isEmpty {
            let hasTag = log.aromaTags.contains { $0.localizedCaseInsensitiveContains(aromaTagFilter) }
            if !hasTag { return false }
        }
        if !appearanceNoteFilter.isEmpty,
           !log.appearanceNotes.localizedCaseInsensitiveContains(appearanceNoteFilter) {
            return false
        }
        if !balanceTagFilter.isEmpty {
            let hasBalanceTag = log.balanceTags.contains { $0.localizedCaseInsensitiveContains(balanceTagFilter) }
            if !hasBalanceTag { return false }
        }
        if filterCostEffective == true, !log.isCostEffective {
            return false
        }
        if filterWillingToRepeat == true, !log.isWillingToRepeat {
            return false
        }
        if filterAgingPotential == true, !log.hasAgingPotential {
            return false
        }
        return true
    }

    private func matchesSpecificMetadata(item: BeverageItem) -> Bool {
        guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else {
            return wineTypeFilter == "すべて" && sakeSpecificNameFilter == "すべて" && beerStyleFilter.isEmpty
        }

        switch item.category {
        case .wine:
            guard wineTypeFilter != "すべて",
                  let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) else {
                return true
            }
            return meta.wineType == wineTypeFilter

        case .sake:
            guard sakeSpecificNameFilter != "すべて",
                  let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) else {
                return true
            }
            return meta.specificName == sakeSpecificNameFilter

        case .beer:
            guard !beerStyleFilter.isEmpty,
                  let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) else {
                return true
            }
            return meta.beerStyle.localizedCaseInsensitiveContains(beerStyleFilter)
        }
    }

    private func sortComparator(_ lhs: TastingLog, _ rhs: TastingLog) -> Bool {
        switch sortOrder {
        case .dateDescending: lhs.date > rhs.date
        case .dateAscending: lhs.date < rhs.date
        case .ratingDescending: lhs.rating > rhs.rating
        case .ratingAscending: lhs.rating < rhs.rating
        }
    }
}
