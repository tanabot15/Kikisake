//  AddLocationSheetView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// 保管場所を追加するためのシートビュー
public struct AddLocationSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedType: StorageCategoryType = .cellar
    @State private var memo: String = ""
    
    // グリッド設定用のState（デフォルトで有効に設定）
    @State private var isGridEnabled: Bool = true
    @State private var gridRows: Int = 4
    @State private var gridColumns: Int = 6

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

                // セラー構造（グリッド）設定セクション
                Section("セラー構造・棚番マッピング") {
                    Toggle("グリッド（棚）で視覚管理する", isOn: $isGridEnabled)
                    
                    if isGridEnabled {
                        Stepper("段数（行）: \(gridRows)段", value: $gridRows, in: 1...10)
                        Stepper("1段あたりの本数（列）: \(gridColumns)本", value: $gridColumns, in: 1...12)
                    }
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
                        let newLoc = StorageLocation(
                            name: name,
                            type: selectedType,
                            memo: memo,
                            isGridEnabled: isGridEnabled,
                            gridRows: gridRows,
                            gridColumns: gridColumns
                        )
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
