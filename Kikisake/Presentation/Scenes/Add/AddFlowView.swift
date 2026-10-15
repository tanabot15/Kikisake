//
//  AddFlowView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Tab 3] 追加・登録フロー統括ビュー
public struct AddFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddFlowViewModel()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    public var body: some View {
        NavigationStack {
            VStack {
                // ステップインジケータ（Step 2で在庫保存して終わる場合はStep 2まで表示、またはシンプルに表示）
                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { step in
                        Circle()
                            .fill(viewModel.currentStep >= step ? Color.accentColor : Color(.systemGray3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)

                // ステップごとの画面切り替え
                Group {
                    switch viewModel.currentStep {
                    case 1:
                        SelectCategoryStepView(viewModel: viewModel)
                    case 2:
                        BasicInfoStepView(viewModel: viewModel) { message in
                            alertMessage = message
                            showAlert = true
                        }
                    case 3:
                        StructuredTastingStepView(viewModel: viewModel)
                    case 4:
                        FinalizeStepView(viewModel: viewModel)
                    default:
                        SelectCategoryStepView(viewModel: viewModel)
                    }
                }

                // ボトムナビゲーションボタン（Step 2のときは「次へ」でテイスティング入力へ進む）
                HStack {
                    if viewModel.currentStep > 1 {
                        Button("戻る") {
                            viewModel.currentStep -= 1
                        }
                        .buttonStyle(.bordered)
                    }

                    Spacer()

                    if viewModel.currentStep < 4 {
                        Button("次へ") {
                            if viewModel.currentStep == 2 && viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
                                alertMessage = "銘柄名を入力してください。"
                                showAlert = true
                                return
                            }
                            viewModel.currentStep += 1
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("保存する（飲んだ記録を完了）") {
                            do {
                                try viewModel.save(modelContext: modelContext)
                                // 保存成功後はログタブ（index 0）に移動
                                AppState.shared.selectedTab = 0
                            } catch {
                                alertMessage = "保存に失敗しました: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
                .padding()
            }
            .navigationTitle("追加")
            .navigationBarTitleDisplayMode(.inline)
            .alert("確認", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
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
