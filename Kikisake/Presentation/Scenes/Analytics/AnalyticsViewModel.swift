//  AnalyticsViewModel.swift
//  Kikisake

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
        case .consumption:
            return String(localized: "飲酒ログ")
        case .evaluation:
            return String(localized: "評価")
        case .comparison:
            return String(localized: "比較")
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

    /// ✨ Localizable.xcstrings が自動検出し、英訳を行えるように直接文字列リテラルを指定
    public var displayName: String {
        switch self {
        case .all:
            return String(localized: "全期間")
        case .month1:
            return String(localized: "直近1ヶ月")
        case .months3:
            return String(localized: "直近3ヶ月")
        case .year1:
            return String(localized: "直近1年")
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

            if let category = selectedCategoryFilter {
                guard let item = log.item, item.category == category else { return false }

                if let subCategory = selectedSubCategoryFilter {
                    guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else { return false }

                    switch category {
                    case .wine:
                        guard let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data),
                              meta.wineType == subCategory else { return false }
                    case .sake:
                        guard let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data),
                              meta.specificName == subCategory else { return false }
                    case .beer:
                        guard let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data),
                              meta.beerStyle == subCategory else { return false }
                    }
                }
            }

            if !regionFilter.isEmpty {
                let region = log.item?.region ?? ""
                if !region.localizedCaseInsensitiveContains(regionFilter) { return false }
            }

            if let minRating = minRatingFilter {
                if log.rating < minRating { return false }
            }

            if !aromaTagFilter.isEmpty {
                let hasTag = log.aromaTags.contains { $0.localizedCaseInsensitiveContains(aromaTagFilter) }
                if !hasTag { return false }
            }

            return true
        }
    }

    /// 比較候補として絞り込まれたログ一覧
    public func comparisonCandidateLogs(from logs: [TastingLog]) -> [TastingLog] {
        logs.filter { log in
            if let category = selectedCategoryFilter {
                guard let item = log.item, item.category == category else { return false }
            }
            if !regionFilter.isEmpty {
                let region = log.item?.region ?? ""
                if !region.localizedCaseInsensitiveContains(regionFilter) { return false }
            }
            if let minRating = minRatingFilter {
                if log.rating < minRating { return false }
            }
            return true
        }
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
        self.selectedTimeFilter = .all
        self.selectedCategoryFilter = nil
        self.selectedSubCategoryFilter = nil
        self.regionFilter = ""
        self.minRatingFilter = nil
        self.aromaTagFilter = ""
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
            guard let item = log.item,
                  item.category == category,
                  let json = item.specificMetadataJSON,
                  let data = json.data(using: .utf8) else { continue }

            switch category {
            case .wine:
                if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data), !meta.wineType.isEmpty {
                    subTypes.insert(meta.wineType)
                }
            case .sake:
                if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data), !meta.specificName.isEmpty {
                    subTypes.insert(meta.specificName)
                }
            case .beer:
                if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data), !meta.beerStyle.isEmpty {
                    subTypes.insert(meta.beerStyle)
                }
            }
        }
        return Array(subTypes).sorted()
    }

    public func categoryRatio(from logs: [TastingLog]) -> [BeverageCategory: Int] {
        let targetLogs = filteredLogs(from: logs)
        return calculateUseCase.calculateCategoryRatio(from: targetLogs)
    }

    public func subCategoryRatio(from logs: [TastingLog]) -> [String: Int] {
        guard let category = selectedCategoryFilter else { return [:] }
        let targetLogs = filteredLogs(from: logs)
        var counts: [String: Int] = [:]

        for log in targetLogs {
            guard let item = log.item, item.category == category else { continue }
            guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else {
                counts["未設定", default: 0] += 1
                continue
            }

            switch category {
            case .wine:
                if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data), !meta.wineType.isEmpty {
                    counts[meta.wineType, default: 0] += 1
                } else {
                    counts["その他", default: 0] += 1
                }
            case .sake:
                if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data), !meta.specificName.isEmpty {
                    counts[meta.specificName, default: 0] += 1
                } else {
                    counts["その他", default: 0] += 1
                }
            case .beer:
                if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data), !meta.beerStyle.isEmpty {
                    counts[meta.beerStyle, default: 0] += 1
                } else {
                    counts["その他", default: 0] += 1
                }
            }
        }
        return counts
    }

    public func drinkingHeatmapData(from logs: [TastingLog]) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetLogs = filteredLogs(from: logs)

        var days: [HeatmapDay] = []
        for dayOffset in (0..<119).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let count = targetLogs.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
                days.append(HeatmapDay(date: date, count: count))
            }
        }
        return days
    }

    public func topRatedLog(for category: BeverageCategory, from logs: [TastingLog]) -> TastingLog? {
        let targetLogs = filteredLogs(from: logs)
        return targetLogs
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

    public func averageTasteProfile(from logs: [TastingLog]) -> (sweetness: Double, saltiness: Double, acidity: Double, bitterness: Double, umami: Double, tannin: Double, body: Double, finishLength: Double) {
        let targetLogs = filteredLogs(from: logs)
        return calculateUseCase.calculateAverageTasteProfile(from: targetLogs)
    }

    public func featureFlagsSummary(from logs: [TastingLog]) -> (costEffective: Int, repeatIntent: Int, agingPotential: Int, total: Int) {
        let targetLogs = filteredLogs(from: logs)
        let total = targetLogs.count
        guard total > 0 else { return (0, 0, 0, 0) }

        let costEffective = targetLogs.filter { $0.isCostEffective }.count
        let repeatIntent = targetLogs.filter { $0.isWillingToRepeat }.count
        let agingPotential = targetLogs.filter { $0.hasAgingPotential }.count

        return (costEffective, repeatIntent, agingPotential, total)
    }

    public func averageRating(from targetLogs: [TastingLog]) -> Double {
        guard !targetLogs.isEmpty else { return 0.0 }
        let totalRating = targetLogs.reduce(0.0) { $0 + $1.rating }
        return totalRating / Double(targetLogs.count)
    }
}
