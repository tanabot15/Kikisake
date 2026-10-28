//  CellarGridView.swift
//  Kikisake

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// セラーや冷蔵庫の棚番（グリッド）を視覚的に表示するコンポーネント
public struct CellarGridView: View {
    let location: StorageLocation
    let items: [BeverageItem]
    let modelContext: ModelContext
    
    let onSelectSlot: (Int, Int, BeverageItem?) -> Void
    let onSelectItem: (BeverageItem) -> Void
    
    var onError: ((String) -> Void)? = nil

    public init(
        location: StorageLocation,
        items: [BeverageItem],
        modelContext: ModelContext,
        onSelectSlot: @escaping (Int, Int, BeverageItem?) -> Void,
        onSelectItem: @escaping (BeverageItem) -> Void,
        onError: ((String) -> Void)? = nil
    ) {
        self.location = location
        self.items = items
        self.modelContext = modelContext
        self.onSelectSlot = onSelectSlot
        self.onSelectItem = onSelectItem
        self.onError = onError
    }

    public var body: some View {
        VStack(spacing: 14) {
            if !location.memo.isEmpty {
                HStack {
                    Text(location.memo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }

            VStack(spacing: 8) {
                ForEach(1...location.gridRows, id: \.self) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(String(format: String(localized: "第 %d 段"), row))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: location.gridColumns), spacing: 6) {
                            ForEach(1...location.gridColumns, id: \.self) { col in
                                let itemInSlot = items.first { item in
                                    item.storageLocation == location.name &&
                                    item.gridRow == row &&
                                    item.gridColumn == col
                                }

                                CellarGridSlotCell(item: itemInSlot, row: row, column: col)
                                    .dropDestination(for: String.self) { droppedItems, _ in
                                        guard let uuidString = droppedItems.first,
                                              let uuid = UUID(uuidString: uuidString),
                                              let movingItem = self.items.first(where: { $0.id == uuid }) else {
                                            return false
                                        }
                                        
                                        let existingItemInTargetSlot = self.items.first { item in
                                            item.storageLocation == self.location.name &&
                                            item.gridRow == row &&
                                            item.gridColumn == col &&
                                            item.id != movingItem.id
                                        }
                                        
                                        if existingItemInTargetSlot != nil {
                                            onError?(String(format: String(localized: "指定されたスロット（第 %d 段 %d 列）にはすでに別のボトルが置かれているため移動できません。"), row, col))
                                            return false
                                        }
                                        
                                        movingItem.gridRow = row
                                        movingItem.gridColumn = col
                                        movingItem.storageLocation = self.location.name
                                        try? modelContext.save()
                                        return true
                                    }
                                    .onTapGesture {
                                        onSelectSlot(row, col, itemInSlot)
                                    }
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                }
            }

            let unassignedItems = items.filter { $0.storageLocation == location.name && ($0.gridRow == nil || $0.gridColumn == nil) }
            if !unassignedItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("棚の外（未配置の在庫）")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                        ForEach(unassignedItems) { item in
                            CellarGridSlotCell(item: item, row: 0, column: 0)
                                .onTapGesture {
                                    onSelectItem(item)
                                }
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

/// 個々のスロット（ボトルまたは空きマス）を表すセル
private struct CellarGridSlotCell: View {
    let item: BeverageItem?
    let row: Int
    let column: Int

    var body: some View {
        ZStack {
            if let item = item {
                slotContent(item: item)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .background(Color(.systemBackground).opacity(0.5))
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                    )
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .modifier(DraggableModifier(item: item))
    }

    @ViewBuilder
    private func slotContent(item: BeverageItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(categoryColor(item.category).opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(categoryColor(item.category), lineWidth: 1.5)
                )

            VStack(spacing: 2) {
                Image(systemName: "wineglass.fill")
                    .font(.caption2)
                    .foregroundStyle(categoryColor(item.category))

                Text(item.name)
                    .font(.system(size: 8, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 2)
            }
            .padding(4)
        }
    }

    private func categoryColor(_ category: BeverageCategory) -> Color {
        switch category {
        case .wine: return .purple
        case .sake: return .blue
        case .beer: return .orange
        }
    }
}

private struct DraggableModifier: ViewModifier {
    let item: BeverageItem?

    func body(content: Content) -> some View {
        if let item = item {
            content.draggable(item.id.uuidString)
        } else {
            content
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: config)
    
    let sampleLocation = StorageLocation(
        name: "自宅メインセラー",
        type: .cellar,
        memo: "温度14度設定・5段ラック",
        isGridEnabled: true,
        gridRows: 3,
        gridColumns: 4
    )
    
    let sampleItem = BeverageItem(
        name: "Barolo DOCG",
        producer: "Prunotto",
        category: .wine,
        storageLocation: "自宅メインセラー",
        gridRow: 1,
        gridColumn: 2
    )
    
    container.mainContext.insert(sampleLocation)
    container.mainContext.insert(sampleItem)
    
    return NavigationStack {
        CellarGridView(
            location: sampleLocation,
            items: [sampleItem],
            modelContext: container.mainContext,
            onSelectSlot: { row, col, item in
                print("Tapped row: \(row), col: \(col), item: \(item?.name ?? "Empty")")
            },
            onSelectItem: { item in
                print("Tapped unassigned item: \(item.name)")
            }
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    .modelContainer(container)
}
