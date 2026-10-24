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
    
    // スロット選択シート用 State
    @State private var pendingTargetLocation: StorageLocation? = nil
    @State private var isInventoryOnlyFlow: Bool = false
    @State private var isShowingSlotSelectionSheet: Bool = false

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
                // 左上：ステップ1のときは「在庫へ」メニューボタン、ステップ2以降は「戻る」
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep == 1 {
                        Menu {
                            Text("保管場所を選択して保存").font(.caption)
                            Divider()
                            if locations.isEmpty {
                                Button("未設定 (デフォルト)") {
                                    handleLocationSelection(locationName: "未設定", isInventoryOnly: true)
                                }
                            } else {
                                ForEach(locations, id: \.name) { loc in
                                    Button(loc.name) {
                                        handleLocationSelection(locationName: loc.name, isInventoryOnly: true)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("在庫へ")
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(isNameEmpty ? .gray : .accentColor)
                        }
                        .disabled(isNameEmpty)
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
                                Text("戻る")
                            }
                        }
                    }
                }

                // 右上：ステップ1〜4は「次へ」、ステップ5は「保存」
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
                            if isNameEmpty {
                                alertMessage = "銘柄名は必須項目です。"
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
            .confirmationDialog("ボトルの扱いを選択", isPresented: $isShowingSaveOptions, titleVisibility: .visible) {
                Button("飲みきった（ログのみ記録・在庫なし）") {
                    executeFullSave(storageLocation: "未設定", stockQuantity: 0, targetTab: 0)
                }
                
                if locations.isEmpty {
                    Button("未設定の場所にストック") {
                        executeFullSave(storageLocation: "未設定", stockQuantity: 1, targetTab: 3)
                    }
                } else {
                    ForEach(locations, id: \.name) { loc in
                        Button("\(loc.name)にストック") {
                            handleLocationSelection(locationName: loc.name, isInventoryOnly: false)
                        }
                    }
                }

                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("このテイスティング記録とともに、在庫をどのように登録しますか？")
            }
            // 棚・スロット位置選択シート
            .sheet(isPresented: $isShowingSlotSelectionSheet) {
                if let targetLoc = pendingTargetLocation {
                    LocationSlotSelectionSheet(location: targetLoc, viewModel: viewModel) {
                        // 選択完了時の保存実行
                        if isInventoryOnlyFlow {
                            saveToInventory(locationName: targetLoc.name)
                        } else {
                            executeFullSave(storageLocation: targetLoc.name, stockQuantity: 1, targetTab: 3)
                        }
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
                if viewModel.editingLog == nil && viewModel.sourceItem == nil {
                    if viewModel.name.isEmpty && viewModel.selectedImageData == nil {
                        viewModel.reset()
                    }
                }
            }
        }
    }

    /// 保管場所選択時のハンドラ（グリッド有効かつ設定があればスロット選択画面を挟む）
    private func handleLocationSelection(locationName: String, isInventoryOnly: Bool) {
        if isNameEmpty {
            alertMessage = "銘柄名は必須項目です。"
            showAlert = true
            return
        }
        
        viewModel.storageLocation = locationName
        viewModel.selectedGridRow = nil
        viewModel.selectedGridColumn = nil

        if let foundLoc = locations.first(where: { $0.name == locationName }), foundLoc.isGridEnabled {
            pendingTargetLocation = foundLoc
            isInventoryOnlyFlow = isInventoryOnly
            isShowingSlotSelectionSheet = true
        } else {
            if isInventoryOnly {
                saveToInventory(locationName: locationName)
            } else {
                executeFullSave(storageLocation: locationName, stockQuantity: 1, targetTab: 3)
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
            alertMessage = "在庫の保存に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }

    /// ステップ5から「テイスティングログ＋ボトルの扱いを選んで保存」する処理
    private func executeFullSave(storageLocation: String, stockQuantity: Int, targetTab: Int) {
        do {
            viewModel.storageLocation = storageLocation
            viewModel.stockQuantityString = "\(stockQuantity)"
            
            try viewModel.saveWithStock(modelContext: modelContext, stockQuantity: stockQuantity)
            
            AppState.shared.selectedTab = targetTab
        } catch {
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: config)
    
    // プレビュー用にデフォルトの保管場所を挿入
    container.mainContext.insert(StorageLocation(name: "ワインセラー", type: .cellar))
    container.mainContext.insert(StorageLocation(name: "冷蔵庫", type: .refrigerator))

    return AddFlowView()
        .modelContainer(container)
}
