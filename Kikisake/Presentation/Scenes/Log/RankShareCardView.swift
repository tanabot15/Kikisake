//  RankShareCardView.swift
//  Kikisake

import SwiftUI

/// SNSシェア用の称号・バッジグラフィックカード
public struct RankShareCardView: View {
    public let badge: CollectionRankBadge
    public let unlockedCount: Int
    public let totalCount: Int

    public init(badge: CollectionRankBadge, unlockedCount: Int, totalCount: Int) {
        self.badge = badge
        self.unlockedCount = unlockedCount
        self.totalCount = totalCount
    }

    public var body: some View {
        VStack(spacing: 20) {
            // アプリロゴ・ヘッダー
            HStack(spacing: 6) {
                Image(systemName: "wineglass.fill")
                    .font(.caption)
                Text("Kikisake Collection Award")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1.2)
            }
            .foregroundStyle(.white.opacity(0.85))
            .padding(.top, 8)

            // ランクメダルアイコン
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 112, height: 112)

                Circle()
                    .stroke(.white.opacity(0.55), lineWidth: 2)
                    .frame(width: 100, height: 100)

                Image(systemName: badge.tier.iconName)
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
            }

            // ランク種別ピル
            Text("\(badge.category.displayName) • \(badge.tier.tierName)ランク達成")
                .font(.caption)
                .fontWeight(.heavy)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.white.opacity(0.22))
                .foregroundStyle(.white)
                .clipShape(Capsule())

            // 称号タイトル & サブタイトル
            VStack(spacing: 8) {
                Text(badge.title)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(badge.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            Divider()
                .background(.white.opacity(0.3))
                .padding(.horizontal, 16)

            // 達成スコア表示
            HStack(spacing: 36) {
                VStack(spacing: 2) {
                    Text(String(localized: "図鑑達成数"))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(unlockedCount) / \(totalCount)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                }

                VStack(spacing: 2) {
                    Text(String(localized: "達成日"))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(Date().formatted(date: .numeric, time: .omitted))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(24)
        .frame(width: 320)
        .background(
            LinearGradient(
                colors: badge.tier.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: badge.tier.accentColor.opacity(0.4), radius: 16, x: 0, y: 8)
    }
}

/// 称号のプレビューとSNSシェアを実行するシートビュー
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
                    // 1. 現在の最高称号カード（未達成時はブロンズ目標を表示）
                    if let activeBadge = currentBadge {
                        RankShareCardView(
                            badge: activeBadge,
                            unlockedCount: unlockedCount,
                            totalCount: totalCount
                        )
                        .padding(.top, 8)

                        // SNSシェアボタン（画像＋テキスト）
                        shareActionSection(badge: activeBadge)
                    } else if let firstBadge = allBadges.first {
                        lockedPreviewSection(targetBadge: firstBadge)
                    }

                    // 2. 全ランク一覧（ブロンズ / シルバー / ゴールド）
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "\(category.displayName)の称号ランク一覧"))
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)

                        ForEach(allBadges) { badge in
                            let isAchieved = unlockedCount >= badge.requiredCount
                            rankMilestoneRow(badge: badge, isAchieved: isAchieved)
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
            .onAppear {
                renderShareImage()
            }
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

        VStack(spacing: 10) {
            if let uiImage = renderedImage {
                let image = Image(uiImage: uiImage)
                ShareLink(
                    item: image,
                    subject: Text("Kikisake 称号獲得"),
                    message: Text(shareText),
                    preview: SharePreview(badge.title, image: image)
                ) {
                    Label(String(localized: "SNSで称号カードをシェア"), systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            } else {
                ShareLink(item: shareText) {
                    Label(String(localized: "SNSでシェアする"), systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private func lockedPreviewSection(targetBadge: CollectionRankBadge) -> some View {
        let remaining = max(0, targetBadge.requiredCount - unlockedCount)
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(String(localized: "まだ称号を獲得していません"))
                .font(.headline)
                .fontWeight(.bold)

            Text(String(format: String(localized: "あと %d 種類記録すると、最初のブロンズ称号「%@」が解放され、SNSでシェアできるようになります！"), remaining, targetBadge.title))
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

    @ViewBuilder
    private func rankMilestoneRow(badge: CollectionRankBadge, isAchieved: Bool) -> some View {
        HStack(spacing: 14) {
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
        self.renderedImage = renderer.uiImage
    }
}

#Preview("称号シェアシート") {
    RankShareSheetView(category: .wine, unlockedCount: 34, totalCount: 100)
}
