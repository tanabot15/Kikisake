//  AnalyticsViewModel.swift
//  Kikisake

import Foundation
import SwiftData

/// 分析画面の表示セクション種類
public enum AnalyticsSection: String, CaseIterable, Identifiable {
    case consumption = "飲酒量・ログ"
    case evaluation = "評価・好み"

    public var id: String { rawValue }
}

/// 期間フィルターの種類
public enum AnalyticsTimeFilter: String, CaseIterable, Identifiable {
    case all = "全期間"
    case month1 = "直近1ヶ月"
    case months3 = "直近3ヶ月"
    case year1 = "直近1年"

    public var id: String { rawValue }

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

    /// 期間、酒種、およびサブタイプフィルター適用済みのログを取得する
    public func filteredLogs(from logs: [TastingLog]) -> [TastingLog] {
        logs.filter { log in
            // 1. 期間判定
            guard selectedTimeFilter.evaluate(date: log.date) else { return false }
            
            // 2. 酒種 (カテゴリ) 判定
            if let category = selectedCategoryFilter {
                guard let item = log.item, item.category == category else { return false }
                
                // 3. サブカテゴリ判定
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

    /// デフォルト状態（全期間・全酒種・サブタイプなし）から何等かのフィルター条件が追加されているか
    public var hasActiveFilters: Bool {
        selectedTimeFilter != .all || selectedCategoryFilter != nil || selectedSubCategoryFilter != nil
    }

    /// フィルター条件をデフォルトにリセットする
    public func resetFilters() {
        self.selectedTimeFilter = .all
        self.selectedCategoryFilter = nil
        self.selectedSubCategoryFilter = nil
    }

    /// 選択された酒種に応じて、ログから動的に存在するサブタイプリストを取得する
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

    /// 酒種（メインカテゴリ）比率を取得する
    public func categoryRatio(from logs: [TastingLog]) -> [BeverageCategory: Int] {
        let targetLogs = filteredLogs(from: logs)
        return calculateUseCase.calculateCategoryRatio(from: targetLogs)
    }

    /// 選択された酒種に応じたサブタイプ別比率（wineType / specificName / beerStyle）を取得する
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

    /// 直近17週間（約4ヶ月）の飲酒日ヒートマップ用データを生成
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

    /// 指定した酒種の中で「最も評価が高いNo.1」のログ（1件のみ）を取得する
    public func topRatedLog(for category: BeverageCategory, from logs: [TastingLog]) -> TastingLog? {
        let targetLogs = filteredLogs(from: logs)
        return targetLogs
            .filter { $0.item?.category == category }
            .max(by: { $0.rating < $1.rating })
    }

    /// よく登場する香りタグ上位を取得
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

    /// 平均テイストプロファイルを取得する
    public func averageTasteProfile(from logs: [TastingLog]) -> (sweetness: Double, saltiness: Double, acidity: Double, bitterness: Double, umami: Double, tannin: Double, body: Double, finishLength: Double) {
        let targetLogs = filteredLogs(from: logs)
        return calculateUseCase.calculateAverageTasteProfile(from: targetLogs)
    }

    /// 特徴・評価フラグの集計データを取得する
    public func featureFlagsSummary(from logs: [TastingLog]) -> (costEffective: Int, repeatIntent: Int, agingPotential: Int, total: Int) {
        let targetLogs = filteredLogs(from: logs)
        let total = targetLogs.count
        guard total > 0 else { return (0, 0, 0, 0) }
        
        let costEffective = targetLogs.filter { $0.isCostEffective }.count
        let repeatIntent = targetLogs.filter { $0.isWillingToRepeat }.count
        let agingPotential = targetLogs.filter { $0.hasAgingPotential }.count
        
        return (costEffective, repeatIntent, agingPotential, total)
    }
    
    /// フィルター済みログの平均評価スコアを取得する
    public func averageRating(from targetLogs: [TastingLog]) -> Double {
        guard !targetLogs.isEmpty else { return 0.0 }
        let totalRating = targetLogs.reduce(0.0) { $0 + $1.rating }
        return totalRating / Double(targetLogs.count)
    }
}
