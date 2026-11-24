//
//  TasteRadarCardView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/19.
//

import SwiftUI
import SwiftData

/// 味わい構造（多角形・レーダーチャート）カードコンポーネント
public struct TasteRadarCardView: View {
    public struct TasteAxisItem: Identifiable, Hashable {
        public let id: String
        public let title: String
        public let value: Double

        public init(title: String, value: Double) {
            self.id = title
            self.title = title
            self.value = value
        }
    }

    private struct ChartMetrics {
        let levels: Int
        let frameHeight: CGFloat
        let radiusOffset: CGFloat
        let fontTitleSize: CGFloat
        let fontValueSize: CGFloat

        init(isCompactMode: Bool) {
            self.levels = isCompactMode ? 3 : 4
            self.frameHeight = isCompactMode ? 96 : 220
            self.radiusOffset = isCompactMode ? 15 : 26
            self.fontTitleSize = isCompactMode ? 7.5 : 10
            self.fontValueSize = isCompactMode ? 7.5 : 9
        }
    }

    let log: TastingLog
    let isCompactMode: Bool

    /// 表示コンテキスト
    public enum PresentationStyle {
        case standard
        case shareCard(
            accentColor: Color,
            surfaceColor: Color,
            lineColor: Color,
            textColor: Color,
            mutedTextColor: Color
        )
    }

    let presentationStyle: PresentationStyle

    public init(
        log: TastingLog,
        isCompactMode: Bool = false,
        presentationStyle: PresentationStyle = .standard
    ) {
        self.log = log
        self.isCompactMode = isCompactMode
        self.presentationStyle = presentationStyle
    }

    /// 味わい構造の項目リスト（塩味を含む）を生成するヘルパー
    public static func tasteItems(for log: TastingLog) -> [TasteAxisItem] {
        var items: [TasteAxisItem] = [
            .init(title: "甘味", value: log.sweetness),
            .init(title: "酸味", value: log.acidity),
            .init(title: "苦味", value: log.bitterness),
            .init(title: "旨味", value: log.umami),
            .init(title: "塩味", value: log.saltiness)
        ]

        if let tannin = log.tannin {
            items.append(.init(title: "渋味", value: tannin))
        }

        items.append(.init(title: "ボディ", value: log.body))
        items.append(.init(title: "余韻", value: log.finishLength))

        return items
    }

    public var body: some View {
        let items = Self.tasteItems(for: log)
        let metrics = ChartMetrics(isCompactMode: isCompactMode)

        switch presentationStyle {
        case .standard:
            standardContent(items: items, metrics: metrics)

        case let .shareCard(accentColor, surfaceColor, lineColor, textColor, mutedTextColor):
            shareCardContent(
                items: items,
                metrics: metrics,
                accentColor: accentColor,
                surfaceColor: surfaceColor,
                lineColor: lineColor,
                textColor: textColor,
                mutedTextColor: mutedTextColor
            )
        }
    }

    // MARK: - Standard

    @ViewBuilder
    private func standardContent(items: [TasteAxisItem], metrics: ChartMetrics) -> some View {
        if isCompactMode {
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text("味わいプロファイル")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.primary)
                    Spacer()
                }

