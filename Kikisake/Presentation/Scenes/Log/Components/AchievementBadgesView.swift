//
//  AchievementBadgesView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

private struct BadgeShareSheetTarget: Identifiable {
    let id = UUID()
    let category: BeverageCategory
    let unlockedCount: Int
    let totalCount: Int
    let preferredRankBadge: CollectionRankBadge?
    let regionBadge: RegionAchievementBadge?
}

/// コンプリート図鑑のランクバッジと産地別アチーブメントバッジを管理・閲覧する画面
public struct AchievementBadgesView: View {
    let allLogs: [TastingLog]
    @Bindable var logViewModel: LogViewModel
    @Bindable var collectionViewModel: CollectionViewModel
    @Bindable private var appState = AppState.shared

    @State private var selectedCategory: BeverageCategory = .wine
    @State private var shareTarget: BadgeShareSheetTarget? = nil
    @State private var selectedRegionBadge: RegionAchievementBadge? = nil

    public init(
        allLogs: [TastingLog],
        logViewModel: LogViewModel = LogViewModel(),
        viewModel: CollectionViewModel = CollectionViewModel()
    ) {
        self.allLogs = allLogs
        self.logViewModel = logViewModel
        self.collectionViewModel = viewModel
    }

    public var body: some View {
        let isPro = appState.isProVersion
        let completions = collectionViewModel.checkCompletions(for: selectedCategory, logs: allLogs, isPro: isPro)
        let unlockedCount = completions.filter(\.isUnlocked).count
        let totalCount = completions.count
        let grouped = collectionViewModel.groupedCompletions(for: selectedCategory, logs: allLogs, isPro: isPro)
        let regionBadges = RegionAchievementEvaluator.badges(for: selectedCategory, groupedCompletions: grouped)
        let unlockedRegionCount = regionBadges.filter(\.isUnlocked).count

        ScrollView {
            VStack(spacing: 20) {
                categoryPicker

                overallAchievementSummaryCard(
                    unlockedItems: unlockedCount,
                    totalItems: totalCount,
                    unlockedRegions: unlockedRegionCount,
                    totalRegions: regionBadges.count
                )

                rankTierSection(unlockedCount: unlockedCount, totalCount: totalCount)

                regionBadgesSection(regionBadges: regionBadges)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            selectedCategory = logViewModel.collectionCategoryFilter ?? collectionViewModel.selectedCategory
        }
        .sheet(item: $shareTarget) { target in
            RankShareSheetView(
                category: target.category,
                unlockedCount: target.unlockedCount,
                totalCount: target.totalCount,
                preferredRankBadge: target.preferredRankBadge,
                regionBadge: target.regionBadge
            )
        }
        .sheet(item: $selectedRegionBadge) { badge in
            regionBadgeDetailSheet(
                badge: badge,
                unlockedCount: unlockedCount,
                totalCount: totalCount
            )
        }
    }

    // MARK: - Subviews

    private var categoryPicker: some View {
        Picker(String(localized: "酒種"), selection: $selectedCategory) {
            ForEach(BeverageCategory.allCases, id: \.self) { category in
                Text(category.displayName).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedCategory) { _, newValue in
            collectionViewModel.selectedCategory = newValue
            if logViewModel.collectionCategoryFilter != nil {
                logViewModel.collectionCategoryFilter = newValue
            }
        }
    }

    private func overallAchievementSummaryCard(
        unlockedItems: Int,
        totalItems: Int,
        unlockedRegions: Int,
        totalRegions: Int
    ) -> some View {
        HStack(spacing: 12) {
            summaryMetricBox(
                title: String(localized: "図鑑達成"),
                value: "\(unlockedItems) / \(totalItems)",
                icon: "book.closed.fill",
                color: .accentColor
            )
            summaryMetricBox(
                title: String(localized: "解除済み産地バッジ"),
                value: "\(unlockedRegions) / \(totalRegions)",
                icon: "rosette",
                color: .indigo
            )
        }
    }

    private func summaryMetricBox(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.14))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    private func rankTierSection(unlockedCount: Int, totalCount: Int) -> some View {
        let badges = CollectionRankBadge.badges(for: selectedCategory)

        return VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "称号ランクバッジ"))
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(badges) { badge in
                    let isEarned = unlockedCount >= badge.requiredCount
                    let progress = min(1.0, Double(unlockedCount) / Double(max(badge.requiredCount, 1)))

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    isEarned
                                        ? LinearGradient(colors: badge.tier.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [Color(.systemGray5), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 44, height: 44)
                            Image(systemName: isEarned ? badge.tier.iconName : "lock.fill")
                                .font(.headline)
                                .foregroundStyle(isEarned ? .white : .secondary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(badge.tier.tierName)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(badge.tier.accentColor.opacity(0.15))
                                    .foregroundStyle(badge.tier.accentColor)
                                    .clipShape(Capsule())

                                Text(badge.title)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(isEarned ? .primary : .secondary)

                                Spacer()

                                Text("\(min(unlockedCount, badge.requiredCount))/\(badge.requiredCount)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }

                            Text(badge.subtitle)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)

                            ProgressView(value: progress)
                                .tint(isEarned ? badge.tier.accentColor : Color.accentColor)
                        }

                        if isEarned {
                            Button {
                                shareTarget = BadgeShareSheetTarget(
                                    category: selectedCategory,
                                    unlockedCount: unlockedCount,
                                    totalCount: totalCount,
                                    preferredRankBadge: badge,
                                    regionBadge: nil
                                )
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(14)
                }
            }
        }
    }

