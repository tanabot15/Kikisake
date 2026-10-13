//
//  AromaTagChip.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// 香り選択用タグチップコンポーネント
public struct AromaTagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    public var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        AromaTagChip(tag: "カシス", isSelected: true, action: {})
        AromaTagChip(tag: "ヴァニラ", isSelected: false, action: {})
    }
    .padding()
}
