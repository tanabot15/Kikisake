//
//  AddFlowViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

/// 新規登録およびテイスティングフローを管理するViewModel
@Observable
public final class AddFlowViewModel {
    public var currentStep: Int = 1

    // Step 1: 一般的な情報
    public var selectedCategory: BeverageCategory = .wine
    public var sourceItem: BeverageItem? = nil
    public var name: String = ""
    public var producer: String = ""
    public var region: String = ""
    public var vintage: String = ""
    public var abvString: String = ""
    public var priceString: String = ""
    public var storageLocation: String = AppConstants.Storage.defaultLocation

    // - ワイン用
    public var wineType: String = "赤"
    public var grapeVarieties: String = ""
    // - 日本酒用
    public var sakeSpecificName: String = "純米大吟醸"
    public var riceVariety: String = ""
    public var polishingRate: String = ""
    public var sakeMeterValue: String = ""
    // - ビール用
    public var beerStyle: String = ""
    public var ibu: String = ""

    // Step 2: 色・外観
    public var appearanceNotes: String = "ルビーレッド"
    public var appearanceColorHex: String = "#991A33"

    // Step 3: 香り
    public var selectedAromaTags: [String] = []

    // Step 4: 味わい
    public var sweetness: Double = 2.5  // 甘味
    public var saltiness: Double = 2.5  // 塩味
    public var acidity: Double = 2.5    // 酸味
    public var bitterness: Double = 2.5 // 苦味
    public var umami: Double = 2.5      // 旨味

    // 選択項目
    public var tannin: Double = 2.5     // タンニン（渋味）
    public var body: Double = 2.5       // ボディ
    public var selectedBalanceTags: [String] = [] // バランス評価タグ
    public var finishLength: Double = 2.5// 余韻の長さ

    // Step 5: 最終ステップ（総合評価・メモ）
    public var rating: Double = 4.0
    public var memo: String = ""
    public var tastingDate: Date = Date()

    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {
        if let item = AppState.shared.openingItem {
            configureWithItem(item)
            self.currentStep = 2
            AppState.shared.openingItem = nil
        }
    }

    /// 入力されたフォームの情報をすべて初期状態にリセットする
    public func reset() {
        self.currentStep = 1
        self.selectedCategory = .wine
        self.sourceItem = nil
        self.name = ""
        self.producer = ""
        self.region = ""
        self.vintage = ""
        self.abvString = ""
        self.priceString = ""
        self.storageLocation = AppConstants.Storage.defaultLocation
        
        // 固有パラメータのリセット
        self.wineType = "赤"
        self.grapeVarieties = ""
        self.sakeSpecificName = "純米大吟醸"
        self.riceVariety = ""
        self.polishingRate = ""
        self.sakeMeterValue = ""
        self.beerStyle = ""
        self.ibu = ""

        self.appearanceNotes = "ルビーレッド"
        self.appearanceColorHex = "#991A33"
        self.selectedAromaTags = []
        self.sweetness = 2.5
        self.saltiness = 0.0
        self.acidity = 2.5
        self.bitterness = 2.5
        self.umami = 2.5
        self.tannin = 2.5
        self.body = 2.5
        self.selectedBalanceTags = []
        self.finishLength = 2.5
        self.rating = 4.0
        self.memo = ""
        self.tastingDate = Date()
    }

    /// 在庫アイテムを選択した際に入力値を初期化する
    public func configureWithItem(_ item: BeverageItem) {
        self.sourceItem = item
        self.selectedCategory = item.category
        self.name = item.name
        self.producer = item.producer
        self.region = item.region
        self.vintage = item.vintage ?? ""
        if let abv = item.alcoholByVolume {
            self.abvString = "\(abv)"
        }
        if let price = item.price {
            self.priceString = "\(price)"
        }
        self.storageLocation = item.storageLocation
        
        // 既存のJSONメタデータがあれば復元（必要に応じてデコード処理を記述可能）
    }

    /// 選択中の酒種に応じたメタデータのJSON文字列を生成する
    private func buildMetadataJSON() -> String? {
        let encoder = JSONEncoder()
        switch selectedCategory {
        case .wine:
            let meta = WineSpecificMetadata(wineType: wineType, grapeVarieties: grapeVarieties)
            return try? String(data: encoder.encode(meta), encoding: .utf8)
        case .sake:
            let meta = SakeSpecificMetadata(specificName: sakeSpecificName, riceVariety: riceVariety, polishingRate: polishingRate, sakeMeterValue: sakeMeterValue)
            return try? String(data: encoder.encode(meta), encoding: .utf8)
        case .beer:
            let meta = BeerSpecificMetadata(beerStyle: beerStyle, ibu: ibu)
            return try? String(data: encoder.encode(meta), encoding: .utf8)
        }
    }

    /// テイスティングを行わず、セラー・冷蔵庫の在庫として新規登録する
    public func saveAsInventoryOnly(modelContext: ModelContext) throws {
        let abv = Double(abvString)
        let price = Int(priceString)
        let metadataJSON = buildMetadataJSON()

        let newItem = BeverageItem(
            name: name,
            producer: producer,
            category: selectedCategory,
            region: region,
            vintage: vintage.isEmpty ? nil : vintage,
            alcoholByVolume: abv,
            price: price,
            stockQuantity: 1,
            storageLocation: storageLocation,
            specificMetadataJSON: metadataJSON
        )

        modelContext.insert(newItem)
        try modelContext.save()

        reset()
    }

    /// データを保存する（新規アイテム作成、または在庫からの消費 ＋ ログ作成）
    public func save(modelContext: ModelContext) throws {
        let price = Int(priceString)
        let isTanninApplicable: Bool = {
            guard selectedCategory == .wine else { return false }
            return wineType == "赤" || wineType == "ロゼ" || wineType == "オレンジ"
        }()
        
        let metadataJSON = buildMetadataJSON()

        let targetItem: BeverageItem
        if let existingItem = sourceItem {
            targetItem = existingItem
            try consumeUseCase.executeConsumption(for: existingItem)
        } else {
            targetItem = BeverageItem(
                name: name,
                producer: producer,
                category: selectedCategory,
                region: region,
                vintage: vintage.isEmpty ? nil : vintage,
                price: price,
                stockQuantity: 0,
                storageLocation: storageLocation,
                specificMetadataJSON: metadataJSON
            )
            modelContext.insert(targetItem)
        }

        let newLog = TastingLog(
            date: tastingDate,
            rating: rating,
            appearanceNotes: appearanceNotes,
            appearanceColorHex: appearanceColorHex,
            aromaTags: selectedAromaTags,
            sweetness: sweetness,
            saltiness: saltiness,
            acidity: acidity,
            bitterness: bitterness,
            umami: umami,
            tannin: isTanninApplicable ? tannin : nil,
            body: body,
            balanceTags: selectedBalanceTags,
            finishLength: finishLength,
            memo: memo,
            item: targetItem
        )

        modelContext.insert(newLog)
        try modelContext.save()

        reset()
    }
}
