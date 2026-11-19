//  CollectionAnalyticsViewModel.swift
//  Kikisake

import Foundation
import SwiftData

@Observable
public final class CollectionViewModel {
    public var selectedCategory: BeverageCategory = .wine

    // ✨ ここで国・都道府県の表示順序を自由にコントロールできます
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
        let all = CollectionMatrixDataSource.definitions(for: category)
        return all.filter { $0.isProOnly }.count
    }

    /// 指定された酒種の図鑑アイテムごとに、合致するすべてのログの配列を返す
    public func checkCompletions(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> [(definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLogs: [TastingLog])] {
        let definitions = activeDefinitions(for: category, isPro: isPro)
        
        return definitions.map { def in
            let matchedLogs = logs.filter { log in
                guard let item = log.item, item.category == category else { return false }
                
                let regionMatched = item.region.contains(def.region)
                
                var elementMatched = false
                if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    switch category {
                    case .wine:
                        if let meta = try? decoder.decode(WineSpecificMetadata.self, from: data) {
                            let hasVariety = meta.grapeVarieties.contains(def.targetElement) ||
                                             meta.blendComponents.contains(where: { $0.variety.contains(def.targetElement) })
                            elementMatched = hasVariety
                        }
                    case .sake:
                        if let meta = try? decoder.decode(SakeSpecificMetadata.self, from: data) {
                            elementMatched = meta.riceVariety.contains(def.targetElement)
                        }
                    case .beer:
                        if let meta = try? decoder.decode(BeerSpecificMetadata.self, from: data) {
                            elementMatched = meta.beerStyle.contains(def.targetElement)
                        }
                    }
                }
                
                return regionMatched && elementMatched
            }
            
            return (definition: def, isUnlocked: !matchedLogs.isEmpty, unlockedLogs: matchedLogs)
        }
    }

    /// ✨ 指定された表示順序に従って、国・都道府県別にグループ化した配列を返す
    public func groupedCompletions(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> [(region: String, items: [(definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLogs: [TastingLog])])] {
        let allResults = checkCompletions(for: category, logs: logs, isPro: isPro)
        let groupedDict = Dictionary(grouping: allResults, by: { $0.definition.region })
        
        let orderList: [String]
        switch category {
        case .wine: orderList = wineRegionOrder
        case .sake: orderList = sakeRegionOrder
        case .beer: orderList = beerRegionOrder
        }
        
        var sortedGroups: [(region: String, items: [(definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLogs: [TastingLog])])] = []
        var processedRegions = Set<String>()
        
        // 1. 指定された順番通りに追加
        for region in orderList {
            if let items = groupedDict[region], !items.isEmpty {
                sortedGroups.append((region: region, items: items))
                processedRegions.insert(region)
            }
        }
        
        // 2. 万が一 orderList に未記載の産地がデータ側に増えた場合は末尾に追加
        for (region, items) in groupedDict where !processedRegions.contains(region) && !items.isEmpty {
            sortedGroups.append((region: region, items: items))
        }
        
        return sortedGroups
    }
    
    public func availableRegions(for category: BeverageCategory, isPro: Bool) -> [String] {
        let definitions = activeDefinitions(for: category, isPro: isPro)
        let groupedDict = Dictionary(grouping: definitions, by: { $0.region })

        let orderList: [String]
        switch category {
        case .wine: orderList = wineRegionOrder
        case .sake: orderList = sakeRegionOrder
        case .beer: orderList = beerRegionOrder
        }

        var ordered: [String] = []
        var seen = Set<String>()

        for region in orderList where groupedDict[region] != nil {
            ordered.append(region)
            seen.insert(region)
        }

        for region in groupedDict.keys where !seen.contains(region) {
            ordered.append(region)
        }

        return ordered
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

        for def in filtered {
            if !seen.contains(def.targetElement) {
                seen.insert(def.targetElement)
                ordered.append(def.targetElement)
            }
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
        let unlockedCount = results.filter { $0.isUnlocked }.count
        return Double(unlockedCount) / Double(results.count)
    }

    public func currentRankBadge(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> CollectionRankBadge? {
        let unlockedCount = checkCompletions(for: category, logs: logs, isPro: isPro).filter { $0.isUnlocked }.count
        return CollectionRankBadge.currentBadge(for: category, unlockedCount: unlockedCount)
    }

    public func nextRankBadge(
        for category: BeverageCategory,
        logs: [TastingLog],
        isPro: Bool = AppState.shared.isProVersion
    ) -> CollectionRankBadge? {
        let unlockedCount = checkCompletions(for: category, logs: logs, isPro: isPro).filter { $0.isUnlocked }.count
        return CollectionRankBadge.nextBadge(for: category, unlockedCount: unlockedCount)
    }
}
