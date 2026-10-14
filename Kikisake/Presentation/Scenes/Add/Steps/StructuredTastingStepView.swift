//
//  StructuredTastingStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// [Step 3] 構造化テイスティング入力ビュー
public struct StructuredTastingStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    private var sampleAromaTags: [String] {
        switch viewModel.selectedCategory {
        case .wine:
            return ["カシス", "ブラックベリー", "ヴァニラ", "樽香", "スミレ", "トースト"]
        case .sake:
            return ["吟醸香", "青りんご", "洋梨", "バナナ", "米の旨味", "スッキリ"]
        case .beer:
            return ["シトラス", "ホップ", "麦芽", "ロースト香", "ハーバル"]
        }
    }

    public var body: some View {
        Form {
            Section("外観") {
                ColorAppearancePicker(
                    category: viewModel.selectedCategory,
                    selectedAppearance: $viewModel.appearanceNotes
                )
            }

            Section("香り（アロマ）") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("特徴的な香りを選択・タップ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(sampleAromaTags, id: \.self) { tag in
                                let isSelected = viewModel.selectedAromaTags.contains(tag)
                                AromaTagChip(tag: tag, isSelected: isSelected) {
                                    if isSelected {
                                        viewModel.selectedAromaTags.removeAll { $0 == tag }
                                    } else {
                                        viewModel.selectedAromaTags.append(tag)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

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
    return StructuredTastingStepView(viewModel: vm)
}
