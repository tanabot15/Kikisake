//
//  CollectionBookView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Sheet payload for a tapped collection item cell.
public struct CollectionCellSheetWrapper: Identifiable {
    public let id = UUID()
    let definition: CollectionItemDefinition
    let isUnlocked: Bool
    let unlockedLogs: [TastingLog]
}

/// Collection book view displaying regional completion progress, rank badges, and unlocked items.
public struct CollectionBookView: View {
    @Bindable private var viewModel: CollectionViewModel
    @Bindable private var appState = AppState.shared
    var allLogs: [TastingLog]

    @Bindable var logViewModel: LogViewModel

    @State private var activeSheetWrapper: CollectionCellSheetWrapper? = nil
    @State private var selectedHintMessage: String? = nil
    @State private var isShowingSuggestionAlert: Bool = false
    @State private var isShowingPaywall: Bool = false
    @State private var isShowingRankSheet: Bool = false

    public init(
        allLogs: [TastingLog],
        logViewModel: LogViewModel = LogViewModel(),
        viewModel: CollectionViewModel = CollectionViewModel()
    ) {
        self.allLogs = allLogs
        self.logViewModel = logViewModel
        self.viewModel = viewModel
    }

    public var body: some View {
        let activeCategory = logViewModel.collectionCategoryFilter ?? viewModel.selectedCategory
        let isPro = appState.isProVersion
        let proExtraCount = viewModel.lockedProItemCount(for: activeCategory)
        let completionResults = filteredCompletions(for: activeCategory, isPro: isPro)
        let groupedResults = filteredGroupedCompletions(for: activeCategory, isPro: isPro)

        let currentBadge = viewModel.currentRankBadge(for: activeCategory, logs: allLogs, isPro: isPro)
        let nextBadge = viewModel.nextRankBadge(for: activeCategory, logs: allLogs, isPro: isPro)
        let unlockedCount = completionResults.filter(\.isUnlocked).count
        let totalCount = completionResults.count

        VStack(spacing: 16) {
            if !isPro && proExtraCount > 0 {
                proUpgradeBanner(extraCount: proExtraCount)
            }

            categoryPicker(activeCategory: activeCategory)

            progressSummaryCard(unlockedCount: unlockedCount, totalCount: totalCount)

            rankBadgeBanner(
                currentBadge: currentBadge,
                nextBadge: nextBadge,
                unlockedCount: unlockedCount
            )

            if groupedResults.isEmpty {
                ContentUnavailableView(
                    String(localized: "該当する図鑑項目がありません"),
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text(String(localized: "産地や品種・米・スタイルの絞り込み条件を変更してみてください。"))
                )
                .padding(.top, 24)
            } else {
                groupedCollectionView(groupedResults: groupedResults)
            }
        }
        .sheet(item: $activeSheetWrapper) { wrapper in
            CollectionItemDetailSheet(definition: wrapper.definition, unlockedLogs: wrapper.unlockedLogs)
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $isShowingRankSheet) {
            RankShareSheetView(
                category: activeCategory,
                unlockedCount: unlockedCount,
                totalCount: totalCount
            )
        }
        .alert(String(localized: "解放のヒント"), isPresented: $isShowingSuggestionAlert, presenting: selectedHintMessage) { _ in
            Button(String(localized: "閉じる"), role: .cancel) {}
        } message: { hint in
            Text(hint)
        }
    }

    // MARK: - Filtering Helpers

    private func matchesElementFilter(_ definition: CollectionItemDefinition) -> Bool {
        let selected = logViewModel.collectionTargetElementFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !selected.isEmpty else { return true }
        return definition.targetElement == selected
    }

    private func matchesRegionFilter(_ region: String) -> Bool {
        let selected = logViewModel.collectionRegionFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !selected.isEmpty else { return true }
        return region == selected
    }

    private func filteredCompletions(for category: BeverageCategory, isPro: Bool) -> [CollectionCompletionEntry] {
        viewModel.checkCompletions(for: category, logs: allLogs, isPro: isPro).filter { entry in
            matchesRegionFilter(entry.definition.region) && matchesElementFilter(entry.definition)
        }
    }

