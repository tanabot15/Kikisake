//
//  Date+Extension.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

extension Date {
    /// 端末の言語設定に合わせたフォーマットの文字列に変換する
    public func toFormattedString(format: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // 端末の現在の言語設定（ロケール）に自動追従
        
        if let format = format {
            formatter.dateFormat = format
        } else {
            // フォーマットが指定されていない場合は、端末の言語・地域に応じた標準的なスタイルを自動適用
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        }
        
        return formatter.string(from: self)
    }
}
