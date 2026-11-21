//
//  AddFlowViewModel.swift
//  Kikisake
//

import Foundation
import SwiftData
import SwiftUI

@Observable
public final class AddFlowViewModel {
    public var currentStep: Int = 1 { didSet { saveDraft() } }

    public var showAlreadyFilledAlert: Bool = false
    public var pendingOpeningItem: BeverageItem? = nil
    public var isOpeningExistingItem: Bool = false

    private var isResetting: Bool = false
    private var isSaving: Bool = false

    // Step 1: General info
    public var selectedCategory: BeverageCategory = .wine { didSet { saveDraft() } }
    public var sourceItem: BeverageItem? = nil
    public var name: String = "" { didSet { saveDraft() } }
    public var producer: String = "" { didSet { saveDraft() } }
    public var region: String = "" { didSet { saveDraft() } }
    public var vintage: String = "" { didSet { saveDraft() } }
    public var abvString: String = "" { didSet { saveDraft() } }
    public var priceString: String = "" { didSet { saveDraft() } }
    public var storageLocation: String = "" { didSet { saveDraft() } }

    public var selectedImageData: Data? = nil { didSet { saveDraft() } }
    public var originalImageData: Data? = nil { didSet { saveDraft() } }
    public var selectedBackImageData: Data? = nil { didSet { saveDraft() } }
    public var isBackgroundRemoved: Bool = true { didSet { saveDraft() } }

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

    // Step 2: Appearance
    public var appearanceNotes: String = "ルビーレッド" { didSet { saveDraft() } }
    public var appearanceColorHex: String = "#991A33" { didSet { saveDraft() } }

    // Step 3: Aroma
    public var selectedAromaTags: [String] = [] { didSet { saveDraft() } }

    // Step 4: Taste
    public var sweetness: Double = 2.5 { didSet { saveDraft() } }
    public var saltiness: Double = 2.5 { didSet { saveDraft() } }
    public var acidity: Double = 2.5 { didSet { saveDraft() } }
    public var bitterness: Double = 2.5 { didSet { saveDraft() } }
    public var umami: Double = 2.5 { didSet { saveDraft() } }

    public var tannin: Double = 2.5 { didSet { saveDraft() } }
    public var body: Double = 2.5 { didSet { saveDraft() } }
    public var selectedBalanceTags: [String] = [] { didSet { saveDraft() } }
    public var finishLength: Double = 2.5 { didSet { saveDraft() } }

    // Step 5: Finalize
    public var rating: Double = 4.0 { didSet { saveDraft() } }
    public var isCostEffective: Bool = false { didSet { saveDraft() } }
    public var isWillingToRepeat: Bool = false { didSet { saveDraft() } }
    public var hasAgingPotential: Bool = false { didSet { saveDraft() } }
    public var pairing: String = "" { didSet { saveDraft() } }
    public var memo: String = "" { didSet { saveDraft() } }
    public var tastingDate: Date = Date() { didSet { saveDraft() } }

    public var editingLog: TastingLog? = nil
    public var editingItem: BeverageItem? = nil

    private let draftStore = AddFlowDraftStore()

    public init() {}

    // MARK: - Image & Blend Actions

    public func clearFrontImage() {
        isResetting = true
        self.selectedImageData = nil
        self.originalImageData = nil
        self.isBackgroundRemoved = true
        isResetting = false
        saveDraft()
    }

    public func clearBackImage() {
        self.selectedBackImageData = nil
    }

    public func addBlendComponent() {
        blendComponents.append(BlendComponent(variety: "", percentage: nil))
    }

    public func removeBlendComponent(at offsets: IndexSet) {
        blendComponents.remove(atOffsets: offsets)
    }

    // MARK: - Draft Persistence

    public var hasDraft: Bool {
        draftStore.hasDraft
    }

    public func saveDraft() {
        guard !isResetting, !isSaving else { return }
        if editingLog != nil || isOpeningExistingItem { return }
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
            isBackgroundRemoved: isBackgroundRemoved,
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

        let images = AddFlowDraftImages(
            frontImageData: selectedImageData,
            originalImageData: originalImageData,
            backImageData: selectedBackImageData
        )

        draftStore.save(draft: draft, images: images)
    }

