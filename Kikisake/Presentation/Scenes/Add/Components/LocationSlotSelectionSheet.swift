//
//  LocationSlotSelectionSheet.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Visual grid sheet for choosing a storage slot when saving to a grid-enabled location.
public struct LocationSlotSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let location: StorageLocation
    @Bindable var viewModel: AddFlowViewModel
    var onComplete: () -> Void

    @Query private var allItems: [BeverageItem]

    public init(
        location: StorageLocation,
        viewModel: AddFlowViewModel,
        onComplete: @escaping () -> Void
    ) {
        self.location = location
        self.viewModel = viewModel
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    locationSummaryCard
                    slotGridSection
                    selectionStatusBanner
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("スロット指定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("未配置で保存") {
                        viewModel.selectedGridRow = nil
                        viewModel.selectedGridColumn = nil
                        dismiss()
                        onComplete()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("ここに配置") {
                        dismiss()
                        onComplete()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private var locationSummaryCard: some View {
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
    }

    private var slotGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("格納するスロットを選択 (任意)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                if viewModel.selectedGridRow != nil {
                    Button("未配置にする") {
                        viewModel.selectedGridRow = nil
                        viewModel.selectedGridColumn = nil
                    }
                    .font(.caption)
                    .tint(.red)
                }
            }

            VStack(spacing: 8) {
                ForEach(1...location.gridRows, id: \.self) { row in
                    HStack(spacing: 8) {
                        Text("\(row)段")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .trailing)

                        ForEach(1...location.gridColumns, id: \.self) { col in
                            slotTileButton(row: row, col: col)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }

    private func slotTileButton(row: Int, col: Int) -> some View {
        let occupiedItem = itemAt(row: row, col: col)
        let isSelected = viewModel.selectedGridRow == row && viewModel.selectedGridColumn == col

        return Button {
            guard occupiedItem == nil else { return }
            if isSelected {
                viewModel.selectedGridRow = nil
                viewModel.selectedGridColumn = nil
            } else {
                viewModel.selectedGridRow = row
                viewModel.selectedGridColumn = col
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(gridTileBackgroundColor(occupiedItem: occupiedItem, isSelected: isSelected))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                gridTileBorderColor(occupiedItem: occupiedItem, isSelected: isSelected),
                                lineWidth: isSelected ? 2.5 : 1
                            )
                    )

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                } else if occupiedItem != nil {
                    Image(systemName: "wineglass.fill")
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
        .disabled(occupiedItem != nil)
    }

    @ViewBuilder
    private var selectionStatusBanner: some View {
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
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.secondary)
                Text("スロットを未選択のまま（棚の外に）保存することもできます")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
    }

    private func itemAt(row: Int, col: Int) -> BeverageItem? {
        allItems.first { item in
            item.storageLocation == location.name &&
            item.gridRow == row &&
            item.gridColumn == col &&
            item.id != viewModel.sourceItem?.id
        }
    }

    private func gridTileBackgroundColor(occupiedItem: BeverageItem?, isSelected: Bool) -> Color {
        if isSelected {
            Color.accentColor.opacity(0.15)
        } else if occupiedItem != nil {
            Color(.systemGray6)
        } else {
            Color(.systemBackground)
        }
    }

    private func gridTileBorderColor(occupiedItem: BeverageItem?, isSelected: Bool) -> Color {
        if isSelected {
            Color.accentColor
        } else if occupiedItem != nil {
            Color(.systemGray4)
        } else {
            Color.green.opacity(0.4)
        }
    }
}

#Preview {
    LocationSlotSelectionSheetPreviewHost()
}

private struct LocationSlotSelectionSheetPreviewHost: View {
    private let sample = PreviewSampleData.makeSampleBundle()
    @State private var viewModel = AddFlowViewModel()

    var body: some View {
        LocationSlotSelectionSheet(
            location: sample.cellarLocation,
            viewModel: viewModel,
            onComplete: {}
        )
        .modelContainer(PreviewSampleData.container)
    }
}
