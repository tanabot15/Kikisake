//  CollectionBookAnalyticsView.swift
//  Kikisake

import SwiftUI
import SwiftData

public struct CollectionBookAnalyticsView: View {
    @State private var viewModel = CollectionAnalyticsViewModel()
    @Bindable private var appState = AppState.shared
    var allLogs: [TastingLog]

    // タップされた図鑑セルの詳細保持用State
    @State private var selectedCell: (definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLogs: [TastingLog])? = nil
    @State private var isShowingDetailSheet: Bool = false
    @State private var isShowingPaywall: Bool = false

    public init(allLogs: [TastingLog]) {
        self.allLogs = allLogs
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        let isPro = appState.isProVersion
        let proExtraCount = viewModel.lockedProItemCount(for: viewModel.selectedCategory)
        let completionResults = viewModel.checkCompletions(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
        let groupedResults = viewModel.groupedCompletions(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)

        return VStack(spacing: 16) {
            // 0. Pro版誘導バナー
            if !isPro && proExtraCount > 0 {
                proUpgradeBanner(extraCount: proExtraCount)
            }

            // 1. 酒種切り替えピッカー
            Picker(String(localized: "酒種"), selection: $viewModel.selectedCategory) {
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 4)

            // 2. 進捗サマリーカード
            progressSummaryCard(completionResults: completionResults)
            
            // 3. 国・都道府県別のコレクション一覧
            groupedCollectionView(groupedResults: groupedResults)
        }
        .sheet(isPresented: $isShowingDetailSheet) {
            if let cell = selectedCell {
                CollectionItemDetailSheet(definition: cell.definition, unlockedLogs: cell.unlockedLogs)
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
    }

    // MARK: - Subviews

    private func proUpgradeBanner(extraCount: Int) -> some View {
        Button {
            isShowingPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "プロ版で図鑑を全解放"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text(String(format: String(localized: "マニアックな品種や産地など、追加の %d 項目が解放されます"), extraCount))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func progressSummaryCard(completionResults: [(definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLogs: [TastingLog])]) -> some View {
        let unlockedCount = completionResults.filter { $0.isUnlocked }.count
        let totalCount = completionResults.count
        let rate = totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0.0

        return VStack(spacing: 12) {
            HStack {
                Text(String(localized: "コンプリート進捗"))
                    .font(.headline)
                Spacer()
                Text(String(format: String(localized: "%d / %d"), unlockedCount, totalCount))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
            }

            ProgressView(value: rate)
                .tint(.accentColor)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func groupedCollectionView(
        groupedResults: [(region: String, items: [(definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLogs: [TastingLog])])]
    ) -> some View {
        // 折り返しテキストが読みやすいよう、3列程度になる幅に設定
        let columns = [GridItem(.adaptive(minimum: 105, maximum: 140), spacing: 10, alignment: .top)]

        return VStack(alignment: .leading, spacing: 20) {
            ForEach(groupedResults, id: \.region) { group in
                let unlockedInRegion = group.items.filter { $0.isUnlocked }.count
                let totalInRegion = group.items.count

                VStack(alignment: .leading, spacing: 10) {
                    // ✨ 国・都道府県セクションヘッダー
                    HStack(alignment: .firstTextBaseline) {
                        Text(group.region)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("\(unlockedInRegion) / \(totalInRegion)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(unlockedInRegion == totalInRegion && totalInRegion > 0 ? Color.accentColor : .secondary)
                    }
                    .padding(.horizontal, 4)

                    // 該当地域のグリッド
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(group.items, id: \.definition.id) { cell in
                            Button {
                                selectedCell = cell
                                isShowingDetailSheet = true
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: cell.isUnlocked ? "checkmark.circle.fill" : "lock.circle")
                                            .font(.system(size: 14))
                                            .foregroundStyle(cell.isUnlocked ? Color.accentColor : Color(.systemGray3))
                                        
                                        Spacer()

                                        if cell.unlockedLogs.count > 1 {
                                            Text("\(cell.unlockedLogs.count)")
                                                .font(.system(size: 10, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.accentColor.opacity(0.15))
                                                .foregroundStyle(Color.accentColor)
                                                .cornerRadius(6)
                                        }
                                    }

                                    // ✨ 銘柄・品種名が途切れないよう折り返し表示
                                    Text(cell.definition.targetElement)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(cell.isUnlocked ? .primary : .secondary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer(minLength: 0)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
                                .background(cell.isUnlocked ? Color(.secondarySystemGroupedBackground) : Color(.systemGray6).opacity(0.6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(cell.isUnlocked ? Color.accentColor.opacity(0.3) : Color(.systemGray4).opacity(0.5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 🎁 タップ時に開く銘柄詳細シート（BeverageCardViewを使用）
private struct CollectionItemDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let definition: CollectionItemDefinition
    let unlockedLogs: [TastingLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // ヘッダー情報
                    VStack(spacing: 4) {
                        Text(definition.targetElement)
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("\(definition.region) （\(definition.category.displayName)）")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    Divider()

                    if unlockedLogs.isEmpty {
                        ContentUnavailableView(
                            String(localized: "未達成の項目です"),
                            systemImage: "lock.slash",
                            description: Text(String(localized: "この条件に一致するお酒を記録すると、図鑑が解放されます。"))
                        )
                        .padding(.top, 40)
                    } else {
                        // ✨ 該当するすべての銘柄を BeverageCardView を使ってリスト表示
                        VStack(spacing: 12) {
                            ForEach(unlockedLogs, id: \.id) { log in
                                if let item = log.item {
                                    BeverageCardView(
                                        name: item.name,
                                        producer: item.producer,
                                        category: item.category,
                                        region: item.region,
                                        vintage: item.vintage,
                                        rating: log.rating,
                                        imageData: item.imageDatas?.first,
                                        isBackgroundRemoved: item.isBackgroundRemoved,
                                        appearanceColorHex: log.appearanceColorHex
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "図鑑アイテム詳細"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "閉じる")) {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview("図鑑（ブロンズ達成）") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, StorageLocation.self, configurations: config)
    
    let samples: [(String, String, String)] = [
        ("Château Margaux", "フランス, ボルドー", "カベルネ・ソーヴィニヨン"),
        ("Château Cheval Blanc", "フランス, ボルドー", "メルロ"),
        ("Romanée-Conti", "フランス, ブルゴーニュ", "ピノ・ノワール"),
        ("Montrachet", "フランス, ブルゴーニュ", "シャルドネ"),
        ("Sancerre", "フランス, ロワール", "ソーヴィニヨン・ブラン"),
        ("Côte-Rôtie", "フランス, ローヌ", "シラー / シラーズ"),
        ("Beaujolais Nouveau", "フランス", "ガメイ"),
        ("Tignanello", "イタリア, トスカーナ", "サンジョヴェーゼ"),
        ("Barolo", "イタリア, ピエモンテ", "ネッビオーロ"),
        ("Barbera d'Alba", "イタリア, ピエモンテ", "バルベラ")
    ]

    var logs: [TastingLog] = []
    for (name, region, variety) in samples {
        let item = BeverageItem(
            name: name,
            producer: "Sample Producer",
            category: .wine,
            region: region,
            specificMetadataJSON: "{\"wineType\":\"赤\",\"grapeVarieties\":\"\(variety)\",\"blendComponents\":[]}"
        )
        let log = TastingLog(rating: 4.5, isEvaluated: true, item: item)
        container.mainContext.insert(item)
        container.mainContext.insert(log)
        logs.append(log)
    }

    return NavigationStack {
        ScrollView {
            CollectionBookAnalyticsView(allLogs: logs)
                .padding()
        }
        .navigationTitle(String(localized: "図鑑"))
        .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(container)
}
