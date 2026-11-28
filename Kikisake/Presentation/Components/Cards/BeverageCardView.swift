//
//  BeverageCardView.swift
//  Kikisake
//

import SwiftUI

/// 飲んだ酒のリストや在庫一覧で使用する共通カードビュー（和風名刺デザイン・サイドパネル拡張）
public struct BeverageCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    private static let cardCornerRadius: CGFloat = 12
    private static let cardHeight: CGFloat = 110
    private static let panelWidth: CGFloat = 80

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

    /// ライトモードで薄い色（高輝度・低明度）が指定された場合でもコントラストを確保する文字色
    private var badgeForegroundColor: Color {
        guard colorScheme == .light else {
            return appearanceColor
        }

        let uiColor = UIColor(appearanceColor)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return .primary
        }

        // 輝度が高い（薄い・明るい）色ほど暗くし、視認性を確保
        if brightness > 0.65 {
            let darkenedBrightness = max(0.32, brightness * 0.45)
            let boostedSaturation = min(1.0, max(saturation, 0.35))
            return Color(
                hue: hue,
                saturation: boostedSaturation,
                brightness: darkenedBrightness,
                opacity: alpha
            )
        }

        return appearanceColor
    }

    public var body: some View {
        HStack(spacing: 0) {
            sidePanelView
            detailSectionView
            Spacer(minLength: 0)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Self.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 3)
    }

    private var sidePanelView: some View {
        ZStack {
            sidePanelBackground

            if let imageData, let uiImage = UIImage(data: imageData) {
                if isBackgroundRemoved {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
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
        .frame(width: Self.panelWidth, height: Self.cardHeight)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: Self.cardCornerRadius,
                bottomLeadingRadius: Self.cardCornerRadius,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
        )
        .overlay(
            Rectangle()
                .fill(appearanceColor.opacity(0.2))
                .frame(width: 1),
            alignment: .trailing
        )
    }

    @ViewBuilder
    private var sidePanelBackground: some View {
        if isBackgroundRemoved {
            RadialGradient(
                colors: [
                    appearanceColor.opacity(0.25),
                    Color(.systemBackground).opacity(0.95),
                    Color(.secondarySystemBackground)
                ],
                center: .center,
                startRadius: 5,
                endRadius: 60
            )
        } else {
            LinearGradient(
                colors: [
                    appearanceColor.opacity(0.18),
                    appearanceColor.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var detailSectionView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(producer.isEmpty ? " " : producer)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            metadataRowView

            Spacer(minLength: 0)

            footerRowView
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(height: Self.cardHeight)
    }

    private var metadataRowView: some View {
        HStack(spacing: 6) {
            Text(category.displayName)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2.5)
                .background(appearanceColor.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(appearanceColor.opacity(0.28), lineWidth: 0.6)
                )
                .foregroundStyle(badgeForegroundColor)
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
    }

    private var footerRowView: some View {
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
            Text("【名刺風フルブリード】左パネルが明るいスポットライト背景に")
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
                appearanceColorHex: "#F5F3E7"
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
