//
//  LogListView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Tab 1] 飲んだ酒のリスト（テイスティングログ一覧）画面
public struct LogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TastingLog.date, order: .reverse) private var logs: [TastingLog]
    @State private var viewModel = LogListViewModel()

    /// フィルタリング済みのログリスト
    private var filteredLogs: [TastingLog] {
        viewModel.filteredLogs(logs)
    }

    public var body: some View {
        NavigationStack {
            Group {
                if filteredLogs.isEmpty {
                    ContentUnavailableView(
                        "テイスティングログがありません",
                        systemImage: "wineglass",
                        description: Text("「追加」タブから新しい記録を作成しましょう。")
                    )
                } else {
                    List {
                        ForEach(filteredLogs) { log in
                            NavigationLink(destination: LogDetailView(log: log)) {
                                if let item = log.item {
                                    BeverageCardView(
                                        name: item.name,
                                        producer: item.producer,
                                        category: item.category,
                                        region: item.region,
                                        vintage: item.vintage,
                                        stockQuantity: nil,
                                        rating: log.rating
                                    )
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                        .onDelete(perform: deleteLogs)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("テイスティングログ")
            .searchable(text: $viewModel.searchText, prompt: "銘柄名、生産者、メモで検索")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("すべて表示") {
                            viewModel.selectedCategoryFilter = nil
                        }
                        Divider()
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Button(category.displayName) {
                                viewModel.selectedCategoryFilter = category
                            }
                        }
                    } label: {
                        Label("フィルター", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }

    private func deleteLogs(at offsets: IndexSet) {
        let currentFiltered = filteredLogs
        for index in offsets {
            let log = currentFiltered[index]
            modelContext.delete(log)
        }
        try? modelContext.save()
    }
}

#Preview {
    LogListView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
