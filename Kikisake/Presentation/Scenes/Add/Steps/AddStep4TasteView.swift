//
//  TasteStepView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Step 4 view for entering taste profile parameters and balance tags.
public struct AddStep4TasteView: View {
    @Bindable var viewModel: AddFlowViewModel

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

    private var isTanninApplicable: Bool {
        guard viewModel.selectedCategory == .wine else { return false }
        let type = currentWineType
        return type == "赤" || type == "ロゼ" || type == "オレンジ"
    }

    public var body: some View {
        Form {
            basicTasteSection

            if isTanninApplicable {
                Section(String(localized: "渋味")) {
                    CustomSlider(title: String(localized: "タンニン (Tannin)"), value: $viewModel.tannin)
                }
            }

            Section(String(localized: "重み・骨格")) {
                CustomSlider(title: String(localized: "ボディ (Body)"), value: $viewModel.body)
            }

            balanceTagsSection

            Section(String(localized: "余韻")) {
                CustomSlider(title: String(localized: "余韻の長さ (Finish)"), value: $viewModel.finishLength)
            }
        }
    }

    private var basicTasteSection: some View {
        Section(String(localized: "基本五味 (5味覚)")) {
            CustomSlider(title: String(localized: "甘味 (Sweetness)"), value: $viewModel.sweetness)
            CustomSlider(title: String(localized: "塩味 (Saltiness)"), value: $viewModel.saltiness)
            CustomSlider(title: String(localized: "酸味 (Acidity)"), value: $viewModel.acidity)
            CustomSlider(title: String(localized: "苦味 (Bitterness)"), value: $viewModel.bitterness)
            CustomSlider(title: String(localized: "旨味 (Umami)"), value: $viewModel.umami)
        }
    }

    private var balanceTagsSection: some View {
        Section(String(localized: "バランス表現 (複数選択可)")) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(TastingOptions.balanceOptions, id: \.self) { option in
                    balanceTagButton(for: option)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func balanceTagButton(for option: String) -> some View {
        let isSelected = viewModel.selectedBalanceTags.contains(option)

        return Button {
            if isSelected {
                viewModel.selectedBalanceTags.removeAll { $0 == option }
            } else {
                viewModel.selectedBalanceTags.append(option)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)

                Text(option)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TasteStepViewPreviewHost()
}

private struct TasteStepViewPreviewHost: View {
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

                AddStep4TasteView(viewModel: vm)
            }
            .navigationTitle("味わい入力プレビュー")
            .navigationBarTitleDisplayMode(.inline)
        }
        .modelContainer(PreviewSampleData.container)
    }
}
