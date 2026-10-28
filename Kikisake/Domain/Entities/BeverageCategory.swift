//
//  BeverageCategory.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

/// 酒種を表す列挙型
public enum BeverageCategory: String, Codable, CaseIterable, Sendable {
    case wine = "ワイン"
    case sake = "日本酒"
    case beer = "ビール"
    
    /// ✨ 画面表示用の名称（Localizable.xcstrings対応）
    public var displayName: String {
        return String(localized: String.LocalizationValue(rawValue))
    }
}
