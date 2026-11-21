//  BackupDTOs.swift
//  Kikisake

import Foundation

/// バックアップJSONの最上位ルート構造体
public struct BackupPayload: Codable {
    public let schemaVersion: Int
    public let exportedAt: Date
    public let appVersion: String
    public let storageLocations: [StorageLocationDTO]
    public let beverageItems: [BeverageItemDTO]

    public init(
        schemaVersion: Int = 1,
        exportedAt: Date = Date(),
        appVersion: String = "1.0",
        storageLocations: [StorageLocationDTO],
        beverageItems: [BeverageItemDTO]
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.appVersion = appVersion
        self.storageLocations = storageLocations
        self.beverageItems = beverageItems
    }
}

// MARK: - DTOs

public struct StorageLocationDTO: Codable {
    public let id: UUID
    public let name: String
    public let typeRawValue: String
    public let memo: String
    public let isGridEnabled: Bool
    public let gridRows: Int
    public let gridColumns: Int
    public let createdAt: Date

    public init(from model: StorageLocation) {
        self.id = model.id
        self.name = model.name
        self.typeRawValue = model.typeRawValue
        self.memo = model.memo
        self.isGridEnabled = model.isGridEnabled
        self.gridRows = model.gridRows
        self.gridColumns = model.gridColumns
        self.createdAt = model.createdAt
    }

    public func toModel() -> StorageLocation {
        let type = StorageCategoryType(rawValue: typeRawValue) ?? .cellar
        return StorageLocation(
            id: id,
            name: name,
            type: type,
            memo: memo,
            isGridEnabled: isGridEnabled,
            gridRows: gridRows,
            gridColumns: gridColumns,
            createdAt: createdAt
        )
    }
}

public struct BeverageItemDTO: Codable {
    public let id: UUID
    public let name: String
    public let producer: String
    public let categoryRawValue: String
    public let region: String
    public let vintage: String?
    public let alcoholByVolume: Double?
    public let price: Int?
    public let storageLocation: String
    public let purchaseDate: Date?
    public let gridRow: Int?
    public let gridColumn: Int?
    public let imageDatas: [Data]?
    public let specificMetadataJSON: String?
    public let createdAt: Date
    public let tastingLogs: [TastingLogDTO]

    public init(from model: BeverageItem) {
        self.id = model.id
        self.name = model.name
        self.producer = model.producer
        self.categoryRawValue = model.categoryRawValue
        self.region = model.region
        self.vintage = model.vintage
        self.alcoholByVolume = model.alcoholByVolume
        self.price = model.price
        self.storageLocation = model.storageLocation
        self.purchaseDate = model.purchaseDate
        self.gridRow = model.gridRow
        self.gridColumn = model.gridColumn
        self.imageDatas = model.imageDatas
        self.specificMetadataJSON = model.specificMetadataJSON
        self.createdAt = model.createdAt
        self.tastingLogs = (model.tastingLogs ?? []).map { TastingLogDTO(from: $0) }
    }

    public func toModel() -> BeverageItem {
        let category = BeverageCategory(rawValue: categoryRawValue) ?? .wine
        let item = BeverageItem(
            id: id,
            name: name,
            producer: producer,
            category: category,
            region: region,
            vintage: vintage,
            alcoholByVolume: alcoholByVolume,
            price: price,
            storageLocation: storageLocation,
            purchaseDate: purchaseDate,
            gridRow: gridRow,
            gridColumn: gridColumn,
            imageDatas: imageDatas,
            specificMetadataJSON: specificMetadataJSON,
            createdAt: createdAt
        )
        // 子ログの紐付け復元
        let logs = tastingLogs.map { $0.toModel(parentItem: item) }
        item.tastingLogs = logs
        return item
    }
}

public struct TastingLogDTO: Codable {
    public let id: UUID
    public let date: Date
    public let rating: Double
    public let appearanceNotes: String
    public let appearanceColorHex: String
    public let aromaTags: [String]
    public let sweetness: Double
    public let saltiness: Double
    public let acidity: Double
    public let bitterness: Double
    public let umami: Double
    public let tannin: Double?
    public let body: Double
    public let balanceTags: [String]
    public let finishLength: Double
    public let isCostEffective: Bool
    public let isWillingToRepeat: Bool
    public let hasAgingPotential: Bool
    public let alcoholByVolume: Double?
    public let specificDataJSON: String?
    public let memo: String
    public let isEvaluated: Bool

    public init(from model: TastingLog) {
        self.id = model.id
        self.date = model.date
        self.rating = model.rating
        self.appearanceNotes = model.appearanceNotes
        self.appearanceColorHex = model.appearanceColorHex
        self.aromaTags = model.aromaTags
        self.sweetness = model.sweetness
        self.saltiness = model.saltiness
        self.acidity = model.acidity
        self.bitterness = model.bitterness
        self.umami = model.umami
        self.tannin = model.tannin
        self.body = model.body
        self.balanceTags = model.balanceTags
        self.finishLength = model.finishLength
        self.isCostEffective = model.isCostEffective
        self.isWillingToRepeat = model.isWillingToRepeat
        self.hasAgingPotential = model.hasAgingPotential
        self.alcoholByVolume = model.alcoholByVolume
        self.specificDataJSON = model.specificDataJSON
        self.memo = model.memo
        self.isEvaluated = model.isEvaluated
    }

    public func toModel(parentItem: BeverageItem) -> TastingLog {
        return TastingLog(
            id: id,
            date: date,
            rating: rating,
            appearanceNotes: appearanceNotes,
            appearanceColorHex: appearanceColorHex,
            aromaTags: aromaTags,
            sweetness: sweetness,
            saltiness: saltiness,
            acidity: acidity,
            bitterness: bitterness,
            umami: umami,
            tannin: tannin,
            body: body,
            balanceTags: balanceTags,
            finishLength: finishLength,
            isCostEffective: isCostEffective,
            isWillingToRepeat: isWillingToRepeat,
            hasAgingPotential: hasAgingPotential,
            alcoholByVolume: alcoholByVolume,
            specificDataJSON: specificDataJSON,
            memo: memo,
            isEvaluated: isEvaluated,
            item: parentItem
        )
    }
}

// MARK: - SwiftUI File Document Wrapper

import UniformTypeIdentifiers
import SwiftUI

public struct BackupFileDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.json] }

    public var payloadData: Data

    public init(payloadData: Data) {
        self.payloadData = payloadData
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.payloadData = data
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: payloadData)
    }
}