    public func restoreDraft() {
        guard let loaded = draftStore.load() else { return }
        let draft = loaded.draft

        isResetting = true
        defer { isResetting = false }

        self.currentStep = draft.currentStep
        self.selectedCategory = BeverageCategory(rawValue: draft.selectedCategoryRaw) ?? .wine
        self.name = draft.name
        self.producer = draft.producer
        self.region = draft.region
        self.vintage = draft.vintage
        self.abvString = draft.abvString
        self.priceString = draft.priceString
        self.storageLocation = draft.storageLocation
        self.isBackgroundRemoved = draft.isBackgroundRemoved

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

        self.selectedImageData = loaded.images.frontImageData
        self.originalImageData = loaded.images.originalImageData
        self.selectedBackImageData = loaded.images.backImageData
    }

    public func clearDraft() {
        draftStore.clear()
    }

    // MARK: - State Configuration & Reset

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

    public func reset() {
        isResetting = true
        defer { isResetting = false }

        clearDraft()
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
        self.storageLocation = ""
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
        isResetting = true
        defer { isResetting = false }

        self.sourceItem = item
        self.editingItem = item
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
        self.originalImageData = item.originalImageDatas?.first ?? item.imageDatas?.first
        self.selectedBackImageData = item.backImageDatas?.first
        self.isBackgroundRemoved = item.isBackgroundRemoved

        if self.editingLog == nil {
            self.editingLog = item.tastingLogs?
                .filter { !$0.isEvaluated }
                .sorted(by: { $0.date > $1.date })
                .first
        }
    }

    public func configureWithLog(_ log: TastingLog) {
        configureWithItemAndMetadata(from: log)

        isResetting = true
        defer { isResetting = false }

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

    // MARK: - Persistence Actions

    public func saveAsInventoryOnly(modelContext: ModelContext) throws {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        if storageLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.storageLocation = String(localized: "未設定")
        }
        ensureStorageLocationExistsIfStocked(modelContext: modelContext)

        let newItem = createBeverageItemFromCurrentState(
            gridRow: selectedGridRow,
            gridColumn: selectedGridColumn
        )

        let unevaluatedLog = TastingLog(
            date: Date(),
            rating: 0.0,
            appearanceNotes: "",
            appearanceColorHex: "#802633",
            aromaTags: [],
            memo: "",
            isEvaluated: false
        )

        modelContext.insert(newItem)
        modelContext.insert(unevaluatedLog)
        unevaluatedLog.item = newItem

        try modelContext.save()
        reset()
    }

    public func saveWithStock(modelContext: ModelContext) throws {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        ensureStorageLocationExistsIfStocked(modelContext: modelContext)

        let targetItem = upsertBeverageItem(modelContext: modelContext)
        let logToSave = resolveTargetUnevaluatedLog(for: targetItem, modelContext: modelContext)
        applyTastingData(to: logToSave, isTanninApplicable: currentIsTanninApplicable)
        logToSave.item = targetItem

        try modelContext.save()
        reset()
    }

    public func save(modelContext: ModelContext) throws {
        self.storageLocation = ""
        self.selectedGridRow = nil
        self.selectedGridColumn = nil
        try saveWithStock(modelContext: modelContext)
    }

    public func update(modelContext: ModelContext) throws {
        guard let targetLog = editingLog else {
            try save(modelContext: modelContext)
            return
        }

        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        ensureStorageLocationExistsIfStocked(modelContext: modelContext)

        if let targetItem = editingItem ?? sourceItem {
            updateBeverageItem(targetItem)
            targetLog.item = targetItem
        }

        applyTastingData(to: targetLog, isTanninApplicable: currentIsTanninApplicable)

        try modelContext.save()
        reset()
    }

    // MARK: - Private Helpers

    private var currentIsTanninApplicable: Bool {
        guard selectedCategory == .wine else { return false }
        return wineType == "赤" || wineType == "ロゼ" || wineType == "オレンジ"
    }

