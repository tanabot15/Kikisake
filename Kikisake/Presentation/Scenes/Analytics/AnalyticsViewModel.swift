//
//  AnalyticsViewModel.swift
//  Kikisake
//

import Foundation
import SwiftData

/// 分析画面の表示セクション種類
public enum AnalyticsSection: String, CaseIterable, Identifiable {
    case consumption
    case evaluation
    case comparison

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .consumption: String(localized: "飲酒ログ")
        case .evaluation: String(localized: "評価")
        case .comparison: String(localized: "比較")
        }
    }
}

/// 期間フィルターの種類
public enum AnalyticsTimeFilter: String, CaseIterable, Identifiable {
    case all
    case month1
    case months3
    case year1

    public var id: String { rawValue }

    /// Localizable.xcstrings が自動検出し、英訳を行えるように直接文字列リテラルを指定
    public var displayName: String {
        switch self {
        case .all: String(localized: "全期間")
        case .month1: String(localized: "直近1ヶ月")
        case .months3: String(localized: "直近3ヶ月")
        case .year1: String(localized: "直近1年")
        }
    }

    func evaluate(date: Date, relativeTo referenceDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        switch self {
        case .all:
            return true
        case .month1:
            guard let limitDate = calendar.date(byAdding: .month, value: -1, to: referenceDate) else { return true }
            return date >= limitDate
        case .months3:
            guard let limitDate = calendar.date(byAdding: .month, value: -3, to: referenceDate) else { return true }
            return date >= limitDate
        case .year1:
            guard let limitDate = calendar.date(byAdding: .year, value: -1, to: referenceDate) else { return true }
            return date >= limitDate
        }
    }
}

/// 飲酒日ヒートマップ用データモデル
public struct HeatmapDay: Identifiable {
    public var id: Date { date }
    public var date: Date
    public var count: Int
}

@Observable
public final class AnalyticsViewModel {
    public var selectedSection: AnalyticsSection = .consumption

    // --- 共通・飲酒ログ・評価向けフィルター条件 ---
    public var selectedTimeFilter: AnalyticsTimeFilter = .all
    public var selectedCategoryFilter: BeverageCategory? = nil
    public var selectedSubCategoryFilter: String? = nil
    public var regionFilter: String = ""

    // --- 評価・比較向け追加フィルター条件 ---
    public var minRatingFilter: Double? = nil
    public var aromaTagFilter: String = ""

    // --- 比較タブ用選択状態 ---
    public var comparisonLeftLogID: UUID? = nil
    public var comparisonRightLogID: UUID? = nil

    private let calculateUseCase = CalculateAnalyticsUseCase()

    public init() {}

    public func filteredLogs(from logs: [TastingLog]) -> [TastingLog] {
        logs.filter { log in
            guard selectedTimeFilter.evaluate(date: log.date) else { return false }
            guard matchesCommonFilters(log: log, includeSubCategory: true) else { return false }

            if !aromaTagFilter.isEmpty {
                let hasTag = log.aromaTags.contains { $0.localizedCaseInsensitiveContains(aromaTagFilter) }
                if !hasTag { return false }
            }

            return true
        }
    }

    /// 比較候補として絞り込まれたログ一覧
    public func comparisonCandidateLogs(from logs: [TastingLog]) -> [TastingLog] {
        logs.filter { matchesCommonFilters(log: $0, includeSubCategory: false) }
    }

    public var hasActiveFilters: Bool {
        switch selectedSection {
        case .consumption:
            return selectedTimeFilter != .all ||
                   selectedCategoryFilter != nil ||
                   selectedSubCategoryFilter != nil ||
                   !regionFilter.isEmpty
        case .evaluation:
            return selectedTimeFilter != .all ||
                   selectedCategoryFilter != nil ||
                   selectedSubCategoryFilter != nil ||
                   !regionFilter.isEmpty ||
                   minRatingFilter != nil ||
                   !aromaTagFilter.isEmpty
        case .comparison:
            return selectedCategoryFilter != nil ||
                   !regionFilter.isEmpty ||
                   minRatingFilter != nil
        }
    }

    public func resetFilters() {
        selectedTimeFilter = .all
        selectedCategoryFilter = nil
        selectedSubCategoryFilter = nil
        regionFilter = ""
        minRatingFilter = nil
        aromaTagFilter = ""
    }

