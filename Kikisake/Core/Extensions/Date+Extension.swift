//
//  Date+Extension.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

extension Date {
    /// 指定されたフォーマットの文字列に変換する
    /// - Parameter format: 日付フォーマット文字列 (デフォルト: "yyyy年M月d日")
    /// - Returns: フォーマット済みの文字列
    public func toFormattedString(format: String = "yyyy年M月d日") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
}
