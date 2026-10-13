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
final class BeverageItem {
    @Attribute(.unique) var id: UUID
    var name: String                  // 銘柄名
    var producer: String              // 生産者 / 蔵元 / ブルワリー
    var categoryRawValue: String      // 酒種（BeverageCategory）
    var region: String                // 生産地（例: ボルドー, 新潟県, ベルギー）
    var vintage: String?              // ヴィンテージ / 製造年月
    var price: Int?                   // 価格

    // インベントリ（在庫）管理
    var stockQuantity: Int            // 在庫数（0の場合は消費済み）
    var storageLocation: String       // 保管場所（ワインセラー / 冷蔵庫 等）
    var purchaseDate: Date?           // 購入日

    // 写真データ
    @Attribute(.externalStorage) var imageDatas: [Data]?

    // リレーションシップ：1つのアイテムに対して複数のテイスティングログ
    @Relationship(deleteRule: .cascade, inverse: \TastingLog.item)
    var tastingLogs: [TastingLog]?

    var createdAt: Date

    /// 保存されている文字列から酒種列挙型を取得・設定するコンピューテッドプロパティ
    var category: BeverageCategory {
        get { BeverageCategory(rawValue: categoryRawValue) ?? .wine }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        producer: String,
        category: BeverageCategory,
        region: String = "",
        vintage: String? = nil,
        price: Int? = nil,
        stockQuantity: Int = 1,
        storageLocation: String = "ワインセラー",
        purchaseDate: Date? = nil,
        imageDatas: [Data]? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.producer = producer
        self.categoryRawValue = category.rawValue
        self.region = region
        self.vintage = vintage
        self.price = price
        self.stockQuantity = stockQuantity
        self.storageLocation = storageLocation
        self.purchaseDate = purchaseDate
        self.imageDatas = imageDatas
        self.tastingLogs = []
        self.createdAt = createdAt
    }
}
