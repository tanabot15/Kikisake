//  AnalyticsFilterSheet.swift
//  Kikisake

import SwiftUI

/// 分析画面専用のフィルター設定シート
public struct AnalyticsFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AnalyticsViewModel

    public init(viewModel: AnalyticsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 1. 期間設定
                Section("分析対象の期間") {
                    Picker("期間を選択", selection: $viewModel.selectedTimeFilter) {
                        ForEach(AnalyticsTimeFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.inline)
                }

                // 2. 酒種 (カテゴリ) 設定
                Section("酒種 (カテゴリ)") {
                    Picker("酒種を選択", selection: $viewModel.selectedCategoryFilter) {
                        Text("すべて").tag(BeverageCategory?.none)
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(BeverageCategory?.some(category))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 3. フィルターリセット
                Section {
                    Button(role: .destructive) {
                        viewModel.resetFilters()
                    } label: {
                        HStack {
                            Spacer()
                            Text("フィルター条件をリセット")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("分析フィルター")
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
    AnalyticsFilterSheet(viewModel: AnalyticsViewModel())
}
