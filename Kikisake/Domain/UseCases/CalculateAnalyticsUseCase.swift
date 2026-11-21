//
//  CalculateAnalyticsUseCase.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

/// 味わいプロファイルの平均値集計結果
public struct AverageTasteProfile: Equatable, Sendable {
    public let sweetness: Double
    public let saltiness: Double
    public let acidity: Double
    public let bitterness: Double
    public let umami: Double
    public let tannin: Double
    public let body: Double
    public let finishLength: Double

    public static let zero = AverageTasteProfile(
        sweetness: 0,
        saltiness: 0,
        acidity: 0,
        bitterness: 0,
        umami: 0,
        tannin: 0,
        body: 0,
        finishLength: 0
    )
}

/// 分析画面向けの各種統計・集計ロジックを提供するユースケース
public struct CalculateAnalyticsUseCase {
    public init() {}

    /// 酒種ごとの飲酒比率（件数ベース）を計算する
    /// - Parameter logs: すべてのテイスティングログ
    /// - Returns: 酒種ごとの件数ディクショナリ
    public func calculateCategoryRatio(from logs: [TastingLog]) -> [BeverageCategory: Int] {
        var ratio = Dictionary(uniqueKeysWithValues: BeverageCategory.allCases.map { ($0, 0) })

        for log in logs {
            guard let category = log.item?.category else { continue }
            ratio[category, default: 0] += 1
        }

        return ratio
    }

    /// 平均味わいプロファイルの平均値を計算する
    /// - Parameter logs: 対象のテイスティングログ
    /// - Returns: 各パラメータの平均値構造体
    public func calculateAverageTasteProfile(from logs: [TastingLog]) -> AverageTasteProfile {
        guard !logs.isEmpty else { return .zero }

        var totalSweetness = 0.0
        var totalSaltiness = 0.0
        var totalAcidity = 0.0
        var totalBitterness = 0.0
        var totalUmami = 0.0
        var totalTannin = 0.0
        var tanninCount = 0
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
                tanninCount += 1
            }
            totalBody += log.body
            totalFinishLength += log.finishLength
        }

        let count = Double(logs.count)
        let averageTannin = tanninCount > 0 ? (totalTannin / Double(tanninCount)) : 0.0

        return AverageTasteProfile(
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
