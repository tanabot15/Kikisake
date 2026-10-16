//
//  AromaStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI

/// [Step 3] 香り（アロマ）入力ビュー
public struct AromaStepView: View {
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
            Section("香り（アロマ）") {
                VStack(alignment: .leading, spacing: 12) {
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
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return AromaStepView(viewModel: vm)
}
