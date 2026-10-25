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

    @State private var targetItemForMove: BeverageItem? = nil
    @State private var isShowingMoveDialog: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ConditionalAdMobBannerView()
                        .frame(height: 50)
                        .background(Color(.systemBackground))
                    
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
                        VStack(spacing: 14) {
                            ForEach(targetLocations, id: \.id) { loc in
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
                                        VStack(spacing: 12) {
                                            Divider()
                                                .padding(.horizontal)

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
                                                .padding(.horizontal)
                                            }
                                            
                                            // --- 表示モードに応じたビューの出し分け ---
                                            if currentMode == .grid && loc.isGridEnabled {
                                                // 1. グリッド表示
                                                CellarGridView(location: loc, items: displayItems) { row, col, item in
                                                    if let item = item {
                                                        targetItemForMove = item
                                                        isShowingMoveDialog = true
                                                    } else {
                                                        print("Empty slot tapped at Row: \(row), Col: \(col)")
                                                    }
                                                }
                                                .padding(.horizontal, 12)

                                                // ✨ 2. グリッド表示時でも、棚に位置が割り振られていない「未配置」のアイテムが存在する場合は下部にリスト表示する
                                                let unassignedItems = displayItems.filter { $0.gridRow == nil || $0.gridColumn == nil }
                                                if !unassignedItems.isEmpty {
                                                    VStack(alignment: .leading, spacing: 8) {
                                                        Text("棚の外（未配置の在庫）")
                                                            .font(.subheadline)
                                                            .fontWeight(.bold)
                                                            .foregroundStyle(.secondary)
                                                            .padding(.horizontal, 16)
                                                            .padding(.top, 4)

                                                        ForEach(unassignedItems) { item in
                                                            renderItemRow(item: item)
                                                        }
                                                    }
                                                }

                                            } else {
                                                // リスト表示
                                                if displayItems.isEmpty {
                                                    Text("条件に一致する在庫はありません")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                        .padding(.vertical, 16)
                                                } else {
                                                    ForEach(displayItems) { item in
                                                        renderItemRow(item: item)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.bottom, 12)
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("在庫管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                            Label("場所を追加", systemImage: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationSheetView()
            }
            .sheet(isPresented: $isShowingFilterSheet) {
                InventoryFilterSheet(viewModel: viewModel, allItems: items)
            }
            .confirmationDialog("移動先の選択", isPresented: $isShowingMoveDialog, titleVisibility: .visible) {
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
            } message: {
                if let item = targetItemForMove {
                    Text("「\(item.name)」の移動先を選択してください。")
                }
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

    /// 各アイテムのリスト行を描画するヘルパー
    @ViewBuilder
    private func renderItemRow(item: BeverageItem) -> some View {
        let averageRating: Double? = {
            guard let logs = item.tastingLogs, !logs.isEmpty else { return nil }
            let total = logs.reduce(0.0) { $0 + $1.rating }
            return total / Double(logs.count)
        }()

        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let latestLog = item.tastingLogs?.sorted(by: { $0.date > $1.date }).first {
                    NavigationLink(destination: LogDetailView(log: latestLog)) {
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
                } else {
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
            }

            // アクションエリア（移動メニュー / ボトルを開ける / 削除）
            HStack {
                Menu {
                    Text("移動先の保管場所を選択").font(.caption)
                    Divider()
                    ForEach(locations, id: \.name) { otherLoc in
                        if otherLoc.name != item.storageLocation {
                            Button {
                                viewModel.moveItem(item, to: otherLoc.name, modelContext: modelContext)
                            } label: {
                                Label(otherLoc.name, systemImage: otherLoc.type.defaultIconName)
                            }
                        }
                    }
                } label: {
                    Text("保管場所を移動")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
                .tint(.green)

                Spacer()

                if item.stockQuantity <= 0 {
                    Button(role: .destructive) {
                        viewModel.deleteItem(item, modelContext: modelContext)
                    } label: {
                        Text("飲みきった")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }

                Button {
                    do {
                        try viewModel.consumeBottle(item: item)
                        AppState.shared.openingItem = item
                    } catch {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                } label: {
                    Text("ボトルを開ける")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .disabled(item.stockQuantity <= 0)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal, 12)
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
