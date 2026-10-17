//
//  InventoryView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Tab 4] ユーザーカスタム可能なグラフィカル在庫管理画面
public struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    @Query(sort: \BeverageItem.createdAt, order: .reverse) private var items: [BeverageItem]
    
    @State private var viewModel = InventoryViewModel()
    @State private var showAddLocationSheet: Bool = false

    public var body: some View {
        NavigationStack {
            Group {
                if let selectedLocation = viewModel.selectedLocationFilter {
                    // --- 選択された保管場所の中身（ボトル一覧）画面 ---
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            let displayItems = viewModel.filteredItems(items, for: selectedLocation)
                            if displayItems.isEmpty {
                                ContentUnavailableView(
                                    "この保管場所に在庫はありません",
                                    systemImage: "shippingbox",
                                    description: Text("「追加」タブからボトルを登録してください。")
                                )
                                .padding(.top, 40)
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

                                        HStack {
                                            Text("残り: \(item.stockQuantity) 本")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(item.stockQuantity > 0 ? Color.accentColor : .secondary)
                                            
                                            Spacer()

                                            Button {
                                                do {
                                                    try viewModel.consumeBottle(item: item)
                                                } catch {
                                                    print("Error consuming bottle: \(error.localizedDescription)")
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
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                    .navigationTitle(selectedLocation)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                viewModel.selectedLocationFilter = nil
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("保管場所一覧")
                                }
                            }
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: "\(selectedLocation)内の銘柄名で検索")

                } else {
                    // --- 保管場所一覧画面（ホーム） ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("保管場所を選択")
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
                                        let total = viewModel.totalCount(for: loc.name, in: items)
                                        let summary = viewModel.categorySummary(for: loc.name, in: items)

                                        Button {
                                            viewModel.selectedLocationFilter = loc.name
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

                                                VStack(alignment: .leading, spacing: 6) {
                                                    Text(loc.name)
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.primary)

                                                    Text(summary)
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }

                                                Spacer()

                                                HStack(spacing: 8) {
                                                    Text("\(total)本")
                                                        .font(.subheadline)
                                                        .fontWeight(.bold)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(Color(.systemGray6))
                                                        .cornerRadius(8)

                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.tertiary)
                                                }
                                            }
                                            .padding(16)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                                        }
                                        .buttonStyle(.plain)
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
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: config)
    
    // --- 1. ユーザーカスタムの保管場所を複数登録 ---
    let mainCellar = StorageLocation(name: "メインセラー", type: .cellar, memo: "温度14度設定")
    let subCellar = StorageLocation(name: "サブセラー", type: .cellar, memo: "小型ワインクーラー")
    let fridge = StorageLocation(name: "キッチン冷蔵庫", type: .refrigerator, memo: "生酒・ビール用")
    let roomShelf = StorageLocation(name: "リビングの棚", type: .roomTemp, memo: "常温保存用")

    container.mainContext.insert(mainCellar)
    container.mainContext.insert(subCellar)
    container.mainContext.insert(fridge)
    container.mainContext.insert(roomShelf)

    // --- 2. 各保管場所に紐づくサンプルボトルを登録 ---
    let wine1 = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        price: 8500,
        stockQuantity: 2,
        storageLocation: "メインセラー"
    )

    let wine2 = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015",
        price: 85000,
        stockQuantity: 1,
        storageLocation: "サブセラー"
    )

    let sake1 = BeverageItem(
        name: "新政 No.6 R-type 生原酒",
        producer: "新政酒造",
        category: .sake,
        region: "秋田県",
        vintage: "2026/04",
        price: 2400,
        stockQuantity: 2,
        storageLocation: "キッチン冷蔵庫"
    )

    let beer1 = BeverageItem(
        name: "IPA Special Edition",
        producer: "BrewDog",
        category: .beer,
        region: "スコットランド",
        vintage: "2026",
        price: 600,
        stockQuantity: 4,
        storageLocation: "リビングの棚"
    )

    container.mainContext.insert(wine1)
    container.mainContext.insert(wine2)
    container.mainContext.insert(sake1)
    container.mainContext.insert(beer1)

    return InventoryView()
        .modelContainer(container)
}
