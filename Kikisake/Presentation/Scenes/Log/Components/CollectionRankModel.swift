//
//  CollectionRankModel.swift
//  Kikisake
//

import SwiftUI

/// Collection completion rank tiers.
public enum CollectionRankTier: Int, CaseIterable, Identifiable, Comparable {
    case bronze = 1
    case silver = 2
    case gold = 3

    public var id: Int { rawValue }

    public static func < (lhs: CollectionRankTier, rhs: CollectionRankTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var tierName: String {
        switch self {
        case .bronze: String(localized: "ブロンズ")
        case .silver: String(localized: "シルバー")
        case .gold: String(localized: "ゴールド")
        }
    }

    public var iconName: String {
        switch self {
        case .bronze: "medal.fill"
        case .silver: "star.circle.fill"
        case .gold: "crown.fill"
        }
    }

    public var gradientColors: [Color] {
        switch self {
        case .bronze:
            [Color(red: 0.80, green: 0.50, blue: 0.20), Color(red: 0.55, green: 0.32, blue: 0.12)]
        case .silver:
            [Color(red: 0.78, green: 0.82, blue: 0.88), Color(red: 0.48, green: 0.52, blue: 0.60)]
        case .gold:
            [Color(red: 0.98, green: 0.78, blue: 0.18), Color(red: 0.85, green: 0.52, blue: 0.05)]
        }
    }

    public var accentColor: Color {
        switch self {
        case .bronze: Color(red: 0.72, green: 0.43, blue: 0.16)
        case .silver: Color(red: 0.52, green: 0.57, blue: 0.65)
        case .gold: Color(red: 0.88, green: 0.62, blue: 0.08)
        }
    }
}

/// Rank badge definition per beverage category and tier.
public struct CollectionRankBadge: Identifiable, Hashable {
    public var id: String { "\(category.rawValue)_\(tier.rawValue)" }
    public let category: BeverageCategory
    public let tier: CollectionRankTier
    public let requiredCount: Int
    public let title: String
    public let subtitle: String

    public static func badges(for category: BeverageCategory) -> [CollectionRankBadge] {
        switch category {
        case .wine:
            return [
                CollectionRankBadge(
                    category: .wine,
                    tier: .bronze,
                    requiredCount: 10,
                    title: String(localized: "見習いソムリエ"),
                    subtitle: String(localized: "主要品種と王道産地の基礎をマスター")
                ),
                CollectionRankBadge(
                    category: .wine,
                    tier: .silver,
                    requiredCount: 30,
                    title: String(localized: "ワインの探究者"),
                    subtitle: String(localized: "世界の銘醸地と多彩なブドウ品種を制覇")
                ),
                CollectionRankBadge(
                    category: .wine,
                    tier: .gold,
                    requiredCount: 70,
                    title: String(localized: "五つ星ソムリエ"),
                    subtitle: String(localized: "希少産地から土着品種まで極めし称号")
                )
            ]
        case .sake:
            return [
                CollectionRankBadge(
                    category: .sake,
                    tier: .bronze,
                    requiredCount: 10,
                    title: String(localized: "見習い利き酒師"),
                    subtitle: String(localized: "代表酒米と名水地の味わいを体感")
                ),
                CollectionRankBadge(
                    category: .sake,
                    tier: .silver,
                    requiredCount: 30,
                    title: String(localized: "銘酒の巡礼者"),
                    subtitle: String(localized: "全国の酒処と多様な酒米の個性を網羅")
                ),
                CollectionRankBadge(
                    category: .sake,
                    tier: .gold,
                    requiredCount: 70,
                    title: String(localized: "匠の利き酒マスター"),
                    subtitle: String(localized: "日本各地の風土と希少米を極めし称号")
                )
            ]
        case .beer:
            return [
                CollectionRankBadge(
                    category: .beer,
                    tier: .bronze,
                    requiredCount: 5,
                    title: String(localized: "クラフトビア・ビギナー"),
                    subtitle: String(localized: "基本のビアスタイルを味わう第一歩")
                ),
                CollectionRankBadge(
                    category: .beer,
                    tier: .silver,
                    requiredCount: 15,
                    title: String(localized: "ホップの冒険者"),
                    subtitle: String(localized: "伝統スタイルからモダンIPAまで制覇")
                ),
                CollectionRankBadge(
                    category: .beer,
                    tier: .gold,
                    requiredCount: 30,
                    title: String(localized: "五つ星ビアテイスター"),
                    subtitle: String(localized: "世界の醸造文化と希少スタイルを極めし称号")
                )
            ]
        }
    }

    public static func currentBadge(for category: BeverageCategory, unlockedCount: Int) -> CollectionRankBadge? {
        badges(for: category)
            .filter { unlockedCount >= $0.requiredCount }
            .max(by: { $0.tier < $1.tier })
    }

    public static func nextBadge(for category: BeverageCategory, unlockedCount: Int) -> CollectionRankBadge? {
        badges(for: category)
            .filter { unlockedCount < $0.requiredCount }
            .min(by: { $0.tier < $1.tier })
    }
}
