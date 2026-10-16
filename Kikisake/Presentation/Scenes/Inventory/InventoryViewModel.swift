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

    /// 保管場所ごとのアイコン（SFSymbol）を返すヘルパー
    public func iconName(for location: String) -> String {
        switch location {
        case "ワインセラー": return "cabinet.fill"
        case "冷蔵庫": return "refrigerator.fill"
        case "常温": return "humidity.fill"
        default: return "shippingbox.fill"
        }
    }

    /// 保管場所ごとの総本数を計算する
    public func totalCount(for location: String, in items: [BeverageItem]) -> Int {
        items
            .filter { $0.storageLocation == location && $0.stockQuantity > 0 }
            .reduce(0) { $0 + $1.stockQuantity }
    }

    /// 保管場所ごとの「酒種ごとの本数」の内訳文字列を生成する（例: "ワイン 2本 / 日本酒 1本"）
    public func categorySummary(for location: String, in items: [BeverageItem]) -> String {
        let locationItems = items.filter { $0.storageLocation == location && $0.stockQuantity > 0 }
        guard !locationItems.isEmpty else { return "在庫なし" }

        var counts: [BeverageCategory: Int] = [:]
        for item in locationItems {
            counts[item.category, default: 0] += item.stockQuantity
        }

        // 存在する酒種のみを抽出してテキスト化
        let summaryParts = BeverageCategory.allCases.compactMap { category -> String? in
            guard let count = counts[category], count > 0 else { return nil }
            return "\(category.displayName) \(count)本"
        }

        return summaryParts.joined(separator: " / ")
    }

    /// 選択中の保管場所および検索キーワードで在庫をフィルタリングする
    public func filteredItems(_ items: [BeverageItem]) -> [BeverageItem] {
        items.filter { item in
            let matchesLocation = (selectedLocationFilter == nil || item.storageLocation == selectedLocationFilter)
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
}
