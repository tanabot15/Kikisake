//  BackupManager.swift
//  Kikisake

import Foundation
import SwiftData

public enum RestoreStrategy {
    case replaceAll // 全上書き（既存データを破棄）
    case merge      // マージ（重複IDは更新、未存在IDは追加）
}

public enum BackupError: LocalizedError {
    case exportFailed(String)
    case importFailed(String)
    case unsupportedSchemaVersion(Int)
    case invalidFile

    public var errorDescription: String? {
        switch self {
        case .exportFailed(let msg): return "エクスポートに失敗しました: \(msg)"
        case .importFailed(let msg): return "リストアに失敗しました: \(msg)"
        case .unsupportedSchemaVersion(let ver): return "サポートされていないデータバージョンです (Version: \(ver))"
        case .invalidFile: return "無効なバックアップファイルです。"
        }
    }
}

@MainActor
public final class BackupManager {
    public static let shared = BackupManager()
    public static let currentSchemaVersion = 1

    private init() {}

    /// 推奨バックアップファイル名を生成（例: Kikisake_Backup_20261027_214500.json）
    public func generateBackupFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())
        return "Kikisake_Backup_\(timestamp).json"
    }

    /// データのエクスポート（JSON Dataを作成）
    public func exportData(modelContext: ModelContext) throws -> Data {
        do {
            // 全モデルのフェッチ
            let locations = try modelContext.fetch(FetchDescriptor<StorageLocation>())
            let items = try modelContext.fetch(FetchDescriptor<BeverageItem>())

            let locationDTOs = locations.map { StorageLocationDTO(from: $0) }
            let itemDTOs = items.map { BeverageItemDTO(from: $0) }

            let payload = BackupPayload(
                schemaVersion: Self.currentSchemaVersion,
                exportedAt: Date(),
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                storageLocations: locationDTOs,
                beverageItems: itemDTOs
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601

            return try encoder.encode(payload)
        } catch {
            throw BackupError.exportFailed(error.localizedDescription)
        }
    }

    /// データのリストア（JSON Dataからの復元）
    public func importData(from data: Data, strategy: RestoreStrategy, modelContext: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let payload: BackupPayload
        do {
            payload = try decoder.decode(BackupPayload.self, from: data)
        } catch {
            throw BackupError.importFailed("JSON解析エラー: \(error.localizedDescription)")
        }

        // バージョンチェック
        guard payload.schemaVersion <= Self.currentSchemaVersion else {
            throw BackupError.unsupportedSchemaVersion(payload.schemaVersion)
        }

        do {
            switch strategy {
            case .replaceAll:
                // 1. 既存データをクリア
                try clearAllData(modelContext: modelContext)

                // 2. StorageLocation の復元
                for locDTO in payload.storageLocations {
                    modelContext.insert(locDTO.toModel())
                }

                // 3. BeverageItem と TastingLog の復元
                for itemDTO in payload.beverageItems {
                    let newItem = itemDTO.toModel()
                    modelContext.insert(newItem)
                }

            case .merge:
                // 既存のStorageLocationを取得
                let existingLocations = try modelContext.fetch(FetchDescriptor<StorageLocation>())
                let existingLocMap = Dictionary(uniqueKeysWithValues: existingLocations.map { ($0.id, $0) })

                for locDTO in payload.storageLocations {
                    if let existing = existingLocMap[locDTO.id] {
                        existing.name = locDTO.name
                        existing.typeRawValue = locDTO.typeRawValue
                        existing.memo = locDTO.memo
                        existing.isGridEnabled = locDTO.isGridEnabled
                        existing.gridRows = locDTO.gridRows
                        existing.gridColumns = locDTO.gridColumns
                    } else {
                        modelContext.insert(locDTO.toModel())
                    }
                }

                // 既存のBeverageItemを取得
                let existingItems = try modelContext.fetch(FetchDescriptor<BeverageItem>())
                let existingItemMap = Dictionary(uniqueKeysWithValues: existingItems.map { ($0.id, $0) })

                for itemDTO in payload.beverageItems {
                    if let existing = existingItemMap[itemDTO.id] {
                        existing.name = itemDTO.name
                        existing.producer = itemDTO.producer
                        existing.categoryRawValue = itemDTO.categoryRawValue
                        existing.region = itemDTO.region
                        existing.vintage = itemDTO.vintage
                        existing.alcoholByVolume = itemDTO.alcoholByVolume
                        existing.price = itemDTO.price
                        existing.storageLocation = itemDTO.storageLocation
                        existing.purchaseDate = itemDTO.purchaseDate
                        existing.gridRow = itemDTO.gridRow
                        existing.gridColumn = itemDTO.gridColumn
                        existing.imageDatas = itemDTO.imageDatas
                        existing.specificMetadataJSON = itemDTO.specificMetadataJSON
                    } else {
                        modelContext.insert(itemDTO.toModel())
                    }
                }
            }

            // 保存
            try modelContext.save()
        } catch {
            throw BackupError.importFailed(error.localizedDescription)
        }
    }

    /// データベース上のすべてのエンティティを安全に削除
    private func clearAllData(modelContext: ModelContext) throws {
        try modelContext.delete(model: TastingLog.self)
        try modelContext.delete(model: BeverageItem.self)
        try modelContext.delete(model: StorageLocation.self)
        try modelContext.save()
    }
}
