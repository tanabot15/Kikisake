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
    let stockQuantity: Int?
    let rating: Double?
    let imageData: Data?

    public init(
        name: String,
        producer: String,
        category: BeverageCategory,
        region: String,
        vintage: String?,
        stockQuantity: Int?,
        rating: Double?,
        imageData: Data? = nil
    ) {
        self.name = name
        self.producer = producer
        self.category = category
        self.region = region
        self.vintage = vintage
        self.stockQuantity = stockQuantity
        self.rating = rating
        self.imageData = imageData
    }

    public var body: some View {
        HStack(spacing: 12) {
            // サムネイル画像（存在する場合のみ表示）
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // プレースホルダー（画像がない場合）
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
                    } else if let stockQuantity {
                        Text("残り \(stockQuantity)本")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
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
        BeverageCardView(
            name: "Château Margaux 2015",
            producer: "Château Margaux",
            category: .wine,
            region: "ボルドー, フランス",
            vintage: "2015",
            stockQuantity: nil,
            rating: 4.8,
            imageData: nil
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
