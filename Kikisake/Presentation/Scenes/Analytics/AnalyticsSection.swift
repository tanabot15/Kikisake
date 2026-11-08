//  AnalyticsSection.swift
//  Kikisake

import Foundation

/// 分析画面の表示セクション種類
public enum AnalyticsSection: String, CaseIterable, Identifiable {
    case consumption
    case evaluation
    case comparison

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .consumption:
            return String(localized: "飲酒ログ")
        case .evaluation:
            return String(localized: "評価")
        case .comparison:
            return String(localized: "比較")
        }
    }
}
