//  BeverageCardView.swift
//  Kikisake

import SwiftUI

/// 飲んだ酒のリストや在庫一覧で使用する共通カードビュー（和風名刺デザイン・サイドパネル拡張）
public struct BeverageCardView: View {
    let name: String
    let producer: String
    let category: BeverageCategory
    let region: String
    let vintage: String?
    let rating: Double?
    let imageData: Data?
    let isBackgroundRemoved: Bool
    let appearanceColorHex: String?

    public init(
        name: String,
        producer: String,
        category: BeverageCategory,
        region: String,
        vintage: String?,
        rating: Double?,
        imageData: Data? = nil,
        isBackgroundRemoved: Bool = true,
        appearanceColorHex: String? = nil
    ) {
        self.name = name
        self.producer = producer
        self.category = category
        self.region = region
        self.vintage = vintage
        self.rating = rating
        self.imageData = imageData
        self.isBackgroundRemoved = isBackgroundRemoved
        self.appearanceColorHex = appearanceColorHex
    }

    private var appearanceColor: Color {
        guard let hex = appearanceColorHex, !hex.isEmpty else { return Color.accentColor }
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        if scanner.scanHexInt64(&rgbValue) {
            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0
            return Color(red: red, green: green, blue: blue)
        }
        return Color.accentColor
    }

    public var body: some View {
        HStack(spacing: 0) {
            // ✨ 1. 左側エリア：カードの上・左・下の端（ぎりぎり）まで完全に密着させるパネル
            ZStack {
                // 背景：外観カラーを薄く敷いたプレート（上・左・下がカード外縁に直結）
                LinearGradient(
                    colors: [
                        appearanceColor.opacity(0.18),
                        appearanceColor.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if let imageData, let uiImage = UIImage(data: imageData) {
                    if isBackgroundRemoved {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                    } else {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                } else {
                    Image(systemName: "wineglass")
                        .font(.system(size: 22))
                        .foregroundStyle(appearanceColor)
                }
            }
            .frame(width: 80, height: 110)
            // 左側の角だけにカード自体の角丸を合わせる
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )
            // 右側の境界にだけ微かなセパレーター線を引く
            .overlay(
                Rectangle()
                    .fill(appearanceColor.opacity(0.2))
                    .frame(width: 1),
                alignment: .trailing
            )

            // ✨ 2. 右側エリア：テキスト情報をゆったり配置
            VStack(alignment: .leading, spacing: 5) {
                // 最上段：組織名・会社名ポジション（生産者 / 蔵元）
                Text(producer.isEmpty ? " " : producer)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // 中央メイン：氏名ポジション（銘柄名）
                Text(name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                // 肩書・種別ポジション（酒種タグ ＋ ヴィンテージ ＋ 外観色）
                HStack(spacing: 6) {
                    Text(category.displayName)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(appearanceColor.opacity(0.15))
                        .foregroundStyle(appearanceColor)
                        .cornerRadius(4)

                    if let vintage, !vintage.isEmpty {
                        Text(vintage)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }

                    Circle()
                        .fill(appearanceColor)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.15), lineWidth: 0.5)
                        )
                }

                Spacer(minLength: 0)

                // 最下段：所在地 ＆ 右下の評価
                HStack(alignment: .bottom) {
                    if !region.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 10))
                            Text(region)
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(height: 110)
            
            Spacer(minLength: 0)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12) // カード全体の角丸
        .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Preview Supporting Helper
fileprivate extension UIImage {
    static func sampleBottleData(systemName: String, tintColor: UIColor) -> Data? {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        guard let image = UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(tintColor, renderingMode: .alwaysOriginal) else {
            return nil
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 80, height: 110), format: format)
        let renderedImage = renderer.image { _ in
            let rect = CGRect(x: 20, y: 35, width: 40, height: 40)
            image.draw(in: rect)
        }
        return renderedImage.pngData()
    }
}

#Preview {
    let dummyWineData = UIImage.sampleBottleData(systemName: "wineglass.fill", tintColor: .purple)
    let dummySakeData = UIImage.sampleBottleData(systemName: "drop.fill", tintColor: .systemTeal)

    return ScrollView {
        VStack(spacing: 16) {
            Text("【名刺風フルブリード】左パネルが上下左端に密着")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            BeverageCardView(
                name: "Château Margaux 2015",
                producer: "Château Margaux",
                category: .wine,
                region: "ボルドー, フランス",
                vintage: "2015",
                rating: 4.8,
                imageData: dummyWineData,
                isBackgroundRemoved: true,
                appearanceColorHex: "#991A33"
            )

            BeverageCardView(
                name: "久保田 萬壽",
                producer: "朝日酒造",
                category: .sake,
                region: "新潟県",
                vintage: "2026",
                rating: 4.5,
                imageData: dummySakeData,
                isBackgroundRemoved: true,
                appearanceColorHex: "#D4AF37"
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
