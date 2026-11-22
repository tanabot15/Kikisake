//
//  TastingCustomizationView.swift
//  Kikisake
//

import SwiftUI

public enum CustomizationTarget: String, CaseIterable, Identifiable {
    case color
    case aroma
    case balance

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .color: return String(localized: "色")
        case .aroma: return String(localized: "香り")
        case .balance: return String(localized: "味わいバランス")
        }
    }
}

/// Customization view for user-defined tasting colors, aroma tags, and balance terms.
public struct TastingCustomizationView: View {
    @Bindable private var manager = TastingCustomizationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTarget: CustomizationTarget = .color
    @State private var selectedCategory: BeverageCategory = .wine
    @State private var selectedWineType: String = "赤"

    @State private var selectedColor: Color = Color(hex: "#991A33") ?? .red
    @State private var newColorName: String = ""

    @State private var newAromaName: String = ""
    @State private var selectedAromaCategory: String = "果実"

    @State private var newBalanceName: String = ""

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

    private var categoryContextLabel: String {
        selectedCategory == .wine
            ? "\(selectedCategory.displayName) / \(selectedWineType)"
            : selectedCategory.displayName
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerControls

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
            .navigationTitle(String(localized: "選択肢のカスタマイズ"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "完了")) {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert(String(localized: "味わい表現の編集"), isPresented: $isShowingEditBalanceAlert) {
                TextField(String(localized: "表現名"), text: $editingBalanceText)
                Button(String(localized: "保存")) {
                    if let idx = editingBalanceIndex {
                        let trimmed = editingBalanceText.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            manager.customBalances[idx] = trimmed
                        }
                    }
                }
                Button(String(localized: "キャンセル"), role: .cancel) {}
            } message: {
                Text(String(localized: "新しい表現名を入力してください。"))
            }
            .alert(String(localized: "香りタグの編集"), isPresented: $isShowingEditAromaAlert) {
                TextField(String(localized: "香りタグ名"), text: $editingAromaText)
                Button(String(localized: "保存")) {
                    if let item = editingAromaItem,
                       let idx = manager.customAromas.firstIndex(where: { $0.id == item.id }) {
                        let trimmed = editingAromaText.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            manager.customAromas[idx].name = trimmed
                        }
                    }
                }
                Button(String(localized: "キャンセル"), role: .cancel) {}
            } message: {
                Text(String(localized: "新しいタグ名を入力してください。"))
            }
            .sheet(isPresented: $isShowingEditColorSheet) {
                CustomColorEditSheet(
                    item: $editingColorItem,
                    nameText: $editingColorNameText,
                    colorValue: $editingColorVal,
                    onSave: { targetItem, updatedName, updatedColor in
                        if let idx = manager.customColors.firstIndex(where: { $0.id == targetItem.id }) {
                            let trimmed = updatedName.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty {
                                manager.customColors[idx].name = trimmed
                                manager.customColors[idx].hex = updatedColor.toHex() ?? "#808080"
                            }
                        }
                        isShowingEditColorSheet = false
                    },
                    onCancel: {
                        isShowingEditColorSheet = false
                    }
                )
            }
        }
    }

    private var headerControls: some View {
        VStack(spacing: 0) {
            Picker(String(localized: "対象の項目"), selection: $selectedTarget) {
                ForEach(CustomizationTarget.allCases) { target in
                    Text(target.displayName).tag(target)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemGroupedBackground))

            if selectedTarget != .balance {
                VStack(spacing: 8) {
                    Picker(String(localized: "酒種"), selection: $selectedCategory) {
                        ForEach(BeverageCategory.allCases, id: \.self) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)

                    if selectedCategory == .wine {
                        Picker(String(localized: "ワインタイプ"), selection: $selectedWineType) {
                            Text(String(localized: "赤")).tag("赤")
                            Text(String(localized: "白")).tag("白")
                            Text(String(localized: "ロゼ")).tag("ロゼ")
                            Text(String(localized: "オレンジ")).tag("オレンジ")
                            Text(String(localized: "スパークリング")).tag("スパークリング")
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    // MARK: - 1. Color Customization

    private var colorCustomizationSection: some View {
        Group {
            Section(String(format: String(localized: "新しいカラーを追加 (%@)"), categoryContextLabel)) {
                ColorPicker(String(localized: "色を選択"), selection: $selectedColor, supportsOpacity: false)

                HStack {
                    TextField(String(localized: "色の名前 (例: ローズピンク)"), text: $newColorName)
                    Button(String(localized: "追加")) {
                        let trimmed = newColorName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        let hex = selectedColor.toHex() ?? "#991A33"
                        let categoryKey = selectedCategory == .wine ? "wine-\(selectedWineType)" : selectedCategory.rawValue
                        let newItem = CustomColorItem(name: trimmed, hex: hex, categoryRaw: categoryKey, isPro: true)
                        manager.customColors.append(newItem)
                        newColorName = ""
                    }
                    .disabled(newColorName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section(String(localized: "追加済みのカスタムカラー")) {
                if manager.customColors.isEmpty {
                    Text(String(localized: "追加されたカスタムカラーはありません"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(manager.customColors) { item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: item.hex) ?? .gray)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.body)
                                Text(String(format: String(localized: "対象: %@"), item.categoryRaw))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

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

            Section(String(format: String(localized: "表示色一覧 (%@)"), categoryContextLabel)) {
                let defaultColors = TastingOptions.colorOptions(for: selectedCategory, wineType: selectedWineType)
                ForEach(defaultColors) { option in
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

    // MARK: - 2. Aroma Customization

    private var aromaCustomizationSection: some View {
        Group {
            Section(String(format: String(localized: "新しい香りタグを追加 (%@)"), categoryContextLabel)) {
                Picker(String(localized: "カテゴリ"), selection: $selectedAromaCategory) {
                    Text(String(localized: "果実")).tag("果実")
                    Text(String(localized: "花・植物")).tag("花・植物")
                    Text(String(localized: "その他")).tag("その他")
                }

                HStack {
                    TextField(String(localized: "新しい香り名 (例: 白桃缶詰)"), text: $newAromaName)
                    Button(String(localized: "追加")) {
                        let trimmed = newAromaName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        let item = CustomAromaItem(
                            categoryTitle: selectedAromaCategory,
                            name: trimmed,
                            beverageCategoryRaw: selectedCategory.rawValue
                        )
                        manager.customAromas.append(item)
                        newAromaName = ""
                    }
                    .disabled(newAromaName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section(String(localized: "追加済みのカスタム香りタグ")) {
                if manager.customAromas.isEmpty {
                    Text(String(localized: "追加された香りタグはありません"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(manager.customAromas) { aroma in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(aroma.name)
                                    .font(.body)
                                Text(String(format: String(localized: "酒種: %@"), aroma.beverageCategoryRaw))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
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

            Section(String(format: String(localized: "香りタグ一覧 (%@)"), categoryContextLabel)) {
                let defaultCategories = TastingOptions.aromaCategories(for: selectedCategory, wineType: selectedWineType)
                ForEach(defaultCategories) { category in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(category.title)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: 6) {
                            ForEach(category.tags) { tag in
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

    // MARK: - 3. Balance Customization

    private var balanceCustomizationSection: some View {
        Group {
            Section(String(localized: "新しい味わい表現を追加")) {
                HStack {
                    TextField(String(localized: "表現を入力 (例: リッチな)"), text: $newBalanceName)
                    Button(String(localized: "追加")) {
                        let trimmed = newBalanceName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty && !manager.customBalances.contains(trimmed) {
                            manager.customBalances.append(trimmed)
                            newBalanceName = ""
                        }
                    }
                    .disabled(newBalanceName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section(String(localized: "追加済みのカスタム表現")) {
                if manager.customBalances.isEmpty {
                    Text(String(localized: "追加されたカスタム表現はありません"))
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

            Section(String(localized: "味わい表現一覧")) {
                let defaultOptions = TastingOptions.balanceOptions
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
