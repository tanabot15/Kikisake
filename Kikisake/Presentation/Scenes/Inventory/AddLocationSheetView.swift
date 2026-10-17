//
//  AddLocationSheetView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/17.
//

import SwiftUI
import SwiftData

/// 保管場所を追加するためのシートビュー
public struct AddLocationSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedType: StorageCategoryType = .cellar
    @State private var memo: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("保管場所の名称") {
                    TextField("例: 自宅メインセラー", text: $name)
                }

                Section("種類") {
                    Picker("種類", selection: $selectedType) {
                        ForEach(StorageCategoryType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("補足メモ (任意)") {
                    TextField("例: 温度14度設定", text: $memo)
                }
            }
            .navigationTitle("保管場所の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let newLoc = StorageLocation(name: name, type: selectedType, memo: memo)
                        modelContext.insert(newLoc)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddLocationSheetView()
        .modelContainer(for: [StorageLocation.self], inMemory: true)
}
