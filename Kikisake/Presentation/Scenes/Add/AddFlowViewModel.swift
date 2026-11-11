//  AddFlowViewModel.swift
//  Kikisake

import Foundation
import SwiftData
import SwiftUI

/// 下書き保存用のCodableデータ構造体
private struct AddFlowDraftData: Codable {
    var currentStep: Int
    var selectedCategoryRaw: String
    var name: String
    var producer: String
    var region: String
    var vintage: String
    var abvString: String
    var priceString: String
    var storageLocation: String
    
    var wineType: String
    var blendComponents: [BlendComponent]
    var appellation: String
    
    var sakeSpecificName: String
    var riceVariety: String
    var polishingRate: String
    var sakeMeterValue: String
    
    var beerStyle: String
    var ibu: String
    
    var appearanceNotes: String
    var appearanceColorHex: String
    var selectedAromaTags: [String]
    
    var sweetness: Double
    var saltiness: Double
    var acidity: Double
    var bitterness: Double
    var umami: Double
    var tannin: Double
    var body: Double
    var selectedBalanceTags: [String]
    var finishLength: Double
    
    var rating: Double
    var isCostEffective: Bool
    var isWillingToRepeat: Bool
    var hasAgingPotential: Bool
    var pairing: String
    var memo: String
    var tastingDate: Date
}

@Observable
public final class AddFlowViewModel {
    public var currentStep: Int = 1 { didSet { saveDraft() } }
    
    public var showAlreadyFilledAlert: Bool = false
    public var pendingOpeningItem: BeverageItem? = nil

    public var isOpeningExistingItem: Bool = false

    // Step 1: 一般的な情報
    public var selectedCategory: BeverageCategory = .wine { didSet { saveDraft() } }
    public var sourceItem: BeverageItem? = nil
    public var name: String = "" { didSet { saveDraft() } }
    public var producer: String = "" { didSet { saveDraft() } }
    public var region: String = "" { didSet { saveDraft() } }
    public var vintage: String = "" { didSet { saveDraft() } }
    public var abvString: String = "" { didSet { saveDraft() } }
    public var priceString: String = "" { didSet { saveDraft() } }
    public var storageLocation: String = "未設定" { didSet { saveDraft() } }
    
    public var selectedImageData: Data? = nil { didSet { saveDraft() } }
    public var originalImageData: Data? = nil
    public var selectedBackImageData: Data? = nil { didSet { saveDraft() } }
    public var isBackgroundRemoved: Bool = true { didSet { saveDraft() } }

    public func clearFrontImage() {
        self.selectedImageData = nil
        self.isBackgroundRemoved = true
        saveDraft()
    }

    public func clearBackImage() {
        self.selectedBackImageData = nil
        saveDraft()
    }

    public var selectedGridRow: Int? = nil
    public var selectedGridColumn: Int? = nil

    public var wineType: String = "赤" { didSet { saveDraft() } }
    public var grapeVarieties: String = ""
    public var blendComponents: [BlendComponent] = [BlendComponent(variety: "", percentage: nil)] { didSet { saveDraft() } }
    public var appellation: String = "" { didSet { saveDraft() } }
    
    public var sakeSpecificName: String = "純米大吟醸" { didSet { saveDraft() } }
    public var riceVariety: String = "" { didSet { saveDraft() } }
    public var polishingRate: String = "" { didSet { saveDraft() } }
    public var sakeMeterValue: String = "" { didSet { saveDraft() } }
    
    public var beerStyle: String = "" { didSet { saveDraft() } }
    public var ibu: String = "" { didSet { saveDraft() } }

    // Step 2: 色・外観
    public var appearanceNotes: String = "ルビーレッド" { didSet { saveDraft() } }
    public var appearanceColorHex: String = "#991A33" { didSet { saveDraft() } }

    // Step 3: 香り
    public var selectedAromaTags: [String] = [] { didSet { saveDraft() } }

