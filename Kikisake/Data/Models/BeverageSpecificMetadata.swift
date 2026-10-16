//
//  BeverageSpecificMetadata.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/16.
//

import Foundation

/// ワイン固有のメタデータ
public struct WineSpecificMetadata: Codable {
    public var wineType: String       // 例: "赤", "白", "ロゼ", "スパークリング", "オレンジ"
    public var grapeVarieties: String // 例: "カベルネ・ソーヴィニヨン"
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
