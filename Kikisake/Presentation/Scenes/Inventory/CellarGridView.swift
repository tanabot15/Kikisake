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
        .frame(height: 76)
        .frame(maxWidth: .infinity)
        .modifier(DraggableModifier(item: item))
    }

    @ViewBuilder
    private func slotContent(item: BeverageItem) -> some View {
        ZStack(alignment: .bottom) {
            // 背景部分にグラデーションを重ねてテキストの視認性を確保
            if item.imageDatas?.first != nil {
                LinearGradient(
                    colors: [Color.black.opacity(0.7), Color.clear],
                    startPoint: .bottom,
                    endPoint: .center
                )
            }

            // 銘柄名・アイコン
            VStack(spacing: 2) {
                if item.imageDatas?.first == nil {
                    Image(systemName: "wineglass.fill")
                        .font(.caption2)
                        .foregroundStyle(categoryColor(item.category))
                }

                Text(item.name)
                    .font(.system(size: 8, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(item.imageDatas?.first != nil ? .white : .primary)
                    .padding(.horizontal, 2)
            }
            .padding(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // ✨ 画像をセルの背景（Background）として安全に敷き詰めることで枠外への飛び出しを完全に防止
        .background {
            if let imageData = item.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                categoryColor(item.category).opacity(0.15)
            }
        }
        // セルの枠線
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(categoryColor(item.category), lineWidth: item.imageDatas?.first != nil ? 1 : 1.5)
        )
        // 最終的に全体の角丸で完全にクリップ
        .clipShape(RoundedRectangle(cornerRadius: 8))
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

/// ✨ プレビュー用にラベル写真のサンプルデータを生成するヘルパー
private func generateSampleLabelImage(color: UIColor) -> Data? {
    let size = CGSize(width: 200, height: 300)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        // ラベル風のデザイン（中央の白い枠）
        UIColor.white.withAlphaComponent(0.9).setFill()
        context.fill(CGRect(x: 20, y: 40, width: 160, height: 220))
    }
    return image.jpegData(compressionQuality: 0.8)
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
        gridColumns: 3
    )
    
    // 1. 写真ありのサンプルアイテム 1 (ワイン: 赤系ラベル)
    let itemWithPhoto1 = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        storageLocation: "自宅メインセラー",
        gridRow: 1,
        gridColumn: 1,
        imageDatas: [generateSampleLabelImage(color: UIColor(red: 0.5, green: 0.1, blue: 0.15, alpha: 1.0)) ?? Data()]
    )

    // 2. 写真ありのサンプルアイテム 2 (日本酒: 白系ラベル)
    let itemWithPhoto2 = BeverageItem(
        name: "獺祭 純米大吟醸 磨き二割三分",
        producer: "旭酒造",
        category: .sake,
        storageLocation: "自宅メインセラー",
        gridRow: 1,
        gridColumn: 3,
        imageDatas: [generateSampleLabelImage(color: UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)) ?? Data()]
    )

    // 3. 写真なしのサンプルアイテム（従来のプレースホルダー表示確認用）
    let itemWithoutPhoto = BeverageItem(
        name: "Chablis 2021",
        producer: "William Fevre",
        category: .wine,
        storageLocation: "自宅メインセラー",
        gridRow: 2,
        gridColumn: 2
    )
    
    container.mainContext.insert(sampleLocation)
    container.mainContext.insert(itemWithPhoto1)
    container.mainContext.insert(itemWithPhoto2)
    container.mainContext.insert(itemWithoutPhoto)
    
    return NavigationStack {
        CellarGridView(
            location: sampleLocation,
            items: [itemWithPhoto1, itemWithPhoto2, itemWithoutPhoto],
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
