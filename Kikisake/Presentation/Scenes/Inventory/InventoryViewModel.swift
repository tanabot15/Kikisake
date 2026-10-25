//  InventoryViewModel.swift
//  Kikisake

import Foundation
import SwiftData
import SwiftUI

/// セラー＆冷蔵庫の在庫管理画面のビジネスロジック・状態管理
@Observable
public final class InventoryViewModel {
    public var selectedLocationFilter: String? = nil
    public var searchText: String = ""
    
    // --- フィルター条件 ---
    public var selectedStorageCategoryType: StorageCategoryType? = nil
    public var selectedCategory: BeverageCategory? = nil
    public var selectedSubCategory: String? = nil

    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {}

    /// デフォルト状態から何等かのフィルター条件が追加されているか
    public var hasActiveFilters: Bool {
        selectedStorageCategoryType != nil || selectedCategory != nil || selectedSubCategory != nil || !searchText.isEmpty
    }

    /// フィルター条件をデフォルトにリセットする
    public func resetFilters() {
        selectedStorageCategoryType = nil
        selectedCategory = nil
        selectedSubCategory = nil
        searchText = ""
    }

    /// 保管場所の種類によるフィルタリング
    public func filteredLocations(_ locations: [StorageLocation]) -> [StorageLocation] {
        locations.filter { loc in
            if let type = selectedStorageCategoryType {
                return loc.type == type
            }
            return true
        }
    }

    /// 保管場所ごとの総本数を計算する
    public func totalCount(for locationName: String, in items: [BeverageItem]) -> Int {
        items
            .filter { $0.storageLocation == locationName && $0.stockQuantity > 0 }
            .reduce(0) { $0 + $1.stockQuantity }
    }

    /// 保管場所ごとの酒種別内訳文字列を生成する（互換用）
    public func categorySummary(for locationName: String, in items: [BeverageItem]) -> String {
        let locationItems = filteredItems(items, for: locationName).filter { $0.stockQuantity > 0 }
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
        let locationItems = filteredItems(items, for: locationName).filter { $0.stockQuantity > 0 }
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
            
            // 1. 酒種フィルター
            let matchesCategory: Bool = {
                guard let category = selectedCategory else { return true }
                return item.category == category
            }()

            // 2. サブカテゴリフィルター
            let matchesSubCategory: Bool = {
                guard let subCategory = selectedSubCategory, let category = selectedCategory else { return true }
                guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else { return false }
                
                switch category {
                case .wine:
                    if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                        return meta.wineType == subCategory
                    }
                case .sake:
                    if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                        return meta.specificName == subCategory
                    }
                case .beer:
                    if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                        return meta.beerStyle == subCategory
                    }
                }
                return false
            }()

            // 3. 検索キーワードフィルター
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.producer.localizedCaseInsensitiveContains(searchText)

            return matchesLocation && matchesCategory && matchesSubCategory && matchesSearch
        }
    }

    /// 選択された酒種に応じて動的にサブタイプのリストを取得する
    public func availableSubCategories(from items: [BeverageItem]) -> [String] {
        guard let category = selectedCategory else { return [] }
        var subTypes = Set<String>()

        for item in items {
            guard item.category == category,
                  let json = item.specificMetadataJSON,
                  let data = json.data(using: .utf8) else { continue }

            switch category {
            case .wine:
                if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data), !meta.wineType.isEmpty {
                    subTypes.insert(meta.wineType)
                }
            case .sake:
                if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data), !meta.specificName.isEmpty {
                    subTypes.insert(meta.specificName)
                }
            case .beer:
                if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data), !meta.beerStyle.isEmpty {
                    subTypes.insert(meta.beerStyle)
                }
            }
        }
        return Array(subTypes).sorted()
    }

    /// 「このボトルを開ける」アクション
    public func consumeBottle(item: BeverageItem) throws {
        try consumeUseCase.executeConsumption(for: item)
    }
    
    /// 指定したアイテムの保管場所を変更（移動）する
    public func moveItem(_ item: BeverageItem, to newLocationName: String, modelContext: ModelContext) {
        item.storageLocation = newLocationName
        try? modelContext.save()
    }
    
    /// リスト表示における並び替え処理（ドラッグによる順序変更）
    public func moveItemsOrder(in items: [BeverageItem], from source: IndexSet, to destination: Int, modelContext: ModelContext) {
        var updatedItems = items
        updatedItems.move(fromOffsets: source, toOffset: destination)
        
        try? modelContext.save()
    }
    
    /// 指定したアイテムを削除する
    public func deleteItem(_ item: BeverageItem, modelContext: ModelContext) {
        let repository = BeverageRepository(modelContext: modelContext)
        repository.deleteItem(item)
    }
}
