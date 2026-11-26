//
//  BlindTastingData.swift
//  Kikisake
//

import Foundation

/// テイスティング記録の進行モード
public enum TastingEntryMode: String, Codable, CaseIterable, Identifiable {
    case normal
    case blind

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .normal: return String(localized: "通常記録")
        case .blind: return String(localized: "ブラインド記録")
        }
    }

    public var subtitle: String {
        switch self {
        case .normal: return String(localized: "銘柄を見ながら外観・香り・味わいを記録")
        case .blind: return String(localized: "銘柄を伏せて感覚だけで予想し、あとから答え合わせ")
        }
    }
}

/// ブラインドテイスティングの予想・答え合わせ結果データ（JSON保存用）
public struct BlindTastingPayload: Codable, Hashable {
    // ワイン予想
    public var guessedWineBlend: [BlendComponent]
    public var guessedWineRegion: String

    // 日本酒予想
    public var guessedSakeSpecificName: String
    public var guessedSakeRiceVariety: String
    public var guessedSakeRegion: String

    // ビール予想
    public var guessedBeerStyle: String
    public var guessedBeerRegion: String

    // 振り返り・採点
    public var accuracyScore: Int          // 0〜100 (%)
    public var reflectionMemo: String

    public init(
        guessedWineBlend: [BlendComponent] = [],
        guessedWineRegion: String = "",
        guessedSakeSpecificName: String = "",
        guessedSakeRiceVariety: String = "",
        guessedSakeRegion: String = "",
        guessedBeerStyle: String = "",
        guessedBeerRegion: String = "",
        accuracyScore: Int = 0,
        reflectionMemo: String = ""
    ) {
        self.guessedWineBlend = guessedWineBlend
        self.guessedWineRegion = guessedWineRegion
        self.guessedSakeSpecificName = guessedSakeSpecificName
        self.guessedSakeRiceVariety = guessedSakeRiceVariety
        self.guessedSakeRegion = guessedSakeRegion
        self.guessedBeerStyle = guessedBeerStyle
        self.guessedBeerRegion = guessedBeerRegion
        self.accuracyScore = accuracyScore
        self.reflectionMemo = reflectionMemo
    }
}

/// ブラインド答え合わせの項目別比較結果
public struct BlindComparisonItem: Identifiable, Hashable {
    public let id = UUID()
    public let label: String
    public let guessedText: String
    public let actualText: String
    public let earnedPoints: Int
    public let maxPoints: Int

    public var isFullMatch: Bool { earnedPoints == maxPoints && maxPoints > 0 }
    public var isPartialMatch: Bool { earnedPoints > 0 && earnedPoints < maxPoints }
}

/// 予想と実際のスペックを比較して正解率を算出する評価ロジック
public enum BlindTastingEvaluator {
    public static func evaluate(
        category: BeverageCategory,
        payload: BlindTastingPayload,
        actualRegion: String,
        actualWineBlend: [BlendComponent],
        actualSakeSpecificName: String,
        actualSakeRiceVariety: String,
        actualBeerStyle: String
    ) -> (score: Int, items: [BlindComparisonItem]) {
        switch category {
        case .wine:
            return evaluateWine(
                payload: payload,
                actualRegion: actualRegion,
                actualBlend: actualWineBlend
            )
        case .sake:
            return evaluateSake(
                payload: payload,
                actualRegion: actualRegion,
                actualSpecificName: actualSakeSpecificName,
                actualRiceVariety: actualSakeRiceVariety
            )
        case .beer:
            return evaluateBeer(
                payload: payload,
                actualRegion: actualRegion,
                actualBeerStyle: actualBeerStyle
            )
        }
    }

    // MARK: - Wine (品種 45pt + 割合 25pt + 地域 30pt = 100pt)
    private static func evaluateWine(
        payload: BlindTastingPayload,
        actualRegion: String,
        actualBlend: [BlendComponent]
    ) -> (Int, [BlindComparisonItem]) {
        let validGuessed = payload.guessedWineBlend.filter { !$0.variety.isEmpty }
        let validActual = actualBlend.filter { !$0.variety.isEmpty }

        let guessedVarietyText = validGuessed.isEmpty
            ? "未選択"
            : validGuessed.map { $0.variety }.joined(separator: " / ")
        let actualVarietyText = validActual.isEmpty
            ? "未登録"
            : validActual.map { $0.variety }.joined(separator: " / ")

        let guessedSet = Set(validGuessed.map { normalize($0.variety) })
        let actualSet = Set(validActual.map { normalize($0.variety) })

        let varietyPoints: Int
        if !guessedSet.isEmpty && !actualSet.isEmpty {
            let intersection = guessedSet.intersection(actualSet)
            if guessedSet == actualSet {
                varietyPoints = 45
            } else if !intersection.isEmpty {
                let ratio = Double(intersection.count) / Double(max(guessedSet.count, actualSet.count))
                varietyPoints = max(15, Int((45.0 * ratio).rounded()))
            } else {
                varietyPoints = 0
            }
        } else {
            varietyPoints = 0
        }

        // 割合評価 (25pt)
        let guessedRatioText = validGuessed.isEmpty
            ? "未選択"
            : validGuessed.map { "\($0.variety) \($0.percentage ?? 0)%" }.joined(separator: " · ")
        let actualRatioText = validActual.isEmpty
            ? "未登録"
            : validActual.map {
                if let pct = $0.percentage {
                    return "\($0.variety) \(pct)%"
                } else {
                    return "\($0.variety) (割合未登録)"
                }
            }.joined(separator: " · ")

        var ratioPoints = 0
        for g in validGuessed {
            if let a = validActual.first(where: { normalize($0.variety) == normalize(g.variety) }),
               let gPct = g.percentage,
               let aPct = a.percentage {
                let diff = abs(gPct - aPct)
                let componentShare = 25.0 / Double(max(validActual.count, 1))
                if diff == 0 {
                    ratioPoints += Int(componentShare.rounded())
                } else if diff <= 10 {
                    ratioPoints += Int((componentShare * 0.8).rounded())
                } else if diff <= 20 {
                    ratioPoints += Int((componentShare * 0.5).rounded())
                }
            }
        }
        ratioPoints = min(25, ratioPoints)

        // 地域評価 (30pt: 親地域一致で15pt、完全一致で30pt)
        let regionPoints = scoreRegion(guessed: payload.guessedWineRegion, actual: actualRegion, maxPoints: 30)

        let items = [
            BlindComparisonItem(
                label: String(localized: "ブドウ品種"),
                guessedText: guessedVarietyText,
                actualText: actualVarietyText,
                earnedPoints: varietyPoints,
                maxPoints: 45
            ),
            BlindComparisonItem(
                label: String(localized: "ブレンド割合"),
                guessedText: guessedRatioText,
                actualText: actualRatioText,
                earnedPoints: ratioPoints,
                maxPoints: 25
            ),
            BlindComparisonItem(
                label: String(localized: "生産地"),
                guessedText: payload.guessedWineRegion.isEmpty ? "未選択" : payload.guessedWineRegion,
                actualText: actualRegion.isEmpty ? "未登録" : actualRegion,
                earnedPoints: regionPoints,
                maxPoints: 30
            )
        ]

        return (varietyPoints + ratioPoints + regionPoints, items)
    }

