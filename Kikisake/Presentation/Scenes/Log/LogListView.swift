//  LogListView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// [Tab 1] 飲んだ酒のリスト、タイムライン、図鑑を統合した画面
public struct LogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TastingLog.date, order: .reverse) private var logs: [TastingLog]
    @State private var viewModel = LogListViewModel()
    @State private var editMode: EditMode = .inactive
    
    @State private var isShowingFilterSheet: Bool = false

    private var filteredLogs: [TastingLog] {
        viewModel.filteredLogs(logs)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !AppState.shared.isProVersion {
                    ConditionalAdMobBannerView()
                        .frame(height: 50)
                        .background(Color(.systemBackground))
                }

                // セグメントピッカー（リスト / タイムライン / 図鑑）
                Picker(String(localized: "表示モード"), selection: $viewModel.selectedSection) {
                    ForEach(LogMainSection.allCases) { section in
                        Text(section.displayName).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGroupedBackground))

                // TabViewによる切り替え
                TabView(selection: $viewModel.selectedSection) {
                    // 1. リストタブ（切り出したビューを利用）
                    LogListViewContent(
                        viewModel: viewModel,
                        filteredLogs: filteredLogs,
                        editMode: $editMode
                    )
                    .tag(LogMainSection.list)

                    // 2. タイムラインタブ
                    timelineViewContent()
                        .tag(LogMainSection.timeline)

                    // 3. 図鑑タブ
                    ScrollView {
                        CollectionBookView(allLogs: logs)
                            .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                    .tag(LogMainSection.collectionBook)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(String(localized: "ログ"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // リストタブ表示時のみ、左上に表示形式（カード/コンパクト）切り替えボタンを出す
                if viewModel.selectedSection == .list {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleListDisplayStyle()
                            }
                        } label: {
                            Image(systemName: viewModel.listDisplayStyleIconName)
                        }
                        .tint(.primary)
                        .accessibilityLabel(String(localized: "表示形式の切り替え"))
                    }
                }
                
                // 図鑑タブ以外のときのみフィルターボタンを表示
                if viewModel.selectedSection != .collectionBook {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingFilterSheet = true
                        } label: {
                            Image(systemName: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .foregroundStyle(viewModel.hasActiveFilters ? Color.accentColor : Color.primary)
                        }
                    }
                }
                
                // 図鑑以外のタブでのみ編集モードボタンを有効にする
                if viewModel.selectedSection != .collectionBook {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                editMode = (editMode == .active) ? .inactive : .active
                            }
                        } label: {
                            Image(systemName: editMode == .active ? "checkmark.circle" : "square.and.pencil")
                                .foregroundStyle(editMode == .active ? Color.accentColor : Color.primary)
                        }
                        .tint(.primary)
                    }
                }
            }
            .sheet(isPresented: $isShowingFilterSheet) {
                LogFilterSheet(viewModel: viewModel)
            }
            .onAppear {
                if let pendingFilter = AppState.shared.pendingLogFilter {
                    viewModel.resetFilters()
                    switch pendingFilter {
                    case .costEffective:
                        viewModel.filterCostEffective = true
                    case .willingToRepeat:
                        viewModel.filterWillingToRepeat = true
                    case .agingPotential:
                        viewModel.filterAgingPotential = true
                    }
                    AppState.shared.pendingLogFilter = nil
                }

                if let pendingAroma = AppState.shared.pendingAromaTagFilter {
                    viewModel.resetFilters()
                    viewModel.aromaTagFilter = pendingAroma
                    AppState.shared.pendingAromaTagFilter = nil
                }
            }
        }
    }

    @ViewBuilder
    private func timelineViewContent() -> some View {
        Group {
            if filteredLogs.isEmpty {
                ContentUnavailableView(
                    String(localized: "該当するログが見つかりません"),
                    systemImage: "wineglass",
                    description: Text(viewModel.hasActiveFilters ? String(localized: "フィルター条件を変更してみてください。") : String(localized: "「追加」タブから新しい記録を作成しましょう。"))
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(filteredLogs.enumerated()), id: \.element.id) { index, log in
                            if let item = log.item {
                                NavigationLink(destination: LogDetailView(log: log)) {
                                    LogTimelineRowView(
                                        log: log,
                                        item: item,
                                        isFirst: index == 0,
                                        isLast: index == filteredLogs.count - 1
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
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
        vintage: "2015"
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
