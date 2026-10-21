//  InventoryView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// [Tab 4] ユーザーカスタム可能なアコーディオン展開式・在庫管理画面
public struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    @Query(sort: \BeverageItem.createdAt, order: .reverse) private var items: [BeverageItem]
    
    @State private var viewModel = InventoryViewModel()
    @State private var showAddLocationSheet: Bool = false
    
    // アコーディオンで展開中の保管場所名を保持するState
    @State private var expandedLocationName: String? = nil

    // エラーハンドリング用のアラートState
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("保管場所一覧")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    if locations.isEmpty {
                        ContentUnavailableView(
                            "保管場所が登録されていません",
                            systemImage: "cabinet",
                            description: Text("右上の「＋」ボタンから保管場所を追加してください。")
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(locations, id: \.id) { loc in
                                let isExpanded = (expandedLocationName == loc.name)
                                let summaryList = viewModel.categorySummaryList(for: loc.name, in: items)
                                let displayItems = viewModel.filteredItems(items, for: loc.name)

                                VStack(spacing: 0) {
                                    // --- 保管場所のヘッダーカード（クリックでアコーディオン開閉） ---
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
                                            // アイコン
                                            ZStack {
                                                Circle()
                                                    .fill(Color.accentColor.opacity(0.12))
                                                    .frame(width: 50, height: 50)
                                                Image(systemName: loc.type.defaultIconName)
                                                    .font(.title3)
                                                    .foregroundStyle(Color.accentColor)
                                            }

                                            // 保管場所名
                                            Text(loc.name)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.primary)

                                            Spacer()
                                            
                                            // 酒の種類と本数を縦に並べて表示
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

                                            // 展開・折りたたみ矢印アイコン
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

                                    // --- アコーディオン展開部分（その場にボトルリストを表示） ---
                                    if isExpanded {
                                        VStack(spacing: 12) {
                                            Divider()
                                                .padding(.horizontal)
                                            
                                            if displayItems.isEmpty {
                                                Text("この保管場所に在庫はありません")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                    .padding(.vertical, 16)
                                            } else {
                                                ForEach(displayItems) { item in
                                                    VStack(alignment: .leading, spacing: 8) {
                                                        BeverageCardView(
                                                            name: item.name,
                                                            producer: item.producer,
                                                            category: item.category,
                                                            region: item.region,
                                                            vintage: item.vintage,
                                                            stockQuantity: item.stockQuantity,
                                                            rating: nil,
                                                            imageData: item.imageDatas?.first
                                                        )

                                                        // ボトルを開けるアクション ＆ 削除ボタン
                                                        HStack {
                                                            Text("残り: \(item.stockQuantity) 本")
                                                                .font(.caption)
                                                                .fontWeight(.semibold)
                                                                .foregroundStyle(item.stockQuantity > 0 ? Color.accentColor : .secondary)
                                                            
                                                            Spacer()

                                                            // 飲みきった（在庫0）場合のみ表示する削除ボタン
                                                            if item.stockQuantity <= 0 {
                                                                Button(role: .destructive) {
                                                                    viewModel.deleteItem(item, modelContext: modelContext)
                                                                } label: {
                                                                    Label("削除", systemImage: "trash")
                                                                        .font(.caption)
                                                                        .fontWeight(.semibold)
                                                                }
                                                                .buttonStyle(.bordered)
                                                                .tint(.red)
                                                            }

                                                            Button {
                                                                do {
                                                                    // 1. 在庫を1減らす消費処理を実行
                                                                    try viewModel.consumeBottle(item: item)
                                                                    
                                                                    // 2. アプリの状態として「今開けたボトル」を保持させる
                                                                    AppState.shared.openingItem = item
                                                                    
                                                                } catch {
                                                                    errorMessage = error.localizedDescription
                                                                    showErrorAlert = true
                                                                }
                                                            } label: {
                                                                Text("このボトルを開ける")
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
                                                    // ✨ スワイプによる削除機能（在庫が0の本人のみ、またはいつでもスワイプ削除可能に設定）
                                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                        if item.stockQuantity <= 0 {
                                                            Button(role: .destructive) {
                                                                viewModel.deleteItem(item, modelContext: modelContext)
                                                            } label: {
                                                                Label("削除", systemImage: "trash")
                                                            }
                                                        }
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
                    Button {
                        showAddLocationSheet = true
                    } label: {
                        Label("場所を追加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationSheetView()
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: config)
    
    // --- 1. 保管場所の登録 ---
    let mainCellar = StorageLocation(name: "メインセラー", type: .cellar, memo: "温度14度設定")
    let fridge = StorageLocation(name: "キッチン冷蔵庫", type: .refrigerator, memo: "生酒用")

    container.mainContext.insert(mainCellar)
    container.mainContext.insert(fridge)

    // --- 2. 「メインセラー」に異なる種類のお酒（ワイン・日本酒・ビール）が混在しているサンプルボトルを登録 ---
    let mixedWine = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        price: 8500,
        stockQuantity: 2,
        storageLocation: "メインセラー"
    )

    let mixedSake = BeverageItem(
        name: "久保田 萬壽",
        producer: "朝日酒造",
        category: .sake,
        region: "新潟県",
        vintage: "2026/05",
        price: 3200,
        stockQuantity: 1,
        storageLocation: "メインセラー"
    )

    let mixedBeer = BeverageItem(
        name: "Inedit Damm",
        producer: "Damm",
        category: .beer,
        region: "バルセロナ, スペイン",
        vintage: "2026",
        price: 900,
        stockQuantity: 3,
        storageLocation: "メインセラー"
    )

    // 冷蔵庫用のサンプル
    let fridgeSake = BeverageItem(
        name: "新政 No.6 R-type 生原酒",
        producer: "新政酒造",
        category: .sake,
        region: "秋田県",
        vintage: "2026/04",
        price: 2400,
        stockQuantity: 2,
        storageLocation: "キッチン冷蔵庫"
    )

    container.mainContext.insert(mixedWine)
    container.mainContext.insert(mixedSake)
    container.mainContext.insert(mixedBeer)
    container.mainContext.insert(fridgeSake)

    return InventoryView()
        .modelContainer(container)
}