    // MARK: - Sake (特定名称 35pt + 使用米 35pt + 地域 30pt = 100pt)
    private static func evaluateSake(
        payload: BlindTastingPayload,
        actualRegion: String,
        actualSpecificName: String,
        actualRiceVariety: String
    ) -> (Int, [BlindComparisonItem]) {
        let specPoints = (!payload.guessedSakeSpecificName.isEmpty && normalize(payload.guessedSakeSpecificName) == normalize(actualSpecificName)) ? 35 : 0
        let ricePoints = (!payload.guessedSakeRiceVariety.isEmpty && normalize(payload.guessedSakeRiceVariety) == normalize(actualRiceVariety)) ? 35 : 0
        let regionPoints = scoreRegion(guessed: payload.guessedSakeRegion, actual: actualRegion, maxPoints: 30)

        let items = [
            BlindComparisonItem(
                label: String(localized: "特定名称"),
                guessedText: payload.guessedSakeSpecificName.isEmpty ? "未選択" : payload.guessedSakeSpecificName,
                actualText: actualSpecificName.isEmpty ? "未登録" : actualSpecificName,
                earnedPoints: specPoints,
                maxPoints: 35
            ),
            BlindComparisonItem(
                label: String(localized: "使用米"),
                guessedText: payload.guessedSakeRiceVariety.isEmpty ? "未選択" : payload.guessedSakeRiceVariety,
                actualText: actualRiceVariety.isEmpty ? "未登録" : actualRiceVariety,
                earnedPoints: ricePoints,
                maxPoints: 35
            ),
            BlindComparisonItem(
                label: String(localized: "生産地"),
                guessedText: payload.guessedSakeRegion.isEmpty ? "未選択" : payload.guessedSakeRegion,
                actualText: actualRegion.isEmpty ? "未登録" : actualRegion,
                earnedPoints: regionPoints,
                maxPoints: 30
            )
        ]

        return (specPoints + ricePoints + regionPoints, items)
    }

    // MARK: - Beer (ビアスタイル 60pt + 生産地 40pt = 100pt)
    private static func evaluateBeer(
        payload: BlindTastingPayload,
        actualRegion: String,
        actualBeerStyle: String
    ) -> (Int, [BlindComparisonItem]) {
        let stylePoints = (!payload.guessedBeerStyle.isEmpty && normalize(payload.guessedBeerStyle) == normalize(actualBeerStyle)) ? 60 : 0
        let regionPoints = scoreRegion(guessed: payload.guessedBeerRegion, actual: actualRegion, maxPoints: 40)

        let items = [
            BlindComparisonItem(
                label: String(localized: "ビアスタイル"),
                guessedText: payload.guessedBeerStyle.isEmpty ? "未選択" : payload.guessedBeerStyle,
                actualText: actualBeerStyle.isEmpty ? "未登録" : actualBeerStyle,
                earnedPoints: stylePoints,
                maxPoints: 60
            ),
            BlindComparisonItem(
                label: String(localized: "生産地"),
                guessedText: payload.guessedBeerRegion.isEmpty ? "未選択" : payload.guessedBeerRegion,
                actualText: actualRegion.isEmpty ? "未登録" : actualRegion,
                earnedPoints: regionPoints,
                maxPoints: 40
            )
        ]

        return (stylePoints + regionPoints, items)
    }

    private static func scoreRegion(guessed: String, actual: String, maxPoints: Int) -> Int {
        guard !guessed.isEmpty, !actual.isEmpty else { return 0 }
        let gNorm = normalize(guessed)
        let aNorm = normalize(actual)
        if gNorm == aNorm {
            return maxPoints
        }
        // "フランス, ボルドー" のような親地域（国・地方）が一致していれば半分の部分点
        let gParent = normalize(guessed.components(separatedBy: ",").first ?? "")
        let aParent = normalize(actual.components(separatedBy: ",").first ?? "")
        if !gParent.isEmpty && gParent == aParent {
            return maxPoints / 2
        }
        return 0
    }

    private static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
