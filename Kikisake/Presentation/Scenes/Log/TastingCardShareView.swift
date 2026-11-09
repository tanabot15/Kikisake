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

    private var cardThemeColors: (primary: Color, secondary: Color) {
        let baseColor = colorFromHex(log.appearanceColorHex)
        
        let primaryColor = baseColor.opacity(0.55)
        let secondaryColor = baseColor.opacity(0.25)
        
        return (primaryColor, secondaryColor)
    }

    public var body: some View {
        let themeColors = cardThemeColors

        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: - 1. 上部セクション
            HStack(alignment: .top, spacing: 12) {
                // --- 左側コンテンツエリア ---
                VStack(alignment: .leading, spacing: 6) {
                    if let item = log.item {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)

                            if !item.producer.isEmpty {
                                Text(item.producer)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(.primary.opacity(0.75))
                                    .lineLimit(1)
                            }
                        }

                        Divider()
                            .padding(.vertical, 1)

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

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 3) {
                                Text("評価")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.primary.opacity(0.75))
                                    .frame(width: 32, alignment: .leading)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", log.rating))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.primary)
                            }
                            
                            if !log.appearanceNotes.isEmpty {
                                HStack(spacing: 4) {
                                    Text("外観")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.primary.opacity(0.75))
                                        .frame(width: 32, alignment: .leading)
                                    
                                    Circle()
                                        .fill(colorFromHex(log.appearanceColorHex))
                                        .frame(width: 8, height: 8)
                                        .overlay(Circle().stroke(Color.primary.opacity(0.3), lineWidth: 0.5))
                                    
                                    Text(log.appearanceNotes)
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                            }

                            if !log.aromaTags.isEmpty {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("香り")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.primary.opacity(0.75))
                                        .frame(width: 32, alignment: .leading)
                                        .padding(.top, 2)
                                    
                                    FlowLayout(spacing: 3) {
                                        ForEach(log.aromaTags, id: \.self) { tag in
                                            Text(tag)
                                                .font(.system(size: 7, weight: .medium))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color(.systemBackground).opacity(0.9))
                                                .foregroundStyle(Color.primary)
                                                .cornerRadius(3)
                                        }
                                    }
                                }
                            }

                            if log.isCostEffective || log.isWillingToRepeat || log.hasAgingPotential {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("特徴")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.primary.opacity(0.75))
                                        .frame(width: 32, alignment: .leading)
                                        .padding(.top, 2)
                                    
                                    FlowLayout(spacing: 3) {
                                        if log.isCostEffective {
                                            Text("コスパ")
                                                .font(.system(size: 7, weight: .semibold))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.green.opacity(0.2))
                                                .foregroundStyle(.green)
                                                .cornerRadius(3)
                                        }
                                        if log.isWillingToRepeat {
                                            Text("リピート")
                                                .font(.system(size: 7, weight: .semibold))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.orange.opacity(0.2))
                                                .foregroundStyle(.orange)
                                                .cornerRadius(3)
                                        }
                                        if log.hasAgingPotential {
                                            Text("熟成")
                                                .font(.system(size: 7, weight: .semibold))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.purple.opacity(0.2))
                                                .foregroundStyle(.purple)
                                                .cornerRadius(3)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(6)
                        .background(Color(.systemBackground).opacity(0.85))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                        )
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // --- 右側ボトル表示部分 ---
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        // ✨ 背景透過時はグラデーションを敷かずクリア、またはカードに馴染む背景にする
                        if let item = log.item, item.isBackgroundRemoved {
                            Color.clear
                        } else {
                            LinearGradient(
                                colors: [Color(.tertiarySystemGroupedBackground), Color(.systemBackground)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }

                        if let item = log.item, let imageData = item.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                            if item.isBackgroundRemoved {
                                // くり抜き済みの場合：切り抜き済み画像または処理済み画像を中央配置で綺麗にフィット
                                if let processed = processedBottleImage {
                                    Image(uiImage: processed)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 150, maxHeight: 190)
                                        .padding(4)
                                } else {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 150, maxHeight: 190)
                                        .padding(4)
                                        .task {
                                            let backgroundRemoved = await BottleMattingHelper.removeBackground(from: uiImage)
                                            self.processedBottleImage = backgroundRemoved
                                        }
                                }
                            } else {
                                // そのままの写真を使用する場合：背景処理を行わず、全体を綺麗にクロップ/フィット表示
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 190)
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))

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
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
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

            // MARK: - 3. ペアリング ＆ コメント ＆ フッター
            if let pairing = log.pairing, !pairing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                    Text(pairing)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(6)
                .padding(.horizontal, 12)
            }

            if !log.memo.isEmpty {
                Text(log.memo)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
            }

            HStack {
                Text("Kikisake - Professional Tasting Log")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.75))
                Spacer()
                Text(log.date.toFormattedString())
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.75))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .frame(width: 380)
        .background(
            ZStack {
                Color(.systemBackground).opacity(0.4)
                
                LinearGradient(
                    colors: [themeColors.primary, themeColors.secondary, Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorFromHex(log.appearanceColorHex).opacity(0.35), lineWidth: 1.2)
        )
        .shadow(color: colorFromHex(log.appearanceColorHex).opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private func specRow(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.primary.opacity(0.75))
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

// MARK: - プレビュー (背景透過あり)
#Preview("背景透過") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018 (背景透過)",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        alcoholByVolume: 14.0,
        imageDatas: [generateVerticalSampleImage() ?? Data()],
        isBackgroundRemoved: true
    )

    let sampleLog = TastingLog(
        rating: 4.8,
        pairing: "和牛のローストビーフ",
        memo: "背景が透過され、ボトルがすっきりと美しく表示されます。",
        isEvaluated: true,
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        TastingCardShareView(log: sampleLog).padding()
    }
    .modelContainer(container)
}

// MARK: - プレビュー (背景透過なし)
#Preview("通常") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018 (そのまま使用)",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018",
        alcoholByVolume: 14.0,
        imageDatas: [generateVerticalSampleImage() ?? Data()],
        isBackgroundRemoved: false
    )

    let sampleLog = TastingLog(
        rating: 4.8,
        pairing: "和牛のローストビーフ",
        memo: "そのままの写真として全体がフィット/クロップ表示されます。",
        isEvaluated: true,
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        TastingCardShareView(log: sampleLog).padding()
    }
    .modelContainer(container)
}
