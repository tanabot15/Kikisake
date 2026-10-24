//  LogDetailView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// テイスティングログの詳細画面
public struct LogDetailView: View {
    let log: TastingLog

    @State private var isShowingImageModal: Bool = false
    @State private var isShowingEditSheet: Bool = false

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
        ScrollView {
            VStack(spacing: 16) {
                ConditionalAdMobBannerView()
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                
                heroHeaderView

                VStack(spacing: 16) {
                    if let item = log.item {
                        basicInfoCard(for: item)
                        specificMetadataCard(for: item)
                    }

                    ratingCard
                    appearanceAndAromaCard
                    
                    // 味わい構造カード
                    TasteRadarCardView(log: log, isCompactMode: false)

                    // マトリクス分析カード
                    MatrixAnalysisCardView(log: log, isCompactMode: false)

                    // ✨ 特徴・評価フラグカード (設定されている場合のみ表示)
                    if log.isCostEffective || log.isWillingToRepeat || log.hasAgingPotential {
                        flagsCard
                    }

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
                HStack(spacing: 16) {
                    Button {
                        isShowingEditSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }

                    if #available(iOS 16.0, *) {
                        let shareImage = renderShareImage()
                        ShareLink(
                            item: shareImage,
                            preview: SharePreview(
                                "\(log.item?.name ?? "テイスティング") の記録",
                                image: shareImage
                            )
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditLogFlowView(log: log)
        }
    }

    /// ✨ 特徴・評価フラグを表示する洗練されたUIカード
    private var flagsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("特徴・評価フラグ")
                .font(.headline)

            FlowLayout(spacing: 8) {
                if log.isCostEffective {
                    Label("コスパ高い", systemImage: "yensign.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.12))
                        .foregroundStyle(.green)
                        .cornerRadius(10)
                }

                if log.isWillingToRepeat {
                    Label("リピート意向", systemImage: "arrow.clockwise.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12))
                        .foregroundStyle(.orange)
                        .cornerRadius(10)
                }

                if log.hasAgingPotential {
                    Label("熟成ポテンシャル", systemImage: "hourglass.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.12))
                        .foregroundStyle(.purple)
                        .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    /// ✨ 横長写真でも画面をはみ出さない、安全かつ洗練されたヘッダービュー
    private var heroHeaderView: some View {
        ZStack(alignment: .bottom) {
            if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                Button {
                    isShowingImageModal = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        ZStack {
                            Color.black
                            // 背景にぼかした画像を敷き詰めてリッチに演出
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 20)
                                .opacity(0.4)

                            // メインの写真：横長・縦長問わず綺麗に収まるように調整
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 320)
                                .padding(.vertical, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipped() // ✨ はみ出しを確実に防止

                        LinearGradient(
                            colors: [.clear, .black.opacity(0.75)],
                            startPoint: .center,
                            endPoint: .bottom
                        )

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
                ZStack {
                    LinearGradient(
                        colors: [colorFromHex(log.appearanceColorHex).opacity(0.4), colorFromHex(log.appearanceColorHex)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: "wineglass.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(height: 200)
            }

            if let item = log.item {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(item.imageDatas?.first != nil ? .white : .primary)
                        .lineLimit(2)

                    if !item.producer.isEmpty {
                        Text(item.producer)
                            .font(.subheadline)
                            .foregroundStyle(item.imageDatas?.first != nil ? .white.opacity(0.8) : .primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
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
                rowContent(label: "飲んだ日", value: log.date.toFormattedString())
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

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
                                HStack {
                                    Text("ブドウ品種")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(meta.blendComponents) { comp in
                                            HStack {
                                                Text(comp.variety)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                
                                                if let pct = comp.percentage {
                                                    Text("(\(pct) %)")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.primary)
                                                }
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

    private var memoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("総合コメント")
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
        price: 12000,
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
        isCostEffective: true,
        isWillingToRepeat: true,
        hasAgingPotential: true,
        memo: "圧倒的な気品と複雑味。長期熟成のポテンシャルを感じさせる素晴らしいバランス。",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return NavigationStack {
        LogDetailView(log: sampleLog)
    }
    .modelContainer(container)
}
