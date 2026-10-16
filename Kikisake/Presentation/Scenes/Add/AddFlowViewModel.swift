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
    public var priceString: String = ""
    public var storageLocation: String = AppConstants.Storage.defaultLocation

    // ✨ 酒種ごとの固有入力パラメータ
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

    // Step 3: 香り
    public var selectedAromaTags: [String] = []

    // Step 4: 味わい
    public var sweetness: Double = 2.5
    public var acidity: Double = 2.5
    public var bitternessOrTannin: Double = 2.5
    public var body: Double = 2.5
    public var finishLength: Double = 2.5

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
        self.selectedAromaTags = []
        self.sweetness = 2.5
        self.acidity = 2.5
        self.bitternessOrTannin = 2.5
        self.body = 2.5
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
        let price = Int(priceString)
        let metadataJSON = buildMetadataJSON()

        let newItem = BeverageItem(
            name: name,
            producer: producer,
            category: selectedCategory,
            region: region,
            vintage: vintage.isEmpty ? nil : vintage,
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
            aromaTags: selectedAromaTags,
            sweetness: sweetness,
            acidity: acidity,
            bitternessOrTannin: bitternessOrTannin,
            body: body,
            finishLength: finishLength,
            memo: memo,
            item: targetItem
        )

        modelContext.insert(newLog)
        try modelContext.save()

        reset()
    }
}
