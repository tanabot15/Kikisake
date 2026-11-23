//
//  AnalyticsFilterSheet.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Section-aware filter configuration sheet for AnalyticsView.
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
                    categoryFilterSection(clearAromaOnChange: false)
                    subCategorySectionIfNeeded
                    regionFilterSection

                case .evaluation:
                    timeFilterSection
                    categoryFilterSection(clearAromaOnChange: true)
                    subCategorySectionIfNeeded
                    regionFilterSection
                    evaluationCriteriaSection

                case .comparison:
                    comparisonSelectionSection
                    comparisonFilterSection
                }

                resetFilterSection
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
        case .consumption: String(localized: "飲酒ログフィルター")
        case .evaluation: String(localized: "評価フィルター")
        case .comparison: String(localized: "比較フィルター")
        }
    }

    // MARK: - Shared Sections

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

    private func categoryFilterSection(clearAromaOnChange: Bool) -> some View {
        Section("酒種 (カテゴリ)") {
            categorySegmentedPicker
                .onChange(of: viewModel.selectedCategoryFilter) { _, _ in
                    viewModel.selectedSubCategoryFilter = nil
                    if clearAromaOnChange,
                       !viewModel.aromaTagFilter.isEmpty,
                       !availableAromaTags.contains(viewModel.aromaTagFilter) {
                        viewModel.aromaTagFilter = ""
                    }
                }
        }
    }

    private var categorySegmentedPicker: some View {
        Picker("酒種を選択", selection: $viewModel.selectedCategoryFilter) {
            Text("すべて").tag(BeverageCategory?.none)
            ForEach(BeverageCategory.allCases, id: \.self) { category in
                Text(category.displayName).tag(BeverageCategory?.some(category))
            }
        }
        .pickerStyle(.segmented)
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

    private var minimumRatingSlider: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("最低評価 (スコア)")
                    .font(.subheadline)
                Spacer()
                Text(
                    viewModel.minRatingFilter == nil
                        ? "指定なし"
                        : String(format: "★ %.1f 以上", viewModel.minRatingFilter!)
                )
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

    private var resetFilterSection: some View {
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

    // MARK: - Evaluation Section

    private var evaluationCriteriaSection: some View {
        Section("評価・アロマ条件") {
            minimumRatingSlider

            Picker("香りタグ", selection: $viewModel.aromaTagFilter) {
                Text("指定なし").tag("")
                ForEach(availableAromaTags, id: \.self) { tag in
                    Text(tag).tag(tag)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Comparison Sections

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
            categorySegmentedPicker
            TextField("産地 (例: ボルドー, 秋田県)", text: $viewModel.regionFilter)
            minimumRatingSlider
        }
    }

    private func selectedLogTitle(for id: UUID?, fallback: TastingLog?) -> String {
        let target = id.flatMap { targetID in allLogs.first { $0.id == targetID } } ?? fallback
        return target?.item?.name ?? String(localized: "未選択")
    }

    private func subCategorySectionTitle(for category: BeverageCategory) -> String {
        switch category {
        case .wine: String(localized: "ワインタイプ")
        case .sake: String(localized: "特定名称")
        case .beer: String(localized: "ビアスタイル")
        }
    }
}

#Preview {
    let sample = PreviewSampleData.makeSampleBundle()
    return AnalyticsFilterSheet(
        viewModel: AnalyticsViewModel(),
        allLogs: [sample.wineLog, sample.sakeLog, sample.beerLog]
    )
    .modelContainer(PreviewSampleData.container)
}
