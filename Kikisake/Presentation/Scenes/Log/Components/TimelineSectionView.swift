//
//  TimelineSectionView.swift
//  Kikisake
//

import SwiftUI

/// Timeline tab section displaying tasting logs chronologically.
public struct TimelineSectionView: View {
    public let logs: [TastingLog]
    public let hasActiveFilters: Bool

    public init(logs: [TastingLog], hasActiveFilters: Bool) {
        self.logs = logs
        self.hasActiveFilters = hasActiveFilters
    }

    public var body: some View {
        Group {
            if logs.isEmpty {
                ContentUnavailableView(
                    String(localized: "該当するログが見つかりません"),
                    systemImage: "wineglass",
                    description: Text(
                        hasActiveFilters
                            ? String(localized: "フィルター条件を変更してみてください。")
                            : String(localized: "「追加」タブから新しい記録を作成しましょう。")
                    )
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                            if let item = log.item {
                                NavigationLink(destination: LogDetailView(log: log)) {
                                    TimelineRowView(
                                        log: log,
                                        item: item,
                                        isFirst: index == 0,
                                        isLast: index == logs.count - 1
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
    let item = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015"
    )
    let log = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceColorHex: "#991A33",
        item: item
    )

    return NavigationStack {
        TimelineSectionView(logs: [log], hasActiveFilters: false)
    }
}