                radarChart(
                    items: items,
                    metrics: metrics,
                    fillColor: Color.accentColor.opacity(0.25),
                    strokeColor: Color.accentColor,
                    pointColor: Color.accentColor,
                    gridColor: Color(.systemGray4),
                    titleColor: .primary,
                    valueColor: .secondary,
                    useEditorialStyle: false
                )
            }
            .padding(6)
            .background(Color(.systemGray6).opacity(0.6))
            .cornerRadius(10)
        } else {
            VStack(spacing: 14) {
                HStack {
                    Text("味わい構造プロファイル")
                        .font(.headline)
                    Spacer()
                }

                radarChart(
                    items: items,
                    metrics: metrics,
                    fillColor: Color.accentColor.opacity(0.25),
                    strokeColor: Color.accentColor,
                    pointColor: Color.accentColor,
                    gridColor: Color(.systemGray4),
                    titleColor: .primary,
                    valueColor: .secondary,
                    useEditorialStyle: false
                )
                .padding(.vertical, 8)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - Share Card Editorial

    @ViewBuilder
    private func shareCardContent(
        items: [TasteAxisItem],
        metrics: ChartMetrics,
        accentColor: Color,
        surfaceColor: Color,
        lineColor: Color,
        textColor: Color,
        mutedTextColor: Color
    ) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("TASTE PROFILE")
                        .font(.system(size: isCompactMode ? 6.5 : 8, weight: .black))
                        .tracking(1.4)
                        .foregroundStyle(textColor)

                    Text("味わい構造")
                        .font(.system(size: isCompactMode ? 8 : 11, weight: .bold, design: .serif))
                        .foregroundStyle(textColor)
                }

                Spacer()

                Text("01")
                    .font(.system(size: isCompactMode ? 7 : 9, weight: .medium, design: .serif))
                    .foregroundStyle(mutedTextColor)
            }

            Rectangle()
                .fill(lineColor.opacity(0.22))
                .frame(height: 0.5)

            radarChart(
                items: items,
                metrics: metrics,
                fillColor: accentColor.opacity(0.18),
                strokeColor: accentColor,
                pointColor: accentColor,
                gridColor: lineColor.opacity(0.32),
                titleColor: textColor,
                valueColor: mutedTextColor,
                useEditorialStyle: true
            )
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, isCompactMode ? 7 : 12)
        .padding(.vertical, isCompactMode ? 6 : 10)
        .background(
            RoundedRectangle(cornerRadius: isCompactMode ? 8 : 12, style: .continuous)
                .fill(surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: isCompactMode ? 8 : 12, style: .continuous)
                .stroke(lineColor.opacity(0.22), lineWidth: 0.7)
        )
    }

    // MARK: - Shared Radar Chart

    @ViewBuilder
    private func radarChart(
        items: [TasteAxisItem],
        metrics: ChartMetrics,
        fillColor: Color,
        strokeColor: Color,
        pointColor: Color,
        gridColor: Color,
        titleColor: Color,
        valueColor: Color,
        useEditorialStyle: Bool
    ) -> some View {
        let normalizedValues = items.map { $0.value / 5.0 }

        ZStack {
            ForEach(1...metrics.levels, id: \.self) { level in
                let isOuterLevel = level == metrics.levels
                RadarPolygon(
                    sides: items.count,
                    scale: CGFloat(level) / CGFloat(metrics.levels),
                    radiusOffset: metrics.radiusOffset
                )
                .stroke(
                    useEditorialStyle ? gridColor.opacity(isOuterLevel ? 1.0 : 0.65) : gridColor,
                    lineWidth: useEditorialStyle
                        ? (isOuterLevel ? 0.7 : 0.45)
                        : (isCompactMode ? 0.5 : (isOuterLevel ? 1 : 0.5))
                )
            }

            RadarAxesLines(
                sides: items.count,
                radiusOffset: metrics.radiusOffset
            )
            .stroke(
                useEditorialStyle ? gridColor.opacity(0.75) : gridColor,
                lineWidth: useEditorialStyle ? 0.45 : (isCompactMode ? 0.5 : 0.8)
            )

            RadarPolygonShape(
                values: normalizedValues,
                radiusOffset: metrics.radiusOffset
            )
            .fill(fillColor)

            RadarPolygonShape(
                values: normalizedValues,
                radiusOffset: metrics.radiusOffset
            )
            .stroke(
                strokeColor,
                lineWidth: useEditorialStyle
                    ? (isCompactMode ? 1.2 : 1.5)
                    : (isCompactMode ? 1.5 : 2)
            )

            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 2 - metrics.radiusOffset
                let labelOffset: CGFloat = isCompactMode ? (useEditorialStyle ? 7 : 6) : (useEditorialStyle ? 13 : 14)

                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let angle = (CGFloat(index) * 2.0 * .pi / CGFloat(items.count)) - (.pi / 2)
                    let clampedVal = max(0.0, min(1.0, item.value / 5.0))
                    let dotX = center.x + radius * CGFloat(clampedVal) * cos(angle)
                    let dotY = center.y + radius * CGFloat(clampedVal) * sin(angle)
                    let x = center.x + (radius + labelOffset) * cos(angle)
                    let y = center.y + (radius + labelOffset) * sin(angle)

                    if useEditorialStyle {
                        Circle()
                            .fill(pointColor)
                            .frame(width: isCompactMode ? 3.5 : 5, height: isCompactMode ? 3.5 : 5)
                            .position(x: dotX, y: dotY)
                    }

                    axisLabelView(
                        item: item,
                        metrics: metrics,
                        titleColor: titleColor,
                        valueColor: valueColor,
                        useEditorialStyle: useEditorialStyle
                    )
                    .position(x: x, y: y)
                }
            }
        }
        .frame(height: metrics.frameHeight)
    }

    @ViewBuilder
    private func axisLabelView(
        item: TasteAxisItem,
        metrics: ChartMetrics,
        titleColor: Color,
        valueColor: Color,
        useEditorialStyle: Bool
    ) -> some View {
        let showValue = !isCompactMode

        if useEditorialStyle {
            VStack(spacing: 1) {
                Text(item.title)
                    .font(.system(size: metrics.fontTitleSize, weight: .semibold, design: .serif))
                    .foregroundStyle(titleColor)

                if showValue {
                    Text(String(format: "%.1f", item.value))
                        .font(.system(size: metrics.fontValueSize, weight: .medium, design: .monospaced))
                        .foregroundStyle(valueColor)
                }
            }
            .multilineTextAlignment(.center)
        } else if showValue {
            VStack(spacing: 0) {
                Text(item.title)
                    .font(.system(size: metrics.fontTitleSize, weight: .bold))
                    .foregroundStyle(titleColor)

                Text(String(format: "%.1f", item.value))
                    .font(.system(size: metrics.fontValueSize, weight: .medium))
                    .foregroundStyle(valueColor)
            }
        } else {
            Text(item.title)
                .font(.system(size: metrics.fontTitleSize, weight: .bold))
                .foregroundStyle(titleColor)
        }
    }
}

#Preview("Standard") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018"
    )

    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "素晴らしいバランス",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return VStack {
        TasteRadarCardView(log: sampleLog, isCompactMode: false, presentationStyle: .standard)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Share Card") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018"
    )

    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "素晴らしいバランス",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return TasteRadarCardView(
        log: sampleLog,
        isCompactMode: false,
        presentationStyle: .shareCard(
            accentColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            surfaceColor: Color(red: 0.975, green: 0.965, blue: 0.935),
            lineColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            textColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            mutedTextColor: Color(red: 0.105, green: 0.095, blue: 0.085).opacity(0.56)
        )
    )
    .padding()
    .background(Color.black)
    .modelContainer(container)
}

#Preview("Share Card Compact") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018"
    )

    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "素晴らしいバランス",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return TasteRadarCardView(
        log: sampleLog,
        isCompactMode: true,
        presentationStyle: .shareCard(
            accentColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            surfaceColor: Color(red: 0.975, green: 0.965, blue: 0.935),
            lineColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            textColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            mutedTextColor: Color(red: 0.105, green: 0.095, blue: 0.085).opacity(0.56)
        )
    )
    .frame(width: 170)
    .padding()
    .background(Color.black)
    .modelContainer(container)
}
