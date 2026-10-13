//
//  TasteProfileSelector.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// 味わいやテクスチャの特徴を選択するチップセレクター
public struct TasteProfileSelector: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: [String]

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selectedOptions.contains(option)
                    Button {
                        if isSelected {
                            selectedOptions.removeAll { $0 == option }
                        } else {
                            selectedOptions.append(option)
                        }
                    } label: {
                        Text(option)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.accentColor : Color(.systemGray5))
                            .foregroundStyle(isSelected ? Color.white : Color.primary)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// 簡易的なFlowLayoutの代替（UIパーツ内での折り返し表示用）
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let width = proposal.width ?? 300
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            if currentX + subviewSize.width > width, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, subviewSize.height)
            currentX += subviewSize.width + spacing
            maxX = max(maxX, currentX)
        }
        let totalSize = CGSize(width: maxX, height: currentY + lineHeight)
        return (totalSize, positions)
    }
}

#Preview {
    @Previewable @State var selected: [String] = ["まろやか", "ドライ"]
    return TasteProfileSelector(
        title: "口当たり・特徴",
        options: ["まろやか", "シャープ", "ドライ", "リッチ", "スパイシー"],
        selectedOptions: $selected
    )
    .padding()
}
