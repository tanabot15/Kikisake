//  LogListView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// [Tab 1] 飲んだ酒のリスト（テイスティングログ一覧）画面
public struct LogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TastingLog.date, order: .reverse) private var logs: [TastingLog]
    @State private var viewModel = LogListViewModel()
    @State private var editMode: EditMode = .inactive
    
    // フィルターシートの表示状態
    @State private var isShowingFilterSheet: Bool = false

    /// フィルタリング済みのログリスト
    private var filteredLogs: [TastingLog] {
        viewModel.filteredLogs(logs)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ConditionalAdMobBannerView()
                    .frame(height: 50)
                    .background(Color(.systemBackground))

                Group {
                    if filteredLogs.isEmpty {
                        ContentUnavailableView(
                            "該当するログが見つかりません",
                            systemImage: "wineglass",
                            description: Text(viewModel.hasActiveFilters ? "フィルター条件を変更してみてください。" : "「追加」タブから新しい記録を作成しましょう。")
                        )
                    } else {
                        // モードに応じたビューの出し分け
                        switch viewModel.viewMode {
                        case .card, .compact:
                            List {
                                ForEach(filteredLogs) { log in
                                    NavigationLink(destination: LogDetailView(log: log)) {
                                        if let item = log.item {
                                            if viewModel.viewMode == .compact {
                                                // シンプル・コンパクトなリスト行
                                                LogCompactRowView(log: log, item: item)
                                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                                    .listRowSeparator(.automatic)
                                            } else {
                                                // 従来のリッチなカード表示
                                                VStack(spacing: 0) {
                                                    BeverageCardView(
                                                        name: item.name,
                                                        producer: item.producer,
                                                        category: item.category,
                                                        region: item.region,
                                                        vintage: item.vintage,
                                                        rating: log.rating,
                                                        imageData: item.imageDatas?.first,
                                                        appearanceColorHex: log.appearanceColorHex
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: deleteLogs)
                                .onMove(perform: moveLogs)
                            }
                            .listStyle(.plain)
                            .environment(\.editMode, $editMode)
                            .searchable(
                                text: $viewModel.searchText,
                                placement: .navigationBarDrawer(displayMode: .always),
                                prompt: "銘柄名、生産者、メモで検索"
                            )

                        case .timeline:
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
                            .searchable(
                                text: $viewModel.searchText,
                                placement: .navigationBarDrawer(displayMode: .always),
                                prompt: "銘柄名、生産者、メモで検索"
                            )
                        }
                    }
                }
            }
            .navigationTitle("ログ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleViewMode()
                        }
                    } label: {
                        Image(systemName: viewModel.viewModeIconName)
                    }
                    .tint(.primary)
                    .accessibilityLabel("表示形式の切り替え")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(viewModel.hasActiveFilters ? Color.accentColor : Color.primary)
                    }
                }
                
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
            .sheet(isPresented: $isShowingFilterSheet) {
                LogFilterSheet(viewModel: viewModel)
            }
            .onAppear {
                // 評価フラグフィルター処理
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

                // ✨ 香りタグフィルター処理
                if let pendingAroma = AppState.shared.pendingAromaTagFilter {
                    viewModel.resetFilters()
                    viewModel.aromaTagFilter = pendingAroma
                    AppState.shared.pendingAromaTagFilter = nil
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
    
    private func moveLogs(from source: IndexSet, to destination: Int) {
        var updatedLogs = filteredLogs
        updatedLogs.move(fromOffsets: source, toOffset: destination)
    }
}

/// シンプル・コンパクトなリスト行コンポーネント
private struct LogCompactRowView: View {
    let log: TastingLog
    let item: BeverageItem

    var body: some View {
        HStack(spacing: 12) {
            // 外観カラーのドット表現
            Circle()
                .fill(Color(hex: log.appearanceColorHex) ?? Color.gray)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
                )
            
            Text(item.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            Spacer()
            
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", log.rating))
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical, 4)
    }
}

/// ✨ タイムライン表示用のカスタム行コンポーネント
private struct LogTimelineRowView: View {
    let log: TastingLog
    let item: BeverageItem
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // 左側：タイムライン軸（ノット ＋ 縦線）
            VStack(spacing: 0) {
                // 上側の縦線
                Rectangle()
                    .fill(isFirst ? Color.clear : Color(.systemGray4))
                    .frame(width: 2, height: 12)

                // ドット（外観カラーを反映、未設定ならアクセントカラー）
                Circle()
                    .fill(Color(hex: log.appearanceColorHex) ?? Color.accentColor)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle().stroke(Color(.systemBackground), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

                // 下側の縦線
                Rectangle()
                    .fill(isLast ? Color.clear : Color(.systemGray4))
                    .frame(width: 2)
            }
            .frame(width: 20)

            // 右側：タイムラインカードコンテンツ
            VStack(alignment: .leading, spacing: 6) {
                // 日付
                Text(log.date.toFormattedString(format: "yyyy年M月d日"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                // メイン情報カード
                HStack(spacing: 10) {
                    if let imageData = item.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(width: 35, height: 35)
                            .overlay {
                                Image(systemName: "wineglass")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(item.category.displayName)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(3)

                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", log.rating))
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }

                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(10)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
            .padding(.bottom, 8)
        }
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
