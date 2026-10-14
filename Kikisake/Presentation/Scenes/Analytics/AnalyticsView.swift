//
//  AnalyticsView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData
import Charts

/// [Tab 2] 飲んだ酒の分析画面
public struct AnalyticsView: View {
    @Query private var logs: [TastingLog]
    @State private var viewModel = AnalyticsViewModel()

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 酒種バランスカード
                    VStack(alignment: .leading, spacing: 12) {
                        Text("酒種別 飲酒比率")
                            .font(.headline)
                        
                        let ratio = viewModel.categoryRatio(from: logs)
                        let totalCount = logs.count

                        if totalCount == 0 {
                            Text("データがありません")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            Chart {
                                ForEach(BeverageCategory.allCases, id: \.self) { category in
                                    let count = ratio[category] ?? 0
                                    SectorMark(
                                        angle: .value("件数", count),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(by: .value("酒種", category.displayName))
                                }
                            }
                            .frame(height: 200)

                            HStack(spacing: 16) {
                                ForEach(BeverageCategory.allCases, id: \.self) { category in
                                    let count = ratio[category] ?? 0
                                    VStack(alignment: .leading) {
                                        Text(category.displayName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("\(count) 件")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)

                    // 平均味わいプロファイルカード
                    VStack(alignment: .leading, spacing: 12) {
                        Text("平均テイストバランス")
                            .font(.headline)

                        let profile = viewModel.averageTasteProfile(from: logs)

                        VStack(spacing: 8) {
                            tasteBar(title: "甘味", value: profile.sweetness)
                            tasteBar(title: "酸味", value: profile.acidity)
                            tasteBar(title: "タンニン/苦味", value: profile.bitternessOrTannin)
                            tasteBar(title: "ボディ", value: profile.body)
                            tasteBar(title: "余韻", value: profile.finishLength)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("分析")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func tasteBar(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            ProgressView(value: value, total: 5.0)
                .tint(.accentColor)
            
            Text(String(format: "%.1f", value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
