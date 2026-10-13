//
//  Formatters.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

/// 各種フォーマットを提供するユーティリティ
public struct Formatters {
    /// 価格を日本円の通貨形式（例: ¥1,000）の文字列に変換する
    /// - Parameter price: 価格（整数）
    /// - Returns: フォーマット済み文字列
    public static func currencyString(from price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: NSNumber(value: price)) ?? "¥\(price)"
    }
}
