//
//  AddFlowViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

/// 新規登録および在庫消費からのログ作成フローを管理するViewModel
@Observable
public final class AddFlowViewModel {
    public var currentStep: Int = 1

    // Step 1: 酒種選択 ＆ 在庫からの読み込み
    public var selectedCategory: BeverageCategory = .wine
    public var sourceItem: BeverageItem? = nil

    // Step 2: 基本情報
    public var name: String = ""
    public var producer: String = ""
    public var region: String = ""
    public var vintage: String = ""
    public var priceString: String = ""
    public var storageLocation: String = AppConstants.Storage.defaultLocation

    // Step 3: 構造化テイスティング
    public var appearanceNotes: String = "ルビーレッド"
    public var selectedAromaTags: [String] = []
    public var sweetness: Double = 2.5
    public var acidity: Double = 2.5
    public var bitternessOrTannin: Double = 2.5
    public var body: Double = 2.5
    public var finishLength: Double = 2.5

    // Step 4: 総合評価・メモ
    public var rating: Double = 4.0
    public var memo: String = ""
    public var tastingDate: Date = Date()

    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {}

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
    }

    /// データを保存する（新規アイテム作成、または在庫からの消費＋ログ作成）
    public func save(modelContext: ModelContext) throws {
        let price = Int(priceString)

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
                stockQuantity: 0, // 新規作成してすぐ飲む場合は在庫0または1
                storageLocation: storageLocation
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
    }
}
