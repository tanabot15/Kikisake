//  CollectionBookAnalyticsView.swift
//  Kikisake

import SwiftUI
import SwiftData

public struct CollectionBookAnalyticsView: View {
    @State private var viewModel = CollectionAnalyticsViewModel()
    var allLogs: [TastingLog]

    // ✨ 受け取るタプルラベルを unlockedLog に合わせる
    @State private var selectedCell: (definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLog: TastingLog?)? = nil
    @State private var isShowingDetailAlert: Bool = false

    public init(allLogs: [TastingLog]) {
        self.allLogs = allLogs
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 16) {
            // 1. 酒種切り替えピッカー
            Picker(String(localized: "酒種"), selection: $viewModel.selectedCategory) {
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 4)

            // 2. 進捗サマリーカード
            progressSummaryCard
            
            // 3. コレクション・マトリクス・グリッド
            collectionGridView
        }
        .alert(selectedCell?.definition.targetElement ?? "", isPresented: $isShowingDetailAlert) {
            Button(String(localized: "閉じる"), role: .cancel) {}
        } message: {
            if let cell = selectedCell {
                if cell.isUnlocked, let log = cell.unlockedLog {
                    Text(String(format: String(localized: "\n産地: %@\n銘柄: %@\n評価: %.1f \n飲んだ日: %@"),
                                cell.definition.region,
                                log.item?.name ?? "不明",
                                log.rating,
                                log.date.formatted(date: .abbreviated, time: .omitted)))
                } else {
                    Text(String(format: String(localized: "【未踏破】\n産地: %@\n品種・スタイル: %@\n\nこの組み合わせの銘柄を飲んで記録すると図鑑が埋まります！"),
                                cell.definition.region,
                                cell.definition.targetElement))
                }
            }
        }
    }

    /// 進捗率プログレスバー
    @ViewBuilder
    private var progressSummaryCard: some View {
        let rate = viewModel.completionRate(for: viewModel.selectedCategory, logs: allLogs)
        let results = viewModel.checkCompletions(for: viewModel.selectedCategory, logs: allLogs)
        let unlockedCount = results.filter { $0.isUnlocked }.count

        VStack(spacing: 8) {
            HStack {
                Label(String(localized: "図鑑コンプリート進捗"), systemImage: "trophy.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(unlockedCount) / \(results.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
            }

            ProgressView(value: rate)
                .tint(Color.accentColor)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }

    /// グリッド表示エリア（産地ごとにグループ化して表示）
    @ViewBuilder
    private var collectionGridView: some View {
        let results = viewModel.checkCompletions(for: viewModel.selectedCategory, logs: allLogs)
        let groupedByRegion = Dictionary(grouping: results, by: { $0.definition.region })

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(groupedByRegion.keys.sorted(), id: \.self) { region in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 6, height: 6)
                            Text(region)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }

                        let items = groupedByRegion[region] ?? []
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                            ForEach(items, id: \.definition.id) { cell in
                                collectionCard(cell: cell)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(.vertical, 4)
        }
    }

    /// 個別のコレクション・セルカード
    @ViewBuilder
    private func collectionCard(cell: (definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLog: TastingLog?)) -> some View {
        Button {
            selectedCell = cell
            isShowingDetailAlert = true
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(cell.isUnlocked ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(cell.isUnlocked ? Color.accentColor : Color(.systemGray4).opacity(0.5), lineWidth: cell.isUnlocked ? 1.5 : 1)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: cell.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(cell.isUnlocked ? Color.accentColor : Color(.systemGray3))

                        if cell.isUnlocked, let log = cell.unlockedLog {
                            Text(log.item?.name ?? "")
                                .font(.system(size: 10))
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                                .fontWeight(.medium)
                        } else {
                            Text("???")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(6)
                }
                .frame(height: 70)

                Text(cell.definition.targetElement)
                    .font(.caption2)
                    .fontWeight(cell.isUnlocked ? .semibold : .regular)
                    .foregroundStyle(cell.isUnlocked ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, StorageLocation.self, configurations: config)
    
    // サンプル1：フランス産のカベルネ・ソーヴィニヨン（図鑑が埋まるケース）
    let wineItem = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "フランス, ボルドー",
        specificMetadataJSON: "{\"wineType\":\"赤\",\"grapeVarieties\":\"カベルネ・ソーヴィニヨン\",\"blendComponents\":[{\"variety\":\"カベルネ・ソーヴィニヨン\",\"percentage\":80}]}"
    )
    let wineLog = TastingLog(
        rating: 4.9,
        appearanceNotes: "深みのあるルビー",
        memo: "素晴らしい味わい。",
        isEvaluated: true,
        item: wineItem
    )
    
    // サンプル2：新潟県の山田錦を使った日本酒（図鑑が埋まるケース）
    let sakeItem = BeverageItem(
        name: "久保田 萬寿",
        producer: "朝日酒造",
        category: .sake,
        region: "新潟県, 長岡",
        specificMetadataJSON: "{\"specificName\":\"純米大吟醸\",\"riceVariety\":\"山田錦\",\"polishingRate\":\"50%\",\"sakeMeterValue\":\"+2\"}"
    )
    let sakeLog = TastingLog(
        rating: 4.8,
        appearanceNotes: "澄んだ透明",
        memo: "芳醇な香り。",
        isEvaluated: true,
        item: sakeItem
    )

    container.mainContext.insert(wineItem)
    container.mainContext.insert(wineLog)
    container.mainContext.insert(sakeItem)
    container.mainContext.insert(sakeLog)

    return NavigationStack {
        ScrollView {
            CollectionBookAnalyticsView(allLogs: [wineLog, sakeLog])
                .padding()
        }
        .navigationTitle(String(localized: "図鑑"))
        .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(container)
}
