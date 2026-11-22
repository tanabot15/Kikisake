//
//  TimelineRowView.swift
//  Kikisake
//

import SwiftUI

/// Timeline row component showing chronological axis and summary card.
public struct TimelineRowView: View {
    public let log: TastingLog
    public let item: BeverageItem
    public let isFirst: Bool
    public let isLast: Bool

    public init(log: TastingLog, item: BeverageItem, isFirst: Bool, isLast: Bool) {
        self.log = log
        self.item = item
        self.isFirst = isFirst
        self.isLast = isLast
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineAxis

            VStack(alignment: .leading, spacing: 6) {
                Text(log.date.toFormattedString(format: "yyyy年M月d日"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                summaryCard
            }
            .padding(.bottom, 8)
        }
    }

    private var timelineAxis: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : Color(.systemGray4))
                .frame(width: 2, height: 12)

            Circle()
                .fill(Color(hex: log.appearanceColorHex) ?? Color.accentColor)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle().stroke(Color(.systemBackground), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

            Rectangle()
                .fill(isLast ? Color.clear : Color(.systemGray4))
                .frame(width: 2)
        }
        .frame(width: 20)
    }

    private var summaryCard: some View {
        HStack(spacing: 10) {
            thumbnailView

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.category.displayName)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundStyle(Color.accentColor)
                        .cornerRadius(3)

                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", log.rating))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }

                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let imageData = item.imageDatas?.first, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 35, height: 35)
                .overlay {
                    Image(systemName: "wineglass")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
        }
    }
}

#Preview("タイムライン行（中間要素）") {
    let item = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015"
    )
    let log = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceColorHex: "#991A33",
        item: item
    )

    return TimelineRowView(
        log: log,
        item: item,
        isFirst: false,
        isLast: false
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
