//
//  TasteStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI

/// [Step 4] 味わい構造入力ビュー（基本五味・タンニン・ボディ・バランス・余韻）
public struct TasteStepView: View {
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

    /// 赤・ロゼ・オレンジワインのみタンニン（渋味）入力欄を表示する判定
    private var isTanninApplicable: Bool {
        guard viewModel.selectedCategory == .wine else { return false }
        let type = currentWineType
        return type == "赤" || type == "ロゼ" || type == "オレンジ"
    }

    /// バランス表現の選択肢
    private let balanceOptions = [
        "スムーズな", "コンパクトな", "スリムな", "ドライな",
        "引き締まった", "ジューシーな", "豊潤な", "厚みのある",
        "まろやかな", "ふくよかな", "ねっとりした"
    ]

    public var body: some View {
        Form {
            // 1. 基本五味
            Section("基本五味 (5味覚)") {
                CustomSlider(title: "甘味 (Sweetness)", value: $viewModel.sweetness)
                CustomSlider(title: "塩味 (Saltiness)", value: $viewModel.saltiness)
                CustomSlider(title: "酸味 (Acidity)", value: $viewModel.acidity)
                CustomSlider(title: "苦味 (Bitterness)", value: $viewModel.bitterness)
                CustomSlider(title: "旨味 (Umami)", value: $viewModel.umami)
            }

            // 2. タンニン (渋味) - 赤・ロゼ・オレンジワインのみ
            if isTanninApplicable {
                Section("渋味") {
                    CustomSlider(title: "タンニン (Tannin)", value: $viewModel.tannin)
                }
            }

            // 3. ボディ
            Section("重み・骨格") {
                CustomSlider(title: "ボディ (Body)", value: $viewModel.body)
            }

            // 4. バランス (複数選択タグ)
            Section("バランス表現 (複数選択可)") {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(balanceOptions, id: \.self) { option in
                        let isSelected = viewModel.selectedBalanceTags.contains(option)
                        Button {
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
                .padding(.vertical, 4)
            }

            // 5. 余韻の長さ
            Section("余韻") {
                CustomSlider(title: "余韻の長さ (Finish)", value: $viewModel.finishLength)
            }
        }
    }
}

// プレビューでワインタイプごとのタンニン表示切り替えをテスト可能
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

                    TasteStepView(viewModel: vm)
                }
                .navigationTitle("味わい入力プレビュー")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    return PreviewWrapper()
}
