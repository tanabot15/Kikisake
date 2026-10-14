//
//  BasicInfoStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// [Step 2] 基本情報入力ビュー
public struct BasicInfoStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("基本情報") {
                TextField("銘柄名 (必須)", text: $viewModel.name)
                TextField("生産者 / 蔵元 / ブルワリー (必須)", text: $viewModel.producer)
                TextField("生産地 (例: ボルドー, 新潟)", text: $viewModel.region)
                TextField("ヴィンテージ / 製造年月 (例: 2020)", text: $viewModel.vintage)
                TextField("価格 (円)", text: $viewModel.priceString)
                    .keyboardType(.numberPad)
            }

            Section("保管場所") {
                Picker("保管場所", selection: $viewModel.storageLocation) {
                    ForEach(AppConstants.Storage.availableLocations, id: \.self) { location in
                        Text(location).tag(location)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return BasicInfoStepView(viewModel: vm)
}
