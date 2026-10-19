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

    @State private var isShowingImageModal: Bool = false

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
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - 1. ヒーローラベル写真ヘッダー
                heroHeaderView

                // MARK: - 2. 詳細情報フォームカード群
                VStack(spacing: 16) {
                    if let item = log.item {
                        basicInfoCard(for: item)
                        specificMetadataCard(for: item)
                    }

                    ratingCard
                    appearanceAndAromaCard
                    tasteStructureCard

                    if !log.memo.isEmpty {
                        memoCard
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("ログ詳細")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingImageModal) {
            if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Button {
                        isShowingImageModal = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 16.0, *) {
                    let shareImage = renderShareImage()
                    ShareLink(
                        item: shareImage,
                        preview: SharePreview(
                            "\(log.item?.name ?? "テイスティング記録") の記録",
                            image: shareImage
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }

    // MARK: - ヒーローヘッダー
    private var heroHeaderView: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                Button {
                    isShowingImageModal = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .clipped()

                        // シャドウグラデーション
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )

                        // 拡大用アイコンバッジ
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.caption)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(12)
                    }
                }
                .buttonStyle(.plain)
            } else {
                // 写真がない場合のプレースホルダー（テイスティング色ベース）
                ZStack {
                    LinearGradient(
                        colors: [colorFromHex(log.appearanceColorHex).opacity(0.4), colorFromHex(log.appearanceColorHex)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 8) {
                        Image(systemName: "wineglass.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.8))
                        Text(log.item?.name ?? "テイスティングログ")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 180)
            }

            // カテゴリ＆銘柄名オーバレイ
            if let item = log.item {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.category.displayName)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(6)

                    Text(item.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(item.imageDatas?.first != nil ? .white : .primary)
                        .lineLimit(2)

                    if !item.producer.isEmpty {
                        Text(item.producer)
                            .font(.subheadline)
                            .foregroundStyle(item.imageDatas?.first != nil ? .white.opacity(0.8) : .secondary)
                    }
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - ヘルパー関数：画面を1枚のImageに変換
    @MainActor
    private func renderShareImage() -> Image {
        let cardView = TastingCardShareView(log: log)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = UIScreen.main.scale

        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "wineglass")
    }

    // MARK: - 基本情報カード
    private func basicInfoCard(for item: BeverageItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("基本情報")
                .font(.headline)

            VStack(spacing: 8) {
                if !item.region.isEmpty {
                    rowContent(label: "生産地", value: item.region)
                }
                if let vintage = item.vintage, !vintage.isEmpty {
                    rowContent(label: "ヴィンテージ / 年月", value: vintage)
                }
                if let abv = item.alcoholByVolume {
                    rowContent(label: "アルコール度数", value: String(format: "%.1f %%", abv))
                }
                if let price = item.price {
                    rowContent(label: "価格", value: "\(price) 円")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - 酒種固有メタデータカード
    @ViewBuilder
    private func specificMetadataCard(for item: BeverageItem) -> some View {
        if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
            switch item.category {
            case .wine:
                if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ワイン詳細")
                            .font(.headline)

                        VStack(spacing: 8) {
                            rowContent(label: "タイプ", value: meta.wineType)
                            if let appellation = meta.appellation, !appellation.isEmpty {
                                rowContent(label: "原産地呼称", value: appellation)
                            }
                            if !meta.blendComponents.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("ブドウ品種 (アッサンブラージュ)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    ForEach(meta.blendComponents) { comp in
                                        HStack {
                                            Text(comp.variety)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            if let pct = comp.percentage {
                                                Text("\(pct) %")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            } else if !meta.grapeVarieties.isEmpty {
                                rowContent(label: "主要品種", value: meta.grapeVarieties)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }

            case .sake:
                if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("日本酒詳細")
                            .font(.headline)

                        VStack(spacing: 8) {
                            rowContent(label: "特定名称", value: meta.specificName)
                            if !meta.riceVariety.isEmpty {
                                rowContent(label: "使用米", value: meta.riceVariety)
                            }
                            if !meta.polishingRate.isEmpty {
                                rowContent(label: "精米歩合", value: meta.polishingRate)
                            }
                            if !meta.sakeMeterValue.isEmpty {
                                rowContent(label: "日本酒度", value: meta.sakeMeterValue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }

            case .beer:
                if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ビール詳細")
                            .font(.headline)

                        VStack(spacing: 8) {
                            rowContent(label: "ビアスタイル", value: meta.beerStyle)
                            if !meta.ibu.isEmpty {
                                rowContent(label: "IBU (苦味単位)", value: meta.ibu)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }
            }
        }
    }

    // MARK: - 評価・スコアカード
    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("評価・スコア")
                .font(.headline)

            HStack {
                Text("飲んだ日")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(log.date.toFormattedString())
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Text("総合スコア")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: Double(i) < log.rating ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                    Text(String(format: "%.1f", log.rating))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - 外観・香りカード
    private var appearanceAndAromaCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("外観・香り")
                .font(.headline)

            if !log.appearanceNotes.isEmpty {
                HStack {
                    Text("外観")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 8) {
                        Circle()
                            .fill(colorFromHex(log.appearanceColorHex))
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                        Text(log.appearanceNotes)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }

            if !log.aromaTags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("香りタグ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(log.aromaTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.accentColor.opacity(0.12))
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - 味わい構造カード
    private var tasteStructureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("味わい構造")
                .font(.headline)

            VStack(spacing: 8) {
                tasteRow(title: "甘味", value: log.sweetness)
                tasteRow(title: "酸味", value: log.acidity)
                tasteRow(title: "苦味", value: log.bitterness)
                tasteRow(title: "旨味", value: log.umami)

                if let tannin = log.tannin {
                    tasteRow(title: "タンニン (渋味)", value: tannin)
                }

                tasteRow(title: "ボディ", value: log.body)
                tasteRow(title: "余韻の長さ", value: log.finishLength)
            }

            if !log.balanceTags.isEmpty {
                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text("バランス表現")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(log.balanceTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(.systemGray5))
                                .foregroundStyle(.primary)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - メモカード
    private var memoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("総合コメント・ペアリング")
                .font(.headline)

            Text(log.memo)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - ヘルパー関数
    private func rowContent(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private func tasteRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)

            ProgressView(value: value, total: 5.0)
                .tint(.accentColor)

            Text(String(format: "%.1f", value))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)

    let wineMeta = WineSpecificMetadata(
        wineType: "赤",
        grapeVarieties: "カベルネ・ソーヴィニヨン",
        blendComponents: [
            BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 60),
            BlendComponent(variety: "メルロ", percentage: 30),
            BlendComponent(variety: "プティ・ヴェルド", percentage: 10)
        ],
        appellation: "AOC マルゴー (Margaux)"
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
