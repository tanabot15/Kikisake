//
//  LogDetailView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// テイスティングログの詳細画面
public struct LogDetailView: View {
    let log: TastingLog

    public init(log: TastingLog) {
        self.log = log
    }

    public var body: some View {
        Form {
            if let item = log.item {
                Section("基本情報") {
                    LabeledContent("銘柄名", value: item.name)
                    LabeledContent("生産者", value: item.producer)
                    LabeledContent("酒種", value: item.category.displayName)
                    if !item.region.isEmpty {
                        LabeledContent("生産地", value: item.region)
                    }
                    if let vintage = item.vintage, !vintage.isEmpty {
                        LabeledContent("ヴィンテージ", value: vintage)
                    }
                }
            }

            Section("評価・スコア") {
                LabeledContent("飲んだ日", value: log.date.toFormattedString())
                HStack {
                    Text("総合スコア")
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: Double(i) < log.rating ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                        }
                        Text(String(format: "%.1f", log.rating))
                            .fontWeight(.bold)
                            .padding(.leading, 4)
                    }
                }
            }

            Section("外観・香り") {
                if !log.appearanceNotes.isEmpty {
                    LabeledContent("外観", value: log.appearanceNotes)
                }
                if !log.aromaTags.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("香りタグ")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(log.aromaTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.15))
                                        .foregroundStyle(Color.accentColor)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
            }

            Section("味わい構造") {
                LabeledContent("甘味", value: String(format: "%.1f", log.sweetness))
                LabeledContent("酸味", value: String(format: "%.1f", log.acidity))
                LabeledContent("タンニン/苦味", value: String(format: "%.1f", log.bitternessOrTannin))
                LabeledContent("ボディ", value: String(format: "%.1f", log.body))
                LabeledContent("余韻の長さ", value: String(format: "%.1f", log.finishLength))
            }

            if !log.memo.isEmpty {
                Section("総合コメント・ペアリング") {
                    Text(log.memo)
                }
            }
        }
        .navigationTitle("ログ詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    
    let sampleItem = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015",
        stockQuantity: 1
    )
    
    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "深みのあるルビーレッド",
        aromaTags: ["カシス", "ヴァニラ", "杉", "トースト"],
        sweetness: 2.0,
        acidity: 4.0,
        bitternessOrTannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "圧倒的な気品と複雑味。ローストビーフとの相性が抜群でした。",
        item: sampleItem
    )
    
    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return NavigationStack {
        LogDetailView(log: sampleLog)
    }
    .modelContainer(container)
}
