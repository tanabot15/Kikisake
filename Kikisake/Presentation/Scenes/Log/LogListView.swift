//  LogListView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// [Tab 1] 飲んだ酒のリスト（テイスティングログ一覧）画面
public struct LogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode // 編集モードの状態を管理
    @Query(sort: \TastingLog.date, order: .reverse) private var logs: [TastingLog]
    @State private var viewModel = LogListViewModel()
    
    // ✨ フィルターシートの表示状態
    @State private var isShowingFilterSheet: Bool = false

    private let filterCategories: [BeverageCategory?] = [nil] + BeverageCategory.allCases.map { Optional($0) }

    /// フィルタリング済みのログリスト
    private var filteredLogs: [TastingLog] {
        viewModel.filteredLogs(logs)
    }

    /// フィルターやソートがデフォルトから変更されているかどうか（バッジ表示用）
    private var hasActiveFilters: Bool {
        viewModel.selectedRatingFilter != nil || viewModel.sortOrder != .dateDescending
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ConditionalAdMobBannerView()
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterCategories, id: \.self) { category in
                            Button {
                                viewModel.selectedCategoryFilter = category
                            } label: {
                                Text(category?.displayName ?? "すべて")
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedCategoryFilter == category ? Color.accentColor : Color(.systemGray6))
                                    .foregroundStyle(viewModel.selectedCategoryFilter == category ? Color.white : Color.primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

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
                                        VStack(spacing: 0) {
                                            BeverageCardView(
                                                name: item.name,
                                                producer: item.producer,
                                                category: item.category,
                                                region: item.region,
                                                vintage: item.vintage,
                                                stockQuantity: nil,
                                                rating: log.rating,
                                                imageData: item.imageDatas?.first,
                                                appearanceColorHex: log.appearanceColorHex
                                            )
                                            .padding(.bottom, 12)
                                            
                                            // 統一感のあるクリーンな区切り線
                                            Divider()
                                                .padding(.horizontal, 4)
                                        }
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                            }
                            .onDelete(perform: deleteLogs)
                            .onMove(perform: moveLogs)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("テイスティングログ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ✨ ツールバーに「フィルターボタン」と「編集ボタン」を配置
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        isShowingFilterSheet = true
                    } label: {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(hasActiveFilters ? Color.accentColor : Color.primary)
                    }

                    Button {
                        withAnimation {
                            if editMode?.wrappedValue == .active {
                                editMode?.wrappedValue = .inactive
                            } else {
                                editMode?.wrappedValue = .active
                            }
                        }
                    } label: {
                        Label(
                            editMode?.wrappedValue == .active ? "完了" : "編集",
                            systemImage: editMode?.wrappedValue == .active ? "checkmark.circle.fill" : "square.and.pencil"
                        )
                    }
                }
            }
            .sheet(isPresented: $isShowingFilterSheet) {
                LogFilterSheet(viewModel: viewModel)
            }
            // 検索バーを常に画面上に露出させ、ユーザーが見つけやすく操作しやすくする
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "銘柄名、生産者、メモで検索"
            )
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
    
    private func moveLogs(from source: IndexSet, to destination: Int) {
        var updatedLogs = filteredLogs
        updatedLogs.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    
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
        appearanceNotes: "ルビーレッド",
        appearanceColorHex: "#991A33",
        aromaTags: ["カシス", "ヴァニラ", "杉"],
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.0,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        balanceTags: ["豊潤な"],
        finishLength: 4.8,
        memo: "圧倒的な気品と複雑味。",
        item: wineItem
    )

    container.mainContext.insert(wineItem)
    container.mainContext.insert(wineLog)

    return LogListView()
        .modelContainer(container)
}
