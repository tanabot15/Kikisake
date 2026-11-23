//
//  ConsumptionView.swift
//  Kikisake
//

import SwiftUI
import SwiftData
import Charts

/// Consumption statistics, 4-month drinking heatmap, and category ratio chart.
public struct ConsumptionView: View {
    @Bindable var viewModel: AnalyticsViewModel
    let targetLogs: [TastingLog]

    private let subCategoryPalette: [Color] = [.purple, .blue, .orange, .pink, .teal, .indigo, .brown]

    public init(viewModel: AnalyticsViewModel, targetLogs: [TastingLog]) {
        self.viewModel = viewModel
        self.targetLogs = targetLogs
    }

    public var body: some View {
        VStack(spacing: 20) {
            summaryCardsView
            heatmapCardView
            categoryRatioCardView
        }
    }

    // MARK: - Summary Cards

    private var summaryCardsView: some View {
        HStack(spacing: 12) {
            let uniqueItemsCount = Set(targetLogs.compactMap { $0.item?.id }).count
            summaryCard(
                title: String(localized: "飲んだ種類"),
                value: "\(uniqueItemsCount)",
                unit: String(localized: " 銘柄"),
                iconName: "wineglass.fill",
                color: .purple
            )

            let averageRating = viewModel.averageRating(from: targetLogs)
            summaryCard(
                title: String(localized: "平均スコア"),
                value: String(format: "%.1f", averageRating),
                unit: String(localized: " 点"),
                iconName: "star.fill",
                color: .orange
            )
        }
    }

    private func summaryCard(title: String, value: String, unit: String, iconName: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    // MARK: - Drinking Heatmap

    private var heatmapCardView: some View {
        let days = viewModel.drinkingHeatmapData(from: targetLogs)
        let rows = Array(repeating: GridItem(.fixed(14), spacing: 4), count: 7)
        let weekdays = [
            String(localized: "日"),
            String(localized: "月"),
            String(localized: "火"),
            String(localized: "水"),
            String(localized: "木"),
            String(localized: "金"),
            String(localized: "土")
        ]

        return VStack(alignment: .leading, spacing: 12) {
            Text("お酒を飲んだ日（直近4ヶ月）")
                .font(.headline)

            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(height: 14, alignment: .leading)
                    }
                }
                .padding(.top, 1)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 4) {
                        ForEach(days) { day in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(heatmapColor(for: day.count))
                                .frame(width: 14, height: 14)
                        }
                    }
                    .padding(.vertical, 1)
                }
            }

            heatmapLegendView
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private var heatmapLegendView: some View {
        let legendOpacities: [Double?] = [nil, 0.25, 0.55, 0.85, 1.0]

        return HStack(spacing: 8) {
            Text("少")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                ForEach(Array(legendOpacities.enumerated()), id: \.offset) { _, opacity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(opacity.map { Color.accentColor.opacity($0) } ?? Color(.systemGray5))
                        .frame(width: 11, height: 11)
                }
            }

            Text("多")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.top, 4)
    }

    private func heatmapColor(for count: Int) -> Color {
        switch count {
        case 0: Color(.systemGray5)
        case 1: Color.accentColor.opacity(0.3)
        case 2: Color.accentColor.opacity(0.6)
        case 3: Color.accentColor.opacity(0.85)
        default: Color.accentColor
        }
    }

    // MARK: - Category / SubCategory Ratio Chart

    private var categoryRatioCardView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(ratioCardTitle)
                .font(.headline)

            if viewModel.selectedCategoryFilter != nil {
                subCategoryRatioChart
            } else {
                mainCategoryRatioChart
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private var ratioCardTitle: String {
        guard let category = viewModel.selectedCategoryFilter else {
            return String(localized: "酒種別 飲酒比率")
        }
        switch category {
        case .wine: return String(localized: "ワインタイプ別 飲酒比率")
        case .sake: return String(localized: "特定名称別 飲酒比率")
        case .beer: return String(localized: "ビアスタイル別 飲酒比率")
        }
    }

    @ViewBuilder
    private var subCategoryRatioChart: some View {
        let subRatio = viewModel.subCategoryRatio(from: targetLogs)
        let sortedKeys = Array(subRatio.keys.sorted())
        let totalCount = subRatio.values.reduce(0, +)

        if totalCount > 0 {
            let colorPairs = sortedKeys.enumerated().map { index, key in
                (key, subCategoryPalette[index % subCategoryPalette.count])
            }
            let colorMapping = Dictionary(uniqueKeysWithValues: colorPairs)

            Chart {
                ForEach(sortedKeys, id: \.self) { key in
                    let count = subRatio[key] ?? 0
                    if count > 0 {
                        SectorMark(
                            angle: .value(String(localized: "件数"), count),
                            innerRadius: .ratio(0.62),
                            angularInset: 2.0
                        )
                        .cornerRadius(4)
                        .foregroundStyle(by: .value(String(localized: "タイプ"), key))
                    }
                }
            }
            .chartForegroundStyleScale(domain: sortedKeys, range: colorPairs.map(\.1))
            .frame(height: 180)
            .chartLegend(.hidden)

            let activeKeys = sortedKeys.filter { (subRatio[$0] ?? 0) > 0 }
            if !activeKeys.isEmpty {
                FlowLayout(spacing: 12) {
                    ForEach(activeKeys, id: \.self) { key in
                        let count = subRatio[key] ?? 0
                        legendChip(title: key, count: count, color: colorMapping[key] ?? .gray)
                    }
                }
            }
        } else {
            Text("サブカテゴリのメタデータが記録されていません")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private var mainCategoryRatioChart: some View {
        let ratio = viewModel.categoryRatio(from: targetLogs)

        Chart {
            ForEach(BeverageCategory.allCases, id: \.self) { category in
                let count = ratio[category] ?? 0
                if count > 0 {
                    SectorMark(
                        angle: .value(String(localized: "件数"), count),
                        innerRadius: .ratio(0.62),
                        angularInset: 2.0
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value(String(localized: "酒種"), category.displayName))
                }
            }
        }
        .chartForegroundStyleScale([
            BeverageCategory.wine.displayName: categoryColor(.wine),
            BeverageCategory.sake.displayName: categoryColor(.sake),
            BeverageCategory.beer.displayName: categoryColor(.beer)
        ])
        .frame(height: 180)
        .chartLegend(.hidden)

        let activeCategories = BeverageCategory.allCases.filter { (ratio[$0] ?? 0) > 0 }
        if !activeCategories.isEmpty {
            HStack(spacing: 16) {
                Spacer()
                ForEach(activeCategories, id: \.self) { category in
                    legendChip(
                        title: category.displayName,
                        count: ratio[category] ?? 0,
                        color: categoryColor(category)
                    )
                }
                Spacer()
            }
        }
    }

    private func legendChip(title: String, count: Int, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text("\(title): \(String(format: String(localized: "%d件"), count))")
                .font(.caption)
                .fontWeight(.medium)
        }
    }

    private func categoryColor(_ category: BeverageCategory) -> Color {
        switch category {
        case .wine: .purple
        case .sake: .blue
        case .beer: .orange
        }
    }
}

#Preview {
    let sample = PreviewSampleData.makeSampleBundle()
    return NavigationStack {
        ScrollView {
            ConsumptionView(
                viewModel: AnalyticsViewModel(),
                targetLogs: [sample.wineLog, sample.sakeLog, sample.beerLog]
            )
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    .modelContainer(PreviewSampleData.container)
}
