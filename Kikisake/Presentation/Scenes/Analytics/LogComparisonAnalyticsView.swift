//  LogComparisonAnalyticsView.swift
//  Kikisake

import SwiftUI
import SwiftData

public struct LogComparisonAnalyticsView: View {
    @Bindable var viewModel: AnalyticsViewModel
    let allLogs: [TastingLog]

    @State private var leftLogID: UUID?
    @State private var rightLogID: UUID?
    
    @State private var isShowingLeftPicker = false
    @State private var isShowingRightPicker = false

    public init(viewModel: AnalyticsViewModel, allLogs: [TastingLog]) {
        self.viewModel = viewModel
        self.allLogs = allLogs
    }

    public var body: some View {
        VStack(spacing: 16) {
            // 1. 上部：ログ選択カード（左右）
            HStack(spacing: 12) {
                logSelectorCard(
                    title: String(localized: "左のログ"),
                    selectedLog: leftLog(from: allLogs),
                    action: { isShowingLeftPicker = true }
                )
                
                logSelectorCard(
                    title: String(localized: "右のログ"),
                    selectedLog: rightLog(from: allLogs),
                    action: { isShowingRightPicker = true }
                )
            }

            // 2. 比較コンテンツ
            if let left = leftLog(from: allLogs), let right = rightLog(from: allLogs) {
                comparisonContent(left: left, right: right)
            } else {
                ContentUnavailableView(
                    String(localized: "ログが選択されていません"),
                    systemImage: "arrow.left.arrow.right.circle",
                    description: Text(String(localized: "上のボタンから左右それぞれのログを選択してください。"))
                )
                .padding(.top, 40)
            }
        }
        .sheet(isPresented: $isShowingLeftPicker) {
            LogSelectionSheet(allLogs: allLogs, selectedLogID: $leftLogID)
        }
        .sheet(isPresented: $isShowingRightPicker) {
            LogSelectionSheet(allLogs: allLogs, selectedLogID: $rightLogID)
        }
    }

    private func leftLog(from logs: [TastingLog]) -> TastingLog? {
        if let id = leftLogID {
            return logs.first(where: { $0.id == id })
        }
        return logs.first // デフォルトで最初のログ
    }

