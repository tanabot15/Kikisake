//
//  CollectionViewModel.swift
//  Kikisake
//

import Foundation
import SwiftData

/// Completion state for a single collection matrix item.
public struct CollectionCompletionEntry: Identifiable {
    public var id: UUID { definition.id }
    public let definition: CollectionItemDefinition
    public let isUnlocked: Bool
    public let unlockedLogs: [TastingLog]
}

/// Region-grouped collection items.
public struct CollectionRegionGroup: Identifiable {
    public var id: String { region }
    public let region: String
    public let items: [CollectionCompletionEntry]
}

@Observable
public final class CollectionViewModel {
    public var selectedCategory: BeverageCategory = .wine

    public var wineRegionOrder: [String] = [
        "フランス", "イタリア", "スペイン", "ポルトガル",
        "ドイツ", "オーストリア", "スイス", "ハンガリー",
        "アメリカ", "カナダ", "チリ", "アルゼンチン",
        "オーストラリア", "ニュージーランド", "南アフリカ",
        "日本", "ギリシャ", "ジョージア", "レバノン", "イギリス", "ウルグアイ"
    ]

    public var sakeRegionOrder: [String] = [
        "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
        "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
        "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県",
        "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
        "鳥取県", "島根県", "岡山県", "広島県", "山口県",
        "徳島県", "香川県", "愛媛県", "高知県",
        "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
    ]

    public var beerRegionOrder: [String] = [
        "日本", "ドイツ", "チェコ", "ベルギー", "イギリス", "アイルランド", "アメリカ", "デンマーク", "エストニア"
    ]

    public init() {}

    public func activeDefinitions(for category: BeverageCategory, isPro: Bool) -> [CollectionItemDefinition] {
        let all = CollectionMatrixDataSource.definitions(for: category)
        return isPro ? all : all.filter { !$0.isProOnly }
    }

    public func lockedProItemCount(for category: BeverageCategory) -> Int {
        CollectionMatrixDataSource.definitions(for: category).filter(\.isProOnly).count
    }

    public func checkCompletions(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> [CollectionCompletionEntry] {
        let definitions = activeDefinitions(for: category, isPro: isPro)
        let categoryLogs = logs.filter { $0.item?.category == category }

        return definitions.map { definition in
            let matchedLogs = categoryLogs.filter { log in
                guard let item = log.item else { return false }
                return item.region.contains(definition.region) &&
                       matchesTargetElement(item: item, category: category, targetElement: definition.targetElement)
            }

            return CollectionCompletionEntry(
                definition: definition,
                isUnlocked: !matchedLogs.isEmpty,
                unlockedLogs: matchedLogs
            )
        }
    }

    public func groupedCompletions(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> [CollectionRegionGroup] {
        let allResults = checkCompletions(for: category, logs: logs, isPro: isPro)
        let groupedDict = Dictionary(grouping: allResults, by: \.definition.region)
        let orderedRegions = orderedRegionKeys(from: Array(groupedDict.keys), category: category)

        return orderedRegions.compactMap { region in
            guard let items = groupedDict[region], !items.isEmpty else { return nil }
            return CollectionRegionGroup(region: region, items: items)
        }
    }

    public func availableRegions(for category: BeverageCategory, isPro: Bool) -> [String] {
        let definitions = activeDefinitions(for: category, isPro: isPro)
        let uniqueRegions = Array(Set(definitions.map(\.region)))
        return orderedRegionKeys(from: uniqueRegions, category: category)
    }

    public func availableTargetElements(
        for category: BeverageCategory,
        isPro: Bool,
        region: String = ""
    ) -> [String] {
        let definitions = activeDefinitions(for: category, isPro: isPro)
        let trimmedRegion = region.trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered = trimmedRegion.isEmpty
            ? definitions
            : definitions.filter { $0.region == trimmedRegion }

        var seen = Set<String>()
        var ordered: [String] = []

        for def in filtered where seen.insert(def.targetElement).inserted {
            ordered.append(def.targetElement)
        }

        return ordered
    }

    public func completionRate(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> Double {
        let results = checkCompletions(for: category, logs: logs, isPro: isPro)
        guard !results.isEmpty else { return 0.0 }
        let unlockedCount = results.filter(\.isUnlocked).count
        return Double(unlockedCount) / Double(results.count)
    }

    public func currentRankBadge(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> CollectionRankBadge? {
        let unlockedCount = unlockedItemCount(for: category, logs: logs, isPro: isPro)
        return CollectionRankBadge.currentBadge(for: category, unlockedCount: unlockedCount)
    }

    public func nextRankBadge(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> CollectionRankBadge? {
        let unlockedCount = unlockedItemCount(for: category, logs: logs, isPro: isPro)
        return CollectionRankBadge.nextBadge(for: category, unlockedCount: unlockedCount)
    }

    // MARK: - Private Helpers

    private func unlockedItemCount(for category: BeverageCategory, logs: [TastingLog], isPro: Bool) -> Int {
        checkCompletions(for: category, logs: logs, isPro: isPro).filter(\.isUnlocked).count
    }

    private func regionOrder(for category: BeverageCategory) -> [String] {
        switch category {
        case .wine: wineRegionOrder
        case .sake: sakeRegionOrder
        case .beer: beerRegionOrder
        }
    }

    private func orderedRegionKeys(from regions: [String], category: BeverageCategory) -> [String] {
        let availableSet = Set(regions)
        let preferredOrder = regionOrder(for: category)

        var ordered: [String] = []
        var seen = Set<String>()

        for region in preferredOrder where availableSet.contains(region) {
            ordered.append(region)
            seen.insert(region)
        }

        for region in regions where !seen.contains(region) {
            ordered.append(region)
        }

        return ordered
    }

    private func matchesTargetElement(
        item: BeverageItem,
        category: BeverageCategory,
        targetElement: String
    ) -> Bool {
        guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else {
            return false
        }

        let decoder = JSONDecoder()
        switch category {
        case .wine:
            guard let meta = try? decoder.decode(WineSpecificMetadata.self, from: data) else {
                return false
            }
            return meta.grapeVarieties.contains(targetElement) ||
                   meta.blendComponents.contains { $0.variety.contains(targetElement) }

        case .sake:
            guard let meta = try? decoder.decode(SakeSpecificMetadata.self, from: data) else {
                return false
            }
            return meta.riceVariety.contains(targetElement)

        case .beer:
            guard let meta = try? decoder.decode(BeerSpecificMetadata.self, from: data) else {
                return false
            }
            return meta.beerStyle.contains(targetElement)
        }
    }
}
