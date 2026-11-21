//
//  RankShareSheetView.swift
//  Kikisake
//

import SwiftUI

/// Sheet presenting rank progress, share card preview, and social sharing actions.
public struct RankShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    public let category: BeverageCategory
    public let unlockedCount: Int
    public let totalCount: Int

    @State private var renderedImage: UIImage? = nil

    public init(category: BeverageCategory, unlockedCount: Int, totalCount: Int) {
        self.category = category
        self.unlockedCount = unlockedCount
        self.totalCount = totalCount
    }

    private var allBadges: [CollectionRankBadge] {
        CollectionRankBadge.badges(for: category)
    }

    private var currentBadge: CollectionRankBadge? {
        CollectionRankBadge.currentBadge(for: category, unlockedCount: unlockedCount)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let activeBadge = currentBadge {
                        RankShareCardView(
                            badge: activeBadge,
                            unlockedCount: unlockedCount,
                            totalCount: totalCount
                        )
                        .padding(.top, 8)

                        shareActionSection(badge: activeBadge)
                    } else if let firstBadge = allBadges.first {
                        lockedPreviewSection(targetBadge: firstBadge)
                    }

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
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "称号・バッジ"))
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
    private func shareActionSection(badge: CollectionRankBadge) -> some View {
        let shareText = String(
            format: String(localized: "【Kikisake 図鑑アワード】%@の%@ランク称号「%@」を獲得しました！（達成数: %d/%d） #Kikisake"),
            badge.category.displayName,
            badge.tier.tierName,
            badge.title,
            unlockedCount,
            totalCount
        )

        Group {
            if let uiImage = renderedImage {
                let image = Image(uiImage: uiImage)
                ShareLink(
                    item: image,
                    subject: Text("Kikisake 称号獲得"),
                    message: Text(shareText),
                    preview: SharePreview(badge.title, image: image)
                ) {
                    shareButtonLabel(title: String(localized: "SNSで称号カードをシェア"))
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

    private func lockedPreviewSection(targetBadge: CollectionRankBadge) -> some View {
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
        guard let activeBadge = currentBadge else { return }
        let card = RankShareCardView(
            badge: activeBadge,
            unlockedCount: unlockedCount,
            totalCount: totalCount
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        renderedImage = renderer.uiImage
    }
}

#Preview("称号シェアシート") {
    RankShareSheetView(category: .wine, unlockedCount: 34, totalCount: 100)
}
