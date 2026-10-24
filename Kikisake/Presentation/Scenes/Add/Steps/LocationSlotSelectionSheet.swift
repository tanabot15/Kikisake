//  LocationSlotSelectionSheet.swift
//  Kikisake

import SwiftUI
import SwiftData

/// 保管場所（セラー）保存時に棚のどの位置（スロット）に置くかを選択するシート（ビジュアルグリッド版）
public struct LocationSlotSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let location: StorageLocation
    @Bindable var viewModel: AddFlowViewModel
    var onComplete: () -> Void

    @Query private var allItems: [BeverageItem]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. セラー概要カード
                    HStack {
                        Image(systemName: location.type.defaultIconName)
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(location.name)
                                .font(.headline)
                            Text("\(location.gridRows)段 × \(location.gridColumns)列 (\(location.gridRows * location.gridColumns)本収納)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)

                    // 2. 視覚的セラーグリッド
                    VStack(alignment: .leading, spacing: 12) {
                        Text("格納するスロットをタップして選択してください")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 8) {
                            ForEach(1...location.gridRows, id: \.self) { row in
                                HStack(spacing: 8) {
                                    Text("\(row)段")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 28, alignment: .trailing)

                                    ForEach(1...location.gridColumns, id: \.self) { col in
                                        let occupiedItem = itemAt(row: row, col: col)
                                        let isSelected = viewModel.selectedGridRow == row && viewModel.selectedGridColumn == col

                                        Button {
                                            if occupiedItem == nil {
                                                viewModel.selectedGridRow = row
                                                viewModel.selectedGridColumn = col
                                            }
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(gridTileBackgroundColor(occupiedItem: occupiedItem, isSelected: isSelected))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(gridTileBorderColor(occupiedItem: occupiedItem, isSelected: isSelected), lineWidth: isSelected ? 2.5 : 1)
                                                    )

                                                if isSelected {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 18, weight: .bold))
                                                        .foregroundStyle(Color.accentColor)
                                                } else if let _ = occupiedItem {
                                                    Image(systemName: "winebottle.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundStyle(Color(.systemGray3))
                                                } else {
                                                    Text("\(col)")
                                                        .font(.caption2)
                                                        .foregroundStyle(Color(.tertiaryLabel))
                                                }
                                            }
                                            .frame(height: 44)
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(occupiedItem != nil) // 埋まっている場所はタップ不可
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }

                    // 3. 選択場所の確認インジケータ
                    if let row = viewModel.selectedGridRow, let col = viewModel.selectedGridColumn {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            Text("選択中: 第 \(row) 段 - \(col) 列目")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("空いているスロットを選択してください")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("格納スロットの指定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("ここに配置して保存") {
                        dismiss()
                        onComplete()
                    }
                    .fontWeight(.bold)
                    .disabled(viewModel.selectedGridRow == nil || viewModel.selectedGridColumn == nil) // 場所未選択時は保存不可
                }
            }
            .onAppear {
                autoSelectFirstAvailableSlot()
            }
        }
    }

    /// 該当位置にあるボトルを取得
    private func itemAt(row: Int, col: Int) -> BeverageItem? {
        allItems.first { item in
            item.storageLocation == location.name &&
            item.gridRow == row &&
            item.gridColumn == col &&
            item.stockQuantity > 0 &&
            item.id != viewModel.sourceItem?.id
        }
    }

    /// 最初に見つかった空きスロットを自動選択
    private func autoSelectFirstAvailableSlot() {
        if viewModel.selectedGridRow != nil && viewModel.selectedGridColumn != nil {
            // すでに有効な場所がセットされている場合はそのまま
            if itemAt(row: viewModel.selectedGridRow!, col: viewModel.selectedGridColumn!) == nil {
                return
            }
        }
        
        for r in 1...location.gridRows {
            for c in 1...location.gridColumns {
                if itemAt(row: r, col: c) == nil {
                    viewModel.selectedGridRow = r
                    viewModel.selectedGridColumn = c
                    return
                }
            }
        }
    }

    // タイルの背景色
    private func gridTileBackgroundColor(occupiedItem: BeverageItem?, isSelected: Bool) -> Color {
        if isSelected {
            return Color.accentColor.opacity(0.15)
        } else if occupiedItem != nil {
            return Color(.systemGray6)
        } else {
            return Color(.systemBackground)
        }
    }

    // タイルの枠線色
    private func gridTileBorderColor(occupiedItem: BeverageItem?, isSelected: Bool) -> Color {
        if isSelected {
            return Color.accentColor
        } else if occupiedItem != nil {
            return Color(.systemGray4)
        } else {
            return Color.green.opacity(0.4)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, configurations: config)
    
    // サンプルの保管場所（ワインセラー: 4段 × 6列）
    let sampleLocation = StorageLocation(
        name: "自宅メインセラー",
        type: .cellar,
        memo: "14度設定",
        isGridEnabled: true,
        gridRows: 4,
        gridColumns: 6
    )
    
    // 既存で 1段目の1列目・2列目に配置されているサンプルボトル
    let occupiedItem1 = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        stockQuantity: 1,
        storageLocation: "自宅メインセラー",
        gridRow: 1,
        gridColumn: 1
    )
    let occupiedItem2 = BeverageItem(
        name: "Opus One 2018",
        producer: "Opus One Winery",
        category: .wine,
        stockQuantity: 1,
        storageLocation: "自宅メインセラー",
        gridRow: 1,
        gridColumn: 2
    )
    
    container.mainContext.insert(sampleLocation)
    container.mainContext.insert(occupiedItem1)
    container.mainContext.insert(occupiedItem2)
    
    struct PreviewWrapper: View {
        @Environment(\.modelContext) private var modelContext
        @State private var viewModel = AddFlowViewModel()
        @State private var targetLocation: StorageLocation? = nil
        
        var body: some View {
            Group {
                if let location = targetLocation {
                    LocationSlotSelectionSheet(
                        location: location,
                        viewModel: viewModel,
                        onComplete: {
                            print("Selected Row: \(viewModel.selectedGridRow ?? 0), Column: \(viewModel.selectedGridColumn ?? 0)")
                        }
                    )
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                let descriptor = FetchDescriptor<StorageLocation>()
                if let loc = try? modelContext.fetch(descriptor).first {
                    targetLocation = loc
                }
            }
        }
    }
    
    return PreviewWrapper()
        .modelContainer(container)
}
