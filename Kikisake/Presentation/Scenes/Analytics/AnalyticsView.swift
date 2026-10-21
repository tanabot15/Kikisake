//
//  AnalyticsView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData
import Charts

/// [Tab 2] 飲んだ酒の洗練された分析画面
public struct AnalyticsView: View {
    @Query private var logs: [TastingLog]
    @State private var viewModel = AnalyticsViewModel()

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AdMobBannerView()
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                
                // セグメンテッドピッカー（上位切替）
                Picker("分析カテゴリ", selection: $viewModel.selectedSection) {
                    ForEach(AnalyticsSection.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 10)
                .background(Color(.systemGroupedBackground))

                // 期間フィルター用ピッカー
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AnalyticsTimeFilter.allCases) { filter in
                            Button {
                                viewModel.selectedTimeFilter = filter
                            } label: {
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(viewModel.selectedTimeFilter == filter ? Color.accentColor : Color(.systemGray5))
                                    .foregroundStyle(viewModel.selectedTimeFilter == filter ? .white : .primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))

                ScrollView {
                    VStack(spacing: 20) {
                        let targetLogs = viewModel.filteredLogs(from: logs)

                        if logs.isEmpty {
                            ContentUnavailableView(
                                "テイスティングデータがありません",
                                systemImage: "chart.bar.xaxis",
                                description: Text("「追加」タブから飲んだ酒を記録すると、ここに分析が表示されます。")
                            )
                            .padding(.top, 40)
                        } else {
                            switch viewModel.selectedSection {
                            case .consumption:
                                consumptionSection(for: targetLogs)
                            case .evaluation:
                                evaluationSection(for: targetLogs)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("分析")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - 1. 飲酒量・ログ分析セクション
    private func consumptionSection(for targetLogs: [TastingLog]) -> some View {
        VStack(spacing: 20) {
            // サマリーカード
            HStack(spacing: 12) {
                summaryCard(
                    title: "総記録回数",
                    value: "\(targetLogs.count) 回",
                    iconName: "square.and.pencil",
                    color: .accentColor
                )
                
                let uniqueItemsCount = Set(targetLogs.compactMap { $0.item?.id }).count
                summaryCard(
                    title: "飲んだ種類",
                    value: "\(uniqueItemsCount) 銘柄",
                    iconName: "wineglass.fill",
                    color: .purple
                )
            }

            // 飲酒日ヒートマップ
            heatmapCard

            // 酒種別 飲酒比率
            categoryRatioCard
        }
    }

    // MARK: - 2. 評価・好み分析セクション
    private func evaluationSection(for targetLogs: [TastingLog]) -> some View {
        VStack(spacing: 20) {
            // マイベスト（ワイン・日本酒・ビール別 縦並び）
            myBestSection

            // 好みの香り・特徴（アロマタグ）
            aromaPreferenceCard

            // 平均テイストバランス
            tasteProfileCard
        }
    }

    // MARK: - サブコンポーネント

    private func summaryCard(title: String, value: String, iconName: String, color: Color) -> some View {
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
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    // --- ヒートマップカード（グリッドサイズを拡大して画面右側まで自然に配置） ---
    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("お酒を飲んだ日（直近4ヶ月）")
                .font(.headline)

            let days = viewModel.drinkingHeatmapData(from: logs)
            let rows = Array(repeating: GridItem(.fixed(14), spacing: 4), count: 7)
            let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

            HStack(alignment: .top, spacing: 8) {
                // 左側の曜日ラベル
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .frame(height: 14, alignment: .leading)
                    }
                }
                .padding(.top, 1)

                // ヒートマップグリッド本体
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

            // 凡例（レジェンド）
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

    // --- 酒種別比率カード ---
    private var categoryRatioCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("酒種別 飲酒比率")
                .font(.headline)

            let ratio = viewModel.categoryRatio(from: logs)

            Chart {
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    let count = ratio[category] ?? 0
                    if count > 0 {
                        SectorMark(
                            angle: .value("件数", count),
                            innerRadius: .ratio(0.62),
                            angularInset: 2.0
                        )
                        .cornerRadius(4)
                        .foregroundStyle(by: .value("酒種", category.displayName))
                    }
                }
            }
            // グラフの色を categoryColor(_:) と完全に一致させる
            .chartForegroundStyleScale([
                BeverageCategory.wine.displayName: categoryColor(.wine),
                BeverageCategory.sake.displayName: categoryColor(.sake),
                BeverageCategory.beer.displayName: categoryColor(.beer)
            ])
            .frame(height: 180)
            .chartLegend(.hidden)

            // 件数が存在する（count > 0）酒種のみを抽出して凡例を表示する
            let activeCategories = BeverageCategory.allCases.filter { (ratio[$0] ?? 0) > 0 }

            if !activeCategories.isEmpty {
                HStack(spacing: 16) {
                    Spacer()
                    ForEach(activeCategories, id: \.self) { category in
                        let count = ratio[category] ?? 0
                        HStack(spacing: 6) {
                            Circle()
                                .fill(categoryColor(category))
                                .frame(width: 8, height: 8)
                            Text("\(category.displayName): \(count)件")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    Spacer()
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

    // --- マイベスト（ワイン・日本酒・ビール別 縦並び）セクション ---
    private var myBestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                Text("マイベスト（お気に入り銘柄）")
                    .font(.headline)
            }

            VStack(spacing: 14) {
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    categoryBestView(for: category)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func categoryBestView(for category: BeverageCategory) -> some View {
        let bestLogs = viewModel.topRatedLogs(for: category, from: logs)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(categoryColor(category))
                    .frame(width: 8, height: 8)
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
            }

            if bestLogs.isEmpty {
                Text("該当期間の高評価（★4.5以上）の記録がありません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(bestLogs) { log in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.item?.name ?? "不明な銘柄")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                Text(log.item?.producer ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()

                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text(String(format: "%.1f", log.rating))
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }

    // --- 好みのアロマ・特徴タグ ---
    private var aromaPreferenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "nose.fill")
                    .foregroundStyle(Color.accentColor)
                Text("よく感じる香り・アロマの好み")
                    .font(.headline)
            }

            let topTags = viewModel.topAromaTags(from: logs)

            if topTags.isEmpty {
                Text("香りの記録データがありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(topTags, id: \.tag) { item in
                        HStack(spacing: 4) {
                            Text(item.tag)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(item.count)")
                                .font(.caption2)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(20)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // --- 味わいプロファイルカード ---
    private var tasteProfileCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Color.accentColor)
                Text("平均テイストバランス")
                    .font(.headline)
            }

            let profile = viewModel.averageTasteProfile(from: logs)

            VStack(alignment: .leading, spacing: 10) {
                Text("基本五味")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                tasteBar(title: "甘味", value: profile.sweetness)
                tasteBar(title: "酸味", value: profile.acidity)
                tasteBar(title: "苦味", value: profile.bitterness)
                tasteBar(title: "旨味", value: profile.umami)

                Divider()
                    .padding(.vertical, 4)

                Text("構造・特徴")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                tasteBar(title: "ボディ", value: profile.body)
                tasteBar(title: "余韻の長さ", value: profile.finishLength)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func tasteBar(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: min(CGFloat(value / 5.0) * geometry.size.width, geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)

            Text(String(format: "%.1f", value))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

/// 簡単な折り返しレイアウト（タグ用）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: height + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)

    let wineItem = BeverageItem(name: "Barolo DOCG 2018", producer: "Prunotto", category: .wine, region: "イタリア")
    let wineLog = TastingLog(rating: 4.8, aromaTags: ["スミレ", "樽香", "チェリー"], sweetness: 2.0, acidity: 4.2, bitterness: 2.0, umami: 2.5, body: 4.5, finishLength: 4.8, item: wineItem)

    let sakeItem = BeverageItem(name: "久保田 萬壽", producer: "朝日酒造", category: .sake, region: "新潟県")
    let sakeLog = TastingLog(rating: 4.6, aromaTags: ["吟醸香", "青りんご"], sweetness: 3.0, acidity: 2.5, bitterness: 1.5, umami: 3.5, body: 3.0, finishLength: 4.0, item: sakeItem)

    container.mainContext.insert(wineItem)
    container.mainContext.insert(wineLog)
    container.mainContext.insert(sakeItem)
    container.mainContext.insert(sakeLog)

    return AnalyticsView()
        .modelContainer(container)
}
