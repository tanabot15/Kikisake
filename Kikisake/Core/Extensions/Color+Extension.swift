//  Color+Extension.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

extension Color {
    /// アプリ共通のアクセントカラー
    public static let kikisakePrimary = Color.accentColor
    
    /// グループ化されたリスト等の背景色
    public static let kikisakeBackground = Color(.systemGroupedBackground)
    
    /// カードやセルの背景色
    public static let kikisakeCardBackground = Color(.secondarySystemGroupedBackground)

    /// ✨ HEXカラー文字列（例: "#991A33" や "991A33"）からSwiftUIのColorを生成するイニシャライザ
    public init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
