//
//  AppearanceStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI

/// [Step 2] 酒種・タイプに応じた最適化された色・外観入力ビュー
public struct AppearanceStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    private struct ColorOption: Identifiable {
        let id = UUID()
        let name: String
        let color: Color
        let hex: String
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

    /// 各ColorOptionに適切なHEXコードを設定したカラーパレット定義
    private var colorOptions: [ColorOption] {
        switch viewModel.selectedCategory {
        case .wine:
            let type = currentWineType
            if type == "白" || type == "スパークリング" {
                // 白ワイン系：10個（明るい順）
                return [
                    ColorOption(name: "ペール・イエロー", color: Color(red: 0.98, green: 0.96, blue: 0.75), hex: "#FAF5BF"),
                    ColorOption(name: "レモン・イエロー", color: Color(red: 0.95, green: 0.93, blue: 0.6), hex: "#F3ED99"),
                    ColorOption(name: "グリーン・イエロー", color: Color(red: 0.85, green: 0.92, blue: 0.6), hex: "#D9EB99"),
                    ColorOption(name: "ストロー・イエロー", color: Color(red: 0.95, green: 0.90, blue: 0.5), hex: "#F3E680"),
                    ColorOption(name: "ペール・ゴールド", color: Color(red: 0.92, green: 0.88, blue: 0.6), hex: "#EBE099"),
                    ColorOption(name: "ストロー", color: Color(red: 0.90, green: 0.85, blue: 0.55), hex: "#E6D98C"),
                    ColorOption(name: "ゴールデン・イエロー", color: Color(red: 0.92, green: 0.82, blue: 0.3), hex: "#EBD14D"),
                    ColorOption(name: "ゴールド", color: Color(red: 0.88, green: 0.75, blue: 0.2), hex: "#E0BF33"),
                    ColorOption(name: "ハニー", color: Color(red: 0.85, green: 0.70, blue: 0.3), hex: "#D9B34D"),
                    ColorOption(name: "アンバー", color: Color(red: 0.80, green: 0.62, blue: 0.2), hex: "#CC9E33")
                ]
            } else if type == "ロゼ" {
                // ロゼワイン：4個（明るい順）
                return [
                    ColorOption(name: "チェリー・ブロッサム", color: Color(red: 0.98, green: 0.80, blue: 0.82), hex: "#FACDD1"),
                    ColorOption(name: "ピーチ・スキン", color: Color(red: 0.96, green: 0.80, blue: 0.70), hex: "#F5CCB3"),
                    ColorOption(name: "サーモン・ピンク", color: Color(red: 0.96, green: 0.72, blue: 0.65), hex: "#F5B8A6"),
                    ColorOption(name: "ラズベリー・ピンク", color: Color(red: 0.95, green: 0.70, blue: 0.75), hex: "#F2B3BF")
                ]
            } else if type == "オレンジ" {
                // オレンジワイン：4個（明るい順）
                return [
                    ColorOption(name: "アプリコット", color: Color(red: 0.95, green: 0.65, blue: 0.35), hex: "#F3A659"),
                    ColorOption(name: "アンバー・オレンジ", color: Color(red: 0.92, green: 0.55, blue: 0.2), hex: "#EB8C33"),
                    ColorOption(name: "コッパー", color: Color(red: 0.85, green: 0.48, blue: 0.25), hex: "#D97A40"),
                    ColorOption(name: "ブロンズ", color: Color(red: 0.80, green: 0.50, blue: 0.3), hex: "#CC804D")
                ]
            } else {
                // 赤ワイン系：10個（明るい順）
                return [
                    ColorOption(name: "ラズベリーレッド", color: Color(red: 0.8, green: 0.2, blue: 0.3), hex: "#CC334D"),
                    ColorOption(name: "チェリーレッド", color: Color(red: 0.7, green: 0.15, blue: 0.25), hex: "#B32640"),
                    ColorOption(name: "クリムゾン", color: Color(red: 0.65, green: 0.08, blue: 0.2), hex: "#A61433"),
                    ColorOption(name: "ルビーレッド", color: Color(red: 0.6, green: 0.1, blue: 0.2), hex: "#991A33"),
                    ColorOption(name: "レンガ/ブリック", color: Color(red: 0.6, green: 0.25, blue: 0.2), hex: "#994033"),
                    ColorOption(name: "ガーネット", color: Color(red: 0.5, green: 0.15, blue: 0.2), hex: "#802633"),
                    ColorOption(name: "パープル", color: Color(red: 0.45, green: 0.1, blue: 0.3), hex: "#731A4D"),
                    ColorOption(name: "ダーク・ルビー", color: Color(red: 0.45, green: 0.05, blue: 0.15), hex: "#730D26"),
                    ColorOption(name: "ダーク・ガーネット", color: Color(red: 0.45, green: 0.2, blue: 0.2), hex: "#733333"),
                    ColorOption(name: "マホガニー", color: Color(red: 0.4, green: 0.15, blue: 0.1), hex: "#66261A")
                ]
            }

        case .sake:
            // 日本酒：10個
            return [
                ColorOption(name: "無色透明", color: Color(.systemGray6), hex: "#F2F2F7"),
                ColorOption(name: "クリスタル・クリア", color: Color(red: 0.97, green: 0.98, blue: 0.98), hex: "#F7FAFA"),
                ColorOption(name: "にごり（濃い乳白色）", color: Color.white, hex: "#FFFFFF"),
                ColorOption(name: "にごり（白濁・薄い）", color: Color(red: 0.95, green: 0.95, blue: 0.95), hex: "#F2F2F2"),
                ColorOption(name: "うすにごり（ささにごり）", color: Color(red: 0.92, green: 0.93, blue: 0.90), hex: "#EBEBE6"),
                ColorOption(name: "微黄色", color: Color(red: 0.98, green: 0.96, blue: 0.85), hex: "#FAF5D9"),
                ColorOption(name: "淡金色", color: Color(red: 0.95, green: 0.90, blue: 0.7), hex: "#F3E6B3"),
                ColorOption(name: "黄金色", color: Color(red: 0.90, green: 0.78, blue: 0.4), hex: "#E6C766"),
                ColorOption(name: "琥珀色（古酒）", color: Color(red: 0.78, green: 0.55, blue: 0.2), hex: "#C78C33"),
                ColorOption(name: "ダーク・アンバー", color: Color(red: 0.6, green: 0.38, blue: 0.1), hex: "#99611A")
            ]

        case .beer:
            // ビール：10個
            return [
                ColorOption(name: "ペール・ストロー", color: Color(red: 0.98, green: 0.94, blue: 0.5), hex: "#FAF080"),
                ColorOption(name: "ストロー/麦わら色", color: Color(red: 0.96, green: 0.90, blue: 0.35), hex: "#F5E659"),
                ColorOption(name: "ゴールデン", color: Color(red: 0.92, green: 0.78, blue: 0.2), hex: "#EBC733"),
                ColorOption(name: "ディープ・ゴールデン", color: Color(red: 0.88, green: 0.68, blue: 0.15), hex: "#E0AD26"),
                ColorOption(name: "ペール・アンバー", color: Color(red: 0.80, green: 0.52, blue: 0.18), hex: "#CC852E"),
                ColorOption(name: "アンバー", color: Color(red: 0.70, green: 0.38, blue: 0.12), hex: "#B3611F"),
                ColorOption(name: "コッパー", color: Color(red: 0.60, green: 0.30, blue: 0.1), hex: "#994D1A"),
                ColorOption(name: "ブラウン", color: Color(red: 0.42, green: 0.20, blue: 0.08), hex: "#6B3314"),
                ColorOption(name: "ダーク・ブラウン", color: Color(red: 0.25, green: 0.12, blue: 0.05), hex: "#401F0D"),
                ColorOption(name: "ブラック", color: Color(red: 0.12, green: 0.08, blue: 0.06), hex: "#1F140F")
            ]
        }
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
                            Button {
                                // ✨ ここで色名とHEXコードを正しくViewModelに反映する
                                viewModel.appearanceNotes = option.name
                                viewModel.appearanceColorHex = option.hex
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
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    if isSelected {
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
    }
}

// ✨ ワインの種類別（赤・白・ロゼ・オレンジ）も含めてテストできるプレビュー
#Preview {
    struct PreviewWrapper: View {
        @State private var vm = AddFlowViewModel()

        var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    // 酒種カテゴリの切り替え
                    Picker("カテゴリ", selection: $vm.selectedCategory) {
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top)

                    // ワイン選択時のみ、タイプ別（赤・白・ロゼ・オレンジ）の切り替えを表示
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
