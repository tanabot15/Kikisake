//  CollectionRankModel.swift
//  Kikisake

import SwiftUI

/// 図鑑の達成ランク（ブロンズ / シルバー / ゴールド）
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
        case .bronze: return String(localized: "ブロンズ")
        case .silver: return String(localized: "シルバー")
        case .gold: return String(localized: "ゴールド")
        }
    }

    public var iconName: String {
        switch self {
        case .bronze: return "medal.fill"
        case .silver: return "star.circle.fill"
        case .gold: return "crown.fill"
        }
    }

    public var gradientColors: [Color] {
        switch self {
        case .bronze:
            return [Color(red: 0.80, green: 0.50, blue: 0.20), Color(red: 0.55, green: 0.32, blue: 0.12)]
        case .silver:
            return [Color(red: 0.78, green: 0.82, blue: 0.88), Color(red: 0.48, green: 0.52, blue: 0.60)]
        case .gold:
            return [Color(red: 0.98, green: 0.78, blue: 0.18), Color(red: 0.85, green: 0.52, blue: 0.05)]
        }
    }

    public var accentColor: Color {
        switch self {
        case .bronze: return Color(red: 0.72, green: 0.43, blue: 0.16)
        case .silver: return Color(red: 0.52, green: 0.57, blue: 0.65)
        case .gold: return Color(red: 0.88, green: 0.62, blue: 0.08)
        }
    }
}

/// 酒種 × ランクごとの称号詳細定義
public struct CollectionRankBadge: Identifiable, Hashable {
    public var id: String { "\(category.rawValue)_\(tier.rawValue)" }
    public let category: BeverageCategory
    public let tier: CollectionRankTier
    public let requiredCount: Int
    public let title: String
    public let subtitle: String

    /// 指定酒種の全ランク定義（ブロンズ・シルバー・ゴールド）を取得
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
                    requiredCount: 25,
                    title: String(localized: "銘酒の巡礼者"),
                    subtitle: String(localized: "全国の酒処と多様な酒米の個性を網羅")
                ),
                CollectionRankBadge(
                    category: .sake,
                    tier: .gold,
                    requiredCount: 50,
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

    /// 現在の達成数から、到達している最高ランクのバッジを返す（未達ならnil）
    public static func currentBadge(for category: BeverageCategory, unlockedCount: Int) -> CollectionRankBadge? {
        badges(for: category)
            .filter { unlockedCount >= $0.requiredCount }
            .max(by: { $0.tier < $1.tier })
    }

    /// 次に目指すべきランクのバッジを返す（ゴールド達成済みならnil）
    public static func nextBadge(for category: BeverageCategory, unlockedCount: Int) -> CollectionRankBadge? {
        badges(for: category)
            .filter { unlockedCount < $0.requiredCount }
            .min(by: { $0.tier < $1.tier })
    }
}
