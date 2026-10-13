//
//  View+Extension.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

extension View {
    /// フォーカスを外してキーボードを非表示にする
    public func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// 角丸と微小なシャドウを付与したカード風モディファイア
    /// - Parameter backgroundColor: 背景色
    /// - Returns: スタイル適用済みのView
    public func cardStyle(backgroundColor: Color = Color(.systemBackground)) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