    private func configureWithItemAndMetadata(from log: TastingLog) {
        self.editingLog = log
        self.editingItem = log.item
        guard let item = log.item else { return }

        configureWithItem(item)

        isResetting = true
        defer { isResetting = false }

        guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else { return }
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

    private func createBeverageItemFromCurrentState(gridRow: Int?, gridColumn: Int?) -> BeverageItem {
        BeverageItem(
            name: name,
            producer: producer,
            category: selectedCategory,
            region: region,
            vintage: vintage.isEmpty ? nil : vintage,
            alcoholByVolume: Double(abvString),
            price: Int(priceString),
            storageLocation: storageLocation,
            gridRow: gridRow,
            gridColumn: gridColumn,
            imageDatas: selectedImageData != nil ? [selectedImageData!] : nil,
            originalImageDatas: originalImageData != nil ? [originalImageData!] : nil,
            backImageDatas: selectedBackImageData != nil ? [selectedBackImageData!] : nil,
            isBackgroundRemoved: isBackgroundRemoved,
            specificMetadataJSON: buildMetadataJSON()
        )
    }

    private func updateBeverageItem(_ targetItem: BeverageItem) {
        targetItem.name = name
        targetItem.producer = producer
        targetItem.category = selectedCategory
        targetItem.region = region
        targetItem.vintage = vintage.isEmpty ? nil : vintage
        targetItem.alcoholByVolume = Double(abvString)
        targetItem.price = Int(priceString)
        targetItem.storageLocation = storageLocation
        targetItem.gridRow = storageLocation.isEmpty ? nil : selectedGridRow
        targetItem.gridColumn = storageLocation.isEmpty ? nil : selectedGridColumn
        targetItem.imageDatas = selectedImageData != nil ? [selectedImageData!] : nil
        targetItem.originalImageDatas = originalImageData != nil ? [originalImageData!] : nil
        targetItem.backImageDatas = selectedBackImageData != nil ? [selectedBackImageData!] : nil
        targetItem.isBackgroundRemoved = isBackgroundRemoved
        targetItem.specificMetadataJSON = buildMetadataJSON()
    }

    private func upsertBeverageItem(modelContext: ModelContext) -> BeverageItem {
        if let existingItem = sourceItem ?? editingItem {
            updateBeverageItem(existingItem)
            return existingItem
        }

        let newItem = createBeverageItemFromCurrentState(
            gridRow: storageLocation.isEmpty ? nil : selectedGridRow,
            gridColumn: storageLocation.isEmpty ? nil : selectedGridColumn
        )
        modelContext.insert(newItem)
        return newItem
    }

    private func resolveTargetUnevaluatedLog(for targetItem: BeverageItem, modelContext: ModelContext) -> TastingLog {
        if let currentEditingLog = editingLog, !currentEditingLog.isEvaluated {
            return currentEditingLog
        }
        if let existingUnevaluated = targetItem.tastingLogs?
            .filter({ !$0.isEvaluated })
            .sorted(by: { $0.date > $1.date })
            .first {
            return existingUnevaluated
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
            tannin: currentIsTanninApplicable ? tannin : nil,
            body: body,
            balanceTags: selectedBalanceTags,
            finishLength: finishLength,
            isCostEffective: isCostEffective,
            isWillingToRepeat: isWillingToRepeat,
            hasAgingPotential: hasAgingPotential,
            pairing: pairing.isEmpty ? nil : pairing,
            memo: memo,
            isEvaluated: true
        )
        modelContext.insert(newLog)
        return newLog
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
            let meta = SakeSpecificMetadata(
                specificName: sakeSpecificName,
                riceVariety: riceVariety,
                polishingRate: polishingRate,
                sakeMeterValue: sakeMeterValue
            )
            return try? String(data: encoder.encode(meta), encoding: .utf8)

        case .beer:
            let meta = BeerSpecificMetadata(beerStyle: beerStyle, ibu: ibu)
            return try? String(data: encoder.encode(meta), encoding: .utf8)
        }
    }

    private func ensureStorageLocationExistsIfStocked(modelContext: ModelContext) {
        let trimmed = storageLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.storageLocation = ""
            return
        }

        let descriptor = FetchDescriptor<StorageLocation>()
        let existingLocations = (try? modelContext.fetch(descriptor)) ?? []

        if !existingLocations.contains(where: { $0.name == trimmed }) {
            let newLocation = StorageLocation(name: trimmed, type: .other, memo: "")
            modelContext.insert(newLocation)
        }
        self.storageLocation = trimmed
    }

    private func applyTastingData(to log: TastingLog, isTanninApplicable: Bool) {
        log.date = tastingDate
        log.rating = rating
        log.appearanceNotes = appearanceNotes
        log.appearanceColorHex = appearanceColorHex
        log.aromaTags = selectedAromaTags
        log.sweetness = sweetness
        log.saltiness = saltiness
        log.acidity = acidity
        log.bitterness = bitterness
        log.umami = umami
        log.tannin = isTanninApplicable ? tannin : nil
        log.body = body
        log.balanceTags = selectedBalanceTags
        log.finishLength = finishLength
        log.isCostEffective = isCostEffective
        log.isWillingToRepeat = isWillingToRepeat
        log.hasAgingPotential = hasAgingPotential
        log.pairing = pairing.isEmpty ? nil : pairing
        log.memo = memo
        log.isEvaluated = true
    }
}
