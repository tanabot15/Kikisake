//
//  Date+Extension.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

extension Date {
    public func toFormattedString(format: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        if let format {
            formatter.dateFormat = format
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        }

        return formatter.string(from: self)
    }
}
