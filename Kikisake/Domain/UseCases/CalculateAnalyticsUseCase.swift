//
//  CalculateAnalyticsUseCase.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import os

/// 分析画面向けの各種統計・集計ロジックを提供するユースケース
public struct CalculateAnalyticsUseCase {
    
    public init() {}

    /// 酒種ごとの飲酒比率（件数ベース）を計算する
    /// - Parameter logs: すべてのテイスティングログ
    /// - Returns: 酒種ごとの件数ディクショナリ
    public func calculateCategoryRatio(from logs: [TastingLog]) -> [BeverageCategory: Int] {
        var ratio: [BeverageCategory: Int] = [
            .wine: 0,
            .sake: 0,
            .beer: 0
        ]
        
        for log in logs {
            guard let category = log.item?.category else { continue }
            ratio[category, default: 0] += 1
        }
        
        return ratio
    }

    /// レーダーチャート等で使用する味わいパラメータの平均値を計算する
    /// - Parameter logs: 対象のテイスティングログ
    /// - Returns: 各パラメータの平均値タプル
    public func calculateAverageTasteProfile(from logs: [TastingLog]) -> (sweetness: Double, acidity: Double, bitternessOrTannin: Double, body: Double, finishLength: Double) {
        guard !logs.isEmpty else { return (0, 0, 0, 0, 0) }
        
        let total = logs.reduce(into: (sweetness: 0.0, acidity: 0.0, bitternessOrTannin: 0.0, body: 0.0, finishLength: 0.0)) { acc, log in
            acc.sweetness += log.sweetness
            acc.acidity += log.acidity
            acc.bitternessOrTannin += log.bitternessOrTannin
            acc.body += log.body
            acc.finishLength += log.finishLength
        }
        
        let count = Double(logs.count)
        return (
            sweetness: total.sweetness / count,
            acidity: total.acidity / count,
            bitternessOrTannin: total.bitternessOrTannin / count,
            body: total.body / count,
            finishLength: total.finishLength / count
        )
    }
}
