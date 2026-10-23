//  LogFilterSheet.swift
//  Kikisake

import SwiftUI

/// テイスティングログの高機能フィルター設定シート
public struct LogFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: LogListViewModel

    public init(viewModel: LogListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 1. 評価（最小スコア）フィルター
                Section("評価 (スコア)") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("最低スコア指定")
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
                    .padding(.vertical, 4)

                    if viewModel.selectedRatingFilter != nil {
                        Button("スコア条件をクリア", role: .destructive) {
                            viewModel.selectedRatingFilter = nil
                        }
                        .font(.subheadline)
                    }
                }

                // 2. 並び替え（ソート）設定
                Section("並び替え (ソート)") {
                    Picker("表示順序", selection: $viewModel.sortOrder) {
                        ForEach(LogSortOrder.allCases, id: \.self) { order in
                            Text(order.displayName).tag(order)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // 3. 一括リセット
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
