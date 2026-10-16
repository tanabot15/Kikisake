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

    /// 平均味わいプロファイルの平均値を計算する
    /// - Parameter logs: 対象のテイスティングログ
    /// - Returns: 各パラメータの平均値タプル（甘味、塩味、酸味、苦味、旨味、タンニン、ボディ、余韻）
    public func calculateAverageTasteProfile(from logs: [TastingLog]) -> (sweetness: Double, saltiness: Double, acidity: Double, bitterness: Double, umami: Double, tannin: Double, body: Double, finishLength: Double) {
        guard !logs.isEmpty else { return (0, 0, 0, 0, 0, 0, 0, 0) }
        
        var totalSweetness = 0.0
        var totalSaltiness = 0.0
        var totalAcidity = 0.0
        var totalBitterness = 0.0
        var totalUmami = 0.0
        var totalTannin = 0.0
        var tanninCount = 0.0
        var totalBody = 0.0
        var totalFinishLength = 0.0
        
        for log in logs {
            totalSweetness += log.sweetness
            totalSaltiness += log.saltiness
            totalAcidity += log.acidity
            totalBitterness += log.bitterness
            totalUmami += log.umami
            if let tannin = log.tannin {
                totalTannin += tannin
                tanninCount += 1.0
            }
            totalBody += log.body
            totalFinishLength += log.finishLength
        }
        
        let count = Double(logs.count)
        let averageTannin = tanninCount > 0 ? (totalTannin / tanninCount) : 0.0
        
        return (
            sweetness: totalSweetness / count,
            saltiness: totalSaltiness / count,
            acidity: totalAcidity / count,
            bitterness: totalBitterness / count,
            umami: totalUmami / count,
            tannin: averageTannin,
            body: totalBody / count,
            finishLength: totalFinishLength / count
        )
    }
}
