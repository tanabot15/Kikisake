//  FlowLayout.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/23.
//

import SwiftUI

/// タグやバッジなどを自動で折り返して並べるレイアウトコンポーネント
public struct FlowLayout: Layout {
    public var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: height + rowHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
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
