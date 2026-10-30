//  TastingCardShareView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// X (Twitter) などのSNS投稿用に最適化された、プロフェッショナル仕様のテイスティングカード画像用ビュー
public struct TastingCardShareView: View {
    let log: TastingLog
    
    @State private var processedBottleImage: UIImage? = nil

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

    /// 外観カラーコードや酒種に応じたシグネチャーカラー（グラデーション用）を算出
    private var cardThemeColors: (primary: Color, secondary: Color) {
        let baseColor = colorFromHex(log.appearanceColorHex)
        
        let primaryColor = baseColor.opacity(0.55)
        let secondaryColor = baseColor.opacity(0.25)
        
        return (primaryColor, secondaryColor)
    }

    public var body: some View {
        let themeColors = cardThemeColors

        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: - 1. 上部セクション（左: 基本情報 ＋ スペック ＋ 評価/外観/香り / 右: ダイナミック・ボトルアプローチャ）
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
                                specRow(title: String(localized: "生産地"), value: item.region)
                            }
                            if let vintage = item.vintage, !vintage.isEmpty {
                                specRow(title: String(localized: "VT/年月"), value: vintage)
                            }
                            if let abv = item.alcoholByVolume {
                                specRow(title: String(localized: "度数"), value: String(format: "%.1f%%", abv))
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
                                            specRow(title: String(localized: "品種"), value: varietiesText)
                                        }
                                        if let appellation = meta.appellation, !appellation.isEmpty {
                                            specRow(title: String(localized: "呼称"), value: appellation)
                                        }
                                    }
                                case .sake:
                                    if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                                        if !meta.specificName.isEmpty {
                                            specRow(title: String(localized: "特定名称"), value: meta.specificName)
                                        }
                                        if !meta.riceVariety.isEmpty {
                                            specRow(title: String(localized: "使用米"), value: meta.riceVariety)
                                        }
                                        if !meta.polishingRate.isEmpty {
                                            specRow(title: String(localized: "精米歩合"), value: meta.polishingRate)
                                        }
                                    }
                                case .beer:
                                    if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                                        if !meta.beerStyle.isEmpty {
                                            specRow(title: String(localized: "スタイル"), value: meta.beerStyle)
                                        }
                                        if !meta.ibu.isEmpty {
                                            specRow(title: String(localized: "IBU"), value: meta.ibu)
                                        }
                                    }
                                }
                            }
                        }

                        // 基本情報 & スペックの下に入る「評価・外観・香り・特徴フラグ」サブセクション
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
                                                .background(Color(.systemBackground).opacity(0.7))
                                                .foregroundStyle(Color.primary)
                                                .cornerRadius(3)
                                        }
                                    }
                                }
                            }

                            // 特徴フラグ
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
                        .background(Color(.systemBackground).opacity(0.5))
                        .cornerRadius(6)
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // --- 右側：【ダイナミック・ボトルアプローチャ】透過・エッジ抽出フォトフレーム ＋ 裏面ラベルオーバーレイ ---
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        // 背景グラデーションポディウム
                        LinearGradient(
                            colors: [Color(.tertiarySystemGroupedBackground), Color(.systemBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        if let uiImage = processedBottleImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 2, y: 4)
                                .padding(6)
                        } else if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                                .padding(4)
                                .task {
                                    let backgroundRemoved = await BottleMattingHelper.removeBackground(from: uiImage)
                                    self.processedBottleImage = backgroundRemoved
                                }
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

                    // ✨ 右下に洗練されたサイズで重ねる裏面ラベルのミニサムネイル
                    if let backImageData = log.item?.backImageDatas?.first, let backUiImage = UIImage(data: backImageData) {
                        Image(uiImage: backUiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1)
                            .padding(8)
                    }
                }
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
        .background(
            ZStack {
                LinearGradient(
                    colors: [themeColors.primary, themeColors.secondary, Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.65)
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorFromHex(log.appearanceColorHex).opacity(0.25), lineWidth: 1.2)
        )
        .shadow(color: colorFromHex(log.appearanceColorHex).opacity(0.2), radius: 10, x: 0, y: 4)
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

/// プレビュー用のサンプル画像生成ヘルパー
private func generateVerticalSampleImage() -> Data? {
    let size = CGSize(width: 600, height: 1200)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        UIColor(red: 0.15, green: 0.05, blue: 0.08, alpha: 1.0).setFill()
        let bodyRect = CGRect(x: 180, y: 300, width: 240, height: 820)
        UIBezierPath(roundedRect: bodyRect, cornerRadius: 40).fill()
        
        let neckRect = CGRect(x: 235, y: 100, width: 130, height: 210)
        UIBezierPath(rect: neckRect).fill()
        
        UIColor(red: 0.85, green: 0.70, blue: 0.35, alpha: 1.0).setFill()
        let capRect = CGRect(x: 235, y: 70, width: 130, height: 70)
        UIBezierPath(roundedRect: capRect, cornerRadius: 8).fill()
        
        UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0).setFill()
        let labelRect = CGRect(x: 200, y: 480, width: 200, height: 320)
        UIBezierPath(roundedRect: labelRect, cornerRadius: 12).fill()
    }
    return image.jpegData(compressionQuality: 0.9)
}

/// プレビュー用の裏面ラベル画像生成ヘルパー
private func generateBackSampleImage() -> Data? {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600))
    let image = renderer.image { _ in
        UIColor.darkGray.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 400, height: 600))
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
        backImageDatas: [generateBackSampleImage() ?? Data()], // ✨ プレビュー用に裏面ラベルデータを付与
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

    return ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        TastingCardShareView(log: sampleLog)
            .padding()
    }
    .modelContainer(container)
}
