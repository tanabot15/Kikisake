//
//  BlindAnalyticsView.swift
//  Kikisake
//

import SwiftUI
import SwiftData
import Charts

/// ブラインドテイスティングの正解率・推移・酒種別成績・予想傾向を分析するビュー
public struct BlindAnalyticsView: View {
    @Bindable var viewModel: AnalyticsViewModel
    let targetLogs: [TastingLog]

    private struct BlindScorePoint: Identifiable {
        let id: UUID
        let date: Date
        let score: Int
        let title: String
    }

    private struct CategoryStat: Identifiable {
        let id: BeverageCategory
        let category: BeverageCategory
        let count: Int
        let averageScore: Double
    }

    private struct RankedGuess: Identifiable {
        let id: String
        let label: String
        let count: Int
    }

    public init(viewModel: AnalyticsViewModel, targetLogs: [TastingLog]) {
        self.viewModel = viewModel
        self.targetLogs = targetLogs
    }

    private var blindLogs: [TastingLog] {
        targetLogs
            .filter { $0.isBlind && $0.isEvaluated }
            .sorted { $0.date < $1.date }
    }

    private var scoredLogs: [(log: TastingLog, score: Int)] {
        blindLogs.compactMap { log in
            guard let score = log.blindAccuracyScore else { return nil }
            return (log: log, score: min(100, max(0, score)))
        }
    }

    private var averageScore: Double {
        guard !scoredLogs.isEmpty else { return 0.0 }
        let total = scoredLogs.reduce(0) { $0 + $1.score }
        return Double(total) / Double(scoredLogs.count)
    }

    private var bestScore: Int {
        scoredLogs.map(\.score).max() ?? 0
    }

    private var latestScore: Int? {
        scoredLogs.last?.score
    }

    public var body: some View {
        if blindLogs.isEmpty {
            ContentUnavailableView(
                String(localized: "ブラインド記録がありません"),
                systemImage: "eye.slash",
                description: Text(
                    viewModel.hasActiveFilters
                        ? String(localized: "フィルター条件を変更するか、ブラインド記録を追加してみてください。")
                        : String(localized: "「追加」タブからブラインド記録に挑戦すると、ここに分析が表示されます。")
                )
            )
            .padding(.top, 40)
        } else {
            VStack(spacing: 20) {
                summaryCardsView
                scoreTrendChartCardView
                categoryPerformanceCardView
                guessTendencyCardView
                recentBlindLogsCardView
            }
        }
    }

    // MARK: - Summary Cards

    private var summaryCardsView: some View {
        HStack(spacing: 10) {
            kpiCard(
                title: String(localized: "挑戦回数"),
                value: String(format: String(localized: "%d回"), blindLogs.count),
                icon: "eye.slash.fill",
                color: .indigo
            )
            kpiCard(
                title: String(localized: "平均正解率"),
                value: scoredLogs.isEmpty ? "—" : String(format: "%.1f%%", averageScore),
                icon: "target",
                color: .accentColor
            )
            kpiCard(
                title: String(localized: "最高正解率"),
                value: scoredLogs.isEmpty ? "—" : "\(bestScore)%",
                icon: "trophy.fill",
                color: .orange
            )
        }
    }

    private func kpiCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Score Trend Chart

