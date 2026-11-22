//
//  StoragePickerWithGridMappingView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Storage location selector with optional grid slot mapping.
public struct StoragePickerWithGridMappingView: View {
    @Bindable var viewModel: AddFlowViewModel
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    @Query private var allItems: [BeverageItem]

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker(String(localized: "保管場所"), selection: $viewModel.storageLocation) {
                if locations.isEmpty {
                    Text(String(localized: "未設定 (自動作成)")).tag("未設定")
                } else {
                    ForEach(locations, id: \.name) { loc in
                        Text(loc.name).tag(loc.name)
                    }
                }
            }
            .onChange(of: viewModel.storageLocation) { _, _ in
                viewModel.selectedGridRow = nil
                viewModel.selectedGridColumn = nil
            }

            if let currentLocation = locations.first(where: { $0.name == viewModel.storageLocation }),
               currentLocation.isGridEnabled {
                Divider()
                gridSlotSelectorView(for: currentLocation)
            }
        }
        .onAppear {
            if locations.isEmpty {
                viewModel.storageLocation = "未設定"
            } else if viewModel.storageLocation.isEmpty || !locations.contains(where: { $0.name == viewModel.storageLocation }),
                      let first = locations.first {
                viewModel.storageLocation = first.name
            }
        }
    }

    @ViewBuilder
    private func gridSlotSelectorView(for currentLocation: StorageLocation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundStyle(Color.accentColor)
                Text(String(localized: "棚・スロット位置の指定 (任意)"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            HStack(spacing: 12) {
                Picker(
                    String(localized: "段 (Row)"),
                    selection: Binding(
                        get: { viewModel.selectedGridRow ?? 1 },
                        set: { viewModel.selectedGridRow = $0 }
                    )
                ) {
                    ForEach(1...currentLocation.gridRows, id: \.self) { row in
                        Text(String(format: String(localized: "第 %d 段"), row)).tag(row)
                    }
                }
                .pickerStyle(.menu)

                Picker(
                    String(localized: "列 (Column)"),
                    selection: Binding(
                        get: { viewModel.selectedGridColumn ?? 1 },
                        set: { viewModel.selectedGridColumn = $0 }
                    )
                ) {
                    ForEach(1...currentLocation.gridColumns, id: \.self) { col in
                        Text(String(format: String(localized: "%d 列目"), col)).tag(col)
                    }
                }
                .pickerStyle(.menu)
            }

            if let row = viewModel.selectedGridRow, let col = viewModel.selectedGridColumn {
                let isOccupied = allItems.contains { item in
                    item.storageLocation == currentLocation.name &&
                    item.gridRow == row &&
                    item.gridColumn == col &&
                    item.id != viewModel.sourceItem?.id
                }

                if isOccupied {
                    Label(
                        String(localized: "このスロットにはすでに別のボトルが配置されています"),
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(.orange)
                } else {
                    Label(
                        String(localized: "このスロットは空いています"),
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StoragePickerWithGridMappingViewPreviewHost()
}

private struct StoragePickerWithGridMappingViewPreviewHost: View {
    private let container: ModelContainer

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, configurations: config)
        modelContainer.mainContext.insert(
            StorageLocation(name: "ワインセラー", type: .cellar, isGridEnabled: true, gridRows: 3, gridColumns: 4)
        )
        self.container = modelContainer
    }

    var body: some View {
        StoragePickerWithGridMappingView(viewModel: AddFlowViewModel())
            .padding()
            .modelContainer(container)
    }
}
