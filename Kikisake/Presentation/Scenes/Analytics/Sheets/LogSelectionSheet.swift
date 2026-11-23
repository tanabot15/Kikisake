//
//  LogSelectionSheet.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Modal log picker sheet used in comparison mode.
public struct LogSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let allLogs: [TastingLog]
    @Binding var selectedLogID: UUID?

    public init(allLogs: [TastingLog], selectedLogID: Binding<UUID?>) {
        self.allLogs = allLogs
        self._selectedLogID = selectedLogID
    }

    public var body: some View {
        NavigationStack {
            List(allLogs) { log in
                Button {
                    selectedLogID = log.id
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.item?.name ?? String(localized: "不明な銘柄"))
                                .font(.headline)
                                .foregroundStyle(.primary)
                            if let producer = log.item?.producer, !producer.isEmpty {
                                Text(producer)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text(String(format: "%.1f", log.rating))
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "比較するログを選択"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "キャンセル")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LogSelectionSheetPreviewHost()
}

private struct LogSelectionSheetPreviewHost: View {
    private let sample = PreviewSampleData.makeSampleBundle()
    @State private var selectedID: UUID? = nil

    var body: some View {
        LogSelectionSheet(
            allLogs: [sample.wineLog, sample.sakeLog, sample.beerLog],
            selectedLogID: $selectedID
        )
        .modelContainer(PreviewSampleData.container)
    }
}