    private func filteredGroupedCompletions(for category: BeverageCategory, isPro: Bool) -> [CollectionRegionGroup] {
        viewModel.groupedCompletions(for: category, logs: allLogs, isPro: isPro).compactMap { group in
            guard matchesRegionFilter(group.region) else { return nil }
            let filteredItems = group.items.filter { matchesElementFilter($0.definition) }
            guard !filteredItems.isEmpty else { return nil }
            return CollectionRegionGroup(region: group.region, items: filteredItems)
        }
    }

    // MARK: - Subviews

    private func categoryPicker(activeCategory: BeverageCategory) -> some View {
        Picker(
            String(localized: "酒種"),
            selection: Binding(
                get: { activeCategory },
                set: { newValue in
                    viewModel.selectedCategory = newValue
                    if logViewModel.collectionCategoryFilter != nil {
                        logViewModel.collectionCategoryFilter = newValue
                    }
                }
            )
        ) {
            ForEach(BeverageCategory.allCases, id: \.self) { category in
                Text(category.displayName).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 4)
    }

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

    private func progressSummaryCard(unlockedCount: Int, totalCount: Int) -> some View {
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

    private func rankBadgeBanner(
        currentBadge: CollectionRankBadge?,
        nextBadge: CollectionRankBadge?,
        unlockedCount: Int
    ) -> some View {
        Button {
            isShowingRankSheet = true
        } label: {
            HStack(spacing: 14) {
                badgeCircleIcon(badge: currentBadge, size: 44, iconFont: .headline)

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentBadge?.tier.tierName ?? String(localized: "未獲得"))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(badgeTagBackgroundColor(for: currentBadge))
                        .foregroundStyle(badgeTagForegroundColor(for: currentBadge))
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

    private func groupedCollectionView(groupedResults: [CollectionRegionGroup]) -> some View {
        let columns = [GridItem(.adaptive(minimum: 105, maximum: 140), spacing: 10, alignment: .top)]

        return VStack(alignment: .leading, spacing: 20) {
            ForEach(groupedResults) { group in
                let unlockedInRegion = group.items.filter(\.isUnlocked).count
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
                            .foregroundStyle(
                                unlockedInRegion == totalInRegion && totalInRegion > 0
                                    ? Color.accentColor
                                    : .secondary
                            )
                    }
                    .padding(.horizontal, 4)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(group.items) { cell in
                            collectionCellButton(for: cell)
                        }
                    }
                }
            }
        }
    }

    private func collectionCellButton(for cell: CollectionCompletionEntry) -> some View {
        Button {
            if cell.isUnlocked {
                activeSheetWrapper = CollectionCellSheetWrapper(
                    definition: cell.definition,
                    isUnlocked: cell.isUnlocked,
                    unlockedLogs: cell.unlockedLogs
                )
            } else {
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
                    .stroke(
                        cell.isUnlocked ? Color.accentColor.opacity(0.3) : Color(.systemGray4).opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func badgeCircleIcon(badge: CollectionRankBadge?, size: CGFloat, iconFont: Font) -> some View {
        ZStack {
            Circle()
                .fill(badgeGradient(for: badge))
                .frame(width: size, height: size)

            Image(systemName: badge?.tier.iconName ?? "lock.fill")
                .font(iconFont)
                .foregroundStyle(badge != nil ? .white : .secondary)
        }
    }

    private func badgeGradient(for badge: CollectionRankBadge?) -> LinearGradient {
        if let badge {
            return LinearGradient(
                colors: badge.tier.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color(.systemGray5), Color(.systemGray4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func badgeTagBackgroundColor(for badge: CollectionRankBadge?) -> Color {
        badge != nil ? badge!.tier.accentColor.opacity(0.15) : Color(.systemGray5)
    }

    private func badgeTagForegroundColor(for badge: CollectionRankBadge?) -> Color {
        badge != nil ? badge!.tier.accentColor : .secondary
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
