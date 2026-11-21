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
    CollectionItemDetailSheetPreviewHost(hasUnlockedLog: true)
}

#Preview("未達成（ログなし）") {
    CollectionItemDetailSheetPreviewHost(hasUnlockedLog: false)
}

private struct CollectionItemDetailSheetPreviewHost: View {
    let hasUnlockedLog: Bool
    private let container: ModelContainer
    private let definition: CollectionItemDefinition
    private let unlockedLogs: [TastingLog]

    init(hasUnlockedLog: Bool) {
        self.hasUnlockedLog = hasUnlockedLog

        let schema = Schema([
            BeverageItem.self,
            TastingLog.self,
            StorageLocation.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: schema, configurations: [config])
        self.container = modelContainer

        self.definition = CollectionMatrixDataSource.definitions(for: .wine).first!

        if hasUnlockedLog {
            let item = BeverageItem(
                name: "Gevrey-Chambertin 2019",
                producer: "Domaine Sample",
                category: .wine,
                region: "フランス, ブルゴーニュ",
                vintage: "2019"
            )
            let log = TastingLog(
                date: Date(),
                rating: 4.6,
                appearanceNotes: "ルビー",
                appearanceColorHex: "#8B1E3F",
                isEvaluated: true,
                item: item
            )
            modelContainer.mainContext.insert(item)
            modelContainer.mainContext.insert(log)
            self.unlockedLogs = [log]
        } else {
            self.unlockedLogs = []
        }
    }

    var body: some View {
        CollectionItemDetailSheet(
            definition: definition,
            unlockedLogs: unlockedLogs
        )
        .modelContainer(container)
    }
}
