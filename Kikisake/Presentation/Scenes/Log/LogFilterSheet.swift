//  LogFilterSheet.swift
//  Kikisake

import SwiftUI

/// テイスティングログの多機能フィルター設定シート
public struct LogFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: LogListViewModel

    public init(viewModel: LogListViewModel) {
        self.viewModel = viewModel
    }

    /// 現在の選択カテゴリに基づいたカラーオプション一覧
    private var availableColorOptions: [ColorOption] {
        return TastingOptions.colorOptions(for: viewModel.selectedCategoryFilter, wineType: viewModel.wineTypeFilter)
    }

    /// 現在の選択カテゴリに基づいた香りタグ一覧のフラットリスト
    private var availableAromaTags: [String] {
        let categories = TastingOptions.aromaCategories(for: viewModel.selectedCategoryFilter, wineType: viewModel.wineTypeFilter)
        return categories.flatMap { $0.tags }
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 1. 酒種 (カテゴリ) 選択
                Section("酒種 (カテゴリ)") {
                    Picker("酒種を選択", selection: $viewModel.selectedCategoryFilter) {
                        Text("すべて").tag(BeverageCategory?.none)
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(BeverageCategory?.some(category))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 2. 基本情報 (生産者, 生産地, ヴィンテージ)
                Section("基本情報") {
                    TextField("生産者 / 蔵元 / ブルワリー", text: $viewModel.producerFilter)
                    TextField("生産地 (例: ボルドー, 新潟)", text: $viewModel.regionFilter)
                    TextField("ヴィンテージ / 製造年月 (例: 2020)", text: $viewModel.vintageFilter)
                }

                // 3. スペック (アルコール度数 & 価格)
                Section("スペック") {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("最低アルコール度数")
                                .font(.subheadline)
                            Spacer()
                            Text(viewModel.minAbv == nil ? "指定なし" : String(format: "%.1f %% 以上", viewModel.minAbv!))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.accentColor)
                        }

                        Slider(
                            value: Binding(
                                get: { viewModel.minAbv ?? 0.0 },
                                set: { viewModel.minAbv = $0 == 0.0 ? nil : $0 }
                            ),
                            in: 0.0...20.0,
                            step: 0.5
                        )
                    }

                    HStack {
                        Text("上限価格")
                            .font(.subheadline)
                        Spacer()
                        TextField("円", value: $viewModel.maxPrice, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                // 4. テイスティングデータ (評価、外観カラー、香りタグ)
                Section("評価・テイスティングデータ") {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("最低評価 (スコア)")
                                .font(.subheadline)
                            Spacer()
                            Text(viewModel.selectedRatingFilter == nil ? "指定なし" : String(format: "★ %.1f 以上", viewModel.selectedRatingFilter!))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.accentColor)
                        }

                        Slider(
                            value: Binding(
                                get: { viewModel.selectedRatingFilter ?? 1.0 },
                                set: { viewModel.selectedRatingFilter = $0 }
                            ),
                            in: 1.0...5.0,
                            step: 0.5
                        )
                        .tint(.yellow)
                    }

                    // ✨ 外観・色調の選択メニュー（色付きの丸を並列表示）
                    Picker("外観・色調", selection: $viewModel.appearanceNoteFilter) {
                        Text("指定なし").tag("")
                        ForEach(availableColorOptions) { option in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
                                    )
                                Text(option.name)
                            }.tag(option.name)
                        }
                    }
                    .pickerStyle(.menu)

                    // 香りタグの選択メニュー
                    Picker("香りタグ", selection: $viewModel.aromaTagFilter) {
                        Text("指定なし").tag("")
                        ForEach(availableAromaTags, id: \.self) { tag in
                            Text(tag).tag(tag)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // 5. 酒種固有のメタデータ
                Section("固有詳細条件") {
                    if viewModel.selectedCategoryFilter == nil || viewModel.selectedCategoryFilter == .wine {
                        Picker("ワインタイプ", selection: $viewModel.wineTypeFilter) {
                            Text("すべて").tag("すべて")
                            Text("赤").tag("赤")
                            Text("白").tag("白")
                            Text("ロゼ").tag("ロゼ")
                            Text("オレンジ").tag("オレンジ")
                            Text("スパークリング").tag("スパークリング")
                        }
                    }

                    if viewModel.selectedCategoryFilter == nil || viewModel.selectedCategoryFilter == .sake {
                        Picker("日本酒 特定名称", selection: $viewModel.sakeSpecificNameFilter) {
                            Text("すべて").tag("すべて")
                            Text("純米大吟醸").tag("純米大吟醸")
                            Text("純米吟醸").tag("純米吟醸")
                            Text("大吟醸").tag("大吟醸")
                            Text("特別純米").tag("特別純米")
                            Text("純米酒").tag("純米")
                            Text("本醸造").tag("本醸造")
                        }
                    }

                    if viewModel.selectedCategoryFilter == nil || viewModel.selectedCategoryFilter == .beer {
                        TextField("ビアスタイル (例: IPA, Stout)", text: $viewModel.beerStyleFilter)
                    }
                }

                // 6. ソート設定
                Section("並び替え (ソート)") {
                    Picker("表示順序", selection: $viewModel.sortOrder) {
                        ForEach(LogSortOrder.allCases, id: \.self) { order in
                            Text(order.displayName).tag(order)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // 7. 一括リセット
                Section {
                    Button(role: .destructive) {
                        viewModel.resetFilters()
                    } label: {
                        HStack {
                            Spacer()
                            Label("すべてのフィルターをリセット", systemImage: "arrow.counterclockwise")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("フィルターと並び替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
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
    LogFilterSheet(viewModel: LogListViewModel())
}
