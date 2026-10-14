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
            .navigationBarTitleDisplayMode(.inline)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    
    // サンプルデータ 1: ワイン
    let wineItem = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015",
        stockQuantity: 1
    )
    let wineLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "深みのあるルビーレッド",
        aromaTags: ["カシス", "ヴァニラ", "杉"],
        sweetness: 2.0,
        acidity: 4.0,
        bitternessOrTannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "圧倒的な気品と複雑味。",
        item: wineItem
    )
    
    // サンプルデータ 2: 日本酒
    let sakeItem = BeverageItem(
        name: "久保田 萬壽",
        producer: "朝日酒造",
        category: .sake,
        region: "新潟県",
        vintage: "2026/05",
        stockQuantity: 2
    )
    let sakeLog = TastingLog(
        date: Date().addingTimeInterval(-86400 * 2),
        rating: 4.5,
        appearanceNotes: "無色透明で美しい輝き",
        aromaTags: ["吟醸香", "青りんご", "バナナ"],
        sweetness: 3.0,
        acidity: 2.5,
        bitternessOrTannin: 1.5,
        body: 3.0,
        finishLength: 4.0,
        memo: "香りが華やかでなめらかな口当たり。",
        item: sakeItem
    )

    // サンプルデータ 3: ビール
    let beerItem = BeverageItem(
        name: "Inedit Damm",
        producer: "Damm",
        category: .beer,
        region: "バルセロナ, スペイン",
        vintage: "2026",
        stockQuantity: 0
    )
    let beerLog = TastingLog(
        date: Date().addingTimeInterval(-86400 * 5),
        rating: 4.2,
        appearanceNotes: "ペールゴールド・白濁",
        aromaTags: ["シトラス", "ホップ", "スパイス"],
        sweetness: 2.5,
        acidity: 3.0,
        bitternessOrTannin: 2.5,
        body: 3.5,
        finishLength: 3.5,
        memo: "シャンパンのような華やかな香りとリッチな味わい。",
        item: beerItem
    )

    container.mainContext.insert(wineItem)
    container.mainContext.insert(wineLog)
    container.mainContext.insert(sakeItem)
    container.mainContext.insert(sakeLog)
    container.mainContext.insert(beerItem)
    container.mainContext.insert(beerLog)

    return LogListView()
        .modelContainer(container)
}
