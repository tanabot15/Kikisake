//
//  CustomSlider.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// 味わい（酸味・甘味・ボディ等）評価用のカスタムスライダーコンポーネント
public struct CustomSlider: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0.0...5.0
    var step: Double = 0.5
    var unit: String = ""

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(String(format: "%.1f %@", value, unit))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(.accentColor)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var sampleValue: Double = 3.5
    return Form {
        Section {
            CustomSlider(title: "酸味 (Acidity)", value: $sampleValue, unit: "pt")
        }
    }
}
