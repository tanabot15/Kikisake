//
//  InventoryFilterSheet.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Filter configuration sheet dedicated to InventoryView.
public struct InventoryFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: InventoryViewModel
    var allItems: [BeverageItem]

    public init(viewModel: InventoryViewModel, allItems: [BeverageItem]) {
        self.viewModel = viewModel
        self.allItems = allItems
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "保管場所の種類")) {
                    Picker(String(localized: "保管場所の種類"), selection: $viewModel.selectedStorageCategoryType) {
                        Text(String(localized: "すべて")).tag(StorageCategoryType?.none)
                        ForEach(StorageCategoryType.allCases) { type in
                            Text(type.localizedName).tag(StorageCategoryType?.some(type))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(String(localized: "酒種 (カテゴリ)")) {
                    Picker(String(localized: "酒種を選択"), selection: $viewModel.selectedCategory) {
                        Text(String(localized: "すべて")).tag(BeverageCategory?.none)
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(BeverageCategory?.some(category))
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedCategory) { _, _ in
                        viewModel.selectedSubCategory = nil
                    }
                }

                if let category = viewModel.selectedCategory {
                    Section(subCategorySectionTitle(for: category)) {
                        let subCategories = viewModel.availableSubCategories(from: allItems)

                        Picker(String(localized: "サブタイプを選択"), selection: $viewModel.selectedSubCategory) {
                            Text(String(localized: "すべて")).tag(String?.none)
                            ForEach(subCategories, id: \.self) { sub in
                                Text(sub).tag(String?.some(sub))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        viewModel.resetFilters()
                    } label: {
                        HStack {
                            Spacer()
                            Text(String(localized: "フィルター条件をリセット"))
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "在庫フィルター"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "完了")) {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func subCategorySectionTitle(for category: BeverageCategory) -> String {
        switch category {
        case .wine: return String(localized: "ワインタイプ")
        case .sake: return String(localized: "特定名称")
        case .beer: return String(localized: "ビアスタイル")
        }
    }
}

#Preview {
    InventoryFilterSheetPreviewHost()
}

private struct InventoryFilterSheetPreviewHost: View {
    private let sample = PreviewSampleData.makeSampleBundle()

    var body: some View {
        InventoryFilterSheet(
            viewModel: InventoryViewModel(),
            allItems: [sample.wineItem, sample.sakeItem, sample.beerItem]
        )
        .modelContainer(PreviewSampleData.container)
    }
}
