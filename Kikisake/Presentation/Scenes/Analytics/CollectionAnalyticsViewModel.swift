//  CollectionAnalyticsViewModel.swift
//  Kikisake

import Foundation
import SwiftData

@Observable
public final class CollectionAnalyticsViewModel {
    public var selectedCategory: BeverageCategory = .wine

    public init() {}

    /// 指定された酒種の図鑑アイテムごとのコンプリート状態を判定
    public func checkCompletions(for category: BeverageCategory, logs: [TastingLog]) -> [(definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLog: TastingLog?)] {
        let definitions = CollectionMatrixDataSource.definitions(for: category)
        
        return definitions.map { def in
            // ログと紐づくアイテムの地域（region）と品種・米・スタイルが一致するかを判定
            let matchedLog = logs.first { log in
                guard let item = log.item, item.category == category else { return false }
                
                // 1. 産地の部分一致または完全一致チェック (例: "フランス, ボルドー" は "フランス" にマッチ)
                let regionMatched = item.region.contains(def.region)
                
                // 2. 酒種固有のターゲット要素（品種・米・スタイル）のチェック
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
            
            return (definition: def, isUnlocked: matchedLog != nil, unlockedLog: matchedLog)
        }
    }
    
    /// コンプリート率の計算 (0.0 〜 1.0)
    public func completionRate(for category: BeverageCategory, logs: [TastingLog]) -> Double {
        let results = checkCompletions(for: category, logs: logs)
        guard !results.isEmpty else { return 0.0 }
        let unlockedCount = results.filter { $0.isUnlocked }.count
        return Double(unlockedCount) / Double(results.count)
    }
}
