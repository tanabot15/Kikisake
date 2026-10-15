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
    }

    /// テイスティングを行わず、セラー・冷蔵庫の「在庫（stockQuantity: 1）」として新規登録する
    public func saveAsInventoryOnly(modelContext: ModelContext) throws {
        let price = Int(priceString)

        let newItem = BeverageItem(
            name: name,
            producer: producer,
            category: selectedCategory,
            region: region,
            vintage: vintage.isEmpty ? nil : vintage,
            price: price,
            stockQuantity: 1, // 新規在庫として1本登録
            storageLocation: storageLocation
        )

        modelContext.insert(newItem)
        try modelContext.save()

        // フォームをリセット
        reset()
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
                stockQuantity: 0, // すぐ飲む場合は在庫0（または新規作成してログ紐付け）
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

        // 保存成功後にフォームの状態を完全にリセット
        reset()
    }
}
