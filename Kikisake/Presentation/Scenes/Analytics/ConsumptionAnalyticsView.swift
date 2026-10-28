//  ConsumptionAnalyticsView.swift
//  Kikisake

import SwiftUI
import SwiftData
import Charts

public struct ConsumptionAnalyticsView: View {
    @Bindable var viewModel: AnalyticsViewModel
    let targetLogs: [TastingLog]
    let allLogs: [TastingLog]

    public var body: some View {
        VStack(spacing: 20) {
            summaryCardsView
            heatmapCardView
            categoryRatioCardView
        }
    }

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

    private var heatmapCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("お酒を飲んだ日（直近4ヶ月）")
                .font(.headline)

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

            HStack(spacing: 8) {
                Text("少")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(Color(.systemGray5)).frame(width: 11, height: 11)
                    RoundedRectangle(cornerRadius: 2).fill(Color.accentColor.opacity(0.25)).frame(width: 11, height: 11)
                    RoundedRectangle(cornerRadius: 2).fill(Color.accentColor.opacity(0.55)).frame(width: 11, height: 11)
                    RoundedRectangle(cornerRadius: 2).fill(Color.accentColor.opacity(0.85)).frame(width: 11, height: 11)
                    RoundedRectangle(cornerRadius: 2).fill(Color.accentColor).frame(width: 11, height: 11)
                }

                Text("多")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func heatmapColor(for count: Int) -> Color {
        switch count {
        case 0: return Color(.systemGray5)
        case 1: return Color.accentColor.opacity(0.3)
        case 2: return Color.accentColor.opacity(0.6)
        case 3: return Color.accentColor.opacity(0.85)
        default: return Color.accentColor
        }
    }

    private var categoryRatioCardView: some View {
        VStack(alignment: .leading, spacing: 14) {
            let cardTitle: String = {
                if let category = viewModel.selectedCategoryFilter {
                    switch category {
                    case .wine: return String(localized: "ワインタイプ別 飲酒比率")
                    case .sake: return String(localized: "特定名称別 飲酒比率")
                    case .beer: return String(localized: "ビアスタイル別 飲酒比率")
                    }
                } else {
                    return String(localized: "酒種別 飲酒比率")
                }
            }()

            Text(cardTitle)
                .font(.headline)

            if viewModel.selectedCategoryFilter != nil {
                let subRatio = viewModel.subCategoryRatio(from: allLogs)
                let sortedKeys = Array(subRatio.keys.sorted())
                let totalCount = subRatio.values.reduce(0, +)

                if totalCount > 0 {
                    let palette: [Color] = [.purple, .blue, .orange, .pink, .teal, .indigo, .brown]
                    let colorPairs: [(String, Color)] = sortedKeys.enumerated().map { index, key in
                        (String(key), palette[index % palette.count])
                    }
                    let colorMapping = Dictionary(uniqueKeysWithValues: colorPairs)

                    Chart {
                        ForEach(sortedKeys, id: \.self) { key in
                            let count = subRatio[key] ?? 0
                            if count > 0 {
                                SectorMark(angle: .value(String(localized: "件数"), count), innerRadius: .ratio(0.62), angularInset: 2.0)
                                    .cornerRadius(4)
                                    .foregroundStyle(by: .value(String(localized: "タイプ"), key))
                            }
                        }
                    }
                    .chartForegroundStyleScale(domain: sortedKeys, range: colorPairs.map { $0.1 })
                    .frame(height: 180)
                    .chartLegend(.hidden)

                    let activeKeys = sortedKeys.filter { (subRatio[$0] ?? 0) > 0 }
                    if !activeKeys.isEmpty {
                        FlowLayout(spacing: 12) {
                            ForEach(activeKeys, id: \.self) { key in
                                let count = subRatio[key] ?? 0
                                let color = colorMapping[key] ?? .gray
                                HStack(spacing: 6) {
                                    Circle().fill(color).frame(width: 8, height: 8)
                                    Text("\(key): \(String(format: String(localized: "%d件"), count))").font(.caption).fontWeight(.medium)
                                }
                            }
                        }
                    }
                } else {
                    Text("サブカテゴリのメタデータが記録されていません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 12)
                }
            } else {
                let ratio = viewModel.categoryRatio(from: allLogs)

                Chart {
                    ForEach(BeverageCategory.allCases, id: \.self) { category in
                        let count = ratio[category] ?? 0
                        if count > 0 {
                            SectorMark(angle: .value(String(localized: "件数"), count), innerRadius: .ratio(0.62), angularInset: 2.0)
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
                            let count = ratio[category] ?? 0
                            HStack(spacing: 6) {
                                Circle().fill(categoryColor(category)).frame(width: 8, height: 8)
                                Text("\(category.displayName): \(String(format: String(localized: "%d件"), count))").font(.caption).fontWeight(.medium)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func categoryColor(_ category: BeverageCategory) -> Color {
        switch category {
        case .wine: return .purple
        case .sake: return .blue
        case .beer: return .orange
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    
    let sampleItem = BeverageItem(name: "新政 No.6", producer: "新政酒造", category: .sake)
    let sampleLog = TastingLog(date: Date(), rating: 4.7, item: sampleItem)
    
    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)
    
    let logs = [sampleLog]
    let viewModel = AnalyticsViewModel()

    return NavigationStack {
        ScrollView {
            ConsumptionAnalyticsView(viewModel: viewModel, targetLogs: logs, allLogs: logs)
                .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    .modelContainer(container)
}
