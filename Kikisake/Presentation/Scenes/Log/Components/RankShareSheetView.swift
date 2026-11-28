//
//  RankShareSheetView.swift
//  Kikisake
//

import SwiftUI

/// Sheet presenting rank or region badge progress, share card preview, and social sharing actions.
public struct RankShareSheetView: View {
    @Environment(\.dismiss) private var dismiss

    public let category: BeverageCategory
    public let unlockedCount: Int
    public let totalCount: Int
    public let preferredRankBadge: CollectionRankBadge?
    public let regionBadge: RegionAchievementBadge?

    @State private var renderedImage: UIImage? = nil

    public init(
        category: BeverageCategory,
        unlockedCount: Int,
        totalCount: Int,
        preferredRankBadge: CollectionRankBadge? = nil,
        regionBadge: RegionAchievementBadge? = nil
    ) {
        self.category = category
        self.unlockedCount = unlockedCount
        self.totalCount = totalCount
        self.preferredRankBadge = preferredRankBadge
        self.regionBadge = regionBadge
    }

    private var allBadges: [CollectionRankBadge] {
        CollectionRankBadge.badges(for: category)
    }

    private var activeRankBadge: CollectionRankBadge? {
        if let preferredRankBadge,
           preferredRankBadge.category == category,
           unlockedCount >= preferredRankBadge.requiredCount {
            return preferredRankBadge
        }
        return CollectionRankBadge.currentBadge(for: category, unlockedCount: unlockedCount)
    }

    private var activeShareContent: ShareAchievementContent? {
        if let regionBadge, regionBadge.isUnlocked {
            return .region(badge: regionBadge)
        }
        if let activeRankBadge {
            return .rank(badge: activeRankBadge, unlockedCount: unlockedCount, totalCount: totalCount)
        }
        return nil
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let content = activeShareContent {
                        RankShareCardView(content: content)
                            .padding(.top, 8)

                        shareActionSection(content: content)
                    } else if let lockedRegion = regionBadge {
                        lockedRegionPreviewSection(badge: lockedRegion)
                    } else if let firstBadge = allBadges.first {
                        lockedRankPreviewSection(targetBadge: firstBadge)
                    }

                    if let regionBadge {
                        regionMilestonesSection(badge: regionBadge)
                    } else {
                        rankMilestonesSection
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(regionBadge != nil ? String(localized: "産地バッジシェア") : String(localized: "称号・バッジ"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "閉じる")) {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: renderShareImage)
        }
    }

    @ViewBuilder
    private func shareActionSection(content: ShareAchievementContent) -> some View {
        let shareText = content.shareMessage

        Group {
            if let uiImage = renderedImage {
                let image = Image(uiImage: uiImage)
                ShareLink(
                    item: image,
                    subject: Text("Kikisake バッジ獲得"),
                    message: Text(shareText),
                    preview: SharePreview(content.titleText, image: image)
                ) {
                    shareButtonLabel(title: String(localized: "SNSでバッジカードをシェア"))
                }
            } else {
                ShareLink(item: shareText) {
                    shareButtonLabel(title: String(localized: "SNSでシェアする"))
                }
            }
        }
        .padding(.horizontal)
    }

    private func shareButtonLabel(title: String) -> some View {
        Label(title, systemImage: "square.and.arrow.up")
            .font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .cornerRadius(14)
    }

    private func lockedRegionPreviewSection(badge: RegionAchievementBadge) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(String(localized: "まだ産地バッジを解除していません"))
                .font(.headline)
                .fontWeight(.bold)

            Text(
                String(
                    format: String(localized: "%@の図鑑項目を1種以上記録すると、最初のブロンズバッジが解除され、SNSでシェアできるようになります！"),
                    badge.region
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func lockedRankPreviewSection(targetBadge: CollectionRankBadge) -> some View {
        let remaining = max(0, targetBadge.requiredCount - unlockedCount)
        return VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(String(localized: "まだ称号を獲得していません"))
                .font(.headline)
                .fontWeight(.bold)

            Text(
                String(
                    format: String(localized: "あと %d 種類記録すると、最初のブロンズ称号「%@」が解放され、SNSでシェアできるようになります！"),
                    remaining,
                    targetBadge.title
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var rankMilestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "\(category.displayName)の称号ランク一覧"))
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal, 4)

            ForEach(allBadges) { badge in
                rankMilestoneRow(
                    badge: badge,
                    isAchieved: unlockedCount >= badge.requiredCount
                )
            }
        }
        .padding(.horizontal)
    }

    private func regionMilestonesSection(badge: RegionAchievementBadge) -> some View {
        let milestones: [(tier: CollectionRankTier, label: String, achieved: Bool)] = [
            (.bronze, String(localized: "1種以上達成"), badge.unlockedCount >= 1),
            (.silver, String(localized: "達成率 50% 以上"), badge.completionRate >= 0.5),
            (.gold, String(localized: "達成率 80% 以上"), badge.completionRate >= 0.8),
            (.platinum, String(localized: "100% 完全制覇"), badge.totalCount > 0 && badge.unlockedCount >= badge.totalCount)
        ]

        return VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "\(badge.region)の達成ステージ"))
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal, 4)

            ForEach(milestones, id: \.tier) { item in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                item.achieved
                                    ? LinearGradient(colors: item.tier.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color(.systemGray5), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: item.achieved ? item.tier.iconName : "lock.fill")
                            .font(.headline)
                            .foregroundStyle(item.achieved ? .white : .secondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.tier.tierName)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(item.achieved ? .primary : .secondary)
                        Text(item.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if item.achieved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(14)
            }
        }
        .padding(.horizontal)
    }

    private func rankMilestoneRow(badge: CollectionRankBadge, isAchieved: Bool) -> some View {
        HStack(spacing: 14) {
            milestoneIcon(badge: badge, isAchieved: isAchieved)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(badge.tier.tierName)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(isAchieved ? badge.tier.accentColor.opacity(0.15) : Color(.systemGray5))
                        .foregroundStyle(isAchieved ? badge.tier.accentColor : .secondary)
                        .clipShape(Capsule())

                    Text(String(format: String(localized: "%d種達成"), badge.requiredCount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(badge.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(isAchieved ? .primary : .secondary)

                Text(badge.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    private func milestoneIcon(badge: CollectionRankBadge, isAchieved: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    isAchieved
                        ? LinearGradient(colors: badge.tier.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color(.systemGray5), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 48, height: 48)

            Image(systemName: isAchieved ? badge.tier.iconName : "lock.fill")
                .font(.title3)
                .foregroundStyle(isAchieved ? .white : .secondary)
        }
    }

    @MainActor
    private func renderShareImage() {
        guard let content = activeShareContent else { return }
        let card = RankShareCardView(content: content)
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        renderedImage = renderer.uiImage
    }
}

#Preview("称号シェアシート") {
    RankShareSheetView(category: .wine, unlockedCount: 34, totalCount: 100)
}
