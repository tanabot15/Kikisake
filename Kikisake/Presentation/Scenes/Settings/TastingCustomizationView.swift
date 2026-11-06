//  TastingCustomizationView.swift
//  Kikisake

import SwiftUI

/// カスタマイズ対象の項目
public enum CustomizationTarget: String, CaseIterable, Identifiable {
    case color = "色"
    case aroma = "香り"
    case balance = "味わいバランス"

    public var id: String { rawValue }
}

public struct TastingCustomizationView: View {
    @Bindable private var manager = TastingCustomizationManager.shared
    @Environment(\.dismiss) private var dismiss

    // ピッカー用 State
    @State private var selectedTarget: CustomizationTarget = .color

    // MARK: - 1. 色追加用 State
    @State private var selectedColor: Color = Color(hex: "#991A33") ?? .red
    @State private var newColorName: String = ""

    // MARK: - 2. 香り追加用 State
    @State private var newAromaName: String = ""
    @State private var selectedAromaCategory: String = "果実"

    // MARK: - 3. 味わいバランス追加用 State
    @State private var newBalanceName: String = ""

    // MARK: - 編集用 State
    @State private var editingBalanceIndex: Int? = nil
    @State private var editingBalanceText: String = ""
    @State private var isShowingEditBalanceAlert: Bool = false

    @State private var editingAromaItem: CustomAromaItem? = nil
    @State private var editingAromaText: String = ""
    @State private var isShowingEditAromaAlert: Bool = false

