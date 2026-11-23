//
//  CollectionItemDetailSheet.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Detail sheet shown when tapping an unlocked collection item.
struct CollectionItemDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let definition: CollectionItemDefinition
    let unlockedLogs: [TastingLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(definition.targetElement)
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("\(definition.region) （\(definition.category.displayName)）")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    Divider()

                    if unlockedLogs.isEmpty {
                        ContentUnavailableView(
                            String(localized: "未達成の項目です"),
                            systemImage: "lock.slash",
                            description: Text(String(localized: "この条件に一致するお酒を記録すると、図鑑が解放されます。"))
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(unlockedLogs, id: \.id) { log in
                                if let item = log.item {
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
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "図鑑アイテム詳細"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "閉じる")) {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview("達成済みログあり") {
    let sample = PreviewSampleData.makeSampleBundle()
    let definition = CollectionMatrixDataSource.definitions(for: .wine).first!
    return CollectionItemDetailSheet(
        definition: definition,
        unlockedLogs: [sample.wineLog]
    )
    .modelContainer(PreviewSampleData.container)
}

#Preview("未達成（ログなし）") {
    let definition = CollectionMatrixDataSource.definitions(for: .wine).first!
    return CollectionItemDetailSheet(
        definition: definition,
        unlockedLogs: []
    )
    .modelContainer(PreviewSampleData.container)
}
