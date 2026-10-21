//
//  InventoryViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

/// セラー＆冷蔵庫の在庫管理画面のビジネスロジック・状態管理
@Observable
public final class InventoryViewModel {
    public var selectedLocationFilter: String? = nil
    public var searchText: String = ""

    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {}

    /// 保管場所ごとの総本数を計算する
    public func totalCount(for locationName: String, in items: [BeverageItem]) -> Int {
        items
            .filter { $0.storageLocation == locationName && $0.stockQuantity > 0 }
            .reduce(0) { $0 + $1.stockQuantity }
    }

    /// 保管場所ごとの酒種別内訳文字列を生成する（互換用）
    public func categorySummary(for locationName: String, in items: [BeverageItem]) -> String {
        let locationItems = items.filter { $0.storageLocation == locationName && $0.stockQuantity > 0 }
        guard !locationItems.isEmpty else { return "在庫なし" }

        var counts: [BeverageCategory: Int] = [:]
        for item in locationItems {
            counts[item.category, default: 0] += item.stockQuantity
        }

        let summaryParts = BeverageCategory.allCases.compactMap { category -> String? in
            guard let count = counts[category], count > 0 else { return nil }
            return "\(category.displayName) \(count)本"
        }

        return summaryParts.joined(separator: " / ")
    }

    /// 保管場所ごとの「酒種ごとの内訳（名称と本数）」を縦並び用にタプルの配列として返す
    public func categorySummaryList(for locationName: String, in items: [BeverageItem]) -> [(categoryName: String, count: Int)] {
        let locationItems = items.filter { $0.storageLocation == locationName && $0.stockQuantity > 0 }
        guard !locationItems.isEmpty else { return [] }

        var counts: [BeverageCategory: Int] = [:]
        for item in locationItems {
            counts[item.category, default: 0] += item.stockQuantity
        }

        return BeverageCategory.allCases.compactMap { category in
            guard let count = counts[category], count > 0 else { return nil }
            return (categoryName: category.displayName, count: count)
        }
    }

    /// 特定の保管場所におけるフィルタリング済みアイテム一覧
    public func filteredItems(_ items: [BeverageItem], for locationName: String) -> [BeverageItem] {
        items.filter { item in
            let matchesLocation = item.storageLocation == locationName
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.producer.localizedCaseInsensitiveContains(searchText)
            return matchesLocation && matchesSearch
        }
    }

    /// 「このボトルを開ける」アクション
    public func consumeBottle(item: BeverageItem) throws {
        try consumeUseCase.executeConsumption(for: item)
    }
    
    /// 指定したアイテムを削除する
    public func deleteItem(_ item: BeverageItem, modelContext: ModelContext) {
        let repository = BeverageRepository(modelContext: modelContext)
        repository.deleteItem(item)
    }
}
