//
//  AnalyticsViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

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

    /// 指定日が含まれるか、あるいは指定期間内かを判定する
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
    public var selectedTimeFilter: AnalyticsTimeFilter = .all
    
    private let calculateUseCase = CalculateAnalyticsUseCase()

    public init() {}

    /// 期間フィルター適用済みのログを取得する
    public func filteredLogs(from logs: [TastingLog]) -> [TastingLog] {
        logs.filter { selectedTimeFilter.evaluate(date: $0.date) }
    }

    /// 酒種比率を取得する
    public func categoryRatio(from logs: [TastingLog]) -> [BeverageCategory: Int] {
        let targetLogs = filteredLogs(from: logs)
        return calculateUseCase.calculateCategoryRatio(from: targetLogs)
    }

    /// 直近17週間（約4ヶ月）の飲酒日ヒートマップ用データを生成
    public func drinkingHeatmapData(from logs: [TastingLog]) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var days: [HeatmapDay] = []
        for dayOffset in (0..<119).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                // ヒートマップは日付ベースの全体傾向または期間内に一致するもの
                let count = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
                days.append(HeatmapDay(date: date, count: count))
            }
        }
        return days
    }

    /// 指定した酒種ごとの高評価（マイベスト）ログを取得（★4.5以上を降順で）
    public func topRatedLogs(for category: BeverageCategory, from logs: [TastingLog], limit: Int = 3) -> [TastingLog] {
        let targetLogs = filteredLogs(from: logs)
        return targetLogs.filter { log in
            log.rating >= 4.5 && log.item?.category == category
        }
        .sorted { $0.rating > $1.rating }
        .prefix(limit)
        .map { $0 }
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
}
