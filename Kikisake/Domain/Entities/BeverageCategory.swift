//
//  BeverageCategory.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

/// 酒種を表す列挙型
public enum BeverageCategory: String, Codable, CaseIterable, Sendable {
    case wine
    case sake
    case beer
    
    /// ✨ Localizable.xcstrings が自動検出し、英訳を行えるように直接文字列リテラルを指定
    public var displayName: String {
        switch self {
        case .wine:
            return String(localized: "ワイン")
        case .sake:
            return String(localized: "日本酒")
        case .beer:
            return String(localized: "ビール")
        }
    }
}
