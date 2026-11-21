//
//  AddLocationSheetView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Sheet view for adding a new storage location.
public struct AddLocationSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedType: StorageCategoryType = .cellar
    @State private var memo: String = ""

    @State private var isGridEnabled: Bool = true
    @State private var gridRows: Int = 4
    @State private var gridColumns: Int = 6

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "保管場所の名称")) {
                    TextField(String(localized: "例: 自宅メインセラー"), text: $name)
                }

                Section(String(localized: "種類")) {
                    Picker(String(localized: "種類"), selection: $selectedType) {
                        ForEach(StorageCategoryType.allCases) { type in
                            Text(type.localizedName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(String(localized: "補足メモ (任意)")) {
                    TextField(String(localized: "例: 温度14度設定"), text: $memo)
                }

                Section(String(localized: "セラー構造・棚番マッピング")) {
                    Toggle(String(localized: "グリッドで視覚管理する"), isOn: $isGridEnabled)

                    if isGridEnabled {
                        Stepper(String(format: String(localized: "段数（行）: %d段"), gridRows), value: $gridRows, in: 1...10)
                        Stepper(String(format: String(localized: "1段あたりの本数（列）: %d本"), gridColumns), value: $gridColumns, in: 1...12)
                    }
                }
            }
            .navigationTitle(String(localized: "保管場所の追加"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "キャンセル")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "追加")) {
                        createLocation()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func createLocation() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newLocation = StorageLocation(
            name: trimmedName,
            type: selectedType,
            memo: memo,
            isGridEnabled: isGridEnabled,
            gridRows: gridRows,
            gridColumns: gridColumns
        )
        modelContext.insert(newLocation)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddLocationSheetView()
        .modelContainer(for: [StorageLocation.self], inMemory: true)
}
