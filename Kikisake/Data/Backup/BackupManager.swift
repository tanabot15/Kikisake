//
//  BackupManager.swift
//  Kikisake
//

import Foundation
import SwiftData

public enum RestoreStrategy: Sendable {
    case replaceAll
    case merge
}

public enum BackupError: LocalizedError {
    case exportFailed(String)
    case importFailed(String)
    case unsupportedSchemaVersion(Int)
    case invalidFile

    public var errorDescription: String? {
        switch self {
        case .exportFailed(let msg):
            String(localized: "エクスポートに失敗しました: \(msg)")
        case .importFailed(let msg):
            String(localized: "リストアに失敗しました: \(msg)")
        case .unsupportedSchemaVersion(let ver):
            String(localized: "サポートされていないデータバージョンです (Version: \(ver))")
        case .invalidFile:
            String(localized: "無効なバックアップファイルです。")
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
            let locations = try modelContext.fetch(FetchDescriptor<StorageLocation>())
            let items = try modelContext.fetch(FetchDescriptor<BeverageItem>())

            let payload = BackupPayload(
                schemaVersion: Self.currentSchemaVersion,
                exportedAt: Date(),
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                storageLocations: locations.map(StorageLocationDTO.init(from:)),
                beverageItems: items.map(BeverageItemDTO.init(from:))
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
            throw BackupError.importFailed(error.localizedDescription)
        }

        guard payload.schemaVersion <= Self.currentSchemaVersion else {
            throw BackupError.unsupportedSchemaVersion(payload.schemaVersion)
        }

        do {
            switch strategy {
            case .replaceAll:
                try replaceAllData(with: payload, in: modelContext)
            case .merge:
                try mergeData(from: payload, into: modelContext)
            }

            try modelContext.save()
        } catch {
            throw BackupError.importFailed(error.localizedDescription)
        }
    }

    private func replaceAllData(with payload: BackupPayload, in modelContext: ModelContext) throws {
        try modelContext.delete(model: TastingLog.self)
        try modelContext.delete(model: BeverageItem.self)
        try modelContext.delete(model: StorageLocation.self)
        try modelContext.save()

        for locDTO in payload.storageLocations {
            modelContext.insert(locDTO.toModel())
        }

        for itemDTO in payload.beverageItems {
            modelContext.insert(itemDTO.toModel())
        }
    }

    private func mergeData(from payload: BackupPayload, into modelContext: ModelContext) throws {
        let existingLocations = try modelContext.fetch(FetchDescriptor<StorageLocation>())
        let existingLocMap = Dictionary(uniqueKeysWithValues: existingLocations.map { ($0.id, $0) })

        for locDTO in payload.storageLocations {
            if let existing = existingLocMap[locDTO.id] {
                locDTO.apply(to: existing)
            } else {
                modelContext.insert(locDTO.toModel())
            }
        }

        let existingItems = try modelContext.fetch(FetchDescriptor<BeverageItem>())
        let existingItemMap = Dictionary(uniqueKeysWithValues: existingItems.map { ($0.id, $0) })

        for itemDTO in payload.beverageItems {
            if let existing = existingItemMap[itemDTO.id] {
                itemDTO.apply(to: existing)
            } else {
                modelContext.insert(itemDTO.toModel())
            }
        }
    }
}
