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
    public var selectedLocationFilter: String = "All"
    public var searchText: String = ""

    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {}

    /// 保管場所や検索キーワードで在庫をフィルタリングする
    public func filteredItems(_ items: [BeverageItem]) -> [BeverageItem] {
        items.filter { item in
            let matchesLocation = (selectedLocationFilter == "All" || item.storageLocation == selectedLocationFilter)
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
