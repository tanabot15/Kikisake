//
//  RankShareCardView.swift
//  Kikisake
//

import SwiftUI

public enum ShareAchievementContent {
    case rank(badge: CollectionRankBadge, unlockedCount: Int, totalCount: Int)
    case region(badge: RegionAchievementBadge)

    var category: BeverageCategory {
        switch self {
        case .rank(let badge, _, _): badge.category
        case .region(let badge): badge.category
        }
    }

    var tier: CollectionRankTier {
        switch self {
        case .rank(let badge, _, _): badge.tier
        case .region(let badge): badge.achievedTier ?? .bronze
        }
    }

    var pillText: String {
        switch self {
        case .rank(let badge, _, _):
            return "\(badge.category.displayName) • \(badge.tier.tierName)ランク達成"
        case .region(let badge):
            let tierName = badge.achievedTier?.tierName ?? String(localized: "達成")
            return "\(badge.category.displayName) • \(badge.region) \(tierName)"
        }
    }

    var titleText: String {
        switch self {
        case .rank(let badge, _, _): badge.title
        case .region(let badge): badge.badgeTitle
        }
    }

    var subtitleText: String {
        switch self {
        case .rank(let badge, _, _):
            return badge.subtitle
        case .region(let badge):
            return String(
                format: String(localized: "%@の図鑑を %d/%d 種類（%.0f%%）達成"),
                badge.region,
                badge.unlockedCount,
                badge.totalCount,
                badge.completionRate * 100
            )
        }
    }

    var countSummaryText: String {
        switch self {
        case .rank(_, let unlocked, let total):
            return "\(unlocked) / \(total)"
        case .region(let badge):
            return "\(badge.unlockedCount) / \(badge.totalCount)"
        }
    }

    var shareMessage: String {
        switch self {
        case .rank(let badge, let unlocked, let total):
            return String(
                format: String(localized: "【Kikisake 図鑑アワード】%@の%@ランク称号「%@」を獲得しました！（達成数: %d/%d） #Kikisake"),
                badge.category.displayName,
                badge.tier.tierName,
                badge.title,
                unlocked,
                total
            )
        case .region(let badge):
            let tierName = badge.achievedTier?.tierName ?? ""
            return String(
                format: String(localized: "【Kikisake 産地バッジ】%@の「%@」（%@）を獲得しました！（%d/%d種達成） #Kikisake"),
                badge.category.displayName,
                badge.badgeTitle,
                tierName,
                badge.unlockedCount,
                badge.totalCount
            )
        }
    }
}

/// Shareable graphic card displaying an achieved rank or region achievement badge.
public struct RankShareCardView: View {
    private let content: ShareAchievementContent

    public init(badge: CollectionRankBadge, unlockedCount: Int, totalCount: Int) {
        self.content = .rank(badge: badge, unlockedCount: unlockedCount, totalCount: totalCount)
    }

    public init(regionBadge: RegionAchievementBadge) {
        self.content = .region(badge: regionBadge)
    }

    public init(content: ShareAchievementContent) {
        self.content = content
    }

    public var body: some View {
        let tier = content.tier

        VStack(spacing: 20) {
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

            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 112, height: 112)

                Circle()
                    .stroke(.white.opacity(0.55), lineWidth: 2)
                    .frame(width: 100, height: 100)

                Image(systemName: tier.iconName)
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
            }

            Text(content.pillText)
                .font(.caption)
                .fontWeight(.heavy)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.white.opacity(0.22))
                .foregroundStyle(.white)
                .clipShape(Capsule())

            VStack(spacing: 8) {
                Text(content.titleText)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(content.subtitleText)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            Divider()
                .background(.white.opacity(0.3))
                .padding(.horizontal, 16)

            HStack(spacing: 36) {
                VStack(spacing: 2) {
                    Text(String(localized: "図鑑達成数"))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(content.countSummaryText)
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                }

                VStack(spacing: 2) {
                    Text(String(localized: "表示日"))
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
                colors: tier.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: tier.accentColor.opacity(0.4), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    let badge = CollectionRankBadge.badges(for: .wine)[1]
    return RankShareCardView(badge: badge, unlockedCount: 34, totalCount: 100)
        .padding()
}
