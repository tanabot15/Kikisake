//
//  InventoryLocationCardView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Accordion card and expandable list/grid body for a single storage location.
struct InventoryLocationCardView: View {
    let location: StorageLocation
    let items: [BeverageItem]
    let modelContext: ModelContext
    @Bindable var viewModel: InventoryViewModel

    let isExpanded: Bool
    @Binding var displayMode: CellarDisplayMode
    @Binding var isEditingList: Bool

    let onToggleExpand: () -> Void
    let onRequestResize: (StorageLocation) -> Void
    let onSelectItem: (BeverageItem) -> Void
    let onError: (String) -> Void

    private var currentMode: CellarDisplayMode {
        if location.isGridEnabled {
            return displayMode
        }
        return .list
    }

    var body: some View {
        let summaryList = viewModel.categorySummaryList(for: location.name, in: items)
        let displayItems = viewModel.filteredItems(items, for: location.name)

        VStack(spacing: 0) {
            headerButton(summaryList: summaryList)

            if isExpanded {
                expandedBody(displayItems: displayItems)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func headerButton(summaryList: [(categoryName: String, count: Int)]) -> some View {
        Button(action: onToggleExpand) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: location.type.defaultIconName)
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }

                Text(location.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()

                if summaryList.isEmpty {
                    Text(String(localized: "在庫なし"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(summaryList, id: \.categoryName) { summary in
                            Text(String(format: String(localized: "%@ %d本"), summary.categoryName, summary.count))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
                    .padding(.trailing, 4)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func expandedBody(displayItems: [BeverageItem]) -> some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal)

            toolbarRow(displayItems: displayItems)

            if currentMode == .grid && location.isGridEnabled {
                CellarGridView(
                    location: location,
                    items: displayItems,
                    modelContext: modelContext,
                    onSelectSlot: { _, _, item in
                        if let item = item {
                            onSelectItem(item)
                        }
                    },
                    onSelectItem: onSelectItem,
                    onError: onError
                )
                .padding(.horizontal, 12)
            } else {
                listContent(displayItems: displayItems)
            }
        }
        .padding(.bottom, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func toolbarRow(displayItems: [BeverageItem]) -> some View {
        HStack {
            if location.isGridEnabled {
                Picker(String(localized: "表示形式"), selection: $displayMode) {
                    ForEach(CellarDisplayMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Spacer()

            if currentMode == .grid && location.isGridEnabled {
                Button {
                    onRequestResize(location)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            if currentMode == .list && !displayItems.isEmpty {
                Button {
                    withAnimation {
                        isEditingList.toggle()
                    }
                } label: {
                    Image(systemName: isEditingList ? "checkmark.circle.fill" : "square.and.pencil")
                        .fontWeight(.semibold)
                        .foregroundStyle(isEditingList ? Color.accentColor : .secondary)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func listContent(displayItems: [BeverageItem]) -> some View {
        if displayItems.isEmpty {
            Text(String(localized: "条件に一致する在庫はありません"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 16)
        } else {
            VStack(spacing: 8) {
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                    editableRow(item: item, index: index, displayItems: displayItems)
                }
            }
            .animation(.snappy, value: isEditingList)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
    }

    private func editableRow(item: BeverageItem, index: Int, displayItems: [BeverageItem]) -> some View {
        HStack(spacing: 8) {
            if isEditingList {
                Button {
                    viewModel.deleteItem(item, modelContext: modelContext)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
                .transition(.scale.combined(with: .opacity))
                .padding(.leading, 8)
            }

            itemCardButton(item: item)

            if isEditingList {
                Image(systemName: "line.3.horizontal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 8)
                    .contentShape(Rectangle())
                    .draggable(item.id.uuidString)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .dropDestination(for: String.self) { droppedItems, _ in
            guard let uuidString = droppedItems.first,
                  let uuid = UUID(uuidString: uuidString),
                  let sourceIndex = displayItems.firstIndex(where: { $0.id == uuid }) else {
                return false
            }

            var mutableItems = displayItems
            let movedItem = mutableItems.remove(at: sourceIndex)
            mutableItems.insert(movedItem, at: index)

            viewModel.saveNewOrder(for: mutableItems, modelContext: modelContext)
            return true
        }
    }

    private func itemCardButton(item: BeverageItem) -> some View {
        let averageRating: Double? = {
            let logs = item.tastingLogs ?? []
            guard !logs.isEmpty else { return nil }
            let total = logs.reduce(0.0) { $0 + $1.rating }
            return total / Double(logs.count)
        }()

        return Button {
            if !isEditingList {
                onSelectItem(item)
            }
        } label: {
            BeverageCardView(
                name: item.name,
                producer: item.producer,
                category: item.category,
                region: item.region,
                vintage: item.vintage,
                rating: averageRating,
                imageData: item.imageDatas?.first,
                isBackgroundRemoved: item.isBackgroundRemoved
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
