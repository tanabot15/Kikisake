//
//  TastingRepository.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData
import os

/// テイスティングログの永続化操作を担当するリポジトリ
@MainActor
public final class TastingRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// すべてのテイスティングログを取得する
    /// - Returns: TastingLogの配列
    public func fetchAllLogs() -> [TastingLog] {
        let descriptor = FetchDescriptor<TastingLog>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            AppLogger.persistence.error("Failed to fetch tasting logs: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    /// 新規テイスティングログを追加する
    /// - Parameter log: 追加する TastingLog
    public func addLog(_ log: TastingLog) {
        modelContext.insert(log)
        saveContext()
    }

    /// 指定したテイスティングログを削除する
    /// - Parameter log: 削除する TastingLog
    public func deleteLog(_ log: TastingLog) {
        modelContext.delete(log)
        saveContext()
    }

    /// 変更を永続化する
    public func saveContext() {
        do {
            try modelContext.save()
            AppLogger.persistence.info("Successfully saved TastingLog changes.")
        } catch {
            AppLogger.persistence.error("Failed to save ModelContext for logs: \(error.localizedDescription, privacy: .public)")
        }
    }
}
