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
    let log: TastingLog
    let isCompactMode: Bool

    public init(log: TastingLog, isCompactMode: Bool = false) {
        self.log = log
        self.isCompactMode = isCompactMode
    }

    /// 味わい構造の項目リスト（塩味を含む）を生成するヘルパー
    public static func tasteItems(for log: TastingLog) -> [(title: String, value: Double)] {
        var items: [(title: String, value: Double)] = [
            ("甘味", log.sweetness),
            ("酸味", log.acidity),
            ("苦味", log.bitterness),
            ("旨味", log.umami),
            ("塩味", log.saltiness)
        ]
        if let tannin = log.tannin {
            items.append(("渋味", tannin))
        }
        items.append(("ボディ", log.body))
        items.append(("余韻", log.finishLength))
        return items
    }

    public var body: some View {
        let items = Self.tasteItems(for: log)
        let levels = isCompactMode ? 3 : 4
        let frameHeight: CGFloat = isCompactMode ? 104 : 240
        let radiusOffset: CGFloat = isCompactMode ? 16 : 28
        let fontTitleSize: CGFloat = isCompactMode ? 8 : 10
        let fontValueSize: CGFloat = isCompactMode ? 8 : 9

        // 条件に応じて外側の装飾（パディングや背景色）を切り分ける
        Group {
            if isCompactMode {
                VStack(spacing: 2) {
                    // マトリクス側と高さを合わせるためのヘッダー行
                    HStack(spacing: 2) {
                        Text("味わいプロファイル")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.primary)
                        Spacer()
                    }

                    radarChartContent(items: items, levels: levels, frameHeight: frameHeight, radiusOffset: radiusOffset, fontTitleSize: fontTitleSize, fontValueSize: fontValueSize)
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

                    radarChartContent(items: items, levels: levels, frameHeight: frameHeight, radiusOffset: radiusOffset, fontTitleSize: fontTitleSize, fontValueSize: fontValueSize)
                        .padding(.vertical, 8)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
        }
    }

    /// レーダーチャートの描画本体（共通部分）
    @ViewBuilder
    private func radarChartContent(items: [(title: String, value: Double)], levels: Int, frameHeight: CGFloat, radiusOffset: CGFloat, fontTitleSize: CGFloat, fontValueSize: CGFloat) -> some View {
        ZStack {
            ForEach(1...levels, id: \.self) { level in
                RadarPolygon(sides: items.count, scale: CGFloat(level) / CGFloat(levels), radiusOffset: radiusOffset)
                    .stroke(Color(.systemGray4), lineWidth: isCompactMode ? 0.5 : (level == levels ? 1 : 0.5))
            }

            RadarAxesLines(sides: items.count, radiusOffset: radiusOffset)
                .stroke(Color(.systemGray4), lineWidth: isCompactMode ? 0.5 : 0.8)

            RadarPolygonShape(values: items.map { $0.value / 5.0 }, radiusOffset: radiusOffset)
                .fill(Color.accentColor.opacity(0.25))

            RadarPolygonShape(values: items.map { $0.value / 5.0 }, radiusOffset: radiusOffset)
                .stroke(Color.accentColor, lineWidth: isCompactMode ? 1.5 : 2)

            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 2 - radiusOffset

                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let angle = (CGFloat(index) * 2.0 * .pi / CGFloat(items.count)) - (.pi / 2)
                    let labelOffset: CGFloat = isCompactMode ? 6 : 14
                    let x = center.x + (radius + labelOffset) * cos(angle)
                    let y = center.y + (radius + labelOffset) * sin(angle)

                    if isCompactMode {
                        Text(item.title)
                            .font(.system(size: fontTitleSize, weight: .bold))
                            .foregroundStyle(.primary)
                            .position(x: x, y: y)
                    } else {
                        VStack(spacing: 1) {
                            Text(item.title)
                                .font(.system(size: fontTitleSize, weight: .bold))
                                .foregroundStyle(.primary)
                            Text(String(format: "%.1f", item.value))
                                .font(.system(size: fontValueSize))
                                .foregroundStyle(.secondary)
                        }
                        .position(x: x, y: y)
                    }
                }
            }
        }
        .frame(height: frameHeight)
    }
}

// MARK: - レーダーチャート用ヘルパーシェイプ
public struct RadarPolygon: Shape {
    public let sides: Int
    public let scale: CGFloat
    public let radiusOffset: CGFloat

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = (min(rect.width, rect.height) / 2 - radiusOffset) * scale

        for i in 0..<sides {
            let angle = (CGFloat(i) * 2.0 * .pi / CGFloat(sides)) - (.pi / 2)
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

public struct RadarAxesLines: Shape {
    public let sides: Int
    public let radiusOffset: CGFloat

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - radiusOffset

        for i in 0..<sides {
            let angle = (CGFloat(i) * 2.0 * .pi / CGFloat(sides)) - (.pi / 2)
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            path.move(to: center)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

public struct RadarPolygonShape: Shape {
    public let values: [Double]
    public let radiusOffset: CGFloat

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - radiusOffset
        let sides = values.count

        for (i, value) in values.enumerated() {
            let clampedVal = max(0.0, min(1.0, value))
            let angle = (CGFloat(i) * 2.0 * .pi / CGFloat(sides)) - (.pi / 2)
            let x = center.x + radius * CGFloat(clampedVal) * cos(angle)
            let y = center.y + radius * CGFloat(clampedVal) * sin(angle)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
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

    return TasteRadarCardView(log: sampleLog)
        .padding()
        .modelContainer(container)
}
