//
//  EditLogFlowView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Modal 5-step flow for editing an existing tasting log.
public struct EditLogFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let targetLog: TastingLog
    @Bindable private var viewModel = AppState.shared.addFlowViewModel
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @FocusState private var focusedField: GeneralInfoField?

    private let totalSteps = 5

    public init(log: TastingLog) {
        self.targetLog = log
    }

    private var isNameEmpty: Bool {
        viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator
                stepContent
            }
            .navigationTitle("ログの修正 (\(viewModel.currentStep)/\(totalSteps))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { editToolbarContent }
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

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(viewModel.currentStep >= step ? Color.accentColor : Color(.systemGray3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 1:
            AddStep1GeneralInfoView(viewModel: viewModel, focusedField: $focusedField) { message in
                presentAlert(message)
            }
        case 2:
            AddStep2AppearanceView(viewModel: viewModel)
        case 3:
            AddStep3AromaView(viewModel: viewModel)
        case 4:
            AddStep4TasteView(viewModel: viewModel)
        case 5:
            AddStep5FinalizeView(viewModel: viewModel)
        default:
            AddStep1GeneralInfoView(viewModel: viewModel, focusedField: $focusedField) { message in
                presentAlert(message)
            }
        }
    }

    @ToolbarContentBuilder
    private var editToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if viewModel.currentStep == 1 {
                Button("キャンセル") {
                    dismiss()
                }
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
            if viewModel.currentStep < totalSteps {
                Button("次へ") {
                    advanceStepIfValid()
                }
                .fontWeight(.semibold)
            } else {
                Button("更新") {
                    saveChangesIfValid()
                }
                .fontWeight(.bold)
            }
        }
    }

    private func advanceStepIfValid() {
        guard !isNameEmpty else {
            presentAlert("銘柄名は必須項目です。")
            return
        }
        viewModel.currentStep += 1
    }

    private func saveChangesIfValid() {
        guard !isNameEmpty else {
            presentAlert("銘柄名は必須項目です。")
            return
        }
        do {
            try viewModel.update(modelContext: modelContext)
            dismiss()
        } catch {
            presentAlert("更新に失敗しました: \(error.localizedDescription)")
        }
    }

    private func presentAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    let sample = PreviewSampleData.makeSampleBundle()
    return EditLogFlowView(log: sample.wineLog)
        .modelContainer(PreviewSampleData.container)
}
