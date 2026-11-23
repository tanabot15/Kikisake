//
//  LogComparisonView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Side-by-side tasting log comparison view.
public struct LogComparisonView: View {
    @Bindable var viewModel: AnalyticsViewModel
    let allLogs: [TastingLog]

    @State private var isShowingLeftPicker = false
    @State private var isShowingRightPicker = false

    public init(viewModel: AnalyticsViewModel, allLogs: [TastingLog]) {
        self.viewModel = viewModel
        self.allLogs = allLogs
    }

    private var candidateLogs: [TastingLog] {
        viewModel.comparisonCandidateLogs(from: allLogs)
    }

    private var leftLog: TastingLog? {
        if let id = viewModel.comparisonLeftLogID,
           let matched = candidateLogs.first(where: { $0.id == id }) {
            return matched
        }
        return candidateLogs.first
    }

    private var rightLog: TastingLog? {
        if let id = viewModel.comparisonRightLogID,
           let matched = candidateLogs.first(where: { $0.id == id }) {
            return matched
        }
        return candidateLogs.dropFirst().first ?? candidateLogs.first
    }

    public var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                logSelectorCard(
                    title: String(localized: "左のログ"),
                    selectedLog: leftLog,
                    action: { isShowingLeftPicker = true }
                )

                logSelectorCard(
                    title: String(localized: "右のログ"),
                    selectedLog: rightLog,
                    action: { isShowingRightPicker = true }
                )
            }

            if let left = leftLog, let right = rightLog {
                comparisonContent(left: left, right: right)
            } else {
                ContentUnavailableView(
                    String(localized: "該当する比較ログがありません"),
                    systemImage: "arrow.left.arrow.right.circle",
                    description: Text(
                        viewModel.hasActiveFilters
                            ? String(localized: "フィルター条件を変更してみてください。")
                            : String(localized: "上のボタンから左右それぞれのログを選択してください。")
                    )
                )
                .padding(.top, 40)
            }
        }
        .sheet(isPresented: $isShowingLeftPicker) {
            LogSelectionSheet(allLogs: candidateLogs, selectedLogID: $viewModel.comparisonLeftLogID)
        }
        .sheet(isPresented: $isShowingRightPicker) {
            LogSelectionSheet(allLogs: candidateLogs, selectedLogID: $viewModel.comparisonRightLogID)
        }
    }

    private func logSelectorCard(title: String, selectedLog: TastingLog?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if let log = selectedLog {
                    Text(log.item?.name ?? String(localized: "不明な銘柄"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                        Text(String(format: "%.1f", log.rating))
                            .font(.caption)
                            .fontWeight(.bold)
                        if let vintage = log.item?.vintage, !vintage.isEmpty {
                            Text("・ \(vintage)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text(String(localized: "タップして選択"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func comparisonContent(left: TastingLog, right: TastingLog) -> some View {
        VStack(spacing: 20) {
            comparisonCard(title: String(localized: "ボトル写真")) {
                HStack(spacing: 12) {
                    heroImageThumbnail(for: left)
                    heroImageThumbnail(for: right)
                }
            }

            comparisonCard(title: String(localized: "評価")) {
                comparisonRow(label: String(localized: "総合スコア")) {
                    scoreStarsView(for: left.rating)
                } rightContent: {
                    scoreStarsView(for: right.rating)
                }
            }

            comparisonCard(title: String(localized: "基本情報")) {
                VStack(spacing: 10) {
                    comparisonTextRow(
                        label: String(localized: "酒種"),
                        leftVal: left.item?.category.displayName ?? "-",
                        rightVal: right.item?.category.displayName ?? "-"
                    )
                    comparisonTextRow(
                        label: String(localized: "生産者"),
                        leftVal: left.item?.producer ?? "-",
                        rightVal: right.item?.producer ?? "-"
                    )
                    comparisonTextRow(
                        label: String(localized: "産地"),
                        leftVal: left.item?.region ?? "-",
                        rightVal: right.item?.region ?? "-"
                    )
                    comparisonTextRow(
                        label: String(localized: "価格"),
                        leftVal: left.item?.price.map { "\($0) 円" } ?? "-",
                        rightVal: right.item?.price.map { "\($0) 円" } ?? "-"
                    )
                }
            }

            comparisonCard(title: String(localized: "外観・香り")) {
                VStack(spacing: 10) {
                    comparisonRow(label: String(localized: "外観")) {
                        colorChipView(colorHex: left.appearanceColorHex, note: left.appearanceNotes)
                    } rightContent: {
                        colorChipView(colorHex: right.appearanceColorHex, note: right.appearanceNotes)
                    }
                    Divider()
                    comparisonRow(label: String(localized: "香りタグ")) {
                        tagFlow(tags: left.aromaTags)
                    } rightContent: {
                        tagFlow(tags: right.aromaTags)
                    }
                }
            }

            comparisonCard(title: String(localized: "テイストバランス")) {
                HStack(spacing: 12) {
                    TasteRadarCardView(log: left, isCompactMode: true)
                    TasteRadarCardView(log: right, isCompactMode: true)
                }
            }

            comparisonCard(title: String(localized: "マトリクス位置")) {
                HStack(spacing: 12) {
                    MatrixAnalysisCardView(log: left, isCompactMode: true)
                    MatrixAnalysisCardView(log: right, isCompactMode: true)
                }
            }

            comparisonCard(title: String(localized: "ペアリング等")) {
                VStack(spacing: 10) {
                    comparisonTextRow(
                        label: String(localized: "ペアリング"),
                        leftVal: left.pairing ?? "-",
                        rightVal: right.pairing ?? "-"
                    )
                    Divider()
                    comparisonTextRow(
                        label: String(localized: "メモ"),
                        leftVal: left.memo.isEmpty ? "-" : left.memo,
                        rightVal: right.memo.isEmpty ? "-" : right.memo
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func heroImageThumbnail(for log: TastingLog) -> some View {
        ZStack {
            if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ZStack {
                    LinearGradient(
                        colors: [colorFromHex(log.appearanceColorHex).opacity(0.4), colorFromHex(log.appearanceColorHex)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "wineglass.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func scoreStarsView(for rating: Double) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: Double(i) < rating ? "star.fill" : "star")
                        .font(.system(size: 8))
                        .foregroundStyle(.orange)
                }
            }
            Text(String(format: "%.1f点", rating))
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func colorChipView(colorHex: String, note: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(colorFromHex(colorHex))
                .frame(width: 16, height: 16)
                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
            Text(note.isEmpty ? "未設定" : note)
                .font(.subheadline)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func colorFromHex(_ hex: String) -> Color {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        if scanner.scanHexInt64(&rgbValue) {
            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0
            return Color(red: red, green: green, blue: blue)
        }
        return .gray
    }

    private func comparisonCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Text(title)
                    .font(.headline)
                Spacer()
            }
            content()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func comparisonTextRow(label: String, leftVal: String, rightVal: String) -> some View {
        comparisonRow(label: label) {
            Text(leftVal)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        } rightContent: {
            Text(rightVal)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
    }

    private func comparisonRow<LeftContent: View, RightContent: View>(
        label: String,
        @ViewBuilder leftContent: () -> LeftContent,
        @ViewBuilder rightContent: () -> RightContent
    ) -> some View {
        HStack {
            leftContent()
                .frame(maxWidth: .infinity, alignment: .center)

            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 76, alignment: .center)
                .multilineTextAlignment(.center)

            rightContent()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func tagFlow(tags: [String]) -> some View {
        if tags.isEmpty {
            Text("-")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            FlowLayout(spacing: 4) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    let sample = PreviewSampleData.makeSampleBundle()
    return NavigationStack {
        ScrollView {
            LogComparisonView(
                viewModel: AnalyticsViewModel(),
                allLogs: [sample.wineLog, sample.sakeLog, sample.beerLog]
            )
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("ログ比較")
        .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(PreviewSampleData.container)
}
