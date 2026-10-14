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

    /// 平均テイストプロファイルを取得する
    public func averageTasteProfile(from logs: [TastingLog]) -> (sweetness: Double, acidity: Double, bitternessOrTannin: Double, body: Double, finishLength: Double) {
        return calculateUseCase.calculateAverageTasteProfile(from: logs)
    }
}
