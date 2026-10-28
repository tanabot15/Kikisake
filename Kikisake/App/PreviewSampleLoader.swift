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

    /// サンプルデータを独立挿入（ワイン2本、日本酒2本、ビール1本）
    public static func insertSamples(into context: ModelContext) {
        insertDefaultLocationsIfNeeded(into: context)

        let encoder = JSONEncoder()

        // ==========================================
        // 1. ワイン 1本目: Château Margaux 2015 (ワインセラー 1行1列目)
        // ==========================================
        let wineMeta1 = WineSpecificMetadata(
            wineType: "赤",
            grapeVarieties: "カベルネ・ソーヴィニヨン, メルロ",
            blendComponents: [
                BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 87),
                BlendComponent(variety: "メルロ", percentage: 10),
                BlendComponent(variety: "プティ・ヴェルド", percentage: 3)
            ],
            appellation: "Margaux AOC"
        )
        let wineMeta1JSON = String(data: try! encoder.encode(wineMeta1), encoding: .utf8)

        let wineItem1 = BeverageItem(
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
            specificMetadataJSON: wineMeta1JSON
        )
        let wineLog1 = TastingLog(
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
            item: wineItem1
        )

        // ==========================================
        // 2. ワイン 2本目: Meursault 2020 (ワインセラー 1行2列目)
        // ==========================================
        let wineMeta2 = WineSpecificMetadata(
            wineType: "白",
            grapeVarieties: "シャルドネ",
            blendComponents: [
                BlendComponent(variety: "シャルドネ", percentage: 100)
            ],
            appellation: "Meursault AOC"
        )
        let wineMeta2JSON = String(data: try! encoder.encode(wineMeta2), encoding: .utf8)

        let wineItem2 = BeverageItem(
            name: "Domaine Leflaive Meursault 2020",
            producer: "Domaine Leflaive",
            category: .wine,
            region: "ブルゴーニュ, フランス",
            vintage: "2020",
            alcoholByVolume: 13.0,
            price: 24000,
            storageLocation: "ワインセラー",
            gridRow: 1,
            gridColumn: 2,
            specificMetadataJSON: wineMeta2JSON
        )
        let wineLog2 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 5),
            rating: 4.7,
            appearanceNotes: "美しいストロー・イエロー",
            appearanceColorHex: "#F3E680",
            aromaTags: ["レモン", "洋梨", "ヴァニラ", "アーモンド", "バター"],
            sweetness: 2.0,
            saltiness: 0.0,
            acidity: 4.0,
            bitterness: 1.5,
            umami: 3.0,
            tannin: nil,
            body: 4.2,
            balanceTags: ["まろやかな", "豊潤な"],
            finishLength: 4.6,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: true,
            memo: "クリーミーな質感と引き締まったミネラルのバランスが絶妙。ナッツの芳ばしい余韻。",
            isEvaluated: true,
            item: wineItem2
        )

        // ==========================================
        // 3. 日本酒 1本目: 新政 No.6 R-type 生原酒 (冷蔵庫 1行1列目)
        // ==========================================
        let sakeMeta1 = SakeSpecificMetadata(
            specificName: "特別純米 生原酒",
            riceVariety: "秋田県産酒造好適米",
            polishingRate: "65%",
            sakeMeterValue: "+1.0"
        )
        let sakeMeta1JSON = String(data: try! encoder.encode(sakeMeta1), encoding: .utf8)

        let sakeItem1 = BeverageItem(
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
            specificMetadataJSON: sakeMeta1JSON
        )
        let sakeLog1 = TastingLog(
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
            item: sakeItem1
        )

        // ==========================================
        // 4. 日本酒 2本目: 黒龍 吟十八号 (冷蔵庫 1行2列目)
        // ==========================================
        let sakeMeta2 = SakeSpecificMetadata(
            specificName: "純米吟醸",
            riceVariety: "五百万石",
            polishingRate: "55%",
            sakeMeterValue: "+4.0"
        )
        let sakeMeta2JSON = String(data: try! encoder.encode(sakeMeta2), encoding: .utf8)

        let sakeItem2 = BeverageItem(
            name: "黒龍 吟十八号",
            producer: "黒龍酒造",
            category: .sake,
            region: "福井県",
            vintage: "2026/02",
            alcoholByVolume: 15.5,
            price: 3300,
            storageLocation: "冷蔵庫",
            gridRow: 1,
            gridColumn: 2,
            specificMetadataJSON: sakeMeta2JSON
        )
        let sakeLog2 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 4),
            rating: 4.6,
            appearanceNotes: "クリアで美しい無色透明",
            appearanceColorHex: "#F2F2F7",
            aromaTags: ["白桃", "メロン", "炊いた米", "アーモンド"],
            sweetness: 2.5,
            saltiness: 0.0,
            acidity: 3.0,
            bitterness: 1.2,
            umami: 3.8,
            tannin: nil,
            body: 3.2,
            balanceTags: ["スムーズな", "引き締まった"],
            finishLength: 4.4,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: "上品な香りと透明感のある口当たり。食事を引き立てる洗練された純米吟醸。",
            isEvaluated: true,
            item: sakeItem2
        )

        // ==========================================
        // 5. ビール 1本目: Inedit Damm (常温 1行1列目)
        // ==========================================
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

        // コンテキストへの挿入
        context.insert(wineItem1)
        context.insert(wineLog1)
        context.insert(wineItem2)
        context.insert(wineLog2)
        context.insert(sakeItem1)
        context.insert(sakeLog1)
        context.insert(sakeItem2)
        context.insert(sakeLog2)
        context.insert(beerItem)
        context.insert(beerLog)

        try? context.save()
        print("[Sample Loader] ワイン2本・日本酒2本・ビール1本のサンプルデータ挿入が完了しました。")
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
