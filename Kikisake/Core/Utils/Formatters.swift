//
//  Formatters.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

/// 各種フォーマットを提供するユーティリティ
public struct Formatters {
    /// 価格を通貨形式の文字列に変換する（端末のロケールに自動対応）
    /// - Parameter price: 価格（整数）
    /// - Returns: フォーマット済み文字列
    public static func currencyString(from price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        // デフォルトの通貨コードを JPY にしつつ、ロケールが英語圏等の場合は
        // そのロケールに適した通貨記号・表示形式に自動でアタッチされます
        formatter.currencyCode = "JPY"
        
        return formatter.string(from: NSNumber(value: price)) ?? "¥\(price)"
    }
}
