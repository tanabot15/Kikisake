//
//  EditLogFlowView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/20.
//

import SwiftUI
import SwiftData

/// 既存テイスティングログの編集用モーダル画面
public struct EditLogFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let targetLog: TastingLog
    @State private var viewModel = AddFlowViewModel()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @FocusState private var focusedField: GeneralInfoField?

    public init(log: TastingLog) {
        self.targetLog = log
    }

    private var isNameEmpty: Bool {
        viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 5ステップインジケータ
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { step in
                        Circle()
                            .fill(viewModel.currentStep >= step ? Color.accentColor : Color(.systemGray3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 12)

                // 各ステップビューの切替（AddFlowViewと同じものをそのまま再利用）
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
            .navigationTitle("ログの修正 (\(viewModel.currentStep)/5)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentStep > 1 {
                        Button("戻る") {
                            viewModel.currentStep -= 1
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
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
                    } else {
                        Button("更新") {
                            if isNameEmpty {
                                alertMessage = "銘柄名は必須項目です。"
                                showAlert = true
                                return
                            }
                            do {
                                try viewModel.update(modelContext: modelContext)
                                dismiss()
                            } catch {
                                alertMessage = "更新に失敗しました: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            .alert("確認", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if isNameEmpty {
                        focusedField = .name
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                viewModel.configureWithLog(targetLog)
            }
        }
    }
}

#Preview {
    let schema = Schema([BeverageItem.self, TastingLog.self, StorageLocation.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    // プレビュー用のサンプル保管場所
    let cellar = StorageLocation(name: "ワインセラー", type: .cellar)
    container.mainContext.insert(cellar)

    // プレビュー用のサンプルアイテムとログ
    let sampleItem = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015",
        price: 85000,
        stockQuantity: 1,
        storageLocation: "ワインセラー"
    )
    
    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.9,
        appearanceNotes: "深みのあるルビーレッド",
        appearanceColorHex: "#991A33",
        aromaTags: ["カシス", "ヴァニラ", "杉"],
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.8,
        balanceTags: ["豊潤な"],
        finishLength: 5.0,
        memo: "圧倒的な気品と複雑味。",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return EditLogFlowView(log: sampleLog)
        .modelContainer(container)
}
