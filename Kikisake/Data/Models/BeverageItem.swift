//  BeverageItem.swift
//  Kikisake

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

    // 在庫管理
    public var storageLocation: String
    public var purchaseDate: Date?

    // セラー内グリッド位置情報（未配置の場合はnil）
    public var gridRow: Int?
    public var gridColumn: Int?

    // 写真データ（表示用：切り抜き済み or オリジナル）
    @Attribute(.externalStorage) public var imageDatas: [Data]?

    // ✨ 追加：切り抜き前のオリジナル写真データ（背景透過の復元・再適用用）
    @Attribute(.externalStorage) public var originalImageDatas: [Data]?
    
    // 裏面ラベル写真データ
    @Attribute(.externalStorage) public var backImageDatas: [Data]?

    // 背景をくり抜いたかどうか（デフォルトは true）
    public var isBackgroundRemoved: Bool = true

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
        storageLocation: String = "ワインセラー",
        purchaseDate: Date? = nil,
        gridRow: Int? = nil,
        gridColumn: Int? = nil,
        imageDatas: [Data]? = nil,
        originalImageDatas: [Data]? = nil,
        backImageDatas: [Data]? = nil,
        isBackgroundRemoved: Bool = true,
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
        self.storageLocation = storageLocation
        self.purchaseDate = purchaseDate
        self.gridRow = gridRow
        self.gridColumn = gridColumn
        self.imageDatas = imageDatas
        self.originalImageDatas = originalImageDatas
        self.backImageDatas = backImageDatas
        self.isBackgroundRemoved = isBackgroundRemoved
        self.specificMetadataJSON = specificMetadataJSON
        self.tastingLogs = []
        self.createdAt = createdAt
    }
}
