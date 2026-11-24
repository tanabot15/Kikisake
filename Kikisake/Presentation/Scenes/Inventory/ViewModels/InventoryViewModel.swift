import Foundation
import SwiftData
import SwiftUI

@Observable
public final class InventoryViewModel {
    private let consumeUseCase = ConsumeBeverageUseCase()

    public init() {}

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
        let locationItems = itemsForLocation(for: locationName, in: items)
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

    public func itemsForLocation(for locationName: String, in items: [BeverageItem]) -> [BeverageItem] {
        items.filter { $0.storageLocation == locationName }
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

    // MARK: - StorageLocation Management

    public func renameLocation(
        _ location: StorageLocation,
        newName: String,
        allItems: [BeverageItem],
        modelContext: ModelContext
    ) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let oldName = location.name
        guard oldName != trimmed else { return }

        location.name = trimmed

        for item in allItems where item.storageLocation == oldName {
            item.storageLocation = trimmed
        }

        try? modelContext.save()
    }

    public func moveLocation(
        _ location: StorageLocation,
        direction: MoveDirection,
        in orderedLocations: [StorageLocation],
        modelContext: ModelContext
    ) {
        guard let currentIndex = orderedLocations.firstIndex(where: { $0.id == location.id }) else { return }

        let targetIndex: Int
        switch direction {
        case .up:
            guard currentIndex > 0 else { return }
            targetIndex = currentIndex - 1
        case .down:
            guard currentIndex < orderedLocations.count - 1 else { return }
            targetIndex = currentIndex + 1
        }

        var mutable = orderedLocations
        let moving = mutable.remove(at: currentIndex)
        mutable.insert(moving, at: targetIndex)

        saveLocationOrder(mutable, modelContext: modelContext)
    }

    public func moveLocation(
        from sourceID: UUID,
        to destinationID: UUID,
        in orderedLocations: [StorageLocation],
        modelContext: ModelContext
    ) {
        guard sourceID != destinationID,
              let fromIndex = orderedLocations.firstIndex(where: { $0.id == sourceID }),
              let toIndex = orderedLocations.firstIndex(where: { $0.id == destinationID }) else { return }

        var mutable = orderedLocations
        let moving = mutable.remove(at: fromIndex)
        mutable.insert(moving, at: toIndex)

        saveLocationOrder(mutable, modelContext: modelContext)
    }

    public func deleteLocation(
        _ location: StorageLocation,
        allItems: [BeverageItem],
        modelContext: ModelContext
    ) {
        for item in allItems where item.storageLocation == location.name {
            item.storageLocation = ""
            item.gridRow = nil
            item.gridColumn = nil
        }

        modelContext.delete(location)
        try? modelContext.save()
    }

    private func saveLocationOrder(_ orderedLocations: [StorageLocation], modelContext: ModelContext) {
        let baseDate = Date()
        for (offset, loc) in orderedLocations.enumerated() {
            loc.createdAt = baseDate.addingTimeInterval(TimeInterval(offset))
        }
        try? modelContext.save()
    }

    public enum MoveDirection {
        case up
        case down
    }
}
