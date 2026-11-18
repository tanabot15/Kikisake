//  CollectionBookView.swift
//  Kikisake

import SwiftUI
import SwiftData

// シート用のラッパー構造体（Identifiableに適合させる）
public struct CollectionCellSheetWrapper: Identifiable {
    public let id = UUID()
    let definition: CollectionItemDefinition
    let isUnlocked: Bool
    let unlockedLogs: [TastingLog]
}

public struct CollectionBookView: View {
    @State private var viewModel = CollectionViewModel()
    @Bindable private var appState = AppState.shared
    var allLogs: [TastingLog]

    // シート表示用のStateをひとつに統合（.sheet(item:)用）
    @State private var activeSheetWrapper: CollectionCellSheetWrapper? = nil
    
    // 未達成タップ時のサジェスト表示用アラート制御
    @State private var selectedHintMessage: String? = nil
    @State private var isShowingSuggestionAlert: Bool = false

    @State private var isShowingPaywall: Bool = false
    @State private var isShowingRankSheet: Bool = false

    public init(allLogs: [TastingLog]) {
        self.allLogs = allLogs
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        let isPro = appState.isProVersion
        let proExtraCount = viewModel.lockedProItemCount(for: viewModel.selectedCategory)
        let completionResults = viewModel.checkCompletions(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
        let groupedResults = viewModel.groupedCompletions(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
        
        let currentBadge = viewModel.currentRankBadge(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
        let nextBadge = viewModel.nextRankBadge(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
        let unlockedCount = completionResults.filter { $0.isUnlocked }.count
        let totalCount = completionResults.count

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
            
            // 3. 称号・ランクバッジバナー
            rankBadgeBanner(currentBadge: currentBadge, nextBadge: nextBadge, unlockedCount: unlockedCount)

            // 4. 国・都道府県別のコレクション一覧
            groupedCollectionView(groupedResults: groupedResults)
        }
        // ✨ .sheet(item:) を利用することで、1回目の真っ白な表示バグを完全に防止
        .sheet(item: $activeSheetWrapper) { wrapper in
            CollectionItemDetailSheet(definition: wrapper.definition, unlockedLogs: wrapper.unlockedLogs)
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $isShowingRankSheet) {
            RankShareSheetView(
                category: viewModel.selectedCategory,
                unlockedCount: unlockedCount,
                totalCount: totalCount
            )
        }
        // ✨ 未達成アイテムタップ時のサジェスト用アラート
        .alert(String(localized: "解放のヒント"), isPresented: $isShowingSuggestionAlert, presenting: selectedHintMessage) { hint in
            Button(String(localized: "閉じる"), role: .cancel) {}
        } message: { hint in
            Text(hint)
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
                Text(String(localized: "図鑑コンプリート進捗"))
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

    @ViewBuilder
    private func rankBadgeBanner(currentBadge: CollectionRankBadge?, nextBadge: CollectionRankBadge?, unlockedCount: Int) -> some View {
        Button {
            isShowingRankSheet = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            currentBadge != nil
                            ? LinearGradient(colors: currentBadge!.tier.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color(.systemGray5), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: currentBadge?.tier.iconName ?? "lock.fill")
                        .font(.headline)
                        .foregroundStyle(currentBadge != nil ? .white : .secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentBadge?.tier.tierName ?? String(localized: "未獲得"))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(currentBadge != nil ? currentBadge!.tier.accentColor.opacity(0.15) : Color(.systemGray5))
                        .foregroundStyle(currentBadge != nil ? currentBadge!.tier.accentColor : .secondary)
                        .clipShape(Capsule())

                    if let current = currentBadge {
                        Text(current.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    } else if let next = nextBadge {
                        Text(String(format: String(localized: "あと %d 種で「%@」"), max(0, next.requiredCount - unlockedCount), next.title))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }

                    Text(currentBadge?.subtitle ?? String(localized: "タップして称号・ランク一覧を確認"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
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

    private func groupedCollectionView(
        groupedResults: [(region: String, items: [(definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLogs: [TastingLog])])]
    ) -> some View {
        let columns = [GridItem(.adaptive(minimum: 105, maximum: 140), spacing: 10, alignment: .top)]

        return VStack(alignment: .leading, spacing: 20) {
            ForEach(groupedResults, id: \.region) { group in
                let unlockedInRegion = group.items.filter { $0.isUnlocked }.count
                let totalInRegion = group.items.count

                VStack(alignment: .leading, spacing: 10) {
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

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(group.items, id: \.definition.id) { cell in
                            Button {
                                if cell.isUnlocked {
                                    // 達成済みの場合は詳細シートを表示
                                    activeSheetWrapper = CollectionCellSheetWrapper(
                                        definition: cell.definition,
                                        isUnlocked: cell.isUnlocked,
                                        unlockedLogs: cell.unlockedLogs
                                    )
                                } else {
                                    // ✨ 未達成の場合はサジェストヒントを表示
                                    selectedHintMessage = cell.definition.suggestionHint
                                    isShowingSuggestionAlert = true
                                }
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

// MARK: - タップ時に開く銘柄詳細シート
private struct CollectionItemDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let definition: CollectionItemDefinition
    let unlockedLogs: [TastingLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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
            CollectionBookView(allLogs: logs)
                .padding()
        }
        .navigationTitle(String(localized: "図鑑"))
        .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(container)
}
