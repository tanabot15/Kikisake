//
//  InventoryView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Tab 4] ワインセラー＋冷蔵庫の管理画面
public struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BeverageItem.createdAt, order: .reverse) private var items: [BeverageItem]
    @State private var viewModel = InventoryViewModel()

    private let filterLocations = ["All"] + AppConstants.Storage.availableLocations

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 保管場所セグメントタブ
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterLocations, id: \.self) { location in
                            Button {
                                viewModel.selectedLocationFilter = location
                            } label: {
                                Text(location == "All" ? "すべて" : location)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedLocationFilter == location ? Color.accentColor : Color(.systemGray6))
                                    .foregroundStyle(viewModel.selectedLocationFilter == location ? Color.white : Color.primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Group {
                    let displayItems = viewModel.filteredItems(items)
                    if displayItems.isEmpty {
                        ContentUnavailableView(
                            "在庫がありません",
                            systemImage: "cabinet",
                            description: Text("「追加」タブからボトルを登録してください。")
                        )
                    } else {
                        List {
                            ForEach(displayItems) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    BeverageCardView(
                                        name: item.name,
                                        producer: item.producer,
                                        category: item.category,
                                        region: item.region,
                                        vintage: item.vintage,
                                        stockQuantity: item.stockQuantity,
                                        rating: nil
                                    )

                                    // アクションボタン
                                    HStack {
                                        Text("保管場所: \(item.storageLocation)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()

                                        Button {
                                            do {
                                                try viewModel.consumeBottle(item: item)
                                                try modelContext.save()
                                            } catch {
                                                print("Error consuming bottle: \(error)")
                                            }
                                        } label: {
                                            Label("このボトルを開ける", systemImage: "bolt.fill")
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
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                            }
                            .onDelete(perform: deleteItems)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("在庫管理")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "銘柄名や生産者で検索")
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let displayItems = viewModel.filteredItems(items)
        for index in offsets {
            let item = displayItems[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}

#Preview {
    InventoryView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
