//
//  FlowLayout.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/23.
//

import SwiftUI

/// タグやバッジなどを自動で折り返して並べるレイアウトコンポーネント
public struct FlowLayout: Layout {
    private struct LayoutResult {
        let size: CGSize
        let placements: [CGPoint]
    }

    public var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        computeLayout(maxWidth: proposal.width ?? .infinity, origin: .zero, subviews: subviews).size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = computeLayout(maxWidth: bounds.width, origin: bounds.origin, subviews: subviews)
        for (subview, point) in zip(subviews, layout.placements) {
            subview.place(at: point, proposal: .unspecified)
        }
    }

    private func computeLayout(maxWidth: CGFloat, origin: CGPoint, subviews: Subviews) -> LayoutResult {
        var x = origin.x
        var y = origin.y
        var rowHeight: CGFloat = 0
        var placements: [CGPoint] = []
        placements.reserveCapacity(subviews.count)

        let rowLimitX = maxWidth.isInfinite ? .infinity : origin.x + maxWidth

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > origin.x && x + size.width > rowLimitX {
                x = origin.x
                y += rowHeight + spacing
                rowHeight = 0
            }

            placements.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        let totalHeight = (y - origin.y) + rowHeight
        let resolvedWidth = maxWidth.isInfinite ? max(0, x - origin.x - spacing) : maxWidth
        return LayoutResult(size: CGSize(width: resolvedWidth, height: totalHeight), placements: placements)
    }
}

#Preview {
    let sampleTags = [
        "スミレ", "樽香", "チェリー", "タバコ", "スパイス",
        "ブラックベリー", "カシス", "なめし皮", "チョコレート",
        "ヴァニラ", "グリエ", "乾燥イチジク", "鉱物", "トースト"
    ]

    return VStack(alignment: .leading, spacing: 12) {
        Text("香りタグのサンプルプレビュー")
            .font(.headline)
            .foregroundStyle(.primary)

        FlowLayout(spacing: 8) {
            ForEach(sampleTags, id: \.self) { tag in
                Text(tag)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
