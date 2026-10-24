//  CellarGridView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// セラーや冷蔵庫の棚番（グリッド）を視覚的に表示するコンポーネント
public struct CellarGridView: View {
    let location: StorageLocation
    let items: [BeverageItem]
    
    // スロットタップ時のアクション（ボトルが入っている場合 / 空きスロットの場合）
    let onSelectSlot: (Int, Int, BeverageItem?) -> Void

    public init(
        location: StorageLocation,
        items: [BeverageItem],
        onSelectSlot: @escaping (Int, Int, BeverageItem?) -> Void
    ) {
        self.location = location
        self.items = items
        self.onSelectSlot = onSelectSlot
    }

    public var body: some View {
        VStack(spacing: 14) {
            // 保管場所のメモやグリッド情報のヘッダー表示
            if !location.memo.isEmpty {
                HStack {
                    Text(location.memo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }

            // グリッド（棚）の段（行）ループ
            VStack(spacing: 8) {
                ForEach(1...location.gridRows, id: \.self) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        // 各段のラベル
                        HStack {
                            Text("第 \(row) 段")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)

                        // 各段の横列（スロット）ループ
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: location.gridColumns), spacing: 6) {
                            ForEach(1...location.gridColumns, id: \.self) { col in
                                // 該当する行・列に配置されているアイテムを特定
                                let itemInSlot = items.first { item in
                                    item.storageLocation == location.name &&
                                    item.gridRow == row &&
                                    item.gridColumn == col &&
                                    item.stockQuantity > 0
                                }

                                CellarGridSlotCell(item: itemInSlot, row: row, column: col)
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
                // ボトルが配置されている場合
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
            } else {
                // 空きスロットの場合
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
    }

    private func categoryColor(_ category: BeverageCategory) -> Color {
        switch category {
        case .wine: return .purple
        case .sake: return .blue
        case .beer: return .orange
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, configurations: config)
    
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
        stockQuantity: 1,
        storageLocation: "自宅メインセラー",
        gridRow: 1,
        gridColumn: 2
    )
    
    container.mainContext.insert(sampleLocation)
    container.mainContext.insert(sampleItem)
    
    return CellarGridView(location: sampleLocation, items: [sampleItem]) { row, col, item in
        print("Tapped row: \(row), col: \(col), item: \(item?.name ?? "Empty")")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .modelContainer(container)
}
