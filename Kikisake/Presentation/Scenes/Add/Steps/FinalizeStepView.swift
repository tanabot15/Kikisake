//
//  FinalizeStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// [Step 4] 総合評価・メモ入力および保存確認ビュー
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
                    Slider(value: $viewModel.rating, in: 1.0...5.0, step: 0.5)
                        .tint(.yellow)
                }
                .padding(.vertical, 4)
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
