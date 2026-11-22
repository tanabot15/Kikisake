//
//  SteppedNumberField.swift
//  Kikisake
//

import SwiftUI

/// ＋／− ボタンによる微調整機能を備えた数値入力フィールド
public struct SteppedNumberField<Field: Hashable>: View {
    let title: String
    @Binding var text: String
    let step: Double
    let range: ClosedRange<Double>?
    let defaultValue: Double
    let isInteger: Bool

    @FocusState<Field?>.Binding var focusedField: Field?
    let fieldTag: Field
    let keyboardType: UIKeyboardType

    public init(
        title: String,
        text: Binding<String>,
        step: Double = 0.5,
        range: ClosedRange<Double>? = nil,
        defaultValue: Double,
        isInteger: Bool = false,
        focusedField: FocusState<Field?>.Binding,
        fieldTag: Field,
        keyboardType: UIKeyboardType = .decimalPad
    ) {
        self.title = title
        self._text = text
        self.step = step
        self.range = range
        self.defaultValue = defaultValue
        self.isInteger = isInteger
        self._focusedField = focusedField
        self.fieldTag = fieldTag
        self.keyboardType = keyboardType
    }

    public var body: some View {
        HStack(spacing: 8) {
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .focused($focusedField, equals: fieldTag)

            HStack(spacing: 4) {
                Button {
                    adjust(by: -step)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.orange)
                }
                .buttonStyle(.plain)

                Button {
                    adjust(by: step)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func adjust(by delta: Double) {
        let current = Double(text) ?? defaultValue
        let next = current + delta
        if let range, !range.contains(next) { return }
        text = isInteger ? "\(Int(next))" : String(format: "%.1f", next)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var vintageText: String = "2024"
        @State private var abvText: String = "13.5"
        @FocusState private var focusedField: GeneralInfoField?

        var body: some View {
            Form {
                Section("＋／− ステップアップ入力プレビュー") {
                    SteppedNumberField(
                        title: "ヴィンテージ / 製造年月",
                        text: $vintageText,
                        step: 1.0,
                        range: 1950...2030,
                        defaultValue: 2024.0,
                        isInteger: true,
                        focusedField: $focusedField,
                        fieldTag: .vintage,
                        keyboardType: .numberPad
                    )

                    SteppedNumberField(
                        title: "アルコール度数 (%)",
                        text: $abvText,
                        step: 0.5,
                        range: 0.0...70.0,
                        defaultValue: 13.5,
                        isInteger: false,
                        focusedField: $focusedField,
                        fieldTag: .abv,
                        keyboardType: .decimalPad
                    )
                }
            }
        }
    }

    return PreviewWrapper()
}
