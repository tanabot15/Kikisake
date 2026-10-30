//  AddFlowViewModel.swift
//  Kikisake

import Foundation
import SwiftData
import SwiftUI

@Observable
public final class AddFlowViewModel {
    public var currentStep: Int = 1
    
    public var showAlreadyFilledAlert: Bool = false
    public var pendingOpeningItem: BeverageItem? = nil

    // 在庫画面の「このボトルを開ける」から直接遷移してきたかどうかのフラグ
    public var isOpeningExistingItem: Bool = false

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
    
    // ✨ 表面と裏面の写真を完全に独立したプロパティとして保持
    public var selectedImageData: Data? = nil
    public var selectedBackImageData: Data? = nil

    // 削除アクションを明示的に分離（相互干渉を完全に防ぐため）
    public func clearFrontImage() {
        self.selectedImageData = nil
    }

    public func clearBackImage() {
        self.selectedBackImageData = nil
    }

    // セラー内グリッド位置指定用プロパティ
    public var selectedGridRow: Int? = nil
    public var selectedGridColumn: Int? = nil

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

    // Step 5: 総合評価・フラグ・メモ
    public var rating: Double = 4.0
    public var isCostEffective: Bool = false
    public var isWillingToRepeat: Bool = false
    public var hasAgingPotential: Bool = false
    public var memo: String = ""
    public var tastingDate: Date = Date()

    // 編集モード用の保持プロパティ
    public var editingLog: TastingLog? = nil
    public var editingItem: BeverageItem? = nil

    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {}
    
    public func handleOpeningItem(_ item: BeverageItem) {
        configureWithItem(item)
        self.isOpeningExistingItem = true
        self.currentStep = 2
    }
    
    public func applyOpeningItem(_ item: BeverageItem) {
        configureWithItem(item)
        self.isOpeningExistingItem = true
        self.currentStep = 2
    }

    public func addBlendComponent() {
        blendComponents.append(BlendComponent(variety: "", percentage: nil))
    }

    public func removeBlendComponent(at offsets: IndexSet) {
        blendComponents.remove(atOffsets: offsets)
    }

    public func reset() {
        self.currentStep = 1
        self.isOpeningExistingItem = false
        self.selectedCategory = .wine
        self.sourceItem = nil
        self.name = ""
        self.producer = ""
        self.region = ""
        self.vintage = ""
        self.abvString = ""
        self.priceString = ""
        self.storageLocation = "未設定"
        self.selectedGridRow = nil
        self.selectedGridColumn = nil
        self.selectedImageData = nil
        self.selectedBackImageData = nil
        
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
        self.umami = 0.0
        self.tannin = 2.5
        self.body = 2.5
        self.selectedBalanceTags = []
        self.finishLength = 2.5
        self.rating = 4.0
        self.isCostEffective = false
        self.isWillingToRepeat = false
        self.hasAgingPotential = false
        self.memo = ""
        self.tastingDate = Date()
        self.editingLog = nil
        self.editingItem = nil
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
        self.selectedGridRow = item.gridRow
        self.selectedGridColumn = item.gridColumn
        
        // 表面写真と裏面写真を完全に分けて安全にロード
        self.selectedImageData = item.imageDatas?.first
        self.selectedBackImageData = item.backImageDatas?.first
    }

    public func configureWithLog(_ log: TastingLog) {
        self.editingLog = log
        self.editingItem = log.item
        if let item = log.item {
            configureWithItem(item)
            
            if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                let decoder = JSONDecoder()
                switch item.category {
                case .wine:
                    if let meta = try? decoder.decode(WineSpecificMetadata.self, from: data) {
                        self.wineType = meta.wineType
                        self.grapeVarieties = meta.grapeVarieties
                        if !meta.blendComponents.isEmpty {
                            self.blendComponents = meta.blendComponents
                        }
                        self.appellation = meta.appellation ?? ""
                    }
                case .sake:
                    if let meta = try? decoder.decode(SakeSpecificMetadata.self, from: data) {
                        self.sakeSpecificName = meta.specificName
                        self.riceVariety = meta.riceVariety
                        self.polishingRate = meta.polishingRate
                        self.sakeMeterValue = meta.sakeMeterValue
                    }
                case .beer:
                    if let meta = try? decoder.decode(BeerSpecificMetadata.self, from: data) {
                        self.beerStyle = meta.beerStyle
                        self.ibu = meta.ibu
                    }
                }
            }
        }
        