    private func regionBadgesSection(regionBadges: [RegionAchievementBadge]) -> some View {
        let columns = [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 10, alignment: .top)]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "産地別アチーブメントバッジ"))
                    .font(.headline)
                Spacer()
                Text(String(localized: "タップで詳細・図鑑へ移動"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(regionBadges) { badge in
                    Button {
                        selectedRegionBadge = badge
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: badge.achievedTier?.iconName ?? "lock.circle")
                                    .font(.title3)
                                    .foregroundStyle(badge.achievedTier?.accentColor ?? Color(.systemGray3))

                                Spacer()

                                Text(String(format: "%.0f%%", badge.completionRate * 100))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(badge.isUnlocked ? .primary : .secondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(badge.region)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(badge.isUnlocked ? .primary : .secondary)
                                    .lineLimit(1)

                                Text(badge.achievedTier?.tierName ?? String(localized: "未解除"))
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(badge.achievedTier?.accentColor ?? .secondary)
                            }

                            Text("\(badge.unlockedCount) / \(badge.totalCount) \(String(localized: "達成"))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    (badge.achievedTier?.accentColor ?? Color(.systemGray4)).opacity(badge.isUnlocked ? 0.45 : 0.25),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func regionBadgeDetailSheet(
        badge: RegionAchievementBadge,
        unlockedCount: Int,
        totalCount: Int
    ) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            badge.achievedTier != nil
                                ? LinearGradient(colors: badge.achievedTier!.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color(.systemGray5), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 88, height: 88)

                    Image(systemName: badge.achievedTier?.iconName ?? "lock.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(badge.achievedTier != nil ? .white : .secondary)
                }

                VStack(spacing: 6) {
                    Text(badge.badgeTitle)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(String(format: String(localized: "%@ • %d / %d 種達成 (%.0f%%)"), badge.region, badge.unlockedCount, badge.totalCount, badge.completionRate * 100))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(String(localized: "1種以上でブロンズ、50%以上でシルバー、80%以上でゴールド、100%コンプリートでプラチナバッジが解除されます。"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    if badge.isUnlocked {
                        Button {
                            let targetBadge = badge
                            selectedRegionBadge = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                shareTarget = BadgeShareSheetTarget(
                                    category: targetBadge.category,
                                    unlockedCount: unlockedCount,
                                    totalCount: totalCount,
                                    preferredRankBadge: nil,
                                    regionBadge: targetBadge
                                )
                            }
                        } label: {
                            Label(String(localized: "SNSで産地バッジをシェア"), systemImage: "square.and.arrow.up")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                    }

                    Button {
                        logViewModel.collectionCategoryFilter = badge.category
                        logViewModel.collectionRegionFilter = badge.region
                        logViewModel.collectionTargetElementFilter = ""
                        collectionViewModel.selectedCategory = badge.category
                        logViewModel.selectedSection = .collectionBook
                        selectedRegionBadge = nil
                    } label: {
                        Text(String(format: String(localized: "%@の図鑑項目を見る"), badge.region))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.tertiarySystemFill))
                            .foregroundStyle(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle(badge.region)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "閉じる")) {
                        selectedRegionBadge = nil
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    let sample = PreviewSampleData.makeSampleBundle()
    return NavigationStack {
        AchievementBadgesView(
            allLogs: [sample.wineLog, sample.sakeLog, sample.beerLog]
        )
        .navigationTitle(String(localized: "バッジ"))
        .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(PreviewSampleData.container)
}
