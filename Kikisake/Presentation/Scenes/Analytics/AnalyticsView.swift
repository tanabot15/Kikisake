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
                            tasteBar(title: "塩味", value: profile.saltiness)
                            tasteBar(title: "酸味", value: profile.acidity)
                            tasteBar(title: "苦味", value: profile.bitterness)
                            tasteBar(title: "旨味", value: profile.umami)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    
    // サンプル 1: ワイン
    let wineItem = BeverageItem(
        name: "Barolo DOCG",
        producer: "Prunotto",
        category: .wine,
        region: "イタリア"
    )
    let wineLog = TastingLog(
        rating: 4.8,
        appearanceNotes: "ガーネット",
        aromaTags: ["スミレ", "樽香"],
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        balanceTags: ["豊潤な"],
        finishLength: 4.8,
        item: wineItem
    )
    
    // サンプル 2: 日本酒
    let sakeItem = BeverageItem(
        name: "久保田 萬壽",
        producer: "朝日酒造",
        category: .sake,
        region: "新潟県"
    )
    let sakeLog = TastingLog(
        rating: 4.5,
        appearanceNotes: "無色透明",
        aromaTags: ["吟醸香", "青りんご"],
        sweetness: 3.0,
        saltiness: 0.0,
        acidity: 2.5,
        bitterness: 1.5,
        umami: 3.5,
        tannin: nil,
        body: 3.0,
        balanceTags: ["まろやかな"],
        finishLength: 4.0,
        item: sakeItem
    )

    // サンプル 3: ビール
    let beerItem = BeverageItem(
        name: "IPA",
        producer: "BrewDog",
        category: .beer,
        region: "スコットランド"
    )
    let beerLog = TastingLog(
        rating: 4.0,
        appearanceNotes: "アンバー",
        aromaTags: ["シトラス", "ホップ"],
        sweetness: 2.2,
        saltiness: 0.0,
        acidity: 3.0,
        bitterness: 4.0,
        umami: 2.5,
        tannin: nil,
        body: 3.5,
        balanceTags: ["ドライな"],
        finishLength: 3.2,
        item: beerItem
    )

    container.mainContext.insert(wineItem)
    container.mainContext.insert(wineLog)
    container.mainContext.insert(sakeItem)
    container.mainContext.insert(sakeLog)
    container.mainContext.insert(beerItem)
    container.mainContext.insert(beerLog)

    return AnalyticsView()
        .modelContainer(container)
}