        self.tastingDate = log.date
        self.rating = log.rating
        self.appearanceNotes = log.appearanceNotes
        self.appearanceColorHex = log.appearanceColorHex
        self.selectedAromaTags = log.aromaTags
        self.sweetness = log.sweetness
        self.saltiness = log.saltiness
        self.acidity = log.acidity
        self.bitterness = log.bitterness
        self.umami = log.umami
        self.tannin = log.tannin ?? 2.5
        self.body = log.body
        self.selectedBalanceTags = log.balanceTags
        self.finishLength = log.finishLength
        self.isCostEffective = log.isCostEffective
        self.isWillingToRepeat = log.isWillingToRepeat
        self.hasAgingPotential = log.hasAgingPotential
        self.memo = log.memo
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
            if let firstLoc = existingLocations.first {
                self.storageLocation = firstLoc.name
            }
        }
    }

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
            storageLocation: storageLocation,
            gridRow: selectedGridRow,
            gridColumn: selectedGridColumn,
            imageDatas: selectedImageData != nil ? [selectedImageData!] : nil,
            backImageDatas: selectedBackImageData != nil ? [selectedBackImageData!] : nil,
            specificMetadataJSON: metadataJSON
        )

        modelContext.insert(newItem)
        try modelContext.save()

        reset()
    }
    
    public func saveWithStock(modelContext: ModelContext) throws {
        try ensureStorageLocationExists(modelContext: modelContext)

        let isTanninApplicable: Bool = {
            guard selectedCategory == .wine else { return false }
            return wineType == "赤" || wineType == "ロゼ" || wineType == "オレンジ"
        }()
        
        let price = Int(priceString)
        let abv = Double(abvString)
        let metadataJSON = buildMetadataJSON()
        
        let targetItem: BeverageItem
        if let existingItem = sourceItem {
            targetItem = existingItem
            existingItem.storageLocation = storageLocation
            existingItem.gridRow = selectedGridRow
            existingItem.gridColumn = selectedGridColumn
            existingItem.imageDatas = selectedImageData != nil ? [selectedImageData!] : nil
            existingItem.backImageDatas = selectedBackImageData != nil ? [selectedBackImageData!] : nil
        } else {
            targetItem = BeverageItem(
                name: name,
                producer: producer,
                category: selectedCategory,
                region: region,
                vintage: vintage.isEmpty ? nil : vintage,
                alcoholByVolume: abv,
                price: price,
                storageLocation: storageLocation,
                gridRow: selectedGridRow,
                gridColumn: selectedGridColumn,
                imageDatas: selectedImageData != nil ? [selectedImageData!] : nil,
                backImageDatas: selectedBackImageData != nil ? [selectedBackImageData!] : nil,
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
            isCostEffective: isCostEffective,
            isWillingToRepeat: isWillingToRepeat,
            hasAgingPotential: hasAgingPotential,
            memo: memo,
            isEvaluated: true,
            item: targetItem
        )

        modelContext.insert(newLog)
        try modelContext.save()

        reset()
    }

    public func save(modelContext: ModelContext) throws {
        try ensureStorageLocationExists(modelContext: modelContext)

        let isTanninApplicable: Bool = {
            guard selectedCategory == .wine else { return false }
            return wineType == "赤" || wineType == "ロゼ" || wineType == "オレンジ"
        }()
        
        let targetItem: BeverageItem
        if let existingItem = sourceItem {
            targetItem = existingItem
        } else {
            let price = Int(priceString)
            let abv = Double(abvString)
            let metadataJSON = buildMetadataJSON()
            
            targetItem = BeverageItem(
                name: name,
                producer: producer,
                category: selectedCategory,
                region: region,
                vintage: vintage.isEmpty ? nil : vintage,
                alcoholByVolume: abv,
                price: price,
                storageLocation: storageLocation,
                gridRow: selectedGridRow,
                gridColumn: selectedGridColumn,
                imageDatas: selectedImageData != nil ? [selectedImageData!] : nil,
                backImageDatas: selectedBackImageData != nil ? [selectedBackImageData!] : nil,
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
            isCostEffective: isCostEffective,
            isWillingToRepeat: isWillingToRepeat,
            hasAgingPotential: hasAgingPotential,
            memo: memo,
            isEvaluated: true,
            item: targetItem
        )

        modelContext.insert(newLog)
        try modelContext.save()

        reset()
    }

    public func update(modelContext: ModelContext) throws {
        guard let targetLog = editingLog else {
            try save(modelContext: modelContext)
            return
        }

        try ensureStorageLocationExists(modelContext: modelContext)

        let price = Int(priceString)
        let abv = Double(abvString)
        let isTanninApplicable: Bool = {
            guard selectedCategory == .wine else { return false }
            return wineType == "赤" || wineType == "ロゼ" || wineType == "オレンジ"
        }()
        let metadataJSON = buildMetadataJSON()

        if let targetItem = editingItem {
            targetItem.name = name
            targetItem.producer = producer
            targetItem.category = selectedCategory
            targetItem.region = region
            targetItem.vintage = vintage.isEmpty ? nil : vintage
            targetItem.alcoholByVolume = abv
            targetItem.price = price
            targetItem.storageLocation = storageLocation
            targetItem.gridRow = selectedGridRow
            targetItem.gridColumn = selectedGridColumn
            targetItem.imageDatas = selectedImageData != nil ? [selectedImageData!] : nil
            targetItem.backImageDatas = selectedBackImageData != nil ? [selectedBackImageData!] : nil
            targetItem.specificMetadataJSON = metadataJSON
        }

        targetLog.date = tastingDate
        targetLog.rating = rating
        targetLog.appearanceNotes = appearanceNotes
        targetLog.appearanceColorHex = appearanceColorHex
        targetLog.aromaTags = selectedAromaTags
        targetLog.sweetness = sweetness
        targetLog.saltiness = saltiness
        targetLog.acidity = acidity
        targetLog.bitterness = bitterness
        targetLog.umami = umami
        targetLog.tannin = isTanninApplicable ? tannin : nil
        targetLog.body = body
        targetLog.balanceTags = selectedBalanceTags
        targetLog.finishLength = finishLength
        targetLog.isCostEffective = isCostEffective
        targetLog.isWillingToRepeat = isWillingToRepeat
        targetLog.hasAgingPotential = hasAgingPotential
        targetLog.memo = memo
        targetLog.isEvaluated = true

        try modelContext.save()
        reset()
    }
}
