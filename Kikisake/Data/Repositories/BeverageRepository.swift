//
//  BeverageRepository.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData
import os

/// 醸造酒・在庫データの永続化操作を担当するリポジトリ
@MainActor
public final class BeverageRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// すべての在庫・アイテムを取得する
    /// - Returns: BeverageItemの配列
    public func fetchAllItems() -> [BeverageItem] {
        let descriptor = FetchDescriptor<BeverageItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            AppLogger.persistence.error("Failed to fetch beverage items: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    /// 新規アイテムを追加する
    /// - Parameter item: 追加する BeverageItem
    public func addItem(_ item: BeverageItem) {
        modelContext.insert(item)
        saveContext()
    }

    /// 指定したアイテムを削除する
    /// - Parameter item: 削除する BeverageItem
    public func deleteItem(_ item: BeverageItem) {
        modelContext.delete(item)
        saveContext()
    }

    /// 変更を永続化する
    public func saveContext() {
        do {
            try modelContext.save()
            AppLogger.persistence.info("Successfully saved BeverageItem changes.")
        } catch {
            AppLogger.persistence.error("Failed to save ModelContext: \(error.localizedDescription, privacy: .public)")
        }
    }
}
