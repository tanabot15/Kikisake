//
//  View+Extension.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

extension View {
    public func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    public func cardStyle(backgroundColor: Color = Color(.systemBackground)) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    Text("Card Style Preview")
        .cardStyle()
        .padding()
        .background(Color(.systemGroupedBackground))
}