    // Step 4: 味わい
    public var sweetness: Double = 2.5 { didSet { saveDraft() } }
    public var saltiness: Double = 2.5 { didSet { saveDraft() } }
    public var acidity: Double = 2.5 { didSet { saveDraft() } }
    public var bitterness: Double = 2.5 { didSet { saveDraft() } }
    public var umami: Double = 2.5 { didSet { saveDraft() } }

    public var tannin: Double = 2.5 { didSet { saveDraft() } }
    public var body: Double = 2.5 { didSet { saveDraft() } }
    public var selectedBalanceTags: [String] = [] { didSet { saveDraft() } }
    public var finishLength: Double = 2.5 { didSet { saveDraft() } }

    // Step 5: 総合評価・フラグ・ペアリング・メモ
    public var rating: Double = 4.0 { didSet { saveDraft() } }
    public var isCostEffective: Bool = false { didSet { saveDraft() } }
    public var isWillingToRepeat: Bool = false { didSet { saveDraft() } }
    public var hasAgingPotential: Bool = false { didSet { saveDraft() } }
    public var pairing: String = "" { didSet { saveDraft() } }
    public var memo: String = "" { didSet { saveDraft() } }
    public var tastingDate: Date = Date() { didSet { saveDraft() } }

    public var editingLog: TastingLog? = nil
    public var editingItem: BeverageItem? = nil

    private let consumeUseCase = ConsumeBeverageUseCase()
    private let draftKey = "Kikisake_AddFlow_DraftData_v1"
    private let frontImageDraftKey = "Kikisake_AddFlow_FrontImage_v1"
    private let backImageDraftKey = "Kikisake_AddFlow_BackImage_v1"

    public init() {}
    
    // MARK: - 下書き自動保存・復元機能
    
