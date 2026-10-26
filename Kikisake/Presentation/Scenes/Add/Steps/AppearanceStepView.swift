//  AppearanceStepView.swift
//  Kikisake

import SwiftUI

/// [Step 2] 酒種・タイプに応じた最適化された色・外観入力ビュー
public struct AppearanceStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @State private var showPaywall: Bool = false

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

    /// ✨ TastingOptions からカラーパレットを取得
    private var colorOptions: [ColorOption] {
        return TastingOptions.colorOptions(for: viewModel.selectedCategory, wineType: currentWineType)
    }

    public var body: some View {
        Form {
            Section("外観・色調の選択") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(viewModel.selectedCategory.displayName)の色調を選択してください")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(colorOptions) { option in
                            let isSelected = viewModel.appearanceNotes == option.name
                            let isFree = TastingOptions.isFreeColorOption(option, in: colorOptions)
                            let isLocked = !AppState.shared.isProVersion && !isFree

                            Button {
                                if isLocked {
                                    showPaywall = true
                                } else {
                                    viewModel.appearanceNotes = option.name
                                    viewModel.appearanceColorHex = option.hex
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text(option.name)
                                        .font(.subheadline)
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundStyle(isLocked ? .secondary : .primary)
                                    
                                    Spacer()
                                    
                                    if isLocked {
                                        HStack(spacing: 4) {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                            Text("Pro")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.accentColor.opacity(0.15))
                                        .foregroundStyle(Color.accentColor)
                                        .cornerRadius(6)
                                    } else if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.accentColor)
                                    }
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
                }
                .padding(.vertical, 4)
            }

            Section("詳細メモ・自由記述") {
                TextField("外観の補足 (例: 輝きがある、粘性高い)", text: $viewModel.appearanceNotes)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
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

                    AppearanceStepView(viewModel: vm)
                }
                .navigationTitle("外観選択プレビュー")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    return PreviewWrapper()
}
