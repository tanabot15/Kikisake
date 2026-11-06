//  TastingCustomizationView.swift
//  Kikisake

import SwiftUI

public struct TastingCustomizationView: View {
    @Bindable private var manager = TastingCustomizationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var newBalance: String = ""
    @State private var newColorName: String = ""
    @State private var newColorHex: String = "#991A33"
    @State private var newAromaName: String = ""
    @State private var selectedAromaCategory: String = "果実"

    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - 1. 味わいバランス表現のカスタム
                Section("味わいバランス表現 (追加)") {
                    ForEach(manager.customBalances, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { indexSet in
                        manager.customBalances.remove(atOffsets: indexSet)
                    }

                    HStack {
                        TextField("新しい表現を入力", text: $newBalance)
                        Button("追加") {
                            let trimmed = newBalance.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty && !manager.customBalances.contains(trimmed) {
                                manager.customBalances.append(trimmed)
                                newBalance = ""
                            }
                        }
                        .disabled(newBalance.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                // MARK: - 2. 香りタグのカスタム
                Section("香りタグの追加") {
                    Picker("カテゴリ", selection: $selectedAromaCategory) {
                        Text("果実").tag("果実")
                        Text("花・植物").tag("花・植物")
                        Text("その他").tag("その他")
                    }

                    HStack {
                        TextField("新しい香りタグを入力", text: $newAromaName)
                        Button("追加") {
                            let trimmed = newAromaName.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty {
                                let item = CustomAromaItem(categoryTitle: selectedAromaCategory, name: trimmed, beverageCategoryRaw: "wine")
                                manager.customAromas.append(item)
                                newAromaName = ""
                            }
                        }
                        .disabled(newAromaName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    ForEach(manager.customAromas) { aroma in
                        HStack {
                            Text(aroma.name)
                            Spacer()
                            Text(aroma.categoryTitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        manager.customAromas.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("選択肢のカスタマイズ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    TastingCustomizationView()
}
