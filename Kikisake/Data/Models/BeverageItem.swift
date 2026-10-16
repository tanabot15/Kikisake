//
//  BeverageItem.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

/// 醸造酒の在庫およびベースアイテム情報を保持するSwiftDataモデル
@Model
public final class BeverageItem {
    @Attribute(.unique) public var id: UUID
    public var name: String                  // 銘柄名
    public var producer: String              // 生産者 / 蔵元 / ブルワリー
    public var categoryRawValue: String      // 酒種（BeverageCategory）
    public var region: String                // 生産地
    public var vintage: String?              // ヴィンテージ / 製造年月
    public var alcoholByVolume: Double?      // アルコール度数 (例: 14.5)
    public var price: Int?                   // 価格

    // インベントリ（在庫）管理
    public var stockQuantity: Int
    public var storageLocation: String
    public var purchaseDate: Date?

    // 写真データ
    @Attribute(.externalStorage) public var imageDatas: [Data]?

    // 酒種ごとの固有メタデータをJSON形式で保持
    public var specificMetadataJSON: String?

    // リレーションシップ：1つのアイテムに対して複数のテイスティングログ
    @Relationship(deleteRule: .cascade, inverse: \TastingLog.item)
    public var tastingLogs: [TastingLog]?

    public var createdAt: Date

    public var category: BeverageCategory {
        get { BeverageCategory(rawValue: categoryRawValue) ?? .wine }
        set { categoryRawValue = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        name: String,
        producer: String,
        category: BeverageCategory,
        region: String = "",
        vintage: String? = nil,
        alcoholByVolume: Double? = nil,
        price: Int? = nil,
        stockQuantity: Int = 1,
        storageLocation: String = "ワインセラー",
        purchaseDate: Date? = nil,
        imageDatas: [Data]? = nil,
        specificMetadataJSON: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.producer = producer
        self.categoryRawValue = category.rawValue
        self.region = region
        self.vintage = vintage
        self.alcoholByVolume = alcoholByVolume
        self.price = price
        self.stockQuantity = stockQuantity
        self.storageLocation = storageLocation
        self.purchaseDate = purchaseDate
        self.imageDatas = imageDatas
        self.specificMetadataJSON = specificMetadataJSON
        self.tastingLogs = []
        self.createdAt = createdAt
    }
}
