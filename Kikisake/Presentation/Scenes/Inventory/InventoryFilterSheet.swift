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
    private let container: ModelContainer
    private let items: [BeverageItem]

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
        let encoder = JSONEncoder()

        let wineMeta = WineSpecificMetadata(
            wineType: "赤",
            grapeVarieties: "カベルネ・ソーヴィニヨン",
            blendComponents: [],
            appellation: "Bordeaux"
        )
        let wineJSON = String(data: try! encoder.encode(wineMeta), encoding: .utf8)
        let sampleWine = BeverageItem(
            name: "Chateau Margaux",
            producer: "Margaux",
            category: .wine,
            specificMetadataJSON: wineJSON
        )

        let sakeMeta = SakeSpecificMetadata(
            specificName: "純米大吟醸",
            riceVariety: "山田錦",
            polishingRate: "40%",
            sakeMeterValue: "+4.0"
        )
        let sakeJSON = String(data: try! encoder.encode(sakeMeta), encoding: .utf8)
        let sampleSake = BeverageItem(
            name: "獺祭 磨き二割三分",
            producer: "旭酒造",
            category: .sake,
            specificMetadataJSON: sakeJSON
        )

        modelContainer.mainContext.insert(sampleWine)
        modelContainer.mainContext.insert(sampleSake)

        let descriptor = FetchDescriptor<BeverageItem>()
        self.items = (try? modelContainer.mainContext.fetch(descriptor)) ?? []
        self.container = modelContainer
    }

    var body: some View {
        InventoryFilterSheet(viewModel: InventoryViewModel(), allItems: items)
            .modelContainer(container)
    }
}
