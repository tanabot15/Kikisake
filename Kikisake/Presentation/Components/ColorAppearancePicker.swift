//
//  ColorAppearancePicker.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// 外観・色調選択用コンポーネント
public struct ColorAppearancePicker: View {
    let category: BeverageCategory
    @Binding var selectedAppearance: String

    private var options: [String] {
        switch category {
        case .wine:
            return ["レモンイエロー", "黄金色", "ルビーレッド", "ガーネット", "オレンジワイン"]
        case .sake:
            return ["無色透明", "微黄色", "エイジング（琥珀色）", "濁り（にごり酒）"]
        case .beer:
            return ["ペールゴールド", "アンバー", "ダークブラウン", "ブラック"]
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("外観・色調")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            selectedAppearance = option
                        } label: {
                            Text(option)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedAppearance == option ? Color.accentColor : Color(.systemGray6))
                                .foregroundStyle(selectedAppearance == option ? Color.white : Color.primary)
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: String = "ルビーレッド"
    return ColorAppearancePicker(category: .wine, selectedAppearance: $selection)
        .padding()
}