    private var scoreTrendChartCardView: some View {
        let points: [BlindScorePoint] = scoredLogs.map { entry in
            BlindScorePoint(
                id: entry.log.id,
                date: entry.log.date,
                score: entry.score,
                title: entry.log.item?.name ?? String(localized: "無題の記録")
            )
        }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("正解率の推移")
                    .font(.headline)
                Spacer()
                if let latest = latestScore {
                    Text(String(format: String(localized: "直近: %d%%"), latest))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.indigo)
                }
            }

            if points.isEmpty {
                Text("採点済みのスコアデータがありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                Chart(points) { point in
                    LineMark(
                        x: .value("日付", point.date),
                        y: .value("正解率", point.score)
                    )
                    .foregroundStyle(Color.indigo)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("日付", point.date),
                        y: .value("正解率", point.score)
                    )
                    .foregroundStyle(Color.indigo)
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intVal = value.as(Int.self) {
                                Text("\(intVal)%")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Category Performance

    private var categoryPerformanceCardView: some View {
        let stats: [CategoryStat] = BeverageCategory.allCases.compactMap { category in
            let catEntries = scoredLogs.filter { $0.log.item?.category == category }
            guard !catEntries.isEmpty else { return nil }
            let avg = Double(catEntries.reduce(0) { $0 + $1.score }) / Double(catEntries.count)
            return CategoryStat(
                id: category,
                category: category,
                count: catEntries.count,
                averageScore: avg
            )
        }

        return VStack(alignment: .leading, spacing: 14) {
            Text("酒種別の成績")
                .font(.headline)

            if stats.isEmpty {
                Text("酒種別のデータがありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(stats) { stat in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Circle()
                                    .fill(categoryColor(stat.category))
                                    .frame(width: 8, height: 8)
                                Text(stat.category.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(String(format: String(localized: "(%d回)"), stat.count))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(String(format: "%.1f%%", stat.averageScore))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(categoryColor(stat.category))
                                        .frame(
                                            width: min(CGFloat(stat.averageScore / 100.0) * geometry.size.width, geometry.size.width),
                                            height: 8
                                        )
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Guess Tendency

    private var guessTendencyCardView: some View {
        let topVarieties = rankedGuesses(keyPath: \.guessedVariety)
        let topRegions = rankedGuesses(keyPath: \.guessedRegion)

        return VStack(alignment: .leading, spacing: 14) {
            Text("予想の傾向")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("よく予想する品種・スタイル・特定名称")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                if topVarieties.isEmpty {
                    Text("予想データがありません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(topVarieties) { item in
                            guessChip(title: item.label, count: item.count)
                        }
                    }
                }
            }

            Divider().padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 8) {
                Text("よく予想する生産地")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                if topRegions.isEmpty {
                    Text("生産地の予想データがありません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(topRegions) { item in
                            guessChip(title: item.label, count: item.count)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func rankedGuesses(keyPath: KeyPath<TastingLog, String?>, limit: Int = 6) -> [RankedGuess] {
        var counts: [String: Int] = [:]
        for log in blindLogs {
            guard let raw = log[keyPath: keyPath]?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !raw.isEmpty else { continue }
            let parts = raw.components(separatedBy: " / ")
            for part in parts {
                let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    counts[trimmed, default: 0] += 1
                }
            }
        }
        return counts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { RankedGuess(id: $0.key, label: $0.key, count: $0.value) }
    }

    private func guessChip(title: String, count: Int) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Text("\(count)")
                .font(.caption2)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Color.indigo.opacity(0.15))
                .foregroundStyle(.indigo)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - Recent Blind Logs

    private var recentBlindLogsCardView: some View {
        let recent = Array(blindLogs.reversed().prefix(5))

        return VStack(alignment: .leading, spacing: 12) {
            Text("最近のブラインド記録")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(recent) { log in
                    NavigationLink(destination: LogDetailView(log: log)) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.item?.name ?? String(localized: "不明な銘柄"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                HStack(spacing: 6) {
                                    Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                    if let guess = log.guessedVariety, !guess.isEmpty {
                                        Text("· 予想: \(guess)")
                                            .lineLimit(1)
                                    }
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if let score = log.blindAccuracyScore {
                                Text("\(score)%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(score >= 70 ? .green : .indigo)
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(10)
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func categoryColor(_ category: BeverageCategory) -> Color {
        switch category {
        case .wine: .purple
        case .sake: .blue
        case .beer: .orange
        }
    }
}

#Preview {
    let sample = PreviewSampleData.makeSampleBundle()
    sample.wineLog.isBlind = true
    sample.wineLog.blindAccuracyScore = 85
    sample.wineLog.guessedVariety = "カベルネ・ソーヴィニヨン"
    sample.wineLog.guessedRegion = "フランス, ボルドー"

    return NavigationStack {
        ScrollView {
            BlindAnalyticsView(
                viewModel: AnalyticsViewModel(),
                targetLogs: [sample.wineLog, sample.sakeLog, sample.beerLog]
            )
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    .modelContainer(PreviewSampleData.container)
}
