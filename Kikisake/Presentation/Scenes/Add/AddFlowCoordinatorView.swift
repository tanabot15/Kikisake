//
//  AddFlowView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// 5-step tasting log and inventory registration flow coordinator.
public struct AddFlowCoordinatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]

    @Bindable private var viewModel = AppState.shared.addFlowViewModel

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isShowingSaveOptions: Bool = false
    @State private var isShowingInventoryMenu: Bool = false
    @State private var isShowingDraftRestoreAlert: Bool = false

    @State private var pendingTargetLocation: StorageLocation? = nil
    @State private var isInventoryOnlyFlow: Bool = false

    @FocusState private var focusedField: GeneralInfoField?

    private var isNameEmpty: Bool {
        viewModel.currentStep == 1 && viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicatorView
                stepContentView
            }
            .navigationTitle(String(format: String(localized: "追加 (%d/5)"), viewModel.currentStep))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingToolbarItem
                trailingToolbarItem
            }
            .confirmationDialog(String(localized: "ボトルの扱いを選択"), isPresented: $isShowingSaveOptions, titleVisibility: .visible) {
                saveOptionsDialogButtons
            } message: {
                Text(String(localized: "このテイスティング記録とともに、在庫をどのように登録しますか？"))
            }
            .confirmationDialog(String(localized: "在庫の保管場所を選択"), isPresented: $isShowingInventoryMenu, titleVisibility: .visible) {
                inventoryLocationDialogButtons
            } message: {
                Text(String(localized: "未開栓のボトルとして登録する保管場所を選択してください。"))
            }
            .sheet(item: $pendingTargetLocation) { targetLoc in
                LocationSlotSelectionSheet(location: targetLoc, viewModel: viewModel) {
                    if isInventoryOnlyFlow {
                        saveToInventory(locationName: targetLoc.name)
                    } else {
                        executeFullSave(storageLocation: targetLoc.name, targetTab: 3)
                    }
                }
            }
            .alert(String(localized: "確認"), isPresented: $showAlert) {
                Button(String(localized: "OK"), role: .cancel) {
                    if isNameEmpty {
                        focusedField = .name
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .alert(String(localized: "前回の続きから入力しますか？"), isPresented: $isShowingDraftRestoreAlert) {
                Button(String(localized: "続きから復元する")) {
                    viewModel.restoreDraft()
                }
                Button(String(localized: "破棄して新しく始める"), role: .destructive) {
                    viewModel.clearDraft()
                    viewModel.reset()
                }
            } message: {
                Text(String(localized: "入力途中の下書きデータが保存されています。"))
            }
            .onAppear {
                if !viewModel.isOpeningExistingItem && viewModel.editingLog == nil && viewModel.hasDraft {
                    isShowingDraftRestoreAlert = true
                }
            }
        }
    }

    // MARK: - Subviews

    private var stepIndicatorView: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { step in
                Circle()
                    .fill(viewModel.currentStep >= step ? Color.accentColor : Color(.systemGray3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var stepContentView: some View {
        switch viewModel.currentStep {
        case 1:
            VStack(spacing: 0) {
                inventoryQuickActionBanner
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                GeneralInfoStepView(viewModel: viewModel, focusedField: $focusedField) { message in
                    presentAlert(message)
                }
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
            GeneralInfoStepView(viewModel: viewModel, focusedField: $focusedField) { message in
                presentAlert(message)
            }
        }
    }

    private var inventoryQuickActionBanner: some View {
        Button {
            guard validateNameNotEmpty() else { return }
            isShowingInventoryMenu = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "refrigerator")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "未開栓として在庫に登録する"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(String(localized: "テイスティングせずにセラーへストック"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .opacity(isNameEmpty ? 0.6 : 1.0)
    }

    // MARK: - Toolbar & Dialog Actions

    @ToolbarContentBuilder
    private var leadingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if viewModel.currentStep == 1 {
                Button(String(localized: "キャンセル")) {
                    viewModel.reset()
                    AppState.shared.selectedTab = 0
                }
                .foregroundStyle(.primary)
            } else {
                Button {
                    if viewModel.currentStep == 2 && viewModel.isOpeningExistingItem {
                        viewModel.reset()
                        AppState.shared.selectedTab = 3
                    } else {
                        viewModel.currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(String(localized: "戻る"))
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var trailingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.currentStep < 5 {
                Button(String(localized: "次へ")) {
                    guard validateNameNotEmpty() else { return }
                    viewModel.currentStep += 1
                }
                .fontWeight(.semibold)
                .foregroundStyle(isNameEmpty ? .gray : Color.accentColor)
            } else {
                Button(String(localized: "保存")) {
                    guard validateNameNotEmpty() else { return }
                    isShowingSaveOptions = true
                }
                .fontWeight(.bold)
            }
        }
    }

    @ViewBuilder
    private var saveOptionsDialogButtons: some View {
        Button(String(localized: "飲みきった（ログのみ記録・在庫なし）")) {
            executeFullSave(storageLocation: "", targetTab: 0)
        }

        if locations.isEmpty {
            Button(String(localized: "未設定の場所にストック")) {
                executeFullSave(storageLocation: String(localized: "未設定"), targetTab: 3)
            }
        } else {
            ForEach(locations, id: \.name) { loc in
                Button(String(format: String(localized: "%@にストック"), loc.name)) {
                    handleLocationSelection(locationName: loc.name, isInventoryOnly: false)
                }
            }
        }

        Button(String(localized: "キャンセル"), role: .cancel) {}
    }

    @ViewBuilder
    private var inventoryLocationDialogButtons: some View {
        if locations.isEmpty {
            Button(String(localized: "未設定 (デフォルト)")) {
                handleLocationSelection(locationName: String(localized: "未設定"), isInventoryOnly: true)
            }
        } else {
            ForEach(locations, id: \.name) { loc in
                Button(loc.name) {
                    handleLocationSelection(locationName: loc.name, isInventoryOnly: true)
                }
            }
        }
        Button(String(localized: "キャンセル"), role: .cancel) {}
    }

    @discardableResult
    private func validateNameNotEmpty() -> Bool {
        if isNameEmpty {
            presentAlert(String(localized: "銘柄名は必須項目です。"))
            return false
        }
        return true
    }

    private func presentAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }

    private func handleLocationSelection(locationName: String, isInventoryOnly: Bool) {
        guard validateNameNotEmpty() else { return }

        viewModel.storageLocation = locationName
        viewModel.selectedGridRow = nil
        viewModel.selectedGridColumn = nil
        isInventoryOnlyFlow = isInventoryOnly

        if let foundLoc = locations.first(where: { $0.name == locationName }), foundLoc.isGridEnabled {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                pendingTargetLocation = foundLoc
            }
        } else if isInventoryOnly {
            saveToInventory(locationName: locationName)
        } else {
            executeFullSave(storageLocation: locationName, targetTab: 3)
        }
    }

    private func saveToInventory(locationName: String, targetTab: Int = 0) {
        do {
            viewModel.storageLocation = locationName
            try viewModel.saveAsInventoryOnly(modelContext: modelContext)
            AppState.shared.selectedTab = targetTab
        } catch {
            presentAlert(String(format: String(localized: "在庫の保存に失敗しました: %@"), error.localizedDescription))
        }
    }

    private func executeFullSave(storageLocation: String, targetTab: Int) {
        do {
            viewModel.storageLocation = storageLocation
            try viewModel.saveWithStock(modelContext: modelContext)
            AppState.shared.selectedTab = targetTab
        } catch {
            presentAlert(String(format: String(localized: "保存に失敗しました: %@"), error.localizedDescription))
        }
    }
}

#Preview {
    AddFlowViewPreviewHost()
}

private struct AddFlowViewPreviewHost: View {
    private let container: ModelContainer

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(
            for: StorageLocation.self,
            BeverageItem.self,
            TastingLog.self,
            configurations: config
        )
        modelContainer.mainContext.insert(StorageLocation(name: "ワインセラー", type: .cellar))
        modelContainer.mainContext.insert(StorageLocation(name: "冷蔵庫", type: .refrigerator))
        self.container = modelContainer
    }

    var body: some View {
        AddFlowCoordinatorView()
            .modelContainer(container)
    }
}
