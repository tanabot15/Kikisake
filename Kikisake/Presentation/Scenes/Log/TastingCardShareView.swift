//
//  TastingCardShareView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/19.
//

import SwiftUI
import SwiftData

/// X (Twitter) などのSNS投稿用に最適化された、プロフェッショナル仕様のテイスティングカード画像用ビュー
public struct TastingCardShareView: View {
    let log: TastingLog

    public init(log: TastingLog) {
        self.log = log
    }

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
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - 1. ヘッダー（写真 ＋ 基本情報オーバーレイ）
            ZStack(alignment: .bottomLeading) {
                if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                } else {
                    Rectangle()
                        .fill(Color.accentColor.gradient)
                        .frame(height: 120)
                }

                if let item = log.item {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.category.displayName)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.25))
                                .foregroundStyle(.white)
                                .cornerRadius(4)
                            
                            Spacer()

                            // 総合スコアバッジ
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", log.rating))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(6)
                        }

                        Text(item.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        if !item.producer.isEmpty {
                            Text(item.producer)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)
                        }
                    }
                    .padding(12)
                }
            }

            // MARK: - 2. スペック・品種・詳細情報グリッド
            if let item = log.item {
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        if !item.region.isEmpty {
                            specBadge(title: "生産地", value: item.region)
                        }
                        if let vintage = item.vintage, !vintage.isEmpty {
                            specBadge(title: "VT/年月", value: vintage)
                        }
                        if let abv = item.alcoholByVolume {
                            specBadge(title: "度数", value: String(format: "%.1f%%", abv))
                        }
                    }

                    // ブドウ品種 / 使用米 / スタイルをカードに記載
                    if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                        switch item.category {
                        case .wine:
                            if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                                let varietiesText = !meta.blendComponents.isEmpty
                                    ? meta.blendComponents.map { "\($0.variety)(\($0.percentage.map { "\($0)%" } ?? ""))" }.joined(separator: ", ")
                                    : meta.grapeVarieties
                                if !varietiesText.isEmpty {
                                    specBadge(title: "品種", value: varietiesText)
                                }
                            }
                        case .sake:
                            if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                                let sakeInfo = [meta.specificName, meta.riceVariety.isEmpty ? nil : "米:\(meta.riceVariety)", meta.polishingRate.isEmpty ? nil : "精米:\(meta.polishingRate)"].compactMap { $0 }.joined(separator: " / ")
                                specBadge(title: "日本酒詳細", value: sakeInfo)
                            }
                        case .beer:
                            if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                                specBadge(title: "スタイル", value: meta.beerStyle)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }

            // MARK: - 3. レーダーチャート ＆ マトリクス分析の横並びエリア
            HStack(spacing: 8) {
                // 左側：多角形レーダーチャート (コンパクト版)
                TasteRadarCardView(log: log, isCompactMode: true)
                    .frame(maxWidth: .infinity)

                // 右側：マトリクス分析 (コンパクト版)
                MatrixAnalysisCardView(log: log, isCompactMode: true)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 10)

            // MARK: - 4. コメント・フッター
            if !log.memo.isEmpty {
                Text(log.memo)
                    .font(.system(size: 10))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
            }

            HStack {
                Text("Kikisake - Professional Tasting Log")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(log.date.toFormattedString())
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .frame(width: 400)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    private func specBadge(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        alcoholByVolume: 14.0
    )

    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        aromaTags: ["スミレ", "樽香", "チェリー", "タバコ", "スパイス"],
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        balanceTags: ["豊潤な"],
        finishLength: 4.8,
        memo: "圧倒的な気品と複雑味。長期熟成のポテンシャルを感じさせる素晴らしいバランス。",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        TastingCardShareView(log: sampleLog)
            .padding()
    }
    .modelContainer(container)
}