    public func availableRegions(from logs: [TastingLog]) -> [String] {
        let regions = logs.compactMap { log -> String? in
            guard let item = log.item else { return nil }
            if let category = selectedCategoryFilter, item.category != category { return nil }
            let trimmed = item.region.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        return Array(Set(regions)).sorted()
    }

    public func availableAromaTags(from logs: [TastingLog]) -> [String] {
        let tags = logs.flatMap { log -> [String] in
            if let category = selectedCategoryFilter, log.item?.category != category {
                return []
            }
            return log.aromaTags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        }
        return Array(Set(tags)).sorted()
    }

    public func availableSubCategories(from logs: [TastingLog]) -> [String] {
        guard let category = selectedCategoryFilter else { return [] }
        var subTypes = Set<String>()

        for log in logs {
            guard let item = log.item, item.category == category,
                  let subCategory = extractSubCategory(from: item, category: category),
                  !subCategory.isEmpty else { continue }
            subTypes.insert(subCategory)
        }
        return Array(subTypes).sorted()
    }

    public func categoryRatio(from logs: [TastingLog]) -> [BeverageCategory: Int] {
        calculateUseCase.calculateCategoryRatio(from: filteredLogs(from: logs))
    }

    public func subCategoryRatio(from logs: [TastingLog]) -> [String: Int] {
        guard let category = selectedCategoryFilter else { return [:] }
        let targetLogs = filteredLogs(from: logs)
        var counts: [String: Int] = [:]

        for log in targetLogs {
            guard let item = log.item, item.category == category else { continue }
            if item.specificMetadataJSON == nil {
                counts["未設定", default: 0] += 1
            } else if let subCategory = extractSubCategory(from: item, category: category), !subCategory.isEmpty {
                counts[subCategory, default: 0] += 1
            } else {
                counts["その他", default: 0] += 1
            }
        }
        return counts
    }

    public func drinkingHeatmapData(from logs: [TastingLog]) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetLogs = filteredLogs(from: logs)

        return (0..<119).reversed().compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            let count = targetLogs.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
            return HeatmapDay(date: date, count: count)
        }
    }

    public func topRatedLog(for category: BeverageCategory, from logs: [TastingLog]) -> TastingLog? {
        filteredLogs(from: logs)
            .filter { $0.item?.category == category }
            .max(by: { $0.rating < $1.rating })
    }

    public func topAromaTags(from logs: [TastingLog], limit: Int = 8) -> [(tag: String, count: Int)] {
        let targetLogs = filteredLogs(from: logs)
        var counts: [String: Int] = [:]
        for log in targetLogs {
            for tag in log.aromaTags {
                counts[tag, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (tag: $0.key, count: $0.value) }
    }

    public func averageTasteProfile(from logs: [TastingLog]) -> AverageTasteProfile {
        calculateUseCase.calculateAverageTasteProfile(from: filteredLogs(from: logs))
    }

    public func featureFlagsSummary(from logs: [TastingLog]) -> (costEffective: Int, repeatIntent: Int, agingPotential: Int, total: Int) {
        let targetLogs = filteredLogs(from: logs)
        let total = targetLogs.count
        guard total > 0 else { return (0, 0, 0, 0) }

        let costEffective = targetLogs.filter(\.isCostEffective).count
        let repeatIntent = targetLogs.filter(\.isWillingToRepeat).count
        let agingPotential = targetLogs.filter(\.hasAgingPotential).count

        return (costEffective, repeatIntent, agingPotential, total)
    }

    public func averageRating(from targetLogs: [TastingLog]) -> Double {
        guard !targetLogs.isEmpty else { return 0.0 }
        let totalRating = targetLogs.reduce(0.0) { $0 + $1.rating }
        return totalRating / Double(targetLogs.count)
    }

    // MARK: - Private Helpers

    private func matchesCommonFilters(log: TastingLog, includeSubCategory: Bool) -> Bool {
        if let category = selectedCategoryFilter {
            guard let item = log.item, item.category == category else { return false }

            if includeSubCategory, let subCategory = selectedSubCategoryFilter {
                guard extractSubCategory(from: item, category: category) == subCategory else { return false }
            }
        }

        if !regionFilter.isEmpty {
            let region = log.item?.region ?? ""
            if !region.localizedCaseInsensitiveContains(regionFilter) { return false }
        }

        if let minRating = minRatingFilter, log.rating < minRating {
            return false
        }

        return true
    }

    private func extractSubCategory(from item: BeverageItem, category: BeverageCategory) -> String? {
        guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else {
            return nil
        }

        switch category {
        case .wine:
            return try? JSONDecoder().decode(WineSpecificMetadata.self, from: data).wineType
        case .sake:
            return try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data).specificName
        case .beer:
            return try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data).beerStyle
        }
    }
}
