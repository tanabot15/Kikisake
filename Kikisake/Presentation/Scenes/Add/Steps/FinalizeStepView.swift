//  FinalizeStepView.swift
//  Kikisake

import SwiftUI

/// [Step 5] 総合評価・メモ入力および保存確認ビュー
public struct FinalizeStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
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

            // 特徴・印象（評価フラグ）セクションを追加
            Section("特徴・評価フラグ") {
                Toggle(isOn: $viewModel.isCostEffective) {
                    HStack {
                        Image(systemName: "banknote.fill")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading) {
                            Text("コスパが高い")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("価格以上の価値や満足感がある")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Toggle(isOn: $viewModel.isWillingToRepeat) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading) {
                            Text("リピート確定")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("次回もぜひ購入または注文したい")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Toggle(isOn: $viewModel.hasAgingPotential) {
                    HStack {
                        Image(systemName: "hourglass.circle.fill")
                            .foregroundStyle(.purple)
                        VStack(alignment: .leading) {
                            Text("熟成ポテンシャルあり")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("さらに時間を置いて寝かせる価値がある")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("総合コメント") {
                TextEditor(text: $viewModel.memo)
                    .frame(height: 120)
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return FinalizeStepView(viewModel: vm)
}
