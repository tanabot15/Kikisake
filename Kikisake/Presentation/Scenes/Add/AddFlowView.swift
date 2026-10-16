//
//  AddFlowView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Tab 3] 追加・登録フロー統括ビュー（ツールバーナビゲーション版）
public struct AddFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddFlowViewModel()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // ✨ フォーカス状態の管理
    @FocusState private var focusedField: GeneralInfoField?

    /// ステップ1で銘柄名が未入力かどうかを判定するプロパティ
    private var isNameEmpty: Bool {
        viewModel.currentStep == 1 && viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 5ステップインジケータ（画面上部にスリムに配置）
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { step in
                        Circle()
                            .fill(viewModel.currentStep >= step ? Color.accentColor : Color(.systemGray3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 12)

                // ステップごとの画面切り替え
                Group {
                    switch viewModel.currentStep {
                    case 1:
                        GeneralInfoStepView(
                            viewModel: viewModel,
                            focusedField: $focusedField
                        ) { message in
                            alertMessage = message
                            showAlert = true
                        }
                    case 2:
                        AppearanceStepView(viewModel: viewModel)
                    case 3:
                        AromaStepView(viewModel: viewModel)
                    case 4:
                        TasteStepView(viewModel: viewModel)
                    case 5:
                        FinalizeStepView(viewModel: viewModel)
                    default:
                        GeneralInfoStepView(
                            viewModel: viewModel,
                            focusedField: $focusedField
                        ) { message in
                            alertMessage = message
                            showAlert = true
                        }
                    }
                }
            }
            .navigationTitle("追加 (ステップ \(viewModel.currentStep)/5)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 左上：ステップ1のときは「在庫へ保存」、ステップ2以降のときは「戻る」
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep == 1 {
                        Button {
                            if isNameEmpty {
                                alertMessage = "銘柄名は必須項目です。"
                                showAlert = true
                                return
                            }
                            do {
                                try viewModel.saveAsInventoryOnly(modelContext: modelContext)
                                AppState.shared.selectedTab = 3 // 在庫タブへ移動
                            } catch {
                                alertMessage = "在庫の保存に失敗しました: \(error.localizedDescription)"
                                showAlert = true
                            }
                        } label: {
                            Text("在庫へ保存")
                                .foregroundColor(isNameEmpty ? .gray : .accentColor)
                        }
                    } else {
                        Button {
                            viewModel.currentStep -= 1
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("戻る")
                            }
                        }
                    }
                }

                // 右上：次へ または 保存するボタン
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.currentStep < 5 {
                        Button("次へ") {
                            if isNameEmpty {
                                alertMessage = "銘柄名は必須項目です。"
                                showAlert = true
                                return
                            }
                            viewModel.currentStep += 1
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(isNameEmpty ? .gray : .accentColor)
                    } else {
                        Button("保存") {
                            do {
                                try viewModel.save(modelContext: modelContext)
                                AppState.shared.selectedTab = 0
                            } catch {
                                alertMessage = "保存に失敗しました: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            .alert("確認", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    // ✨ アラートの「OK」を押した時に銘柄名テキストフィールドにフォーカスをあてる
                    if isNameEmpty {
                        focusedField = .name
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    AddFlowView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
