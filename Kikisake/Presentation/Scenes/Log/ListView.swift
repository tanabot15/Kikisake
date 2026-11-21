//
//  ListView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// List tab content for tasting logs.
public struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable public var viewModel: LogViewModel
    public var filteredLogs: [TastingLog]
    @Binding public var editMode: EditMode

    public init(viewModel: LogViewModel, filteredLogs: [TastingLog], editMode: Binding<EditMode>) {
        self.viewModel = viewModel
        self.filteredLogs = filteredLogs
        self._editMode = editMode
    }

    public var body: some View {
        VStack(spacing: 0) {
            searchBar

            if filteredLogs.isEmpty {
                ContentUnavailableView(
                    String(localized: "該当するログが見つかりません"),
                    systemImage: "wineglass",
                    description: Text(
                        viewModel.hasActiveFilters || !viewModel.searchText.isEmpty
                            ? String(localized: "検索やフィルター条件を変更してみてください。")
                            : String(localized: "「追加」タブから新しい記録を作成しましょう。")
                    )
                )
                .frame(maxHeight: .infinity)
            } else {
                logList
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(String(localized: "銘柄名、生産者、メモで検索"), text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var logList: some View {
        List {
            ForEach(filteredLogs) { log in
                if let item = log.item {
                    NavigationLink(destination: LogDetailView(log: log)) {
                        rowContent(for: log, item: item)
                    }
                    .buttonStyle(.plain)
                    .applyRowStyle(for: viewModel.listDisplayStyle)
                }
            }
            .onDelete(perform: deleteLogs)
            .onMove(perform: moveLogs)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $editMode)
    }

    @ViewBuilder
    private func rowContent(for log: TastingLog, item: BeverageItem) -> some View {
        switch viewModel.listDisplayStyle {
        case .card:
            BeverageCardView(
                name: item.name,
                producer: item.producer,
                category: item.category,
                region: item.region,
                vintage: item.vintage,
                rating: log.rating,
                imageData: item.imageDatas?.first,
                isBackgroundRemoved: item.isBackgroundRemoved,
                appearanceColorHex: log.appearanceColorHex
            )
        case .compact:
            LogCompactRowView(log: log, item: item)
        }
    }

    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            let log = filteredLogs[index]
            let parentItem = log.item
            modelContext.delete(log)

            if let item = parentItem {
                let remainingLogs = (item.tastingLogs ?? []).filter { $0.id != log.id }
                if remainingLogs.isEmpty && item.storageLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    modelContext.delete(item)
                }
            }
        }
        try? modelContext.save()
    }

    private func moveLogs(from source: IndexSet, to destination: Int) {
        var updatedLogs = filteredLogs
        updatedLogs.move(fromOffsets: source, toOffset: destination)
    }
}

private extension View {
    @ViewBuilder
    func applyRowStyle(for style: ListDisplayStyle) -> some View {
        switch style {
        case .card:
            self
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        case .compact:
            self
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.automatic)
        }
    }
}

/// Compact row view for tasting logs.
public struct LogCompactRowView: View {
    public let log: TastingLog
    public let item: BeverageItem

    public init(log: TastingLog, item: BeverageItem) {
        self.log = log
        self.item = item
    }

    public var body: some View {
        HStack(spacing: 12) {
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

    return NavigationStack {
        ListView(
            viewModel: LogViewModel(),
            filteredLogs: [wineLog],
            editMode: .constant(.inactive)
        )
    }
    .modelContainer(container)
}
