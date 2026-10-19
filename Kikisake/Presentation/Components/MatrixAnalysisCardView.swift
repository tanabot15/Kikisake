//
//  MatrixAnalysisCardView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/19.
//

import SwiftUI
import SwiftData

/// 2軸4象限マトリクス分析カードコンポーネント
public struct MatrixAnalysisCardView: View {
    let log: TastingLog
    let isCompactMode: Bool

    public init(log: TastingLog, isCompactMode: Bool = false) {
        self.log = log
        self.isCompactMode = isCompactMode
    }

    public var body: some View {
        let category = log.item?.category ?? .wine
        let axes = MatrixHelper.axes(for: category)
        let xValue = MatrixHelper.xCoordinate(for: log, category: category)
        let yValue = MatrixHelper.yCoordinate(for: log, category: category)

        if isCompactMode {
            return AnyView(
                VStack(spacing: 2) {
                    Text("マトリクス位置")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 0.8))

                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 65))
                            path.addLine(to: CGPoint(x: 170, y: 65))
                            path.move(to: CGPoint(x: 85, y: 0))
                            path.addLine(to: CGPoint(x: 85, y: 130))
                        }
                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.8, dash: [2]))

                        GeometryReader { geo in
                            let px = CGFloat(xValue) * (geo.size.width - 16) + 8
                            let py = CGFloat(1.0 - yValue) * (geo.size.height - 16) + 8

                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                .position(x: px, y: py)
                        }
                    }
                    .frame(height: 130)
                }
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(Color(.systemGray6).opacity(0.6))
                .cornerRadius(10)
            )
        } else {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("プロフェッショナル・マトリクス分析")
                            .font(.headline)
                        Spacer()
                    }

                    VStack(spacing: 4) {
                        HStack {
                            Spacer()
                            Text("▲ \(axes.yTitle): \(axes.yHigh)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        HStack(spacing: 4) {
                            Text("◀\n\(axes.xLow)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(width: 48)

                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGroupedBackground))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))

                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: 100))
                                    path.addLine(to: CGPoint(x: 260, y: 100))
                                    path.move(to: CGPoint(x: 130, y: 0))
                                    path.addLine(to: CGPoint(x: 130, y: 200))
                                }
                                .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))

                                VStack {
                                    HStack {
                                        Text(axes.topLeft)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.secondary.opacity(0.8))
                                        Spacer()
                                        Text(axes.topRight)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.secondary.opacity(0.8))
                                    }
                                    Spacer()
                                    HStack {
                                        Text(axes.bottomLeft)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.secondary.opacity(0.8))
                                        Spacer()
                                        Text(axes.bottomRight)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.secondary.opacity(0.8))
                                    }
                                }
                                .padding(8)

                                GeometryReader { geo in
                                    let px = CGFloat(xValue) * (geo.size.width - 24) + 12
                                    let py = CGFloat(1.0 - yValue) * (geo.size.height - 24) + 12

                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.3))
                                            .frame(width: 24, height: 24)

                                        Circle()
                                            .fill(Color.accentColor)
                                            .frame(width: 12, height: 12)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    }
                                    .position(x: px, y: py)
                                }
                            }
                            .frame(height: 200)

                            Text("\(axes.xHigh)\n▶")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(width: 48)
                        }

                        HStack {
                            Spacer()
                            Text("▼ \(axes.yTitle): \(axes.yLow)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            )
        }
    }
}

// MARK: - マトリクス計算用ヘルパー
public enum MatrixHelper {
    public static func axes(for category: BeverageCategory) -> (xTitle: String, xLow: String, xHigh: String, yTitle: String, yLow: String, yHigh: String, topLeft: String, topRight: String, bottomLeft: String, bottomRight: String) {
        switch category {
        case .wine:
            return (
                xTitle: "味わいスタイル", xLow: "ドライ/辛口", xHigh: "まろやか/甘口",
                yTitle: "ボディ", yLow: "ライト", yHigh: "フル",
                topLeft: "軽快・甘口", topRight: "重厚・甘口",
                bottomLeft: "すっきり辛口", bottomRight: "本格フルボディ"
            )
        case .sake:
            return (
                xTitle: "濃淡・熟成", xLow: "淡麗・フレッシュ", xHigh: "濃醇・熟成",
                yTitle: "香味タイプ", yLow: "軽快", yHigh: "芳醇",
                topLeft: "薫酒 (華やか)", topRight: "醇酒 (旨口)",
                bottomLeft: "爽酒 (清涼)", bottomRight: "熟酒 (古酒)"
            )
        case .beer:
            return (
                xTitle: "ホップの効き", xLow: "マイルド", xHigh: "芳醇/高苦味",
                yTitle: "コク・ボディ", yLow: "ライト", yHigh: "重厚",
                topLeft: "スタウト・黒", topRight: "インペリアルIPA",
                bottomLeft: "ピルスナー系", bottomRight: "ペールエール"
            )
        }
    }

    public static func xCoordinate(for log: TastingLog, category: BeverageCategory) -> Double {
        let rawVal: Double
        switch category {
        case .wine: rawVal = log.sweetness
        case .sake: rawVal = Double(log.body)
        case .beer: rawVal = log.bitterness
        }
        return max(0.0, min(1.0, (rawVal - 1.0) / 4.0))
    }

    public static func yCoordinate(for log: TastingLog, category: BeverageCategory) -> Double {
        let rawVal: Double
        switch category {
        case .wine: rawVal = log.body
        case .sake: rawVal = log.umami
        case .beer: rawVal = log.body
        }
        return max(0.0, min(1.0, (rawVal - 1.0) / 4.0))
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

    return MatrixAnalysisCardView(log: sampleLog)
        .padding()
        .modelContainer(container)
}
