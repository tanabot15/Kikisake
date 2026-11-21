//
//  TastingCustomizationEditSheets.swift
//  Kikisake
//

import SwiftUI

/// Edit modal/sheet for an existing custom color item.
struct CustomColorEditSheet: View {
    @Binding var item: CustomColorItem?
    @Binding var nameText: String
    @Binding var colorValue: Color
    let onSave: (CustomColorItem, String, Color) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "色の変更")) {
                    ColorPicker(String(localized: "カラーを選択"), selection: $colorValue, supportsOpacity: false)
                    TextField(String(localized: "色名"), text: $nameText)
                }
            }
            .navigationTitle(String(localized: "外観カラーの編集"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "キャンセル")) {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "保存")) {
                        if let currentItem = item {
                            onSave(currentItem, nameText, colorValue)
                        }
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.height(280)])
    }
}
