//
//  AromaStepView.swift
//  Kikisake
//

import SwiftUI

/// Step 3 view for selecting aroma tags grouped by category.
public struct AromaStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @State private var showPaywall: Bool = false

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    private var currentWineType: String {
        guard viewModel.selectedCategory == .wine,
              let json = viewModel.sourceItem?.specificMetadataJSON ?? buildCurrentWineJSON(),
              let data = json.data(using: .utf8),
              let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) else {
            return viewModel.wineType
        }
        return meta.wineType
    }

    private func buildCurrentWineJSON() -> String? {
        let meta = WineSpecificMetadata(
            wineType: viewModel.wineType,
            grapeVarieties: viewModel.grapeVarieties,
            blendComponents: viewModel.blendComponents.filter { !$0.variety.isEmpty }
        )
        guard let data = try? JSONEncoder().encode(meta) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private var aromaCategories: [AromaCategory] {
        TastingOptions.aromaCategories(for: viewModel.selectedCategory, wineType: currentWineType)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView

                ForEach(aromaCategories) { category in
                    aromaCategorySection(for: category)
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(localized: "香りを選択"))
                .font(.headline)
                .fontWeight(.bold)
            Text(String(localized: "感じられた香りの特徴をタップして選択してください。"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    private func aromaCategorySection(for category: AromaCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            FlowLayout(spacing: 8) {
                ForEach(category.tags, id: \.self) { tag in
                    aromaTagChip(tagName: tag.name, in: category)
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    private func aromaTagChip(tagName: String, in category: AromaCategory) -> some View {
        let isSelected = viewModel.selectedAromaTags.contains(tagName)
        let isFree = TastingOptions.isFreeAromaTag(tagName, in: category)
        let isLocked = !AppState.shared.isProVersion && !isFree

        return Button {
            if isLocked {
                showPaywall = true
            } else if isSelected {
                viewModel.selectedAromaTags.removeAll { $0 == tagName }
            } else {
                viewModel.selectedAromaTags.append(tagName)
            }
        } label: {
            HStack(spacing: 6) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.orange)
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }

                Text(tagName)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)

                if isLocked {
                    Text("PRO")
                        .font(.system(size: 8, weight: .heavy))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.orange.opacity(0.2))
                        .foregroundStyle(.orange)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.15)
                    : (isLocked ? Color(.systemGray6).opacity(0.7) : Color(.systemGray6))
            )
            .foregroundStyle(isLocked ? .secondary : (isSelected ? Color.accentColor : .primary))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.accentColor : (isLocked ? Color.orange.opacity(0.3) : Color.clear),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AromaStepViewPreviewHost()
}

private struct AromaStepViewPreviewHost: View {
    @State private var vm = AddFlowViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("カテゴリ", selection: $vm.selectedCategory) {
                    ForEach(BeverageCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)

                if vm.selectedCategory == .wine {
                    Picker("ワインタイプ", selection: $vm.wineType) {
                        Text("赤").tag("赤")
                        Text("白").tag("白")
                        Text("ロゼ").tag("ロゼ")
                        Text("オレンジ").tag("オレンジ")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                AromaStepView(viewModel: vm)
            }
            .navigationTitle("香り選択プレビュー")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
