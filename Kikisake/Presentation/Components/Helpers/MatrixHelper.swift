//
//  MatrixHelper.swift
//  Kikisake
//

import Foundation

public struct MatrixAxesSpec: Hashable {
    public let xTitle: String
    public let xLow: String
    public let xHigh: String
    public let yTitle: String
    public let yLow: String
    public let yHigh: String
    public let topLeft: String
    public let topRight: String
    public let bottomLeft: String
    public let bottomRight: String
}

/// マトリクス計算用ヘルパー
public enum MatrixHelper {
    public static func axes(for category: BeverageCategory) -> MatrixAxesSpec {
        switch category {
        case .wine:
            return MatrixAxesSpec(
                xTitle: "味わいスタイル",
                xLow: "ドライ/辛口",
                xHigh: "まろやか/甘口",
                yTitle: "ボディ",
                yLow: "ライト",
                yHigh: "フル",
                topLeft: "軽快・甘口",
                topRight: "重厚・甘口",
                bottomLeft: "すっきり辛口",
                bottomRight: "本格フルボディ"
            )

        case .sake:
            return MatrixAxesSpec(
                xTitle: "濃淡・熟成",
                xLow: "淡麗・フレッシュ",
                xHigh: "濃醇・熟成",
                yTitle: "香味タイプ",
                yLow: "軽快",
                yHigh: "芳醇",
                topLeft: "薫酒 (華やか)",
                topRight: "醇酒 (旨口)",
                bottomLeft: "爽酒 (清涼)",
                bottomRight: "熟酒 (古酒)"
            )

        case .beer:
            return MatrixAxesSpec(
                xTitle: "ホップの効き",
                xLow: "マイルド",
                xHigh: "芳醇/高苦味",
                yTitle: "コク・ボディ",
                yLow: "ライト",
                yHigh: "重厚",
                topLeft: "スタウト・黒",
                topRight: "インペリアルIPA",
                bottomLeft: "ピルスナー系",
                bottomRight: "ペールエール"
            )
        }
    }

    public static func xCoordinate(for log: TastingLog, category: BeverageCategory) -> Double {
        let rawVal: Double
        switch category {
        case .wine:
            rawVal = log.sweetness
        case .sake:
            rawVal = log.body
        case .beer:
            rawVal = log.bitterness
        }
        return normalizeScore(rawVal)
    }

    public static func yCoordinate(for log: TastingLog, category: BeverageCategory) -> Double {
        let rawVal: Double
        switch category {
        case .wine, .beer:
            rawVal = log.body
        case .sake:
            rawVal = log.umami
        }
        return normalizeScore(rawVal)
    }

    private static func normalizeScore(_ rawValue: Double) -> Double {
        max(0.0, min(1.0, (rawValue - 1.0) / 4.0))
    }
}
