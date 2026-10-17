//
//  AddFlowViewModel.swift
//  Kikisake
//

import Foundation
import SwiftData
import SwiftUI

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
    public var storageLocation: String = "未設定"
    public var selectedImageData: Data? = nil

    // - ワイン用
    public var wineType: String = "赤"
    public var grapeVarieties: String = ""
    public var blendComponents: [BlendComponent] = [BlendComponent(variety: "", percentage: nil)]
    public var appellation: String = ""
    
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
    public var sweetness: Double = 2.5
    public var saltiness: Double = 2.5
    public var acidity: Double = 2.5
    public var bitterness: Double = 2.5
    public var umami: Double = 2.5

    public var tannin: Double = 2.5
    public var body: Double = 2.5
    public var selectedBalanceTags: [String] = []
    public var finishLength: Double = 2.5

    // Step 5: 総合評価・メモ
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

    public func addBlendComponent() {
        blendComponents.append(BlendComponent(variety: "", percentage: nil))
    }

    public func removeBlendComponent(at offsets: IndexSet) {
        blendComponents.remove(atOffsets: offsets)
    }

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
        self.storageLocation = "未設定"
        
        self.wineType = "赤"
        self.grapeVarieties = ""
        self.blendComponents = [BlendComponent(variety: "", percentage: nil)]
        self.appellation = ""
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
    }

    private func buildMetadataJSON() -> String? {
        let encoder = JSONEncoder()
        switch selectedCategory {
        case .wine:
            let mainVariety = blendComponents.first?.variety ?? ""
            let meta = WineSpecificMetadata(
                wineType: wineType,
                grapeVarieties: mainVariety,
                blendComponents: blendComponents.filter { !$0.variety.isEmpty },
                appellation: appellation.isEmpty ? nil : appellation
            )
            return try? String(data: encoder.encode(meta), encoding: .utf8)
            
        case .sake:
            let meta = SakeSpecificMetadata(specificName: sakeSpecificName, riceVariety: riceVariety, polishingRate: polishingRate, sakeMeterValue: sakeMeterValue)
            return try? String(data: encoder.encode(meta), encoding: .utf8)
            
        case .beer:
            let meta = BeerSpecificMetadata(beerStyle: beerStyle, ibu: ibu)
            return try? String(data: encoder.encode(meta), encoding: .utf8)
        }
    }

    private func ensureStorageLocationExists(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<StorageLocation>()
        let existingLocations = (try? modelContext.fetch(descriptor)) ?? []

        if existingLocations.isEmpty {
            let defaultLocation = StorageLocation(name: "未設定", type: .other, memo: "自動生成されたデフォルトの保管場所")
            modelContext.insert(defaultLocation)
            self.storageLocation = "未設定"
        } else if storageLocation.isEmpty || !existingLocations.contains(where: { $0.name == storageLocation }) {
            // 指定された保管場所が登録リストに存在しない場合、最初の保管場所を割り当てる
            if let firstLoc = existingLocations.first {
                self.storageLocation = firstLoc.name
            }
        }
    }

    /// 在庫のみ保存
    public func saveAsInventoryOnly(modelContext: ModelContext) throws {
        try ensureStorageLocationExists(modelContext: modelContext)

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
            imageDatas: selectedImageData != nil ? [selectedImageData!] : nil,
            specificMetadataJSON: metadataJSON
        )

        modelContext.insert(newItem)
        try modelContext.save()

        reset()
    }

    /// テイスティングログ＋在庫管理の保存
    public func save(modelContext: ModelContext) throws {
        try ensureStorageLocationExists(modelContext: modelContext)

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
                imageDatas: selectedImageData != nil ? [selectedImageData!] : nil,
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
