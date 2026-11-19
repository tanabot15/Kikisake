//  AnalyticsFilterSheet.swift
//  Kikisake

import SwiftUI
import SwiftData

/// 分析画面のフィルター設定シート（セクションごとに最適化）
public struct AnalyticsFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AnalyticsViewModel
    var allLogs: [TastingLog]

    @State private var isShowingLeftPicker = false
    @State private var isShowingRightPicker = false

    public init(viewModel: AnalyticsViewModel, allLogs: [TastingLog] = []) {
        self.viewModel = viewModel
        self.allLogs = allLogs
    }

    private var availableRegions: [String] {
        viewModel.availableRegions(from: allLogs)
    }

    private var availableAromaTags: [String] {
        viewModel.availableAromaTags(from: allLogs)
    }

    private var candidateLogs: [TastingLog] {
        viewModel.comparisonCandidateLogs(from: allLogs)
    }

    public var body: some View {
        NavigationStack {
            Form {
                switch viewModel.selectedSection {
                case .consumption:
                    timeFilterSection
                    categoryFilterSection
                    subCategorySectionIfNeeded
                    regionFilterSection

                case .evaluation:
                    timeFilterSection
                    categoryFilterSection
                    subCategorySectionIfNeeded
                    regionFilterSection
                    evaluationCriteriaSection

                case .comparison:
                    comparisonSelectionSection
                    comparisonFilterSection
                }

                // 一括リセット
                Section {
                    Button(role: .destructive) {
                        viewModel.resetFilters()
                    } label: {
                        HStack {
                            Spacer()
                            Text("すべてのフィルターをリセット")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.hasActiveFilters)
                }
            }
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $isShowingLeftPicker) {
                LogSelectionSheet(allLogs: candidateLogs, selectedLogID: $viewModel.comparisonLeftLogID)
            }
            .sheet(isPresented: $isShowingRightPicker) {
                LogSelectionSheet(allLogs: candidateLogs, selectedLogID: $viewModel.comparisonRightLogID)
            }
        }
    }

    private var sheetTitle: String {
        switch viewModel.selectedSection {
        case .consumption:
            return String(localized: "飲酒ログフィルター")
        case .evaluation:
            return String(localized: "評価フィルター")
        case .comparison:
            return String(localized: "比較フィルター")
        }
    }

    // MARK: - 共通セクション

    private var timeFilterSection: some View {
        Section("分析対象の期間") {
            Picker("期間を選択", selection: $viewModel.selectedTimeFilter) {
                ForEach(AnalyticsTimeFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            .pickerStyle(.inline)
        }
    }

    private var categoryFilterSection: some View {
        Section("酒種 (カテゴリ)") {
            Picker("酒種を選択", selection: $viewModel.selectedCategoryFilter) {
                Text("すべて").tag(BeverageCategory?.none)
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(BeverageCategory?.some(category))
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedCategoryFilter) { _, _ in
                viewModel.selectedSubCategoryFilter = nil
                if !viewModel.aromaTagFilter.isEmpty &&
                    !availableAromaTags.contains(viewModel.aromaTagFilter) {
                    viewModel.aromaTagFilter = ""
                }
            }
        }
    }

    @ViewBuilder
    private var subCategorySectionIfNeeded: some View {
        if let category = viewModel.selectedCategoryFilter {
            Section(subCategorySectionTitle(for: category)) {
                let subCategories = viewModel.availableSubCategories(from: allLogs)

                Picker("サブタイプを選択", selection: $viewModel.selectedSubCategoryFilter) {
                    Text("すべて").tag(String?.none)
                    ForEach(subCategories, id: \.self) { sub in
                        Text(sub).tag(String?.some(sub))
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    private var regionFilterSection: some View {
        Section("産地") {
            TextField("産地で絞り込み (例: ボルドー, 新潟)", text: $viewModel.regionFilter)

            if !availableRegions.isEmpty {
                Picker("記録済みの産地から選択", selection: $viewModel.regionFilter) {
                    Text("指定なし").tag("")
                    ForEach(availableRegions, id: \.self) { region in
                        Text(region).tag(region)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    // MARK: - 評価タブ専用セクション

    private var evaluationCriteriaSection: some View {
        Section("評価・アロマ条件") {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("最低評価 (スコア)")
                        .font(.subheadline)
                    Spacer()
                    Text(viewModel.minRatingFilter == nil ? "指定なし" : String(format: "★ %.1f 以上", viewModel.minRatingFilter!))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                }

                Slider(
                    value: Binding(
                        get: { viewModel.minRatingFilter ?? 1.0 },
                        set: { viewModel.minRatingFilter = $0 }
                    ),
                    in: 1.0...5.0,
                    step: 0.5
                )
                .tint(.yellow)
            }

            Picker("香りタグ", selection: $viewModel.aromaTagFilter) {
                Text("指定なし").tag("")
                ForEach(availableAromaTags, id: \.self) { tag in
                    Text(tag).tag(tag)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - 比較タブ専用セクション

    private var comparisonSelectionSection: some View {
        Section("比較対象ログ") {
            Button {
                isShowingLeftPicker = true
            } label: {
                HStack {
                    Text("左のログ")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(selectedLogTitle(for: viewModel.comparisonLeftLogID, fallback: allLogs.first))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Button {
                isShowingRightPicker = true
            } label: {
                HStack {
                    Text("右のログ")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(selectedLogTitle(for: viewModel.comparisonRightLogID, fallback: allLogs.dropFirst().first ?? allLogs.first))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    private var comparisonFilterSection: some View {
        Section("比較候補の絞り込み") {
            Picker("酒種を選択", selection: $viewModel.selectedCategoryFilter) {
                Text("すべて").tag(BeverageCategory?.none)
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(BeverageCategory?.some(category))
                }
            }
            .pickerStyle(.segmented)

            TextField("産地 (例: ボルドー, 秋田県)", text: $viewModel.regionFilter)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("最低評価 (スコア)")
                        .font(.subheadline)
                    Spacer()
                    Text(viewModel.minRatingFilter == nil ? "指定なし" : String(format: "★ %.1f 以上", viewModel.minRatingFilter!))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                }

                Slider(
                    value: Binding(
                        get: { viewModel.minRatingFilter ?? 1.0 },
                        set: { viewModel.minRatingFilter = $0 }
                    ),
                    in: 1.0...5.0,
                    step: 0.5
                )
                .tint(.yellow)
            }
        }
    }

    private func selectedLogTitle(for id: UUID?, fallback: TastingLog?) -> String {
        let target = id.flatMap { targetID in allLogs.first(where: { $0.id == targetID }) } ?? fallback
        return target?.item?.name ?? String(localized: "未選択")
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
