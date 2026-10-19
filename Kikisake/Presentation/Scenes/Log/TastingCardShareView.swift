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
        VStack(alignment: .leading, spacing: 14) {
            // MARK: - 1. ヘッダー（写真 ＋ 基本情報オーバーレイ）
            ZStack(alignment: .bottomLeading) {
                if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                } else {
                    Rectangle()
                        .fill(Color.accentColor.gradient)
                        .frame(height: 140)
                }

                if let item = log.item {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.category.displayName)
                                .font(.system(size: 10, weight: .bold))
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
                                    .font(.subheadline)
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
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)
                        }
                    }
                    .padding(12)
                }
            }

            // MARK: - 2. スペック・詳細情報グリッド
            if let item = log.item {
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
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

                    // 酒種ごとの固有詳細（メタデータ）の表示
                    if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                        switch item.category {
                        case .wine:
                            if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                                let varietiesText = !meta.blendComponents.isEmpty
                                    ? meta.blendComponents.map { "\($0.variety)(\($0.percentage.map { "\($0)%" } ?? ""))" }.joined(separator: ", ") // ✨ by から separator に修正
                                    : meta.grapeVarieties
                                if !varietiesText.isEmpty {
                                    specBadge(title: "品種", value: varietiesText)
                                }
                            }
                        case .sake:
                            if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                                specBadge(title: "特定名称", value: "\(meta.specificName) / 精米:\(meta.polishingRate)")
                            }
                        case .beer:
                            if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                                specBadge(title: "スタイル", value: meta.beerStyle)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            // MARK: - 3. 外観・香り・五味構造
            VStack(alignment: .leading, spacing: 8) {
                // 外観と香りタグ
                HStack(spacing: 8) {
                    if !log.appearanceNotes.isEmpty {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(colorFromHex(log.appearanceColorHex))
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5))
                            Text(log.appearanceNotes)
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                        }
                    }

                    Spacer()

                    Text(log.date.toFormattedString())
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                if !log.aromaTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(log.aromaTags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.system(size: 9, weight: .medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.12))
                                    .foregroundStyle(Color.accentColor)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }

                // 五味プロファイル簡易バー
                VStack(spacing: 4) {
                    miniTasteRow(title: "甘味", value: log.sweetness)
                    miniTasteRow(title: "酸味", value: log.acidity)
                    miniTasteRow(title: "苦味", value: log.bitterness)
                    miniTasteRow(title: "旨味", value: log.umami)
                    if let tannin = log.tannin {
                        miniTasteRow(title: "渋味", value: tannin)
                    }
                    miniTasteRow(title: "ボディ", value: log.body)
                    miniTasteRow(title: "余韻", value: log.finishLength)
                }
                .padding(8)
                .background(Color(.systemGray6).opacity(0.6))
                .cornerRadius(8)

                // 総合コメント
                if !log.memo.isEmpty {
                    Text(log.memo)
                        .font(.system(size: 11))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 12)

            // MARK: - 4. フッター（ブランディング）
            HStack {
                Text("Kikisake - Professional Tasting Log")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Date().toFormattedString())
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .frame(width: 380)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private func specBadge(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func miniTasteRow(title: String, value: Double) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .frame(width: 32, alignment: .leading)
                .foregroundStyle(.secondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray4))
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: max(0, min(CGFloat(value / 5.0) * geo.size.width, geo.size.width)), height: 4)
                }
            }
            .frame(height: 4)

            Text(String(format: "%.1f", value))
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 22, alignment: .trailing)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)

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
