//
//  BeverageCardView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// 飲んだ酒のリストや在庫一覧で使用する共通カードビュー
public struct BeverageCardView: View {
    let name: String
    let producer: String
    let category: BeverageCategory
    let region: String
    let vintage: String?
    let rating: Double?
    let imageData: Data?
    let appearanceColorHex: String?

    public init(
        name: String,
        producer: String,
        category: BeverageCategory,
        region: String,
        vintage: String?,
        rating: Double?,
        imageData: Data? = nil,
        appearanceColorHex: String? = nil
    ) {
        self.name = name
        self.producer = producer
        self.category = category
        self.region = region
        self.vintage = vintage
        self.rating = rating
        self.imageData = imageData
        self.appearanceColorHex = appearanceColorHex
    }

    /// HEX文字列からSwiftUIのColorを生成するヘルパー
    private var appearanceColor: Color? {
        guard let hex = appearanceColorHex, !hex.isEmpty else { return nil }
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        if scanner.scanHexInt64(&rgbValue) {
            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0
            return Color(red: red, green: green, blue: blue)
        }
        return nil
    }

    public var body: some View {
        HStack(spacing: 12) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "wineglass")
                            .foregroundStyle(.secondary)
                    }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(category.displayName)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(4)
                            
                            if let vintage, !vintage.isEmpty {
                                Text(vintage)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let color = appearanceColor {
                                Circle()
                                    .fill(color)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                                    )
                            }
                        }

                        Text(name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(producer)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    if let rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                    }
                }

                if !region.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                        Text(region)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 12) {
        // パターン1: ワイン（ルビーレッドのカラーサークル表示）
        BeverageCardView(
            name: "Château Margaux 2015",
            producer: "Château Margaux",
            category: .wine,
            region: "ボルドー, フランス",
            vintage: "2015",
            rating: 4.8,
            imageData: nil,
            appearanceColorHex: "#991A33" // ルビーレッド
        )

        // パターン2: 日本酒（淡金色のカラーサークル表示）
        BeverageCardView(
            name: "久保田 萬壽",
            producer: "朝日酒造",
            category: .sake,
            region: "新潟県",
            vintage: "2026",
            rating: 4.5,
            imageData: nil,
            appearanceColorHex: "#F3E6B3" // 淡金色
        )

        // パターン3: ビール（ゴールデンのカラーサークル表示）
        BeverageCardView(
            name: "Inedit Damm",
            producer: "Damm",
            category: .beer,
            region: "バルセロナ, スペイン",
            vintage: "2026",
            rating: 4.2,
            imageData: nil,
            appearanceColorHex: "#EBC733" // ゴールデン
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
