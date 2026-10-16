//
//  AnalyticsViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

/// 分析画面のビジネスロジック・状態管理
@Observable
public final class AnalyticsViewModel {
    private let calculateUseCase = CalculateAnalyticsUseCase()

    public init() {}

    /// 酒種比率を取得する
    public func categoryRatio(from logs: [TastingLog]) -> [BeverageCategory: Int] {
        return calculateUseCase.calculateCategoryRatio(from: logs)
    }

    /// 平均テイストプロファイルを取得する（五味＋タンニン・ボディ・余韻）
    public func averageTasteProfile(from logs: [TastingLog]) -> (sweetness: Double, saltiness: Double, acidity: Double, bitterness: Double, umami: Double, tannin: Double, body: Double, finishLength: Double) {
        guard !logs.isEmpty else {
            return (0, 0, 0, 0, 0, 0, 0, 0)
        }

        let total = Double(logs.count)
        let sweetness = logs.reduce(0.0) { $0 + $1.sweetness } / total
        let saltiness = logs.reduce(0.0) { $0 + $1.saltiness } / total
        let acidity = logs.reduce(0.0) { $0 + $1.acidity } / total
        let bitterness = logs.reduce(0.0) { $0 + $1.bitterness } / total
        let umami = logs.reduce(0.0) { $0 + $1.umami } / total
        
        // タンニンはオプショナル（赤ワイン等のみ）のため、有効なログのみで平均を計算
        let tanninLogs = logs.compactMap { $0.tannin }
        let tannin = tanninLogs.isEmpty ? 0.0 : tanninLogs.reduce(0.0, +) / Double(tanninLogs.count)
        
        let body = logs.reduce(0.0) { $0 + $1.body } / total
        let finishLength = logs.reduce(0.0) { $0 + $1.finishLength } / total

        return (sweetness, saltiness, acidity, bitterness, umami, tannin, body, finishLength)
    }
}
