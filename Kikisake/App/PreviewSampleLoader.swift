//  PreviewSampleLoader.swift
//  Kikisake

import Foundation
import SwiftData

public enum PreviewSampleLoader {
    /// デフォルトの保管場所を作成する
    public static func insertDefaultLocationsIfNeeded(into context: ModelContext) {
        let locationDescriptor = FetchDescriptor<StorageLocation>()
        let existingLocations = (try? context.fetch(locationDescriptor)) ?? []
        let locationNames = existingLocations.map { $0.name }

        var needsSave = false
        if !locationNames.contains("ワインセラー") {
            context.insert(StorageLocation(name: "ワインセラー", type: .cellar, memo: "デフォルトセラー", isGridEnabled: true, gridRows: 4, gridColumns: 6))
            needsSave = true
        }
        if !locationNames.contains("冷蔵庫") {
            context.insert(StorageLocation(name: "冷蔵庫", type: .refrigerator, memo: "生酒用", isGridEnabled: true, gridRows: 3, gridColumns: 4))
            needsSave = true
        }
        if !locationNames.contains("常温") {
            context.insert(StorageLocation(name: "常温", type: .roomTemp, memo: "常温保管", isGridEnabled: true, gridRows: 2, gridColumns: 4))
            needsSave = true
        }

        if needsSave {
            try? context.save()
            print("📦 [Default Loader] デフォルトの保管場所（グリッド有効）を作成しました。")
        }
    }

    /// サンプルデータを一意の1本としてそれぞれ独立挿入
    public static func insertSamples(into context: ModelContext) {
        insertDefaultLocationsIfNeeded(into: context)

        let encoder = JSONEncoder()

        // 1. ワインのサンプルメタデータ（セラー 1行1列目）
        let wineMeta = WineSpecificMetadata(
            wineType: "赤",
            grapeVarieties: "カベルネ・ソーヴィニヨン, メルロ",
            blendComponents: [
                BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 87),
                BlendComponent(variety: "メルロ", percentage: 10),
                BlendComponent(variety: "プティ・ヴェルド", percentage: 3)
            ],
            appellation: "Margaux AOC"
        )
        let wineMetaJSON = String(data: try! encoder.encode(wineMeta), encoding: .utf8)

        let wineItem = BeverageItem(
            name: "Château Margaux 2015",
            producer: "Château Margaux",
            category: .wine,
            region: "ボルドー, フランス",
            vintage: "2015",
            alcoholByVolume: 13.5,
            price: 85000,
            storageLocation: "ワインセラー",
            gridRow: 1,
            gridColumn: 1,
            specificMetadataJSON: wineMetaJSON
        )
        let wineLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 3),
            rating: 4.9,
            appearanceNotes: "深みのあるルビーレッド",
            appearanceColorHex: "#991A33",
            aromaTags: ["カシス", "ヴァニラ", "杉", "トースト"],
            sweetness: 2.0,
            saltiness: 0.0,
            acidity: 4.2,
            bitterness: 2.0,
            umami: 2.5,
            tannin: 4.5,
            body: 4.8,
            balanceTags: ["豊潤な", "厚みのある"],
            finishLength: 5.0,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: true,
            memo: "圧倒的な気品と複雑味。カシスの芳醇な香りに樽のニュアンスが完璧に溶け込んでいる。",
            isEvaluated: true,
            item: wineItem
        )

        // 2. 日本酒のサンプルメタデータ（冷蔵庫 1行1列目）
        let sakeMeta = SakeSpecificMetadata(
            specificName: "特別純米 生原酒",
            riceVariety: "秋田県産酒造好適米",
            polishingRate: "65%",
            sakeMeterValue: "+1.0"
        )
        let sakeMetaJSON = String(data: try! encoder.encode(sakeMeta), encoding: .utf8)

        let sakeItem = BeverageItem(
            name: "新政 No.6 R-type 生原酒",
            producer: "新政酒造",
            category: .sake,
            region: "秋田県",
            vintage: "2026/04",
            alcoholByVolume: 13.0,
            price: 2400,
            storageLocation: "冷蔵庫",
            gridRow: 1,
            gridColumn: 1,
            specificMetadataJSON: sakeMetaJSON
        )
        let sakeLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 1),
            rating: 4.7,
            appearanceNotes: "微発泡が感じられる透明な輝き",
            appearanceColorHex: "#F7FAFA",
            aromaTags: ["吟醸香", "青りんご", "洋梨", "フレッシュ"],
            sweetness: 3.2,
            saltiness: 0.0,
            acidity: 3.8,
            bitterness: 1.5,
            umami: 3.5,
            tannin: nil,
            body: 3.0,
            balanceTags: ["ジューシーな", "まろやかな"],
            finishLength: 4.2,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: "ジューシーな酸味と上品な甘みのバランスが素晴らしい。キレも抜群。",
            isEvaluated: true,
            item: sakeItem
        )

        // 3. ビールのサンプルメタデータ（常温 1行1列目）
        let beerMeta = BeerSpecificMetadata(
            beerStyle: "プレミアム・ホワイトビア",
            ibu: "11"
        )
        let beerMetaJSON = String(data: try! encoder.encode(beerMeta), encoding: .utf8)

        let beerItem = BeverageItem(
            name: "Inedit Damm",
            producer: "Damm",
            category: .beer,
            region: "バルセロナ, スペイン",
            vintage: "2026",
            alcoholByVolume: 4.8,
            price: 850,
            storageLocation: "常温",
            gridRow: 1,
            gridColumn: 1,
            specificMetadataJSON: beerMetaJSON
        )
        let beerLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 6),
            rating: 4.3,
            appearanceNotes: "白濁したペールゴールド",
            appearanceColorHex: "#EBC733",
            aromaTags: ["シトラス", "コリアンダー", "スパイス", "ホップ"],
            sweetness: 2.5,
            saltiness: 0.0,
            acidity: 3.0,
            bitterness: 3.5,
            umami: 2.5,
            tannin: nil,
            body: 3.5,
            balanceTags: ["スムーズな", "ドライな"],
            finishLength: 3.8,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: "シャンパンのように華やかで、食事に合わせやすいプレミアム・ホワイトビール。",
            isEvaluated: true,
            item: beerItem
        )

        context.insert(wineItem)
        context.insert(wineLog)
        context.insert(sakeItem)
        context.insert(sakeLog)
        context.insert(beerItem)
        context.insert(beerLog)

        try? context.save()
        print("[Sample Loader] サンプルデータの強制挿入が完了しました。")
    }

    public static func insertSamplesIfNeeded(into context: ModelContext) {
        insertDefaultLocationsIfNeeded(into: context)

        #if DEBUG
        let descriptor = FetchDescriptor<BeverageItem>()
        guard let count = try? context.fetchCount(descriptor), count == 0 else {
            return
        }
        insertSamples(into: context)
        #endif
    }
}
