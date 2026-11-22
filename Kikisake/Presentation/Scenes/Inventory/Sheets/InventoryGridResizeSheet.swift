//
//  InventoryGridResizeSheet.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Sheet for adjusting grid dimensions of a storage location.
struct InventoryGridResizeSheet: View {
    let location: StorageLocation
    @Binding var rows: Int
    @Binding var columns: Int
    let onSave: (Int, Int) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "セラーの構造設定")) {
                    Stepper(String(format: String(localized: "段数（行）: %d段"), rows), value: $rows, in: 1...10)
                    Stepper(String(format: String(localized: "1段あたりの本数（列）: %d本"), columns), value: $columns, in: 1...12)
                }

                Section {
                    Text(String(localized: "※縮小した際、新しいグリッド範囲外（はみ出し部分）に配置されていたボトルは、自動的に「棚の外（未配置）」に移動されます。"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(String(format: String(localized: "%@のサイズ変更"), location.name))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "キャンセル")) {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "保存")) {
                        onSave(rows, columns)
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
