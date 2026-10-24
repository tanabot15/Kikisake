//  TastingCardShareView.swift
//  Kikisake

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
        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: - 1. 上部セクション（左: 基本情報 ＋ スペック ＋ 評価/外観/香り / 右: 正方形のフォトフレーム）
            HStack(alignment: .top, spacing: 12) {
                // --- 左側コンテンツエリア ---
                VStack(alignment: .leading, spacing: 6) {
                    if let item = log.item {
                        // カテゴリバッジ ＆ 銘柄名 ＆ 生産者
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)

                            if !item.producer.isEmpty {
                                Text(item.producer)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Divider()
                            .padding(.vertical, 1)

                        // 詳細スペック (生産地, ヴィンテージ, 度数, 固有メタデータ)
                        VStack(alignment: .leading, spacing: 2) {
                            if !item.region.isEmpty {
                                specRow(title: "生産地", value: item.region)
                            }
                            if let vintage = item.vintage, !vintage.isEmpty {
                                specRow(title: "VT/年月", value: vintage)
                            }
                            if let abv = item.alcoholByVolume {
                                specRow(title: "度数", value: String(format: "%.1f%%", abv))
                            }

                            // 酒種固有のメタデータ
                            if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                                switch item.category {
                                case .wine:
                                    if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                                        let varietiesText = !meta.blendComponents.isEmpty
                                            ? meta.blendComponents.map { "\($0.variety)(\($0.percentage.map { "\($0)%" } ?? ""))" }.joined(separator: ", ")
                                            : meta.grapeVarieties
                                        if !varietiesText.isEmpty {
                                            specRow(title: "品種", value: varietiesText)
                                        }
                                        if let appellation = meta.appellation, !appellation.isEmpty {
                                            specRow(title: "呼称", value: appellation)
                                        }
                                    }
                                case .sake:
                                    if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                                        if !meta.specificName.isEmpty {
                                            specRow(title: "特定名称", value: meta.specificName)
                                        }
                                        if !meta.riceVariety.isEmpty {
                                            specRow(title: "使用米", value: meta.riceVariety)
                                        }
                                        if !meta.polishingRate.isEmpty {
                                            specRow(title: "精米歩合", value: meta.polishingRate)
                                        }
                                    }
                                case .beer:
                                    if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                                        if !meta.beerStyle.isEmpty {
                                            specRow(title: "スタイル", value: meta.beerStyle)
                                        }
                                        if !meta.ibu.isEmpty {
                                            specRow(title: "IBU", value: meta.ibu)
                                        }
                                    }
                                }
                            }
                        }

                        // ✨ 基本情報 & スペックの下に入る「評価・外観・香り・特徴フラグ」サブセクション
                        VStack(alignment: .leading, spacing: 4) {
                            // 評価
                            HStack(spacing: 3) {
                                Text("評価")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 32, alignment: .leading)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", log.rating))
                                    .font(.system(size: 9, weight: .bold))
                            }
                            
                            // 外観
                            if !log.appearanceNotes.isEmpty {
                                HStack(spacing: 4) {
                                    Text("外観")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 32, alignment: .leading)
                                    
                                    Circle()
                                        .fill(colorFromHex(log.appearanceColorHex))
                                        .frame(width: 8, height: 8)
                                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5))
                                    
                                    Text(log.appearanceNotes)
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                            }

                            // 香りタグ
                            if !log.aromaTags.isEmpty {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("香り")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 32, alignment: .leading)
                                        .padding(.top, 2)
                                    
                                    FlowLayout(spacing: 3) {
                                        ForEach(log.aromaTags, id: \.self) { tag in
                                            Text(tag)
                                                .font(.system(size: 7, weight: .medium))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.primary.opacity(0.1))
                                                .foregroundStyle(Color.primary)
                                                .cornerRadius(3)
                                        }
                                    }
                                }
                            }

                            // ✨ 特徴フラグ (設定されている場合のみサブセクション内に表示)
                            if log.isCostEffective || log.isWillingToRepeat || log.hasAgingPotential {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("特徴")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 32, alignment: .leading)
                                        .padding(.top, 2)
                                    
                                    FlowLayout(spacing: 3) {
                                        if log.isCostEffective {
                                            Text("コスパ")
                                                .font(.system(size: 7, weight: .medium))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.green.opacity(0.15))
                                                .foregroundStyle(.green)
                                                .cornerRadius(3)
                                        }
                                        if log.isWillingToRepeat {
                                            Text("リピート")
                                                .font(.system(size: 7, weight: .medium))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.orange.opacity(0.15))
                                                .foregroundStyle(.orange)
                                                .cornerRadius(3)
                                        }
                                        if log.hasAgingPotential {
                                            Text("熟成")
                                                .font(.system(size: 7, weight: .medium))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.purple.opacity(0.15))
                                                .foregroundStyle(.purple)
                                                .cornerRadius(3)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(6)
                        .background(Color(.tertiarySystemGroupedBackground).opacity(0.6))
                        .cornerRadius(6)
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // --- 右側：正方形フォトフレーム ---
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.tertiarySystemGroupedBackground))

                    if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                            .padding(4)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "wineglass")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                            Text("No Image")
                                .font(.system(size: 8))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .frame(width: 150, height: 190)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            Divider()
                .padding(.horizontal, 12)

            // MARK: - 2. 下部セクション（プロファイル・レーダーチャート ＆ マトリクス分析）
            HStack(spacing: 8) {
                TasteRadarCardView(log: log, isCompactMode: true)
                    .frame(maxWidth: .infinity)

                MatrixAnalysisCardView(log: log, isCompactMode: true)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)

            // MARK: - 3. コメント ＆ フッター
            if !log.memo.isEmpty {
                Text(log.memo)
                    .font(.system(size: 10))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
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
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .frame(width: 380)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    private func specRow(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 38, alignment: .leading)
            
            Text(value)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }
}

/// 縦長ボトルのサンプル画像を生成するヘルパー（Preview用）
private func generateVerticalSampleImage() -> Data? {
    let size = CGSize(width: 600, height: 1200)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        UIColor.systemIndigo.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        UIColor.darkGray.setFill()
        let rect = CGRect(x: 200, y: 150, width: 200, height: 900)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 30)
        path.fill()
    }
    return image.jpegData(compressionQuality: 0.8)
}

#Preview {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let wineMeta = WineSpecificMetadata(
        wineType: "赤",
        grapeVarieties: "ネッビオーロ",
        blendComponents: [BlendComponent(variety: "ネッビオーロ", percentage: 100)],
        appellation: "Barolo DOCG"
    )
    let encoder = JSONEncoder()
    let metaJSON = String(data: try! encoder.encode(wineMeta), encoding: .utf8)

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        alcoholByVolume: 14.0,
        imageDatas: [generateVerticalSampleImage() ?? Data()],
        specificMetadataJSON: metaJSON
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
        isCostEffective: true,       // ✨ プレビュー用にフラグをON
        isWillingToRepeat: true,     // ✨ プレビュー用にフラグをON
        hasAgingPotential: true,     // ✨ プレビュー用にフラグをON
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
