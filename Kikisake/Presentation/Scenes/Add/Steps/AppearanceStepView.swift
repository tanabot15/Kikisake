//  AppearanceStepView.swift
//  Kikisake

import SwiftUI

/// [Step 2] 酒種・タイプに応じた色・外観入力ビュー（カラーパレットグリッド ＋ 色名連動メモ版）
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

    /// 選択中のカラーオブジェクト（色名から検索）
    private var selectedColorOption: ColorOption? {
        colorOptions.first { $0.hex.lowercased() == viewModel.appearanceColorHex.lowercased() }
            ?? colorOptions.first { viewModel.appearanceNotes.contains($0.name) }
    }

    public var body: some View {
        Form {
            // MARK: - 1. カラーパレット選択エリア（色のみのコンパクトグリッド）
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(viewModel.selectedCategory.displayName)の色調")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("グラスを傾けて見える最も近い色をタップしてください。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    // 💡 5列の均等グリッドで「色のみ」をコンパクトに並べて網羅表示
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 14) {
                        ForEach(colorOptions) { option in
                            let isSelected = viewModel.appearanceColorHex.lowercased() == option.hex.lowercased()
                            let isFree = TastingOptions.isFreeColorOption(option, in: colorOptions)
                            let isLocked = !AppState.shared.isProVersion && !isFree

                            Button {
                                if isLocked {
                                    showPaywall = true
                                } else {
                                    viewModel.appearanceColorHex = option.hex
                                    // ✨ 選択された色名を自由記述メモに反映
                                    viewModel.appearanceNotes = option.name
                                }
                            } label: {
                                ZStack {
                                    // カラーサークル
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                                        .overlay(
                                            Circle()
                                                .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                                        )

                                    // 選択中チェックマーク
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(isLightColor(option.color) ? .black : .white)
                                    }

                                    // Pro限定キーバッジ
                                    if isLocked {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 9))
                                                    .foregroundStyle(.white)
                                                    .padding(3)
                                                    .background(Color.orange)
                                                    .clipShape(Circle())
                                            }
                                            Spacer()
                                        }
                                        .frame(width: 44, height: 44)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .padding(.vertical, 4)
            }

            // MARK: - 2. 外観の選択名 ＆ 自由記述メモ
            Section("選択された外観・詳細メモ") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("選択中の色名:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let currentOption = selectedColorOption {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(currentOption.color)
                                    .frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5))
                                
                                Text(currentOption.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.accentColor)
                            }
                        } else {
                            Text("未選択")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Divider()

                    TextField("外観の表現・補足メモ (例: 深みのあるルビーレッド。粘性が高く輝きがある)", text: $viewModel.appearanceNotes, axis: .vertical)
                        .lineLimit(2...4)
                }
                .padding(.vertical, 4)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    /// チェックマークの視認性のための背景色明暗判定
    private func isLightColor(_ color: Color) -> Bool {
        // 色コードに応じた簡易明暗判定
        let hex = viewModel.appearanceColorHex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        let brightness = (r * 299 + g * 587 + b * 114) / 1000
        return brightness > 0.65
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
