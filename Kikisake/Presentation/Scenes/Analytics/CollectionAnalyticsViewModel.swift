//  CollectionAnalyticsViewModel.swift
//  Kikisake

import Foundation
import SwiftData

@Observable
public final class CollectionAnalyticsViewModel {
    public var selectedCategory: BeverageCategory = .wine

    public init() {}

    public func activeDefinitions(for category: BeverageCategory, isPro: Bool) -> [CollectionItemDefinition] {
        let all = CollectionMatrixDataSource.definitions(for: category)
        return isPro ? all : all.filter { !$0.isProOnly }
    }

    public func lockedProItemCount(for category: BeverageCategory) -> Int {
        let all = CollectionMatrixDataSource.definitions(for: category)
        return all.filter { $0.isProOnly }.count
    }

    /// ✨ 指定された酒種の図鑑アイテムごとに、合致するすべてのログの配列を返すように拡張
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
