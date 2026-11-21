//
//  FinalizeStepView.swift
//  Kikisake
//

import SwiftUI

/// Step 5 view for rating, feature flags, pairing, and tasting notes.
public struct FinalizeStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            ratingAndDateSection
            featureFlagsSection

            Section("ペアリング") {
                TextField(
                    "合わせるべき料理や食材 (例: ローストビーフ, カマンベールチーズ)",
                    text: $viewModel.pairing,
                    axis: .vertical
                )
                .lineLimit(2...3)
            }

            Section("総合コメント") {
                TextEditor(text: $viewModel.memo)
                    .frame(height: 120)
            }
        }
    }

    private var ratingAndDateSection: some View {
        Section("総合評価・日付") {
            DatePicker("飲んだ日", selection: $viewModel.tastingDate, displayedComponents: [.date])

            VStack(alignment: .leading, spacing: 6) {
                Text("総合スコア: \(String(format: "%.1f", viewModel.rating))")
                    .font(.subheadline)
                Slider(value: $viewModel.rating, in: 1.0...5.0, step: 0.1)
                    .tint(.yellow)
            }
            .padding(.vertical, 4)
        }
    }

    private var featureFlagsSection: some View {
        Section("特徴・評価フラグ") {
            flagToggle(
                isOn: $viewModel.isCostEffective,
                title: "コスパが高い",
                subtitle: "価格以上の価値や満足感がある",
                iconName: "banknote.fill",
                iconColor: .green
            )

            flagToggle(
                isOn: $viewModel.isWillingToRepeat,
                title: "リピート確定",
                subtitle: "次回もぜひ購入または注文したい",
                iconName: "arrow.clockwise.circle.fill",
                iconColor: .orange
            )

            flagToggle(
                isOn: $viewModel.hasAgingPotential,
                title: "熟成ポテンシャルあり",
                subtitle: "さらに時間を置いて寝かせる価値がある",
                iconName: "hourglass.circle.fill",
                iconColor: .purple
            )
        }
    }

    private func flagToggle(
        isOn: Binding<Bool>,
        title: String,
        subtitle: String,
        iconName: String,
        iconColor: Color
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    FinalizeStepViewPreviewHost()
}

private struct FinalizeStepViewPreviewHost: View {
    @State private var vm = AddFlowViewModel()

    var body: some View {
        FinalizeStepView(viewModel: vm)
    }
}
