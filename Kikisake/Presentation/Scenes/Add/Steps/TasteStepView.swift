//
//  TasteStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI

/// [Step 4] 味わい構造入力ビュー
public struct TasteStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("味わい構造") {
                CustomSlider(title: "甘味 (Sweetness)", value: $viewModel.sweetness)
                CustomSlider(title: "酸味 (Acidity)", value: $viewModel.acidity)
                CustomSlider(title: "タンニン / 苦味", value: $viewModel.bitternessOrTannin)
                CustomSlider(title: "ボディ (Body)", value: $viewModel.body)
                CustomSlider(title: "余韻の長さ", value: $viewModel.finishLength)
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return TasteStepView(viewModel: vm)
}
