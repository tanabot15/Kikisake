//  CollectionBookAnalyticsView.swift
//  Kikisake

import SwiftUI
import SwiftData

public struct CollectionBookAnalyticsView: View {
    @State private var viewModel = CollectionAnalyticsViewModel()
    @Bindable private var appState = AppState.shared
    var allLogs: [TastingLog]

    @State private var selectedCell: (definition: CollectionItemDefinition, isUnlocked: Bool, unlockedLog: TastingLog?)? = nil
    @State private var isShowingDetailAlert: Bool = false
    @State private var isShowingPaywall: Bool = false
    @State private var isShowingRankSheet: Bool = false

    public init(allLogs: [TastingLog]) {
        self.allLogs = allLogs
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        let isPro = appState.isProVersion
        let proExtraCount = viewModel.lockedProItemCount(for: viewModel.selectedCategory)

        return VStack(spacing: 16) {
            // 0. 無料ユーザー向け Pro版アップグレード誘導バナー
            if !isPro && proExtraCount > 0 {
                proUpgradeBanner(extraCount: proExtraCount)
            }

            // 1. 酒種切り替えピッカー
            Picker(String(localized: "酒種"), selection: $viewModel.selectedCategory) {
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 4)

            // 2. 進捗＆称号サマリーカード
            progressSummaryCard
            
            // 3. コレクション・マトリクス・グリッド
            collectionGridView
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $isShowingRankSheet) {
            let results = viewModel.checkCompletions(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
            let unlockedCount = results.filter { $0.isUnlocked }.count
            RankShareSheetView(
                category: viewModel.selectedCategory,
                unlockedCount: unlockedCount,
                totalCount: results.count
            )
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

    /// 進捗率プログレスバー＆現在の称号・シェアエリア
    @ViewBuilder
    private var progressSummaryCard: some View {
        let isPro = appState.isProVersion
        let rate = viewModel.completionRate(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
        let results = viewModel.checkCompletions(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
        let unlockedCount = results.filter { $0.isUnlocked }.count
        let currentBadge = CollectionRankBadge.currentBadge(for: viewModel.selectedCategory, unlockedCount: unlockedCount)
        let nextBadge = CollectionRankBadge.nextBadge(for: viewModel.selectedCategory, unlockedCount: unlockedCount)

        VStack(spacing: 12) {
            // 上段：コンプリート進捗率
            VStack(spacing: 8) {
                HStack {
                    Label(
                        isPro ? String(localized: "図鑑コンプリート進捗 (Pro全開放)") : String(localized: "図鑑コンプリート進捗 (スタンダード)"),
                        systemImage: "trophy.fill"
                    )
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

            Divider()

            // 下段：獲得済み称号バッジ＆SNSシェアボタン
            HStack(spacing: 12) {
                if let badge = currentBadge {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: badge.tier.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)

                        Image(systemName: badge.tier.iconName)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(badge.tier.tierName)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(badge.tier.accentColor)
                            if let next = nextBadge {
                                Text(String(format: String(localized: "(次: %d種で%@)"), next.requiredCount, next.tier.tierName))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Text(badge.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                } else if let firstBadge = nextBadge {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)

                        Image(systemName: "medal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "称号未獲得"))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text(String(format: String(localized: "あと%d種で「%@」"), max(0, firstBadge.requiredCount - unlockedCount), firstBadge.title))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                }

                Spacer()

                Button {
                    isShowingRankSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: currentBadge != nil ? "square.and.arrow.up" : "list.bullet.rectangle")
                        Text(currentBadge != nil ? String(localized: "シェア") : String(localized: "称号一覧"))
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }

    /// グリッド表示エリア（産地ごとにグループ化して表示）
    @ViewBuilder
    private var collectionGridView: some View {
        let isPro = appState.isProVersion
        let results = viewModel.checkCompletions(for: viewModel.selectedCategory, logs: allLogs, isPro: isPro)
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

    /// Pro版で追加されるマイナー組み合わせの解放誘導バナー
    @ViewBuilder
    private func proUpgradeBanner(extraCount: Int) -> some View {
        Button {
            isShowingPaywall = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.yellow, .orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 44, height: 44)

                    Image(systemName: "crown.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: String(localized: "Pro版でさらに %d 種の希少枠を解放"), extraCount))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(String(localized: "マイナー産地・土着品種・マニアックなスタイルの組み合わせを全て図鑑に追加します"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1.2)
                    )
            )
        }
        .buttonStyle(.plain)
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

#Preview("図鑑ビュー（ブロンズ達成サンプル）") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, StorageLocation.self, configurations: config)
    
    let samples: [(String, String, String)] = [
        ("Château Margaux", "フランス, ボルドー", "カベルネ・ソーヴィニヨン"),
        ("Château Cheval Blanc", "フランス, ボルドー", "メルロ"),
        ("Romanée-Conti", "フランス, ブルゴーニュ", "ピノ・ノワール"),
        ("Montrachet", "フランス, ブルゴーニュ", "シャルドネ"),
        ("Sancerre", "フランス, ロワール", "ソーヴィニヨン・ブラン"),
        ("Côte-Rôtie", "フランス, ローヌ", "シラー / シラーズ"),
        ("Beaujolais Nouveau", "フランス", "ガメイ"),
        ("Tignanello", "イタリア, トスカーナ", "サンジョヴェーゼ"),
        ("Barolo", "イタリア, ピエモンテ", "ネッビオーロ"),
        ("Barbera d'Alba", "イタリア, ピエモンテ", "バルベラ")
    ]

    var logs: [TastingLog] = []
    for (name, region, variety) in samples {
        let item = BeverageItem(
            name: name,
            producer: "Sample Producer",
            category: .wine,
            region: region,
            specificMetadataJSON: "{\"wineType\":\"赤\",\"grapeVarieties\":\"\(variety)\",\"blendComponents\":[]}"
        )
        let log = TastingLog(rating: 4.5, isEvaluated: true, item: item)
        container.mainContext.insert(item)
        container.mainContext.insert(log)
        logs.append(log)
    }

    return NavigationStack {
        ScrollView {
            CollectionBookAnalyticsView(allLogs: logs)
                .padding()
        }
        .navigationTitle(String(localized: "図鑑"))
        .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(container)
}
