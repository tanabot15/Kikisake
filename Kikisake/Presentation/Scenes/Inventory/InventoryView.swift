//
//  InventoryView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Tab 4] ワインセラー＋冷蔵庫のグラフィカル在庫管理画面
public struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BeverageItem.createdAt, order: .reverse) private var items: [BeverageItem]
    @State private var viewModel = InventoryViewModel()

    public var body: some View {
        NavigationStack {
            Group {
                if let selectedLocation = viewModel.selectedLocationFilter {
                    // --- 選択された保管場所の中身（ボトル一覧）画面 ---
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            let displayItems = viewModel.filteredItems(items)
                            if displayItems.isEmpty {
                                ContentUnavailableView(
                                    "この保管場所に在庫はありません",
                                    systemImage: viewModel.iconName(for: selectedLocation),
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

                                        // アクションボタン（このボトルを開ける）
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
                                viewModel.selectedLocationFilter = nil // 保管場所選択に戻る
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
                    // --- 縦1列のグラフィカルな保管場所選択画面（ホーム） ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("保管場所を選択")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.top, 8)

                            VStack(spacing: 14) {
                                ForEach(AppConstants.Storage.availableLocations, id: \.self) { location in
                                    let total = viewModel.totalCount(for: location, in: items)
                                    let summary = viewModel.categorySummary(for: location, in: items)

                                    Button {
                                        viewModel.selectedLocationFilter = location
                                    } label: {
                                        HStack(spacing: 16) {
                                            // アイコン
                                            ZStack {
                                                Circle()
                                                    .fill(Color.accentColor.opacity(0.12))
                                                    .frame(width: 50, height: 50)
                                                Image(systemName: viewModel.iconName(for: location))
                                                    .font(.title3)
                                                    .foregroundStyle(Color.accentColor)
                                            }

                                            // 保管場所名と酒種内訳
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(location)
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.primary)

                                                Text(summary)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }

                                            Spacer()

                                            // 合計本数 ＆ 矢印
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
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                    .navigationTitle("在庫管理")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    
    // --- ワインセラー（ワインと日本酒、ビールが混在しているリッチな状態） ---
    let wineItem1 = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        price: 8500,
        stockQuantity: 2,
        storageLocation: "ワインセラー"
    )
    
    let wineItem2 = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015",
        price: 85000,
        stockQuantity: 1,
        storageLocation: "ワインセラー"
    )

    let cellarSake = BeverageItem(
        name: "十四代 本丸 秘伝玉返し",
        producer: "高木酒造",
        category: .sake,
        region: "山形県",
        vintage: "2026/05",
        price: 3200,
        stockQuantity: 1,
        storageLocation: "ワインセラー"
    )

    // --- 冷蔵庫 ---
    let fridgeSake = BeverageItem(
        name: "新政 No.6 R-type 生原酒",
        producer: "新政酒造",
        category: .sake,
        region: "秋田県",
        vintage: "2026/04",
        price: 2400,
        stockQuantity: 2,
        storageLocation: "冷蔵庫"
    )

    // --- 常温 ---
    let roomBeer = BeverageItem(
        name: "IPA Special Edition",
        producer: "BrewDog",
        category: .beer,
        region: "スコットランド",
        vintage: "2026",
        price: 600,
        stockQuantity: 4,
        storageLocation: "常温"
    )

    container.mainContext.insert(wineItem1)
    container.mainContext.insert(wineItem2)
    container.mainContext.insert(cellarSake)
    container.mainContext.insert(fridgeSake)
    container.mainContext.insert(roomBeer)

    return InventoryView()
        .modelContainer(container)
}
