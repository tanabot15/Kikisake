//
//  BeverageSpecificMetadata.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/16.
//

import Foundation

/// ワインのブレンド品種と割合の構造体
public struct BlendComponent: Codable, Identifiable, Hashable {
    public var id: UUID
    public var variety: String
    public var percentage: Int?

    public init(id: UUID = UUID(), variety: String, percentage: Int? = nil) {
        self.id = id
        self.variety = variety
        self.percentage = percentage
    }
}

/// ワイン固有のメタデータ
public struct WineSpecificMetadata: Codable, Hashable {
    public var wineType: String
    public var grapeVarieties: String
    public var blendComponents: [BlendComponent]
    public var appellation: String?

    public init(
        wineType: String,
        grapeVarieties: String,
        blendComponents: [BlendComponent] = [],
        appellation: String? = nil
    ) {
        self.wineType = wineType
        self.grapeVarieties = grapeVarieties
        self.blendComponents = blendComponents
        self.appellation = appellation
    }
}

/// 日本酒固有のメタデータ
public struct SakeSpecificMetadata: Codable, Hashable {
    public var specificName: String
    public var riceVariety: String
    public var polishingRate: String
    public var sakeMeterValue: String

    public init(
        specificName: String,
        riceVariety: String,
        polishingRate: String,
        sakeMeterValue: String
    ) {
        self.specificName = specificName
        self.riceVariety = riceVariety
        self.polishingRate = polishingRate
        self.sakeMeterValue = sakeMeterValue
    }
}

/// ビール固有のメタデータ
public struct BeerSpecificMetadata: Codable, Hashable {
    public var beerStyle: String
    public var ibu: String

    public init(beerStyle: String, ibu: String) {
        self.beerStyle = beerStyle
        self.ibu = ibu
    }
}
