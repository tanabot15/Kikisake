//
//  InventoryViewModel.swift
//  Kikisake
//

import Foundation
import SwiftData
import SwiftUI

@Observable
public final class InventoryViewModel {
    public var selectedLocationFilter: String? = nil
    public var searchText: String = ""

    public var selectedStorageCategoryType: StorageCategoryType? = nil
    public var selectedCategory: BeverageCategory? = nil
    public var selectedSubCategory: String? = nil

    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {}

    public var hasActiveFilters: Bool {
        selectedStorageCategoryType != nil ||
        selectedCategory != nil ||
        selectedSubCategory != nil ||
        !searchText.isEmpty
    }

    public func resetFilters() {
        selectedStorageCategoryType = nil
        selectedCategory = nil
        selectedSubCategory = nil
        searchText = ""
    }

    public func filteredLocations(_ locations: [StorageLocation]) -> [StorageLocation] {
        locations.filter { loc in
            if let type = selectedStorageCategoryType {
                return loc.type == type
            }
            return true
        }
    }

    public func totalCount(for locationName: String, in items: [BeverageItem]) -> Int {
        items.filter { $0.storageLocation == locationName }.count
    }

    public func categorySummary(for locationName: String, in items: [BeverageItem]) -> String {
        let summaryList = categorySummaryList(for: locationName, in: items)
        guard !summaryList.isEmpty else { return String(localized: "在庫なし") }

        return summaryList
            .map { String(format: String(localized: "%@ %d本"), $0.categoryName, $0.count) }
            .joined(separator: " / ")
    }

    public func categorySummaryList(for locationName: String, in items: [BeverageItem]) -> [(categoryName: String, count: Int)] {
        let locationItems = filteredItems(items, for: locationName)
        guard !locationItems.isEmpty else { return [] }

        var counts: [BeverageCategory: Int] = [:]
        for item in locationItems {
            counts[item.category, default: 0] += 1
        }

        return BeverageCategory.allCases.compactMap { category in
            guard let count = counts[category], count > 0 else { return nil }
            return (categoryName: category.displayName, count: count)
        }
    }

    public func filteredItems(_ items: [BeverageItem], for locationName: String) -> [BeverageItem] {
        items.filter { item in
            let matchesLocation = item.storageLocation == locationName
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            let matchesSubCategory = matchesSubCategoryFilter(for: item)
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.producer.localizedCaseInsensitiveContains(searchText)

            return matchesLocation && matchesCategory && matchesSubCategory && matchesSearch
        }
    }

    public func availableSubCategories(from items: [BeverageItem]) -> [String] {
        guard let category = selectedCategory else { return [] }
        var subTypes = Set<String>()

        for item in items where item.category == category {
            if let subType = extractedSubCategory(from: item, category: category), !subType.isEmpty {
                subTypes.insert(subType)
            }
        }
        return Array(subTypes).sorted()
    }

    public func consumeBottle(item: BeverageItem) throws {
        try consumeUseCase.executeConsumption(for: item)
    }

    public func recordDrinkingFromExistingLog(item: BeverageItem, modelContext: ModelContext) throws {
        let latestLog = item.tastingLogs?
            .filter { $0.isEvaluated }
            .sorted(by: { $0.date > $1.date })
            .first

        let newLog: TastingLog
        if let baseLog = latestLog {
            newLog = TastingLog(
                date: Date(),
                rating: baseLog.rating,
                appearanceNotes: baseLog.appearanceNotes,
                appearanceColorHex: baseLog.appearanceColorHex,
                aromaTags: baseLog.aromaTags,
                sweetness: baseLog.sweetness,
                saltiness: baseLog.saltiness,
                acidity: baseLog.acidity,
                bitterness: baseLog.bitterness,
                umami: baseLog.umami,
                tannin: baseLog.tannin,
                body: baseLog.body,
                balanceTags: baseLog.balanceTags,
                finishLength: baseLog.finishLength,
                isCostEffective: baseLog.isCostEffective,
                isWillingToRepeat: baseLog.isWillingToRepeat,
                hasAgingPotential: baseLog.hasAgingPotential,
                alcoholByVolume: baseLog.alcoholByVolume,
                specificDataJSON: baseLog.specificDataJSON,
                pairing: baseLog.pairing,
                memo: baseLog.memo,
                isEvaluated: true,
                item: item
            )
        } else {
            newLog = TastingLog(
                date: Date(),
                rating: 0.0,
                appearanceNotes: "",
                appearanceColorHex: "#802633",
                aromaTags: [],
                memo: String(localized: "飲酒記録"),
                isEvaluated: false,
                item: item
            )
        }

        modelContext.insert(newLog)
        try modelContext.save()
    }

    public func moveItem(_ item: BeverageItem, to newLocationName: String, modelContext: ModelContext) {
        item.storageLocation = newLocationName
        try? modelContext.save()
    }

    public func updateGridSize(
        for location: StorageLocation,
        newRows: Int,
        newColumns: Int,
        allItems: [BeverageItem],
        modelContext: ModelContext
    ) {
        location.gridRows = newRows
        location.gridColumns = newColumns

        let targetItems = allItems.filter { $0.storageLocation == location.name }
        for item in targetItems {
            if let row = item.gridRow, let col = item.gridColumn, row > newRows || col > newColumns {
                item.gridRow = nil
                item.gridColumn = nil
            }
        }

        try? modelContext.save()
    }

    public func saveNewOrder(for items: [BeverageItem], modelContext: ModelContext) {
        let now = Date()
        for (offset, item) in items.enumerated() {
            item.createdAt = now.addingTimeInterval(Double(-offset))
        }
        try? modelContext.save()
    }

    public func markItemAsConsumed(_ item: BeverageItem, modelContext: ModelContext) {
        item.storageLocation = ""
        item.gridRow = nil
        item.gridColumn = nil
        try? modelContext.save()
    }

    public func deleteItem(_ item: BeverageItem, modelContext: ModelContext) {
        let repository = BeverageRepository(modelContext: modelContext)
        repository.deleteItem(item)
    }

    // MARK: - Private Helpers

    private func matchesSubCategoryFilter(for item: BeverageItem) -> Bool {
        guard let subCategory = selectedSubCategory, let category = selectedCategory else {
            return true
        }
        return extractedSubCategory(from: item, category: category) == subCategory
    }

    private func extractedSubCategory(from item: BeverageItem, category: BeverageCategory) -> String? {
        guard let json = item.specificMetadataJSON, let data = json.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()

        switch category {
        case .wine:
            return try? decoder.decode(WineSpecificMetadata.self, from: data).wineType
        case .sake:
            return try? decoder.decode(SakeSpecificMetadata.self, from: data).specificName
        case .beer:
            return try? decoder.decode(BeerSpecificMetadata.self, from: data).beerStyle
        }
    }
}
