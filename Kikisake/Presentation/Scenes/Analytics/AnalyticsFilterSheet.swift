//  AnalyticsFilterSheet.swift
//  Kikisake

import SwiftUI
import SwiftData

/// 分析画面専用のフィルター設定シート
public struct AnalyticsFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AnalyticsViewModel
    var allLogs: [TastingLog]

    public init(viewModel: AnalyticsViewModel, allLogs: [TastingLog] = []) {
        self.viewModel = viewModel
        self.allLogs = allLogs
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 1. 期間設定
                Section(String(localized: "分析対象の期間")) {
                    Picker(String(localized: "期間を選択"), selection: $viewModel.selectedTimeFilter) {
                        ForEach(AnalyticsTimeFilter.allCases) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .pickerStyle(.inline)
                }

                // 2. 酒種 (カテゴリ) 設定
                Section(String(localized: "酒種 (カテゴリ)")) {
                    Picker(String(localized: "酒種を選択"), selection: $viewModel.selectedCategoryFilter) {
                        Text("すべて").tag(BeverageCategory?.none)
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(BeverageCategory?.some(category))
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedCategoryFilter) { _, _ in
                        viewModel.selectedSubCategoryFilter = nil
                    }
                }

                // 3. 選択された酒種に応じたサブタイプ
                if let category = viewModel.selectedCategoryFilter {
                    Section(subCategorySectionTitle(for: category)) {
                        let subCategories = viewModel.availableSubCategories(from: allLogs)

                        Picker(String(localized: "サブタイプを選択"), selection: $viewModel.selectedSubCategoryFilter) {
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
            .navigationTitle(String(localized: "分析フィルター"))
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    let encoder = JSONEncoder()

    let wineMeta = WineSpecificMetadata(wineType: "赤", grapeVarieties: "ネッビオーロ", blendComponents: [])
    let wineJSON = String(data: try! encoder.encode(wineMeta), encoding: .utf8)
    let sampleItem = BeverageItem(name: "Barolo", producer: "Prunotto", category: .wine, specificMetadataJSON: wineJSON)
    let sampleLog = TastingLog(rating: 4.5, item: sampleItem)

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    let descriptor = FetchDescriptor<TastingLog>()
    let logs = (try? container.mainContext.fetch(descriptor)) ?? []

    return AnalyticsFilterSheet(viewModel: AnalyticsViewModel(), allLogs: logs)
        .modelContainer(container)
}
