//  AnalyticsViewModel.swift
//  Kikisake

import Foundation
import SwiftData

/// 分析画面の表示セクション種類
public enum AnalyticsSection: String, CaseIterable, Identifiable {
    case consumption
    case evaluation

    public var id: String { rawValue }

    /// ✨ Localizable.xcstrings が自動検出し、英訳を行えるように直接文字列リテラルを指定
    public var displayName: String {
        switch self {
        case .consumption:
            return String(localized: "飲酒量・ログ")
        case .evaluation:
            return String(localized: "評価・好み")
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
    
    // --- フィルター条件 ---
    public var selectedTimeFilter: AnalyticsTimeFilter = .all
    public var selectedCategoryFilter: BeverageCategory? = nil
    public var selectedSubCategoryFilter: String? = nil
    
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
            
            return true
        }
    }

    public var hasActiveFilters: Bool {
        selectedTimeFilter != .all || selectedCategoryFilter != nil || selectedSubCategoryFilter != nil
    }

    public func resetFilters() {
        self.selectedTimeFilter = .all
        self.selectedCategoryFilter = nil
        self.selectedSubCategoryFilter = nil
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
