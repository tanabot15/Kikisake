//
//  Formatters.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

public enum Formatters {
    public static func currencyString(from price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.currencyCode = "JPY"

        return formatter.string(from: NSNumber(value: price)) ?? "¥\(price)"
    }
}
