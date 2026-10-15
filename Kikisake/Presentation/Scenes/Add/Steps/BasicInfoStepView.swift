//
//  BasicInfoStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Step 2] 基本情報入力ビュー
public struct BasicInfoStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @Environment(\.modelContext) private var modelContext
    var showAlert: (String) -> Void

    public init(viewModel: AddFlowViewModel, showAlert: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.showAlert = showAlert
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

            // すぐに飲まずにセラー・冷蔵庫に保管する場合の完了ボタン
            Section {
                Button {
                    if viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        showAlert("銘柄名を入力してください。")
                        return
                    }
                    do {
                        try viewModel.saveAsInventoryOnly(modelContext: modelContext)
                        // 保存成功後は在庫管理タブ（index 3）に移動
                        AppState.shared.selectedTab = 3
                    } catch {
                        showAlert("在庫の保存に失敗しました: \(error.localizedDescription)")
                    }
                } label: {
                    HStack {
                        Spacer()
                        Label("あとで飲む", systemImage: "refrigerator")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .tint(.accentColor)
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return BasicInfoStepView(viewModel: vm) { _ in }
}
