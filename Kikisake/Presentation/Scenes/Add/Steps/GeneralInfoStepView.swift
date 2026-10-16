//
//  GeneralInfoStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI
import SwiftData

/// [Step 1] 一般的な情報（酒種・基本情報・保管場所）入力ビュー
public struct GeneralInfoStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @Environment(\.modelContext) private var modelContext
    var showAlert: (String) -> Void

    public init(viewModel: AddFlowViewModel, showAlert: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.showAlert = showAlert
    }

    public var body: some View {
        Form {
            Section("酒種") {
                Picker("酒種", selection: $viewModel.selectedCategory) {
                    ForEach(BeverageCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
            }

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

            // テイスティングを行わず在庫として登録する場合
            Section {
                Button {
                    if viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        showAlert("銘柄名を入力してください。")
                        return
                    }
                    do {
                        try viewModel.saveAsInventoryOnly(modelContext: modelContext)
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
    return GeneralInfoStepView(viewModel: vm) { _ in }
}
