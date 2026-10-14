//
//  PreviewSampleLoader.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData

public enum PreviewSampleLoader {
    /// シミュレータ起動時などに、データが空であればリッチなサンプルデータを挿入する
    public static func insertSamplesIfNeeded(into context: ModelContext) {
        #if DEBUG
        // すでにデータが存在する場合は重複挿入を防ぐためスキップ
        let descriptor = FetchDescriptor<BeverageItem>()
        guard let count = try? context.fetchCount(descriptor), count == 0 else {
            return
        }

        // 1. ワインのサンプル
        let wineItem = BeverageItem(
            name: "Château Margaux 2015",
            producer: "Château Margaux",
            category: .wine,
            region: "ボルドー, フランス",
            vintage: "2015",
            price: 85000,
            stockQuantity: 1,
            storageLocation: "ワインセラー"
        )
        let wineLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 3),
            rating: 4.9,
            appearanceNotes: "深みのあるルビーレッド、エッジにわずかな熟成香",
            aromaTags: ["カシス", "ヴァニラ", "杉", "トースト"],
            sweetness: 2.0,
            acidity: 4.2,
            bitternessOrTannin: 4.5,
            body: 4.8,
            finishLength: 5.0,
            memo: "圧倒的な気品と複雑味。カシスの芳醇な香りに樽のニュアンスが完璧に溶け込んでいる。",
            item: wineItem
        )

        // 2. 日本酒のサンプル
        let sakeItem = BeverageItem(
            name: "新政 No.6 R-type 生原酒",
            producer: "新政酒造",
            category: .sake,
            region: "秋田県",
            vintage: "2026/04",
            price: 2400,
            stockQuantity: 2,
            storageLocation: "冷蔵庫"
        )
        let sakeLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 1),
            rating: 4.7,
            appearanceNotes: "微発泡が感じられる透明な輝き",
            aromaTags: ["吟醸香", "青りんご", "洋梨", "フレッシュ"],
            sweetness: 3.2,
            acidity: 3.8,
            bitternessOrTannin: 1.5,
            body: 3.0,
            finishLength: 4.2,
            memo: "ジューシーな酸味と上品な甘みのバランスが素晴らしい。キレも抜群。",
            item: sakeItem
        )

        // 3. ビールのサンプル
        let beerItem = BeverageItem(
            name: "Inedit Damm",
            producer: "Damm",
            category: .beer,
            region: "バルセロナ, スペイン",
            vintage: "2026",
            price: 850,
            stockQuantity: 3,
            storageLocation: "常温"
        )
        let beerLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 6),
            rating: 4.3,
            appearanceNotes: "白濁したペールゴールド、きめ細やかな泡立ち",
            aromaTags: ["シトラス", "コリアンダー", "スパイス", "ホップ"],
            sweetness: 2.5,
            acidity: 3.0,
            bitternessOrTannin: 2.5,
            body: 3.5,
            finishLength: 3.8,
            memo: "シャンパンのように華やかで、食事に合わせやすいプレミアム・ホワイトビール。",
            item: beerItem
        )

        context.insert(wineItem)
        context.insert(wineLog)
        context.insert(sakeItem)
        context.insert(sakeLog)
        context.insert(beerItem)
        context.insert(beerLog)

        try? context.save()
        print("📸 [Simulator Demo] サンプルデータの挿入が完了しました。")
        #endif
    }
}