    private func rightLog(from logs: [TastingLog]) -> TastingLog? {
        if let id = rightLogID {
            return logs.first(where: { $0.id == id })
        }
        return logs.dropFirst().first ?? logs.first // デフォルトで2番目、なければ最初
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
            // A. ボトル・ラベル写真比較
            comparisonCard(title: String(localized: "ボトル写真")) {
                HStack(spacing: 12) {
                    heroImageThumbnail(for: left)
                    heroImageThumbnail(for: right)
                }
            }

            // B. 総合スコア・評価比較
            comparisonCard(title: String(localized: "評価")) {
                VStack(spacing: 10) {
                    comparisonRow(
                        label: String(localized: "総合スコア"),
                        leftView: AnyView(scoreStarsView(for: left.rating)),
                        rightView: AnyView(scoreStarsView(for: right.rating))
                    )
                }
            }

            // C. 基本情報比較
            comparisonCard(title: String(localized: "基本情報")) {
                VStack(spacing: 10) {
                    comparisonRow(label: String(localized: "酒種"), leftVal: left.item?.category.displayName ?? "-", rightVal: right.item?.category.displayName ?? "-")
                    comparisonRow(label: String(localized: "生産者"), leftVal: left.item?.producer ?? "-", rightVal: right.item?.producer ?? "-")
                    comparisonRow(label: String(localized: "産地"), leftVal: left.item?.region ?? "-", rightVal: right.item?.region ?? "-")
                    comparisonRow(label: String(localized: "価格"), leftVal: left.item?.price.map { "\($0) 円" } ?? "-", rightVal: right.item?.price.map { "\($0) 円" } ?? "-")
                }
            }

            // D. 外観・カラー・香り比較
            comparisonCard(title: String(localized: "外観・香り")) {
                VStack(spacing: 10) {
                    comparisonRow(
                        label: String(localized: "外観"),
                        leftView: AnyView(colorChipView(colorHex: left.appearanceColorHex, note: left.appearanceNotes)),
                        rightView: AnyView(colorChipView(colorHex: right.appearanceColorHex, note: right.appearanceNotes))
                    )
                    Divider()
                    comparisonRow(
                        label: String(localized: "香りタグ"),
                        leftView: AnyView(tagFlow(tags: left.aromaTags)),
                        rightView: AnyView(tagFlow(tags: right.aromaTags))
                    )
                }
            }

            // E. 味わいレーダーチャート並列比較
            comparisonCard(title: String(localized: "テイストバランス")) {
                HStack(spacing: 12) {
                    TasteRadarCardView(log: left, isCompactMode: true)
                    TasteRadarCardView(log: right, isCompactMode: true)
                }
            }

            // F. マトリクス分析並列比較
            comparisonCard(title: String(localized: "マトリクス位置")) {
                HStack(spacing: 12) {
                    MatrixAnalysisCardView(log: left, isCompactMode: true)
                    MatrixAnalysisCardView(log: right, isCompactMode: true)
                }
            }

            // G. ペアリング・メモ比較
            comparisonCard(title: String(localized: "ペアリング等")) {
                VStack(spacing: 10) {
                    comparisonRow(label: String(localized: "ペアリング"), leftVal: left.pairing ?? "-", rightVal: right.pairing ?? "-")
                    Divider()
                    comparisonRow(label: String(localized: "メモ"), leftVal: left.memo.isEmpty ? "-" : left.memo, rightVal: right.memo.isEmpty ? "-" : right.memo)
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

    @ViewBuilder
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

    @ViewBuilder
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
            // セクションタイトルを中央揃えに修正
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

    // テキスト用の汎用比較行
    private func comparisonRow(label: String, leftVal: String, rightVal: String) -> some View {
        HStack {
            Text(leftVal)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
            
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 76, alignment: .center)
                .multilineTextAlignment(.center)
            
            Text(rightVal)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
    }

    // Viewビルダー用の汎用比較行（スコアやカラーチップなど複雑なビュー用）
    private func comparisonRow(label: String, leftView: AnyView, rightView: AnyView) -> some View {
        HStack {
            leftView
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 76, alignment: .center)
                .multilineTextAlignment(.center)
            
            rightView
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

/// ログ選択用シート
public struct LogSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let allLogs: [TastingLog]
    @Binding var selectedLogID: UUID?

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
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let wineItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        price: 8500
    )
    let wineLog = TastingLog(
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        aromaTags: ["チェリー", "樽香"],
        sweetness: 2.0,
        acidity: 4.2,
        tannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        pairing: "和牛のローストビーフ",
        memo: "素晴らしいネッビオーロ。",
        isEvaluated: true,
        item: wineItem
    )

    let sakeItem = BeverageItem(
        name: "新政 No.6",
        producer: "新政酒造",
        category: .sake,
        region: "秋田県",
        vintage: "2024",
        price: 3200
    )
    let sakeLog = TastingLog(
        rating: 4.6,
        appearanceNotes: "クリスタル",
        appearanceColorHex: "#E6F2FF",
        aromaTags: ["洋梨", "メロン"],
        sweetness: 3.2,
        acidity: 3.8,
        body: 3.0,
        finishLength: 4.0,
        pairing: "白身魚のカルパッチョ",
        memo: "ジューシーな酸味。",
        isEvaluated: true,
        item: sakeItem
    )

    container.mainContext.insert(wineItem)
    container.mainContext.insert(wineLog)
    container.mainContext.insert(sakeItem)
    container.mainContext.insert(sakeLog)

    let viewModel = AnalyticsViewModel()

    return NavigationStack {
        ScrollView {
            LogComparisonAnalyticsView(viewModel: viewModel, allLogs: [wineLog, sakeLog])
                .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("ログ比較")
        .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(container)
}
