//
//  RankShareCardView.swift
//  Kikisake
//

import SwiftUI

/// Shareable graphic card displaying an achieved collection rank badge.
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

                Image(systemName: badge.tier.iconName)
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
            }

            Text("\(badge.category.displayName) • \(badge.tier.tierName)ランク達成")
                .font(.caption)
                .fontWeight(.heavy)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.white.opacity(0.22))
                .foregroundStyle(.white)
                .clipShape(Capsule())

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

#Preview {
    let badge = CollectionRankBadge.badges(for: .wine)[1]
    return RankShareCardView(badge: badge, unlockedCount: 34, totalCount: 100)
        .padding()
}
