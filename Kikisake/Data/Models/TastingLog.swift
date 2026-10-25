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
public final class TastingLog {
    @Attribute(.unique) public var id: UUID
    public var date: Date                    // 飲んだ日
    public var rating: Double                // 総合スコア (例: 1.0〜5.0)

    // --- 構造化テイスティングデータ ---
    public var appearanceNotes: String       // 外観（清澄度、色調、輝き等）
    public var appearanceColorHex: String    // 色のHEXコード（例: "#991A33"）
    public var aromaTags: [String]           // 香りタグの配列

    // --- 味わい構造パラメータ（基本五味 + タンニン + ボディ + 余韻） ---
    public var sweetness: Double             // 甘味 (0.0〜5.0)
    public var saltiness: Double             // 塩味 (0.0〜5.0)
    public var acidity: Double               // 酸味 (0.0〜5.0)
    public var bitterness: Double            // 苦味 (0.0〜5.0)
    public var umami: Double                 // 旨味 (0.0〜5.0)
    
    public var tannin: Double?               // タンニン / 渋味（赤・ロゼ・オレンジワイン用）
    public var body: Double                  // ボディ / 重み (0.0〜5.0)
    public var balanceTags: [String]         // バランス評価表現（複数選択）
    public var finishLength: Double          // 余韻の長さ (0.0〜5.0)

    // --- フラグ項目 ---
    public var isCostEffective: Bool         // 1. コスパ（コストパフォーマンスが良いか）
    public var isWillingToRepeat: Bool       // 2. リピート意向（また飲みたいか）
    public var hasAgingPotential: Bool       // 3. 熟成ポテンシャル（さらに寝かせるポテンシャルがあるか）

    // 専門パラメータ（オプショナル）
    public var alcoholByVolume: Double?      // アルコール度数
    public var specificDataJSON: String?     // 日本酒度・酸度・IBU等の酒種特有メタデータ（JSON形式）

    public var memo: String                  // 総合コメント・ペアリングメモ

    // ✨ 評価がユーザーによって入力されたかどうか
    public var isEvaluated: Bool

    // リレーション
    public var item: BeverageItem?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        rating: Double = 4.0,
        appearanceNotes: String = "",
        appearanceColorHex: String = "#802633",
        aromaTags: [String] = [],
        sweetness: Double = 2.5,
        saltiness: Double = 0.0,
        acidity: Double = 2.5,
        bitterness: Double = 2.5,
        umami: Double = 2.5,
        tannin: Double? = nil,
        body: Double = 2.5,
        balanceTags: [String] = [],
        finishLength: Double = 2.5,
        isCostEffective: Bool = false,
        isWillingToRepeat: Bool = false,
        hasAgingPotential: Bool = false,
        alcoholByVolume: Double? = nil,
        specificDataJSON: String? = nil,
        memo: String = "",
        isEvaluated: Bool = false,
        item: BeverageItem? = nil
    ) {
        self.id = id
        self.date = date
        self.rating = rating
        self.appearanceNotes = appearanceNotes
        self.appearanceColorHex = appearanceColorHex
        self.aromaTags = aromaTags
        self.sweetness = sweetness
        self.saltiness = saltiness
        self.acidity = acidity
        self.bitterness = bitterness
        self.umami = umami
        self.tannin = tannin
        self.body = body
        self.balanceTags = balanceTags
        self.finishLength = finishLength
        self.isCostEffective = isCostEffective
        self.isWillingToRepeat = isWillingToRepeat
        self.hasAgingPotential = hasAgingPotential
        self.alcoholByVolume = alcoholByVolume
        self.specificDataJSON = specificDataJSON
        self.memo = memo
        self.isEvaluated = isEvaluated
        self.item = item
    }
}