    @State private var editingColorItem: CustomColorItem? = nil
    @State private var editingColorNameText: String = ""
    @State private var editingColorVal: Color = .red
    @State private var isShowingEditColorSheet: Bool = false

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - ターゲット選択ピッカー
                Picker("対象の項目", selection: $selectedTarget) {
                    ForEach(CustomizationTarget.allCases) { target in
                        Text(target.rawValue).tag(target)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(.systemGroupedBackground))

                Form {
                    switch selectedTarget {
                    case .color:
                        colorCustomizationSection
                    case .aroma:
                        aromaCustomizationSection
                    case .balance:
                        balanceCustomizationSection
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
            // MARK: - 編集用アラート・シート
            .alert("味わい表現の編集", isPresented: $isShowingEditBalanceAlert) {
                TextField("表現名", text: $editingBalanceText)
                Button("保存") {
                    if let idx = editingBalanceIndex {
                        let trimmed = editingBalanceText.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            manager.customBalances[idx] = trimmed
                        }
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("新しい表現名を入力してください。")
            }
            .alert("香りタグの編集", isPresented: $isShowingEditAromaAlert) {
                TextField("香りタグ名", text: $editingAromaText)
                Button("保存") {
                    if let item = editingAromaItem, let idx = manager.customAromas.firstIndex(where: { $0.id == item.id }) {
                        let trimmed = editingAromaText.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            manager.customAromas[idx].name = trimmed
                        }
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("新しいタグ名を入力してください。")
            }
            .sheet(isPresented: $isShowingEditColorSheet) {
                if let item = editingColorItem {
                    NavigationStack {
                        Form {
                            Section("色の変更") {
                                ColorPicker("カラーを選択", selection: $editingColorVal, supportsOpacity: false)
                                TextField("色名", text: $editingColorNameText)
                            }
                        }
                        .navigationTitle("外観カラーの編集")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("キャンセル") {
                                    isShowingEditColorSheet = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("保存") {
                                    if let idx = manager.customColors.firstIndex(where: { $0.id == item.id }) {
                                        let trimmed = editingColorNameText.trimmingCharacters(in: .whitespaces)
                                        if !trimmed.isEmpty {
                                            let hex = editingColorVal.toHex() ?? "#808080"
                                            manager.customColors[idx].name = trimmed
                                            manager.customColors[idx].hex = hex
                                        }
                                    }
                                    isShowingEditColorSheet = false
                                }
                                .fontWeight(.bold)
                            }
                        }
                    }
                    .presentationDetents([.height(280)])
                }
            }
        }
    }

    // MARK: - 1. 外観カラーのカスタマイズビュー
    private var colorCustomizationSection: some View {
        Group {
            Section("新しいカラーを追加") {
                ColorPicker("色を選択", selection: $selectedColor, supportsOpacity: false)

                HStack {
                    TextField("色の名前 (例: ローズピンク)", text: $newColorName)
                    Button("追加") {
                        let trimmed = newColorName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            let hex = selectedColor.toHex() ?? "#991A33"
                            let newItem = CustomColorItem(name: trimmed, hex: hex, categoryRaw: "custom", isPro: true)
                            manager.customColors.append(newItem)
                            newColorName = ""
                        }
                    }
                    .disabled(newColorName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section("追加済みのカスタムカラー") {
                if manager.customColors.isEmpty {
                    Text("追加されたカスタムカラーはありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(manager.customColors) { item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: item.hex) ?? .gray)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))

                            Text(item.name)
                                .font(.body)

                            Spacer()

                            Button {
                                editingColorItem = item
                                editingColorNameText = item.name
                                editingColorVal = Color(hex: item.hex) ?? .red
                                isShowingEditColorSheet = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete { indexSet in
                        manager.customColors.remove(atOffsets: indexSet)
                    }
                }
            }

            Section("デフォルトの表示色マスター (参照)") {
                let defaultColors = TastingOptions.colorOptions(for: .wine, wineType: "赤")
                ForEach(defaultColors.prefix(8)) { option in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(option.color)
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                        Text(option.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - 2. 香りタグのカスタマイズビュー
    private var aromaCustomizationSection: some View {
        Group {
            Section("新しい香りタグを追加") {
                Picker("カテゴリ", selection: $selectedAromaCategory) {
                    Text("果実").tag("果実")
                    Text("花・植物").tag("花・植物")
                    Text("その他").tag("その他")
                }

                HStack {
                    TextField("新しい香り名 (例: 白桃缶詰)", text: $newAromaName)
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
            }

            Section("追加済みのカスタム香りタグ") {
                if manager.customAromas.isEmpty {
                    Text("追加された香りタグはありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(manager.customAromas) { aroma in
                        HStack {
                            Text(aroma.name)
                                .font(.body)
                            Spacer()
                            Text(aroma.categoryTitle)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.accentColor.opacity(0.12))
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(6)

                            Button {
                                editingAromaItem = aroma
                                editingAromaText = aroma.name
                                isShowingEditAromaAlert = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 6)
                        }
                    }
                    .onDelete { indexSet in
                        manager.customAromas.remove(atOffsets: indexSet)
                    }
                }
            }

            Section("デフォルトの香りタグ一覧 (参照)") {
                let defaultCategories = TastingOptions.aromaCategories(for: .wine, wineType: "赤")
                ForEach(defaultCategories) { category in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(category.title)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: 6) {
                            ForEach(category.tags.prefix(6)) { tag in
                                Text(tag.name)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.tertiarySystemGroupedBackground))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - 3. 味わいバランス表現のカスタマイズビュー
    private var balanceCustomizationSection: some View {
        Group {
            Section("新しい味わい表現を追加") {
                HStack {
                    TextField("表現を入力 (例: リッチな)", text: $newBalanceName)
                    Button("追加") {
                        let trimmed = newBalanceName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty && !manager.customBalances.contains(trimmed) {
                            manager.customBalances.append(trimmed)
                            newBalanceName = ""
                        }
                    }
                    .disabled(newBalanceName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section("追加済みのカスタム表現") {
                if manager.customBalances.isEmpty {
                    Text("追加されたカスタム表現はありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(manager.customBalances.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text(item)
                                .font(.body)
                            Spacer()
                            Button {
                                editingBalanceIndex = index
                                editingBalanceText = item
                                isShowingEditBalanceAlert = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete { indexSet in
                        manager.customBalances.remove(atOffsets: indexSet)
                    }
                }
            }

            Section("デフォルトの味わい表現マスター (参照)") {
                let defaultOptions = [
                    "スムーズな", "コンパクトな", "スリムな", "ドライな", "引き締まった", "ジューシーな", "豊潤な", "厚みのある"
                ]
                FlowLayout(spacing: 6) {
                    ForEach(defaultOptions, id: \.self) { opt in
                        Text(opt)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(6)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Color to Hex 拡張ヘルパー
private extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

#Preview {
    TastingCustomizationView()
}
