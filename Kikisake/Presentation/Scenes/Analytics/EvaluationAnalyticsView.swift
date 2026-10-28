//  EvaluationAnalyticsView.swift
//  Kikisake

import SwiftUI
import SwiftData

public struct EvaluationAnalyticsView: View {
    @Bindable var viewModel: AnalyticsViewModel
    let targetLogs: [TastingLog]

    public var body: some View {
        VStack(spacing: 20) {
            myBestSectionView
            featureFlagsSummaryCardView
            aromaPreferenceCardView
            tasteProfileCardView
        }
    }

    private var myBestSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("マイベスト")
                .font(.headline)

            VStack(spacing: 14) {
                let categoriesToDisplay = viewModel.selectedCategoryFilter.map { [$0] } ?? BeverageCategory.allCases
                ForEach(categoriesToDisplay, id: \.self) { category in
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
        let bestLog = viewModel.topRatedLog(for: category, from: targetLogs)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(categoryColor(category)).frame(width: 8, height: 8)
                Text(category.displayName).font(.subheadline).fontWeight(.bold)
                Spacer()
            }

            if let log = bestLog {
                NavigationLink(destination: LogDetailView(log: log)) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.item?.name ?? String(localized: "不明な銘柄"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            if let producer = log.item?.producer, !producer.isEmpty {
                                Text(producer).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                        
                        Spacer()

                        HStack(spacing: 2) {
                            Image(systemName: "star.fill").font(.caption2).foregroundStyle(.orange)
                            Text(String(format: "%.1f", log.rating)).font(.caption).fontWeight(.bold).foregroundStyle(.primary)
                        }

                        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                    }
                    .padding(10)
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            } else {
                Text("該当条件の記録がありません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
        }
    }

    private var featureFlagsSummaryCardView: some View {
        let summary = viewModel.featureFlagsSummary(from: targetLogs)
        
        return VStack(alignment: .leading, spacing: 14) {
            Text("評価フラグの傾向")
                .font(.headline)

            if summary.total == 0 {
                Text("データがありません").font(.subheadline).foregroundStyle(.secondary).padding(.vertical, 8)
            } else {
                HStack(spacing: 10) {
                    flagCardItem(title: String(localized: "コスパ良好"), count: summary.costEffective, systemImage: "yensign.circle.fill", color: .green, filterType: .costEffective)
                    flagCardItem(title: String(localized: "リピート確定"), count: summary.repeatIntent, systemImage: "arrow.clockwise.circle.fill", color: .orange, filterType: .willingToRepeat)
                    flagCardItem(title: String(localized: "熟成ポテンシャル"), count: summary.agingPotential, systemImage: "hourglass.circle.fill", color: .purple, filterType: .agingPotential)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func flagCardItem(title: String, count: Int, systemImage: String, color: Color, filterType: LogFilterType) -> some View {
        Button {
            AppState.shared.pendingLogFilter = filterType
            AppState.shared.selectedTab = 0
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: systemImage).foregroundStyle(color).font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 9, weight: .bold)).foregroundStyle(.tertiary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    Text(String(format: String(localized: "%d件"), count)).font(.subheadline).fontWeight(.bold).foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var aromaPreferenceCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("よく感じる香り・アロマの好み").font(.headline)
                Spacer()
                Text("タップして一覧を表示").font(.caption2).foregroundStyle(.secondary)
            }

            let topTags = viewModel.topAromaTags(from: targetLogs)

            if topTags.isEmpty {
                Text("香りの記録データがありません").font(.subheadline).foregroundStyle(.secondary).padding(.vertical, 8)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(topTags, id: \.tag) { item in
                        Button {
                            AppState.shared.pendingAromaTagFilter = item.tag
                            AppState.shared.selectedTab = 0
                        } label: {
                            HStack(spacing: 4) {
                                Text(item.tag).font(.subheadline).fontWeight(.medium).foregroundStyle(.primary)
                                Text("\(item.count)").font(.caption2).padding(.horizontal, 5).padding(.vertical, 2).background(Color.accentColor.opacity(0.15)).foregroundStyle(Color.accentColor).clipShape(Capsule())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private var tasteProfileCardView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("平均テイストバランス")
                .font(.headline)

            let profile = viewModel.averageTasteProfile(from: targetLogs)

            VStack(alignment: .leading, spacing: 10) {
                Text("基本五味").font(.caption).fontWeight(.bold).foregroundStyle(.secondary)
                tasteBar(title: String(localized: "甘味"), value: profile.sweetness)
                tasteBar(title: String(localized: "酸味"), value: profile.acidity)
                tasteBar(title: String(localized: "苦味"), value: profile.bitterness)
                tasteBar(title: String(localized: "旨味"), value: profile.umami)

                Divider().padding(.vertical, 4)

                Text("構造・特徴").font(.caption).fontWeight(.bold).foregroundStyle(.secondary)
                tasteBar(title: String(localized: "ボディ"), value: profile.body)
                tasteBar(title: String(localized: "余韻の長さ"), value: profile.finishLength)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func tasteBar(title: String, value: Double) -> some View {
        HStack {
            Text(title).font(.subheadline).frame(width: 80, alignment: .leading)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(Color.accentColor).frame(width: min(CGFloat(value / 5.0) * geometry.size.width, geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)
            Text(String(format: "%.1f", value)).font(.caption).fontWeight(.bold).foregroundStyle(.secondary).frame(width: 30, alignment: .trailing)
        }
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
    
    let sampleItem = BeverageItem(name: "バローロ DOCG", producer: "プルノット", category: .wine)
    let sampleLog = TastingLog(
        rating: 4.8,
        aromaTags: ["スミレ", "樽香", "チェリー"],
        isCostEffective: true,
        isWillingToRepeat: true,
        item: sampleItem
    )
    
    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)
    
    let logs = [sampleLog]
    let viewModel = AnalyticsViewModel()

    return NavigationStack {
        ScrollView {
            EvaluationAnalyticsView(viewModel: viewModel, targetLogs: logs)
                .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    .modelContainer(container)
}
