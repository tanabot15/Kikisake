//  AddFlowView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// [Tab 3] 追加・登録フロー統括ビュー（ツールバーナビゲーション版）
public struct AddFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    
    @Bindable private var viewModel = AppState.shared.addFlowViewModel
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isShowingSaveOptions: Bool = false
    @State private var isShowingInventoryMenu: Bool = false
    
    // スロット選択シート用 State
    @State private var pendingTargetLocation: StorageLocation? = nil
    @State private var isInventoryOnlyFlow: Bool = false

    @FocusState private var focusedField: GeneralInfoField?

    private var isNameEmpty: Bool {
        viewModel.currentStep == 1 && viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
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

                // ステップごとの画面切り替え
                Group {
                    switch viewModel.currentStep {
                    case 1:
                        VStack(spacing: 0) {
                            // ✨ ステップ1の最上部に「在庫へ直接登録する」洗練されたクイックアクションバナーを配置
                            inventoryQuickActionBanner
                                .padding(.horizontal)
                                .padding(.top, 4)
                                .padding(.bottom, 8)

                            GeneralInfoStepView(
                                viewModel: viewModel,
                                focusedField: $focusedField
                            ) { message in
                                alertMessage = message
                                showAlert = true
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
            .navigationTitle(String(format: String(localized: "追加 (%d/5)"), viewModel.currentStep))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 左上：ステップ1のときは「キャンセル」、ステップ2以降は「戻る」
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep == 1 {
                        Button(String(localized: "キャンセル")) {
                            viewModel.reset()
                            AppState.shared.selectedTab = 0 // ログ一覧などへ戻る
                        }
                        .foregroundColor(.primary)
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

                // 右上：ステップ1〜4は「次へ」、ステップ5は「保存」
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.currentStep < 5 {
                        Button(String(localized: "次へ")) {
                            if isNameEmpty {
                                alertMessage = String(localized: "銘柄名は必須項目です。")
                                showAlert = true
                                return
                            }
                            viewModel.currentStep += 1
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(isNameEmpty ? .gray : .accentColor)
                    } else {
                        Button(String(localized: "保存")) {
                            if isNameEmpty {
                                alertMessage = String(localized: "銘柄名は必須項目です。")
                                showAlert = true
                                return
                            }
                            isShowingSaveOptions = true
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            // テイスティングログ書き切り後の保存先選択ダイアログ
            .confirmationDialog(String(localized: "ボトルの扱いを選択"), isPresented: $isShowingSaveOptions, titleVisibility: .visible) {
                Button(String(localized: "飲みきった（ログのみ記録・在庫なし）")) {
                    executeFullSave(storageLocation: String(localized: "未設定"), targetTab: 0)
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
            } message: {
                Text(String(localized: "このテイスティング記録とともに、在庫をどのように登録しますか？"))
            }
            // 在庫へ直接登録するときの保管場所選択メニュー（クイックアクション用）
            .confirmationDialog(String(localized: "在庫の保管場所を選択"), isPresented: $isShowingInventoryMenu, titleVisibility: .visible) {
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
            } message: {
                Text(String(localized: "未開栓のボトルとして登録する保管場所を選択してください。"))
            }
            // 棚・スロット位置選択シート
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
        }
    }

    /// ✨ ステップ1上部に配置する洗練された「在庫へ直接登録」バナー
    @ViewBuilder
    private var inventoryQuickActionBanner: some View {
        Button {
            if isNameEmpty {
                alertMessage = String(localized: "銘柄名は必須項目です。")
                showAlert = true
                return
            }
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

    /// 保管場所選択時のハンドラ
    private func handleLocationSelection(locationName: String, isInventoryOnly: Bool) {
        if isNameEmpty {
            alertMessage = String(localized: "銘柄名は必須項目です。")
            showAlert = true
            return
        }
        
        viewModel.storageLocation = locationName
        viewModel.selectedGridRow = nil
        viewModel.selectedGridColumn = nil
        isInventoryOnlyFlow = isInventoryOnly

        if let foundLoc = locations.first(where: { $0.name == locationName }), foundLoc.isGridEnabled {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                pendingTargetLocation = foundLoc
            }
        } else {
            if isInventoryOnly {
                saveToInventory(locationName: locationName)
            } else {
                executeFullSave(storageLocation: locationName, targetTab: 3)
            }
        }
    }

    /// ステップ1から「未開栓のまま在庫として保存」する処理
    private func saveToInventory(locationName: String) {
        do {
            viewModel.storageLocation = locationName
            try viewModel.saveAsInventoryOnly(modelContext: modelContext)
            AppState.shared.selectedTab = 3
        } catch {
            alertMessage = String(format: String(localized: "在庫の保存に失敗しました: %@"), error.localizedDescription)
            showAlert = true
        }
    }

    /// ステップ5から「テイスティングログ＋ボトルの扱いを選んで保存」する処理
    private func executeFullSave(storageLocation: String, targetTab: Int) {
        do {
            viewModel.storageLocation = storageLocation
            try viewModel.saveWithStock(modelContext: modelContext)
            AppState.shared.selectedTab = targetTab
        } catch {
            alertMessage = String(format: String(localized: "保存に失敗しました: %@"), error.localizedDescription)
            showAlert = true
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: config)
    
    container.mainContext.insert(StorageLocation(name: "ワインセラー", type: .cellar))
    container.mainContext.insert(StorageLocation(name: "冷蔵庫", type: .refrigerator))

    return AddFlowView()
        .modelContainer(container)
}
