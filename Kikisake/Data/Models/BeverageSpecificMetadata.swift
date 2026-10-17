//
//  BeverageSpecificMetadata.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/16.
//

import Foundation

/// ワインのブレンド品種と割合の構造体
public struct BlendComponent: Codable, Identifiable, Hashable {
    public var id: UUID = UUID()
    public var variety: String // 品種名 (例: "メルロ")
    public var percentage: Int? // 割合％ (例: 40)

    public init(id: UUID = UUID(), variety: String, percentage: Int? = nil) {
        self.id = id
        self.variety = variety
        self.percentage = percentage
    }
}

/// ワイン固有のメタデータ
public struct WineSpecificMetadata: Codable {
    public var wineType: String           // 例: "赤", "白", "ロゼ", "スパークリング", "オレンジ"
    public var grapeVarieties: String     // 互換性維持用の旧主要品種文字列
    public var blendComponents: [BlendComponent] // アッサンブラージュ品種と割合のリスト
    public var appellation: String?       // 原産地呼称 (例: AOC, DOCG, AVA など)
}

/// 日本酒固有のメタデータ
public struct SakeSpecificMetadata: Codable {
    public var specificName: String   // 例: "純米大吟醸", "特別純米", "生原酒"
    public var riceVariety: String    // 例: "山田錦"
    public var polishingRate: String  // 例: "50%"
    public var sakeMeterValue: String // 例: "+3.0"
}

/// ビール固有のメタデータ
public struct BeerSpecificMetadata: Codable {
    public var beerStyle: String      // 例: "IPA", "Pilsner", "Stout"
    public var ibu: String            // 例: "45"
}
