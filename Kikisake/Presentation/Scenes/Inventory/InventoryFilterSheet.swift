//  InventoryFilterSheet.swift
//  Kikisake

import SwiftUI
import SwiftData

/// 在庫管理画面専用のフィルター設定シート
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
                // 1. 保管場所の種類 (StorageCategoryType)
                Section("保管場所の種類") {
                    Picker("保管場所の種類", selection: $viewModel.selectedStorageCategoryType) {
                        Text("すべて").tag(StorageCategoryType?.none)
                        ForEach(StorageCategoryType.allCases) { type in
                            Text(type.rawValue).tag(StorageCategoryType?.some(type))
                        }
                    }
                    .pickerStyle(.menu)
                }

                // 2. 酒種 (categoryRawValue)
                Section("酒種 (カテゴリ)") {
                    Picker("酒種を選択", selection: $viewModel.selectedCategory) {
                        Text("すべて").tag(BeverageCategory?.none)
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(BeverageCategory?.some(category))
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedCategory) { _, _ in
                        // 酒種が切り替わったらサブカテゴリの選択をリセット
                        viewModel.selectedSubCategory = nil
                    }
                }

                // 3. 選択された酒種に応じたサブタイプ（wineType / specificName / beerStyle）
                if let category = viewModel.selectedCategory {
                    Section(subCategorySectionTitle(for: category)) {
                        let subCategories = viewModel.availableSubCategories(from: allItems)
                        
                        Picker("サブタイプを選択", selection: $viewModel.selectedSubCategory) {
                            Text("すべて").tag(String?.none)
                            ForEach(subCategories, id: \.self) { sub in
                                Text(sub).tag(String?.some(sub))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                // 4. フィルターリセット
                Section {
                    Button(role: .destructive) {
                        viewModel.resetFilters()
                    } label: {
                        HStack {
                            Spacer()
                            Text("フィルター条件をリセット")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("在庫フィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func subCategorySectionTitle(for category: BeverageCategory) -> String {
        switch category {
        case .wine: return "ワインタイプ"
        case .sake: return "特定名称"
        case .beer: return "ビアスタイル"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    let encoder = JSONEncoder()

    // サンプルデータの作成
    let wineMeta = WineSpecificMetadata(wineType: "赤", grapeVarieties: "カベルネ・ソーヴィニヨン", blendComponents: [], appellation: "Bordeaux")
    let wineJSON = String(data: try! encoder.encode(wineMeta), encoding: .utf8)
    let sampleWine = BeverageItem(name: "Chateau Margaux", producer: "Margaux", category: .wine, stockQuantity: 2, specificMetadataJSON: wineJSON)

    let sakeMeta = SakeSpecificMetadata(specificName: "純米大吟醸", riceVariety: "山田錦", polishingRate: "40%", sakeMeterValue: "+4.0")
    let sakeJSON = String(data: try! encoder.encode(sakeMeta), encoding: .utf8)
    let sampleSake = BeverageItem(name: "獺祭 磨き二割三分", producer: "旭酒造", category: .sake, stockQuantity: 1, specificMetadataJSON: sakeJSON)

    container.mainContext.insert(sampleWine)
    container.mainContext.insert(sampleSake)

    // サンプルアイテムを取得してプレビューに渡す
    let descriptor = FetchDescriptor<BeverageItem>()
    let items = (try? container.mainContext.fetch(descriptor)) ?? []

    return InventoryFilterSheet(viewModel: InventoryViewModel(), allItems: items)
        .modelContainer(container)
}
