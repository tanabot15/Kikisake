//
//  LogFilterSheet.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Filter configuration sheet shared across log list/timeline and collection book views.
public struct LogFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: LogViewModel
    private let collectionViewModel: CollectionViewModel
    private let currentCollectionCategory: BeverageCategory
    private let isPro: Bool

    public init(
        viewModel: LogViewModel,
        collectionViewModel: CollectionViewModel = CollectionViewModel(),
        currentCollectionCategory: BeverageCategory = .wine,
        isPro: Bool = AppState.shared.isProVersion
    ) {
        self.viewModel = viewModel
        self.collectionViewModel = collectionViewModel
        self.currentCollectionCategory = currentCollectionCategory
        self.isPro = isPro
    }

    private var availableColorOptions: [ColorOption] {
        TastingOptions.colorOptions(for: viewModel.selectedCategoryFilter, wineType: viewModel.wineTypeFilter)
    }

    private var availableAromaTags: [String] {
        let categories = TastingOptions.aromaCategories(for: viewModel.selectedCategoryFilter, wineType: viewModel.wineTypeFilter)
        return categories.flatMap(\.tags).map(\.name)
    }

    private var effectiveCollectionCategory: BeverageCategory {
        viewModel.collectionCategoryFilter ?? currentCollectionCategory
    }

    private var availableCollectionRegions: [String] {
        collectionViewModel.availableRegions(for: effectiveCollectionCategory, isPro: isPro)
    }

    private var availableCollectionTargetElements: [String] {
        collectionViewModel.availableTargetElements(
            for: effectiveCollectionCategory,
            isPro: isPro,
            region: viewModel.collectionRegionFilter
        )
    }

    public var body: some View {
        NavigationStack {
            Form {
                if viewModel.selectedSection == .collectionBook {
                    collectionFilterSections
                } else {
                    logFilterSections
                }

                Section {
                    Button(role: .destructive) {
                        viewModel.resetCurrentSectionFilters()
                    } label: {
                        HStack {
                            Spacer()
                            Text("すべてのフィルターをリセット")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.hasActiveCurrentSectionFilters)
                }
            }
            .navigationTitle(viewModel.selectedSection == .collectionBook ? "図鑑フィルター" : "フィルターと並び替え")
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

    // MARK: - Collection Book Filters

    @ViewBuilder
    private var collectionFilterSections: some View {
        Section("酒種 (カテゴリ)") {
            Picker("酒種", selection: Binding(
                get: { viewModel.collectionCategoryFilter },
                set: { newValue in
                    viewModel.collectionCategoryFilter = newValue
                    viewModel.collectionRegionFilter = ""
                    viewModel.collectionTargetElementFilter = ""
                }
            )) {
                Text("現在のタブ (\(currentCollectionCategory.displayName))").tag(BeverageCategory?.none)
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(BeverageCategory?.some(category))
                }
            }
        }

        Section("産地") {
            Picker("産地", selection: Binding(
                get: { viewModel.collectionRegionFilter },
                set: { newRegion in
                    viewModel.collectionRegionFilter = newRegion
                    let validElements = collectionViewModel.availableTargetElements(
                        for: effectiveCollectionCategory,
                        isPro: isPro,
                        region: newRegion
                    )
                    if !viewModel.collectionTargetElementFilter.isEmpty,
                       !validElements.contains(viewModel.collectionTargetElementFilter) {
                        viewModel.collectionTargetElementFilter = ""
                    }
                }
            )) {
                Text("すべて").tag("")
                ForEach(availableCollectionRegions, id: \.self) { region in
                    Text(region).tag(region)
                }
            }
        }

        Section("品種・米・スタイル") {
            Picker("品種・米・スタイル", selection: $viewModel.collectionTargetElementFilter) {
                Text("すべて").tag("")
                ForEach(availableCollectionTargetElements, id: \.self) { element in
                    Text(element).tag(element)
                }
            }
        }
    }

    // MARK: - Log Filters

    @ViewBuilder
    private var logFilterSections: some View {
        Section("酒種 (カテゴリ)") {
            Picker("酒種を選択", selection: $viewModel.selectedCategoryFilter) {
                Text("すべて").tag(BeverageCategory?.none)
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(BeverageCategory?.some(category))
                }
            }
            .pickerStyle(.segmented)
        }

        Section("基本情報") {
            TextField("生産者 / 蔵元 / ブルワリー", text: $viewModel.producerFilter)
            TextField("生産地 (例: ボルドー, 新潟)", text: $viewModel.regionFilter)
            TextField("ヴィンテージ / 製造年月 (例: 2020)", text: $viewModel.vintageFilter)
        }

        Section("スペック") {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("最低アルコール度数")
                        .font(.subheadline)
                    Spacer()
                    Text(viewModel.minAbv == nil ? "指定なし" : String(format: "%.1f %% 以上", viewModel.minAbv!))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                }

                Slider(
                    value: Binding(
                        get: { viewModel.minAbv ?? 0.0 },
                        set: { viewModel.minAbv = $0 == 0.0 ? nil : $0 }
                    ),
                    in: 0.0...20.0,
                    step: 0.5
                )
            }

            HStack {
                Text("上限価格")
                    .font(.subheadline)
                Spacer()
                TextField("円", value: $viewModel.maxPrice, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
        }

        Section("評価・テイスティングデータ") {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("最低評価 (スコア)")
                        .font(.subheadline)
                    Spacer()
                    Text(viewModel.selectedRatingFilter == nil ? "指定なし" : String(format: "★ %.1f 以上", viewModel.selectedRatingFilter!))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                }

                Slider(
                    value: Binding(
                        get: { viewModel.selectedRatingFilter ?? 1.0 },
                        set: { viewModel.selectedRatingFilter = $0 }
                    ),
                    in: 1.0...5.0,
                    step: 0.5
                )
                .tint(.yellow)
            }

            Picker("外観・色調", selection: $viewModel.appearanceNoteFilter) {
                Text("指定なし").tag("")
                ForEach(availableColorOptions) { option in
                    Text(option.name).tag(option.name)
                }
            }
            .pickerStyle(.menu)

            Picker("香りタグ", selection: $viewModel.aromaTagFilter) {
                Text("指定なし").tag("")
                ForEach(availableAromaTags, id: \.self) { tag in
                    Text(tag).tag(tag)
                }
            }
            .pickerStyle(.menu)

            Picker("味わい・バランス表現", selection: $viewModel.balanceTagFilter) {
                Text("指定なし").tag("")
                ForEach(TastingOptions.balanceOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
        }

        Section("特徴・評価フラグ") {
            Toggle("コスパが高い", isOn: boolFlagBinding(\.filterCostEffective))
            Toggle("リピート意向あり", isOn: boolFlagBinding(\.filterWillingToRepeat))
            Toggle("熟成ポテンシャルあり", isOn: boolFlagBinding(\.filterAgingPotential))
        }

        Section("固有詳細条件") {
            if viewModel.selectedCategoryFilter == nil || viewModel.selectedCategoryFilter == .wine {
                Picker("ワインタイプ", selection: $viewModel.wineTypeFilter) {
                    ForEach(["すべて", "赤", "白", "ロゼ", "オレンジ", "スパークリング"], id: \.self) {
                        Text($0).tag($0)
                    }
                }
            }

            if viewModel.selectedCategoryFilter == nil || viewModel.selectedCategoryFilter == .sake {
                Picker("日本酒 特定名称", selection: $viewModel.sakeSpecificNameFilter) {
                    ForEach(["すべて", "純米大吟醸", "純米吟醸", "大吟醸", "特別純米", "純米", "本醸造"], id: \.self) {
                        Text($0 == "純米" ? "純米酒" : $0).tag($0)
                    }
                }
            }

            if viewModel.selectedCategoryFilter == nil || viewModel.selectedCategoryFilter == .beer {
                TextField("ビアスタイル (例: IPA, Stout)", text: $viewModel.beerStyleFilter)
            }
        }

        Section("並び替え (ソート)") {
            Picker("表示順序", selection: $viewModel.sortOrder) {
                ForEach(LogSortOrder.allCases, id: \.self) { order in
                    Text(order.displayName).tag(order)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private func boolFlagBinding(_ keyPath: ReferenceWritableKeyPath<LogViewModel, Bool?>) -> Binding<Bool> {
        Binding(
            get: { viewModel[keyPath: keyPath] ?? false },
            set: { viewModel[keyPath: keyPath] = $0 ? true : nil }
        )
    }
}

#Preview {
    LogFilterSheet(viewModel: LogViewModel())
        .modelContainer(PreviewSampleData.container)
}
