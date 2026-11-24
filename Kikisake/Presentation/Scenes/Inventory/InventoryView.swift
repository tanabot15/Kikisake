import SwiftUI
import SwiftData

enum CellarDisplayMode: String, CaseIterable, Identifiable {
    case list
    case grid
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .list:
            return String(localized: "リスト")
        case .grid:
            return String(localized: "グリッド")
        }
    }
}

/// Accordion-expandable inventory management view for storage locations and bottles.
public struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    @Query(sort: \BeverageItem.createdAt, order: .reverse) private var items: [BeverageItem]

    @State private var viewModel = InventoryViewModel()
    @State private var showAddLocationSheet: Bool = false
    @State private var showPaywall: Bool = false

    @State private var isEditingLocations: Bool = false
    @State private var renamingLocation: StorageLocation? = nil
    @State private var draftLocationName: String = ""
    @State private var deletingLocation: StorageLocation? = nil
    @State private var isShowingDeleteLocationAlert: Bool = false

    @State private var expandedLocationName: String? = nil
    @State private var displayModes: [String: CellarDisplayMode] = [:]
    @State private var editingLocationNames: Set<String> = []

    @State private var resizingLocation: StorageLocation? = nil
    @State private var tempRows: Int = 4
    @State private var tempColumns: Int = 6

    @State private var selectedItemForAction: BeverageItem? = nil
    @State private var isShowingActionSheet: Bool = false

    @State private var itemToNavigate: BeverageItem? = nil
    @State private var isNavigatingToDetail: Bool = false
    @State private var targetItemForMove: BeverageItem? = nil
    @State private var isShowingMoveDialog: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !AppState.shared.isProVersion {
                    ConditionalAdMobBannerView()
                        .frame(height: 50)
                        .background(Color(.systemBackground))
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "保管場所一覧"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        if locations.isEmpty {
                            ContentUnavailableView(
                                String(localized: "保管場所がありません"),
                                systemImage: "cabinet",
                                description: Text(String(localized: "右上の「＋」ボタンから保管場所を追加してください。"))
                            )
                            .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(Array(locations.enumerated()), id: \.element.id) { index, loc in
                                    InventoryLocationCardView(
                                        location: loc,
                                        items: items,
                                        modelContext: modelContext,
                                        viewModel: viewModel,
                                        isExpanded: expandedLocationName == loc.name,
                                        isEditingLocations: isEditingLocations,
                                        canMoveUp: index > 0,
                                        canMoveDown: index < locations.count - 1,
                                        displayMode: displayModeBinding(for: loc),
                                        isEditingList: editingBinding(for: loc.name),
                                        onToggleExpand: {
                                            withAnimation(.snappy) {
                                                expandedLocationName = (expandedLocationName == loc.name) ? nil : loc.name
                                            }
                                        },
                                        onRequestRename: { targetLoc in
                                            draftLocationName = targetLoc.name
                                            renamingLocation = targetLoc
                                        },
                                        onRequestDelete: { targetLoc in
                                            deletingLocation = targetLoc
                                            isShowingDeleteLocationAlert = true
                                        },
                                        onMoveLocation: { targetLoc, direction in
                                            withAnimation(.snappy) {
                                                viewModel.moveLocation(
                                                    targetLoc,
                                                    direction: direction,
                                                    in: locations,
                                                    modelContext: modelContext
                                                )
                                            }
                                        },
                                        onDropLocation: { sourceID, destinationID in
                                            withAnimation(.snappy) {
                                                viewModel.moveLocation(
                                                    from: sourceID,
                                                    to: destinationID,
                                                    in: locations,
                                                    modelContext: modelContext
                                                )
                                            }
                                        },
                                        onRequestResize: { targetLoc in
                                            tempRows = targetLoc.gridRows
                                            tempColumns = targetLoc.gridColumns
                                            resizingLocation = targetLoc
                                        },
                                        onSelectItem: { item in
                                            selectedItemForAction = item
                                            isShowingActionSheet = true
                                        },
                                        onError: { message in
                                            errorMessage = message
                                            showErrorAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "在庫管理"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isNavigatingToDetail) {
                if let item = itemToNavigate {
                    detailDestination(for: item)
                }
            }
            .toolbar {
                if !locations.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation(.snappy) {
                                isEditingLocations.toggle()
                                if isEditingLocations {
                                    expandedLocationName = nil
                                }
                            }
                        } label: {
                            Text(isEditingLocations ? Image(systemName: "checkmark.circle") : Image(systemName: "square.and.pencil"))
                                .fontWeight(isEditingLocations ? .bold : .regular)
                        }
                        .tint(isEditingLocations ? Color.accentColor : .primary)
                    }
                }

                if !isEditingLocations {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if !AppState.shared.isProVersion && locations.count >= 3 {
                                showPaywall = true
                            } else {
                                showAddLocationSheet = true
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .tint(.primary)
                    }
                }
            }
            .alert(
                String(localized: "保管場所の名称変更"),
                isPresented: Binding(
                    get: { renamingLocation != nil },
                    set: { if !$0 { renamingLocation = nil } }
                )
            ) {
                TextField(String(localized: "新しい保管場所名"), text: $draftLocationName)
                Button(String(localized: "キャンセル"), role: .cancel) {
                    renamingLocation = nil
                }
                Button(String(localized: "保存")) {
                    if let target = renamingLocation {
                        let oldName = target.name
                        viewModel.renameLocation(
                            target,
                            newName: draftLocationName,
                            allItems: items,
                            modelContext: modelContext
                        )
                        if expandedLocationName == oldName {
                            expandedLocationName = target.name
                        }
                    }
                    renamingLocation = nil
                }
            } message: {
                Text(String(localized: "保管場所の名称を入力してください。"))
            }
            .alert(
                String(localized: "保管場所を削除しますか？"),
                isPresented: $isShowingDeleteLocationAlert
            ) {
                Button(String(localized: "キャンセル"), role: .cancel) {
                    deletingLocation = nil
                }
                Button(String(localized: "削除"), role: .destructive) {
                    if let target = deletingLocation {
                        if expandedLocationName == target.name {
                            expandedLocationName = nil
                        }
                        viewModel.deleteLocation(target, allItems: items, modelContext: modelContext)
                    }
                    deletingLocation = nil
                }
            } message: {
                if let target = deletingLocation {
                    Text(String(format: String(localized: "「%@」を削除します。登録されているボトルの保管場所は未設定になります。"), target.name))
                }
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationSheetView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(item: $resizingLocation) { loc in
                InventoryGridResizeSheet(
                    location: loc,
                    rows: $tempRows,
                    columns: $tempColumns,
                    onSave: { newRows, newColumns in
                        viewModel.updateGridSize(
                            for: loc,
                            newRows: newRows,
                            newColumns: newColumns,
                            allItems: items,
                            modelContext: modelContext
                        )
                        resizingLocation = nil
                    },
                    onCancel: {
                        resizingLocation = nil
                    }
                )
            }
            .confirmationDialog(
                selectedItemForAction?.name ?? String(localized: "ボトルの操作"),
                isPresented: $isShowingActionSheet,
                titleVisibility: .visible
            ) {
                actionSheetButtons
            } message: {
                Text(String(localized: "このボトルに対して行う操作を選択してください。"))
            }
            .onChange(of: isShowingActionSheet) { _, isShowing in
                if !isShowing {
                    selectedItemForAction = nil
                }
            }
            .confirmationDialog(String(localized: "移動先の選択"), isPresented: $isShowingMoveDialog, titleVisibility: .visible) {
                moveDialogButtons
            } message: {
                if let item = targetItemForMove {
                    Text(String(format: String(localized: "「%@」の移動先を選択してください。"), item.name))
                }
            }
            .onChange(of: isShowingMoveDialog) { _, isShowing in
                if !isShowing {
                    targetItemForMove = nil
                }
            }
            .alert(String(localized: "エラー"), isPresented: $showErrorAlert) {
                Button(role: .cancel) {
                    errorMessage = ""
                } label: {
                    Text(String(localized: "OK"))
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Bindings & Destinations

    private func displayModeBinding(for location: StorageLocation) -> Binding<CellarDisplayMode> {
        Binding(
            get: {
                displayModes[location.name] ?? ((location.type == .cellar && location.isGridEnabled) ? .grid : .list)
            },
            set: { newMode in
                displayModes[location.name] = newMode
            }
        )
    }

    private func editingBinding(for locationName: String) -> Binding<Bool> {
        Binding(
            get: { editingLocationNames.contains(locationName) },
            set: { isEditing in
                if isEditing {
                    editingLocationNames.insert(locationName)
                } else {
                    editingLocationNames.remove(locationName)
                }
            }
        )
    }

    @ViewBuilder
    private func detailDestination(for item: BeverageItem) -> some View {
        if let latestLog = item.tastingLogs?.sorted(by: { $0.date > $1.date }).first {
            LogDetailView(log: latestLog)
        } else {
            let fallbackLog = TastingLog(
                date: item.createdAt,
                rating: 0.0,
                appearanceNotes: "",
                appearanceColorHex: "#802633",
                aromaTags: [],
                memo: String(localized: "基本情報のみ登録されています。"),
                item: item
            )
            LogDetailView(log: fallbackLog)
        }
    }

    @ViewBuilder
    private var actionSheetButtons: some View {
        if let item = selectedItemForAction {
            Button(String(localized: "詳細を確認する")) {
                itemToNavigate = item
                isNavigatingToDetail = true
            }

            let hasEvaluatedLog = item.tastingLogs?.contains(where: { $0.isEvaluated }) ?? false

            if hasEvaluatedLog {
                Button(String(localized: "今日飲む")) {
                    do {
                        try viewModel.recordDrinkingFromExistingLog(item: item, modelContext: modelContext)
                    } catch {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            } else {
                Button(String(localized: "ボトルを開ける")) {
                    do {
                        try viewModel.consumeBottle(item: item)
                        AppState.shared.openingItem = item
                    } catch {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }

            Button(String(localized: "保存場所を移動する")) {
                targetItemForMove = item
                isShowingMoveDialog = true
            }

            Button(String(localized: "飲み切った"), role: .destructive) {
                viewModel.markItemAsConsumed(item, modelContext: modelContext)
            }
        }

        Button(String(localized: "キャンセル"), role: .cancel) {
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
        Button(String(localized: "キャンセル"), role: .cancel) {
            targetItemForMove = nil
        }
    }
}

#Preview {
    InventoryView()
        .modelContainer(PreviewSampleData.container)
}
