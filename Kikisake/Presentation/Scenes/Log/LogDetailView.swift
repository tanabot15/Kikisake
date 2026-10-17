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
    
    /// HEX文字列からSwiftUIのColorを生成するヘルパー
    private func colorFromHex(_ hex: String) -> Color {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        if scanner.scanHexInt64(&rgbValue) {
            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0
            return Color(red: red, green: green, blue: blue)
        }
        return .gray
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
                        LabeledContent("ヴィンテージ / 年月", value: vintage)
                    }
                    if let abv = item.alcoholByVolume {
                        LabeledContent("アルコール度数", value: String(format: "%.1f %%", abv))
                    }
                    if let price = item.price {
                        LabeledContent("価格", value: "\(price) 円")
                    }
                }

                // --- 酒種ごとの固有メタデータセクション ---
                if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                    switch item.category {
                    case .wine:
                        if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                            Section("ワイン詳細") {
                                LabeledContent("タイプ", value: meta.wineType)
                                
                                if let appellation = meta.appellation, !appellation.isEmpty {
                                    LabeledContent("原産地呼称", value: appellation)
                                }
                                
                                // アッサンブラージュ（複数品種と割合％）の表示
                                if !meta.blendComponents.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("ブドウ品種 (アッサンブラージュ)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        
                                        ForEach(meta.blendComponents) { component in
                                            HStack {
                                                Text(component.variety)
                                                    .fontWeight(.medium)
                                                Spacer()
                                                if let percentage = component.percentage {
                                                    Text("\(percentage) %")
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 2)
                                } else if !meta.grapeVarieties.isEmpty {
                                    LabeledContent("主要品種", value: meta.grapeVarieties)
                                }
                            }
                        }
                    case .sake:
                        if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                            Section("日本酒詳細") {
                                LabeledContent("特定名称", value: meta.specificName)
                                if !meta.riceVariety.isEmpty {
                                    LabeledContent("使用米", value: meta.riceVariety)
                                }
                                if !meta.polishingRate.isEmpty {
                                    LabeledContent("精米歩合", value: meta.polishingRate)
                                }
                                if !meta.sakeMeterValue.isEmpty {
                                    LabeledContent("日本酒度", value: meta.sakeMeterValue)
                                }
                            }
                        }
                    case .beer:
                        if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                            Section("ビール詳細") {
                                LabeledContent("ビアスタイル", value: meta.beerStyle)
                                if !meta.ibu.isEmpty {
                                    LabeledContent("IBU (苦味単位)", value: meta.ibu)
                                }
                            }
                        }
                    }
                }
            }

            Section("評価・スコア") {
                LabeledContent("飲んだ日", value: log.date.toFormattedString())
                HStack {
                    Text("総合スコア")
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { i in
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
                    HStack {
                        Text("外観")
                        Spacer()
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorFromHex(log.appearanceColorHex))
                                .frame(width: 16, height: 16)
                                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                            Text(log.appearanceNotes)
                                .fontWeight(.medium)
                        }
                    }
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
                LabeledContent("塩味", value: String(format: "%.1f", log.saltiness))
                LabeledContent("酸味", value: String(format: "%.1f", log.acidity))
                LabeledContent("苦味", value: String(format: "%.1f", log.bitterness))
                LabeledContent("旨味", value: String(format: "%.1f", log.umami))
                
                if let tannin = log.tannin {
                    LabeledContent("タンニン (渋味)", value: String(format: "%.1f", tannin))
                }
                
                LabeledContent("ボディ", value: String(format: "%.1f", log.body))
                
                if !log.balanceTags.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("バランス表現")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(log.balanceTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.secondary.opacity(0.15))
                                        .foregroundStyle(.primary)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                
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
    
    // アッサンブラージュと原産地呼称のサンプルJSONを持つワインアイテム
    let wineMeta = WineSpecificMetadata(
        wineType: "赤",
        grapeVarieties: "カベルネ・ソーヴィニヨン",
        blendComponents: [
            BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 60),
            BlendComponent(variety: "メルロ", percentage: 30),
            BlendComponent(variety: "プティ・ヴェルド", percentage: 10)
        ],
        appellation: "AOC マルゴー (Margaux)" // ✨ プレビューに原産地呼称を追加
    )
    let encoder = JSONEncoder()
    let metaJSON = try? String(data: encoder.encode(wineMeta), encoding: .utf8)

    let sampleItem = BeverageItem(
        name: "Château Margaux 2015",
        producer: "Château Margaux",
        category: .wine,
        region: "ボルドー, フランス",
        vintage: "2015",
        alcoholByVolume: 13.5,
        price: 85000,
        stockQuantity: 1,
        specificMetadataJSON: metaJSON
    )
    
    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "深みのあるルビーレッド",
        appearanceColorHex: "#991A33",
        aromaTags: ["カシス", "ヴァニラ", "杉", "トースト"],
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.0,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        balanceTags: ["豊潤な", "厚みのある"],
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
