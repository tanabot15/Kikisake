//  InventoryView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// 表示モードの定義
private enum CellarDisplayMode: String, CaseIterable, Identifiable {
    case list = "リスト"
    case grid = "グリッド"
    var id: String { rawValue }
}

/// [Tab 4] ユーザーカスタム可能なアコーディオン展開式・在庫管理画面
public struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    @Query(sort: \BeverageItem.createdAt, order: .reverse) private var items: [BeverageItem]
    
    @State private var viewModel = InventoryViewModel()
    @State private var showAddLocationSheet: Bool = false
    @State private var isShowingFilterSheet: Bool = false
    
    @State private var expandedLocationName: String? = nil
    @State private var displayModes: [String: CellarDisplayMode] = [:]

    // 保管場所ごとの個別編集モード（並び替え・削除用）
    @State private var editingLocationNames: Set<String> = []
    
    // ✨ グリッドサイズ変更用の状態管理
    @State private var isShowingGridResizeSheet: Bool = false
    @State private var resizingLocation: StorageLocation? = nil
    @State private var tempRows: Int = 4
    @State private var tempColumns: Int = 6

    // アイテムタップ時のアクション制御用 State
    @State private var selectedItemForAction: BeverageItem? = nil
    @State private var isShowingActionSheet: Bool = false

    // 各種遷移・ポップアップ制御用 State
    @State private var itemToNavigate: BeverageItem? = nil
    @State private var isNavigatingToDetail: Bool = false
    @State private var targetItemForMove: BeverageItem? = nil
    @State private var isShowingMoveDialog: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    public var body: some View {
        NavigationStack {
            VStack {
                ConditionalAdMobBannerView()
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("保管場所一覧")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        let targetLocations = viewModel.filteredLocations(locations)
                        
                        if locations.isEmpty || targetLocations.isEmpty {
                            ContentUnavailableView(
                                "該当する保管場所がありません",
                                systemImage: "cabinet",
                                description: Text(viewModel.hasActiveFilters ? "フィルター条件を変更してみてください。" : "右上の「＋」ボタンから保管場所を追加してください。")
                            )
                            .padding(.top, 40)
                        } else {
                            locationListContent(targetLocations: targetLocations)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("在庫管理")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isNavigatingToDetail) {
                if let item = itemToNavigate {
                    let latestLog = item.tastingLogs?.sorted(by: { $0.date > $1.date }).first
                    if let log = latestLog {
                        LogDetailView(log: log)
                    } else {
                        let dummyLog = TastingLog(
                            date: item.createdAt,
                            rating: 0.0,
                            appearanceNotes: "",
                            appearanceColorHex: "#802633",
                            aromaTags: [],
                            memo: "基本情報のみ登録されています。",
                            item: item
                        )
                        LogDetailView(log: dummyLog)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    toolbarContent
                }
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationSheetView()
            }
            .sheet(isPresented: $isShowingFilterSheet) {
                InventoryFilterSheet(viewModel: viewModel, allItems: items)
            }
            // ✨ sheet(item:) を利用して、データが存在するときのみ確実に描画・初期化を行う
            .sheet(item: $resizingLocation) { loc in
                NavigationStack {
                    Form {
                        Section("セラーの構造設定") {
                            Stepper("段数（行）: \(tempRows)段", value: $tempRows, in: 1...10)
                            Stepper("1段あたりの本数（列）: \(tempColumns)本", value: $tempColumns, in: 1...12)
                        }
                        
                        Section {
                            Text("※縮小した際、新しいグリッド範囲外（はみ出し部分）に配置されていたボトルは、自動的に「棚の外（未配置）」に移動されます。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .navigationTitle("\(loc.name)のサイズ変更")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("キャンセル") {
                                resizingLocation = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("保存") {
                                viewModel.updateGridSize(for: loc, newRows: tempRows, newColumns: tempColumns, allItems: items, modelContext: modelContext)
                                resizingLocation = nil
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .confirmationDialog(
                selectedItemForAction?.name ?? "ボトルの操作",
                isPresented: $isShowingActionSheet,
                titleVisibility: .visible
            ) {
                actionSheetButtons
            } message: {
                Text("このボトルに対して行う操作を選択してください。")
            }
            .confirmationDialog("移動先の選択", isPresented: $isShowingMoveDialog, titleVisibility: .visible) {
                moveDialogButtons
            } message: {
                moveDialogMessage
            }
            .alert("エラー", isPresented: $showErrorAlert) {
                Button(role: .cancel) {
                    errorMessage = ""
                } label: {
                    Text("OK")
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Subviews & Builders

    @ViewBuilder
    private func locationListContent(targetLocations: [StorageLocation]) -> some View {
        VStack(spacing: 14) {
            ForEach(targetLocations, id: \.id) { loc in
                locationCardView(for: loc)
            }
        }
    }

    @ViewBuilder
    private func locationCardView(for loc: StorageLocation) -> some View {
        let isExpanded = (expandedLocationName == loc.name)
        let summaryList = viewModel.categorySummaryList(for: loc.name, in: items)
        let displayItems = viewModel.filteredItems(items, for: loc.name)
        
        let currentMode: CellarDisplayMode = {
            if let mode = displayModes[loc.name] { return mode }
            return (loc.type == .cellar && loc.isGridEnabled) ? .grid : .list
        }()

        VStack(spacing: 0) {
            Button {
                withAnimation(.snappy) {
                    if isExpanded {
                        expandedLocationName = nil
                    } else {
                        expandedLocationName = loc.name
                    }
                }
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 50, height: 50)
                        Image(systemName: loc.type.defaultIconName)
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                    }

                    Text(loc.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Spacer()
                    
                    if summaryList.isEmpty {
                        Text("在庫なし")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(summaryList, id: \.categoryName) { summary in
                                Text("\(summary.categoryName) \(summary.count)本")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                        .padding(.trailing, 4)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                expandedContentView(loc: loc, currentMode: currentMode, displayItems: displayItems)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private func expandedContentView(loc: StorageLocation, currentMode: CellarDisplayMode, displayItems: [BeverageItem]) -> some View {
        let isLocEditing = editingLocationNames.contains(loc.name)

        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal)

            // ✨ セラーごとの表示モード切り替え ＆ グリッド時の「サイズ変更」ボタン、リスト時の「並び替え」ボタン
            HStack {
                if loc.isGridEnabled {
                    Picker("表示形式", selection: Binding(
                        get: { currentMode },
                        set: { newMode in
                            displayModes[loc.name] = newMode
                        }
                    )) {
                        ForEach(CellarDisplayMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Spacer()

                // グリッド表示かつグリッド有効時：セラーの縦横サイズ変更ボタン
                if currentMode == .grid && loc.isGridEnabled {
                    Button {
                        tempRows = loc.gridRows
                        tempColumns = loc.gridColumns
                        resizingLocation = loc
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                // リスト表示かつアイテムがある場合のみ：並び替え・編集ボタン
                if currentMode == .list && !displayItems.isEmpty {
                    Button {
                        withAnimation {
                            if isLocEditing {
                                editingLocationNames.remove(loc.name)
                            } else {
                                editingLocationNames.insert(loc.name)
                            }
                        }
                    } label: {
                        Image(systemName: isLocEditing ? "checkmark.circle.fill" : "square.and.pencil")
                            .fontWeight(.semibold)
                            .foregroundColor(isLocEditing ? .accentColor : .secondary)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal)
            
            if currentMode == .grid && loc.isGridEnabled {
                CellarGridView(
                    location: loc,
                    items: displayItems,
                    modelContext: modelContext,
                    onSelectSlot: { row, col, item in
                        if let item = item {
                            selectedItemForAction = item
                            isShowingActionSheet = true
                        } else {
                            print("Empty slot tapped at Row: \(row), Col: \(col)")
                        }
                    },
                    onSelectItem: { item in
                        selectedItemForAction = item
                        isShowingActionSheet = true
                    }
                )
                .padding(.horizontal, 12)

            } else {
                if displayItems.isEmpty {
                    Text("条件に一致する在庫はありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 16)
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                            HStack(spacing: 8) {
                                if isLocEditing {
                                    Button {
                                        viewModel.deleteItem(item, modelContext: modelContext)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.red)
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                    .padding(.leading, 8)
                                }

                                renderItemRow(item: item, isLocEditing: isLocEditing)
                                
                                if isLocEditing {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                        .padding(.trailing, 8)
                                        .contentShape(Rectangle())
                                        .draggable(item.id.uuidString)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .dropDestination(for: String.self) { droppedItems, _ in
                                guard let uuidString = droppedItems.first,
                                      let uuid = UUID(uuidString: uuidString),
                                      let sourceIndex = displayItems.firstIndex(where: { $0.id == uuid }) else {
                                    return false
                                }
                                
                                var mutableItems = displayItems
                                let movedItem = mutableItems.remove(at: sourceIndex)
                                mutableItems.insert(movedItem, at: index)
                                
                                viewModel.saveNewOrder(for: mutableItems, modelContext: modelContext)
                                return true
                            }
                        }
                    }
                    .animation(.snappy, value: isLocEditing)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.bottom, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    @ViewBuilder
    private var toolbarContent: some View {
        HStack(spacing: 12) {
            Button {
                isShowingFilterSheet = true
            } label: {
                Image(systemName: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .foregroundStyle(viewModel.hasActiveFilters ? Color.accentColor : Color.primary)
            }
            .accessibilityLabel("在庫フィルター")

            Button {
                showAddLocationSheet = true
            } label: {
                Image(systemName: "plus")
            }
            .tint(.primary)
        }
    }

    @ViewBuilder
    private var actionSheetButtons: some View {
        if let item = selectedItemForAction {
            Button("詳細を確認する") {
                itemToNavigate = item
                isNavigatingToDetail = true
            }

            Button("ボトルを開ける") {
                do {
                    try viewModel.consumeBottle(item: item)
                    AppState.shared.openingItem = item
                } catch {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
            .disabled(item.stockQuantity <= 0)

            Button("保存場所を移動する") {
                targetItemForMove = item
                isShowingMoveDialog = true
            }

            Button("飲み切った", role: .destructive) {
                viewModel.deleteItem(item, modelContext: modelContext)
            }
        }

        Button("キャンセル", role: .cancel) {
            selectedItemForAction = nil
        }
    }

    @ViewBuilder
    private var moveDialogButtons: some View {
        if let item = targetItemForMove {
            ForEach(locations, id: \.name) { loc in
                if loc.name != item.storageLocation {
                    Button(loc.name) {
                        viewModel.moveItem(item, to: loc.name, modelContext: modelContext)
                        targetItemForMove = nil
                    }
                }
            }
        }
        Button("キャンセル", role: .cancel) {
            targetItemForMove = nil
        }
    }

    @ViewBuilder
    private var moveDialogMessage: some View {
        if let item = targetItemForMove {
            Text("「\(item.name)」の移動先を選択してください。")
        }
    }

    @ViewBuilder
    private func renderItemRow(item: BeverageItem, isLocEditing: Bool) -> some View {
        let averageRating: Double? = {
            let logs = item.tastingLogs ?? []
            guard !logs.isEmpty else { return nil }
            let total = logs.reduce(0.0) { $0 + $1.rating }
            return total / Double(logs.count)
        }()

        Button {
            if !isLocEditing {
                selectedItemForAction = item
                isShowingActionSheet = true
            }
        } label: {
            BeverageCardView(
                name: item.name,
                producer: item.producer,
                category: item.category,
                region: item.region,
                vintage: item.vintage,
                stockQuantity: item.stockQuantity,
                rating: averageRating,
                imageData: item.imageDatas?.first
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: config)
    
    let mainCellar = StorageLocation(
        name: "メインセラー",
        type: .cellar,
        memo: "温度14度設定",
        isGridEnabled: true,
        gridRows: 3,
        gridColumns: 4
    )
    let fridge = StorageLocation(name: "キッチン冷蔵庫", type: .refrigerator, memo: "生酒用", isGridEnabled: false)

    container.mainContext.insert(mainCellar)
    container.mainContext.insert(fridge)

    let mixedWine = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        stockQuantity: 1,
        storageLocation: "メインセラー",
        gridRow: 1,
        gridColumn: 1
    )

    let mixedSake = BeverageItem(
        name: "久保田 萬壽",
        producer: "朝日酒造",
        category: .sake,
        region: "新潟県",
        vintage: "2026/05",
        stockQuantity: 1,
        storageLocation: "メインセラー",
        gridRow: 2,
        gridColumn: 3
    )

    container.mainContext.insert(mixedWine)
    container.mainContext.insert(mixedSake)

    return InventoryView()
        .modelContainer(container)
}
