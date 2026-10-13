//
//  TastingLog.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

/// 個別のテイスティング記録を保持するSwiftDataモデル
@Model
final class TastingLog {
    @Attribute(.unique) var id: UUID
    var date: Date                    // 飲んだ日
    var rating: Double                // 総合スコア (例: 1.0〜5.0)

    // --- 構造化テイスティングデータ ---
    var appearanceNotes: String       // 外観（清澄度、色調、輝き等）

    // 香りタグの配列
    var aromaTags: [String]           // 例: ["カシス", "ヴァニラ", "杉"] / ["吟醸香", "青りんご"]

    // 味わい構造パラメータ（0.0 〜 5.0 のスライダー評価）
    var sweetness: Double             // 甘味
    var acidity: Double               // 酸味
    var bitternessOrTannin: Double    // タンニン（ワイン）/ 苦味（ビール・日本酒）
    var body: Double                  // フルボディ/重み
    var finishLength: Double          // 余韻の長さ

    // 専門パラメータ（オプショナル）
    var alcoholByVolume: Double?      // アルコール度数
    var specificDataJSON: String?     // 日本酒度・酸度・IBU等の酒種特有メタデータ（JSON形式）

    var memo: String                  // 総合コメント・ペアリングメモ

    // リレーション
    var item: BeverageItem?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        rating: Double = 4.0,
        appearanceNotes: String = "",
        aromaTags: [String] = [],
        sweetness: Double = 2.5,
        acidity: Double = 2.5,
        bitternessOrTannin: Double = 2.5,
        body: Double = 2.5,
        finishLength: Double = 2.5,
        alcoholByVolume: Double? = nil,
        specificDataJSON: String? = nil,
        memo: String = "",
        item: BeverageItem? = nil
    ) {
        self.id = id
        self.date = date
        self.rating = rating
        self.appearanceNotes = appearanceNotes
        self.aromaTags = aromaTags
        self.sweetness = sweetness
        self.acidity = acidity
        self.bitternessOrTannin = bitternessOrTannin
        self.body = body
        self.finishLength = finishLength
        self.alcoholByVolume = alcoholByVolume
        self.specificDataJSON = specificDataJSON
        self.memo = memo
        self.item = item
    }
}
