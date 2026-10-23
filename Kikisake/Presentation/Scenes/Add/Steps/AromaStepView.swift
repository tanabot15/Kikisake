//  AromaStepView.swift
//  Kikisake

import SwiftUI

/// [Step 3] 酒種・タイプに応じた「果実」「花・植物」「その他」の3分類による香り選択ビュー
public struct AromaStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    /// ワインのJSONメタデータから現在のワインタイプを安全に取得するヘルパー
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

    /// ✨ TastingOptions から香りデータを取得
    private var aromaCategories: [AromaCategory] {
        return TastingOptions.aromaCategories(for: viewModel.selectedCategory, wineType: currentWineType)
    }

    public var body: some View {
        Form {
            ForEach(aromaCategories) { category in
                Section(header: Text(category.title)) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(category.tags, id: \.self) { tag in
                            let isSelected = viewModel.selectedAromaTags.contains(tag)
                            Button {
                                if isSelected {
                                    viewModel.selectedAromaTags.removeAll { $0 == tag }
                                } else {
                                    viewModel.selectedAromaTags.append(tag)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.subheadline)
                                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                                    
                                    Text(tag)
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
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
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

    return PreviewWrapper()
}