    /// 現在の入力をローカル（UserDefaultsおよび一時ファイル）に自動保存
    public func saveDraft() {
        // 編集モード（既存ログの編集など）のときは下書き対象外とする
        if editingLog != nil || isOpeningExistingItem { return }
        
        // 全く入力されていない初期状態であれば保存しない
        guard !name.isEmpty || !producer.isEmpty || !memo.isEmpty || selectedImageData != nil else { return }
        
        let draft = AddFlowDraftData(
            currentStep: currentStep,
            selectedCategoryRaw: selectedCategory.rawValue,
            name: name,
            producer: producer,
            region: region,
            vintage: vintage,
            abvString: abvString,
            priceString: priceString,
            storageLocation: storageLocation,
            wineType: wineType,
            blendComponents: blendComponents,
            appellation: appellation,
            sakeSpecificName: sakeSpecificName,
            riceVariety: riceVariety,
            polishingRate: polishingRate,
            sakeMeterValue: sakeMeterValue,
            beerStyle: beerStyle,
            ibu: ibu,
            appearanceNotes: appearanceNotes,
            appearanceColorHex: appearanceColorHex,
            selectedAromaTags: selectedAromaTags,
            sweetness: sweetness,
            saltiness: saltiness,
            acidity: acidity,
            bitterness: bitterness,
            umami: umami,
            tannin: tannin,
            body: body,
            selectedBalanceTags: selectedBalanceTags,
            finishLength: finishLength,
            rating: rating,
            isCostEffective: isCostEffective,
            isWillingToRepeat: isWillingToRepeat,
            hasAgingPotential: hasAgingPotential,
            pairing: pairing,
            memo: memo,
            tastingDate: tastingDate
        )
        
        if let encoded = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(encoded, forKey: draftKey)
        }
        if let frontImg = selectedImageData {
            UserDefaults.standard.set(frontImg, forKey: frontImageDraftKey)
        }
        if let backImg = selectedBackImageData {
            UserDefaults.standard.set(backImg, forKey: backImageDraftKey)
        }
    }
    
    /// 保存されている下書きが存在するかどうか
    public var hasDraft: Bool {
        return UserDefaults.standard.data(forKey: draftKey) != nil
    }
    
    /// 下書きデータをViewModelに復元する
    public func restoreDraft() {
        guard let data = UserDefaults.standard.data(forKey: draftKey),
              let draft = try? JSONDecoder().decode(AddFlowDraftData.self, from: data) else { return }
        
        self.currentStep = draft.currentStep
        self.selectedCategory = BeverageCategory(rawValue: draft.selectedCategoryRaw) ?? .wine
        self.name = draft.name
        self.producer = draft.producer
        self.region = draft.region
        self.vintage = draft.vintage
        self.abvString = draft.abvString
        self.priceString = draft.priceString
        self.storageLocation = draft.storageLocation
        
        self.wineType = draft.wineType
        self.blendComponents = draft.blendComponents
        self.appellation = draft.appellation
        
        self.sakeSpecificName = draft.sakeSpecificName
        self.riceVariety = draft.riceVariety
        self.polishingRate = draft.polishingRate
        self.sakeMeterValue = draft.sakeMeterValue
        
        self.beerStyle = draft.beerStyle
        self.ibu = draft.ibu
        
        self.appearanceNotes = draft.appearanceNotes
        self.appearanceColorHex = draft.appearanceColorHex
        self.selectedAromaTags = draft.selectedAromaTags
        
        self.sweetness = draft.sweetness
        self.saltiness = draft.saltiness
        self.acidity = draft.acidity
        self.bitterness = draft.bitterness
        self.umami = draft.umami
        self.tannin = draft.tannin
        self.body = draft.body
        self.selectedBalanceTags = draft.selectedBalanceTags
        self.finishLength = draft.finishLength
        
        self.rating = draft.rating
        self.isCostEffective = draft.isCostEffective
        self.isWillingToRepeat = draft.isWillingToRepeat
        self.hasAgingPotential = draft.hasAgingPotential
        self.pairing = draft.pairing
        self.memo = draft.memo
        self.tastingDate = draft.tastingDate
        
        if let frontImg = UserDefaults.standard.data(forKey: frontImageDraftKey) {
            self.selectedImageData = frontImg
            self.originalImageData = frontImg
        }
        if let backImg = UserDefaults.standard.data(forKey: backImageDraftKey) {
            self.selectedBackImageData = backImg
        }
    }
    
    /// 下書きデータを完全に消去する（保存完了時や明示的キャンセル時）
    public func clearDraft() {
        UserDefaults.standard.removeObject(forKey: draftKey)
        UserDefaults.standard.removeObject(forKey: frontImageDraftKey)
        UserDefaults.standard.removeObject(forKey: backImageDraftKey)
    }

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
        clearDraft() // ✨ リセット時に下書きもクリア
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
        self.originalImageData = nil
        self.selectedBackImageData = nil
        self.isBackgroundRemoved = true
        
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
        self.pairing = ""
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
        
        self.selectedImageData = item.imageDatas?.first
        // ✨ 既存アイテムの読み込み時にもオリジナルデータを保持させることで、背景ありへの切り戻しを可能にする
        self.originalImageData = item.imageDatas?.first
        self.selectedBackImageData = item.backImageDatas?.first
        self.isBackgroundRemoved = item.isBackgroundRemoved
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
        self.pairing = log.pairing ?? ""
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
            isBackgroundRemoved: isBackgroundRemoved,
            specificMetadataJSON: metadataJSON
        )

        modelContext.insert(newItem)
        try modelContext.save()

        reset() // 保存成功時に自動リセット ＆ 下書き消去
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
            existingItem.isBackgroundRemoved = isBackgroundRemoved
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
                isBackgroundRemoved: isBackgroundRemoved,
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
            pairing: pairing.isEmpty ? nil : pairing,
            memo: memo,
            isEvaluated: true,
            item: targetItem
        )

        modelContext.insert(newLog)
        try modelContext.save()

        reset() // 保存成功時に自動リセット ＆ 下書き消去
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
                isBackgroundRemoved: isBackgroundRemoved,
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
            pairing: pairing.isEmpty ? nil : pairing,
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
            targetItem.isBackgroundRemoved = isBackgroundRemoved
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
        targetLog.pairing = pairing.isEmpty ? nil : pairing
        targetLog.memo = memo
        targetLog.isEvaluated = true

        try modelContext.save()
        reset()
    }
}
