//  PreviewSampleLoader.swift
//  Kikisake

import Foundation
import SwiftData

public enum PreviewSampleLoader {
    /// 現在の優先言語が英語かどうかを判定するフラグ
    private static var isEnglish: Bool {
        let currentLang = Bundle.main.preferredLocalizations.first ?? Locale.current.language.languageCode?.identifier ?? "ja"
        return currentLang.hasPrefix("en")
    }

    /// デフォルトの保管場所を作成する（言語設定に応じて切り替え）
    public static func insertDefaultLocationsIfNeeded(into context: ModelContext) {
        let locationDescriptor = FetchDescriptor<StorageLocation>()
        let existingLocations = (try? context.fetch(locationDescriptor)) ?? []
        let locationNames = existingLocations.map { $0.name }

        var needsSave = false
        
        let cellarName = isEnglish ? "Wine Cellar" : "ワインセラー"
        let cellarMemo = isEnglish ? "Default Cellar" : "デフォルトセラー"
        
        let fridgeName = isEnglish ? "Refrigerator" : "冷蔵庫"
        let fridgeMemo = isEnglish ? "For Fresh Sake" : "生酒用"
        
        let roomName = isEnglish ? "Room Temp" : "常温"
        let roomMemo = isEnglish ? "Room Temperature Storage" : "常温保管"

        if !locationNames.contains(cellarName) && !locationNames.contains("ワインセラー") && !locationNames.contains("Wine Cellar") {
            context.insert(StorageLocation(name: cellarName, type: .cellar, memo: cellarMemo, isGridEnabled: true, gridRows: 4, gridColumns: 6))
            needsSave = true
        }
        if !locationNames.contains(fridgeName) && !locationNames.contains("冷蔵庫") && !locationNames.contains("Refrigerator") {
            context.insert(StorageLocation(name: fridgeName, type: .refrigerator, memo: fridgeMemo, isGridEnabled: true, gridRows: 3, gridColumns: 4))
            needsSave = true
        }
        if !locationNames.contains(roomName) && !locationNames.contains("常温") && !locationNames.contains("Room Temp") {
            context.insert(StorageLocation(name: roomName, type: .roomTemp, memo: roomMemo, isGridEnabled: true, gridRows: 2, gridColumns: 4))
            needsSave = true
        }

        if needsSave {
            try? context.save()
            print("[Default Loader] デフォルトの保管場所（グリッド有効）を作成しました。")
        }
    }

    /// サンプルデータを独立挿入（ワイン2本、日本酒2本、ビール1本）
    public static func insertSamples(into context: ModelContext) {
        insertDefaultLocationsIfNeeded(into: context)

        let encoder = JSONEncoder()
        let isEn = isEnglish

        let cellarLocationName = isEn ? "Wine Cellar" : "ワインセラー"
        let fridgeLocationName = isEn ? "Refrigerator" : "冷蔵庫"
        let roomLocationName = isEn ? "Room Temp" : "常温"

        // ==========================================
        // 1. ワイン 1本目: Château Margaux 2015
        // ==========================================
        let wineMeta1 = WineSpecificMetadata(
            wineType: isEn ? "Red" : "赤",
            grapeVarieties: isEn ? "Cabernet Sauvignon, Merlot" : "カベルネ・ソーヴィニヨン, メルロ",
            blendComponents: [
                BlendComponent(variety: "Cabernet Sauvignon", percentage: 87),
                BlendComponent(variety: "Merlot", percentage: 10),
                BlendComponent(variety: "Petit Verdot", percentage: 3)
            ],
            appellation: "Margaux AOC"
        )
        let wineMeta1JSON = String(data: try! encoder.encode(wineMeta1), encoding: .utf8)

        let wineItem1 = BeverageItem(
            name: "Château Margaux 2015",
            producer: "Château Margaux",
            category: .wine,
            region: isEn ? "Bordeaux, France" : "ボルドー, フランス",
            vintage: "2015",
            alcoholByVolume: 13.5,
            price: 85000,
            storageLocation: cellarLocationName,
            gridRow: 1,
            gridColumn: 1,
            specificMetadataJSON: wineMeta1JSON
        )
        let wineLog1 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 3),
            rating: 4.9,
            appearanceNotes: isEn ? "Deep Ruby Red" : "深みのあるルビーレッド",
            appearanceColorHex: "#991A33",
            aromaTags: isEn ? ["Cassis", "Vanilla", "Cedar", "Toast"] : ["カシス", "ヴァニラ", "杉", "トースト"],
            sweetness: 2.0,
            saltiness: 0.0,
            acidity: 4.2,
            bitterness: 2.0,
            umami: 2.5,
            tannin: 4.5,
            body: 4.8,
            balanceTags: isEn ? ["Rich", "Full-bodied"] : ["豊潤な", "厚みのある"],
            finishLength: 5.0,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: true,
            memo: isEn ? "Overwhelming elegance and complexity. Rich cassis fruit seamlessly integrated with oak nuances." : "圧倒的な気品と複雑味。カシスの芳醇な香りに樽のニュアンスが完璧に溶け込んでいる。",
            isEvaluated: true,
            item: wineItem1
        )

        // ==========================================
        // 2. ワイン 2本目: Meursault 2020
        // ==========================================
        let wineMeta2 = WineSpecificMetadata(
            wineType: isEn ? "White" : "白",
            grapeVarieties: "Chardonnay",
            blendComponents: [
                BlendComponent(variety: "Chardonnay", percentage: 100)
            ],
            appellation: "Meursault AOC"
        )
        let wineMeta2JSON = String(data: try! encoder.encode(wineMeta2), encoding: .utf8)

        let wineItem2 = BeverageItem(
            name: "Domaine Leflaive Meursault 2020",
            producer: "Domaine Leflaive",
            category: .wine,
            region: isEn ? "Burgundy, France" : "ブルゴーニュ, フランス",
            vintage: "2020",
            alcoholByVolume: 13.0,
            price: 24000,
            storageLocation: cellarLocationName,
            gridRow: 1,
            gridColumn: 2,
            specificMetadataJSON: wineMeta2JSON
        )
        let wineLog2 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 5),
            rating: 4.7,
            appearanceNotes: isEn ? "Beautiful Straw Yellow" : "美しいストロー・イエロー",
            appearanceColorHex: "#F3E680",
            aromaTags: isEn ? ["Lemon", "Pear", "Vanilla", "Almond", "Butter"] : ["レモン", "洋梨", "ヴァニラ", "アーモンド", "バター"],
            sweetness: 2.0,
            saltiness: 0.0,
            acidity: 4.0,
            bitterness: 1.5,
            umami: 3.0,
            tannin: nil,
            body: 4.2,
            balanceTags: isEn ? ["Mellow", "Rich"] : ["まろやかな", "豊潤な"],
            finishLength: 4.6,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: true,
            memo: isEn ? "Exquisite balance between creamy texture and crisp minerals. Toasted nutty finish." : "クリーミーな質感と引き締まったミネラルのバランスが絶妙。ナッツの芳ばしい余韻。",
            isEvaluated: true,
            item: wineItem2
        )

        // ==========================================
        // 3. 日本酒 1本目: 新政 No.6 R-type 生原酒
        // ==========================================
        let sakeMeta1 = SakeSpecificMetadata(
            specificName: isEn ? "Tokubetsu Junmai Namagenshu" : "特別純米 生原酒",
            riceVariety: isEn ? "Akita Sake Rice" : "秋田県産酒造好適米",
            polishingRate: "65%",
            sakeMeterValue: "+1.0"
        )
        let sakeMeta1JSON = String(data: try! encoder.encode(sakeMeta1), encoding: .utf8)

        let sakeItem1 = BeverageItem(
            name: "Aramasa No.6 R-type",
            producer: "Aramasa Sake Brewery",
            category: .sake,
            region: isEn ? "Akita, Japan" : "秋田県",
            vintage: "2026/04",
            alcoholByVolume: 13.0,
            price: 2400,
            storageLocation: fridgeLocationName,
            gridRow: 1,
            gridColumn: 1,
            specificMetadataJSON: sakeMeta1JSON
        )
        let sakeLog1 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 1),
            rating: 4.7,
            appearanceNotes: isEn ? "Clear with slight effervescence" : "微発泡が感じられる透明な輝き",
            appearanceColorHex: "#F7FAFA",
            aromaTags: isEn ? ["Ginjo Aroma", "Green Apple", "Pear", "Fresh"] : ["吟醸香", "青りんご", "洋梨", "フレッシュ"],
            sweetness: 3.2,
            saltiness: 0.0,
            acidity: 3.8,
            bitterness: 1.5,
            umami: 3.5,
            tannin: nil,
            body: 3.0,
            balanceTags: isEn ? ["Juicy", "Mellow"] : ["ジューシーな", "まろやかな"],
            finishLength: 4.2,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: isEn ? "Wonderful balance of juicy acidity and elegant sweetness. Exceptional crisp finish." : "ジューシーな酸味と上品な甘みのバランスが素晴らしい。キレも抜群。",
            isEvaluated: true,
            item: sakeItem1
        )

        // ==========================================
        // 4. 日本酒 2本目: 黒龍 吟十八号
        // ==========================================
        let sakeMeta2 = SakeSpecificMetadata(
            specificName: isEn ? "Junmai Ginjo" : "純米吟醸",
            riceVariety: "Gohyakumangoku",
            polishingRate: "55%",
            sakeMeterValue: "+4.0"
        )
        let sakeMeta2JSON = String(data: try! encoder.encode(sakeMeta2), encoding: .utf8)

        let sakeItem2 = BeverageItem(
            name: "Kokuryu Gin 18",
            producer: "Kokuryu Sake Brewery",
            category: .sake,
            region: isEn ? "Fukui, Japan" : "福井県",
            vintage: "2026/02",
            alcoholByVolume: 15.5,
            price: 3300,
            storageLocation: fridgeLocationName,
            gridRow: 1,
            gridColumn: 2,
            specificMetadataJSON: sakeMeta2JSON
        )
        let sakeLog2 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 4),
            rating: 4.6,
            appearanceNotes: isEn ? "Clear and crystal" : "クリアで美しい無色透明",
            appearanceColorHex: "#F2F2F7",
            aromaTags: isEn ? ["Peach", "Melon", "Steamed Rice", "Almond"] : ["白桃", "メロン", "炊いた米", "アーモンド"],
            sweetness: 2.5,
            saltiness: 0.0,
            acidity: 3.0,
            bitterness: 1.2,
            umami: 3.8,
            tannin: nil,
            body: 3.2,
            balanceTags: isEn ? ["Smooth", "Crisp"] : ["スムーズな", "引き締まった"],
            finishLength: 4.4,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: isEn ? "Elegant aroma with a refined, smooth palate. Perfect companion for dining." : "上品な香りと透明感のある口当たり。食事を引き立てる洗練された純米吟醸。",
            isEvaluated: true,
            item: sakeItem2
        )

        // ==========================================
        // 5. ビール 1本目: Inedit Damm
        // ==========================================
        let beerMeta = BeerSpecificMetadata(
            beerStyle: isEn ? "Witbier / White Ale" : "プレミアム・ホワイトビア",
            ibu: "11"
        )
        let beerMetaJSON = String(data: try! encoder.encode(beerMeta), encoding: .utf8)

        let beerItem = BeverageItem(
            name: "Inedit Damm",
            producer: "Damm",
            category: .beer,
            region: isEn ? "Barcelona, Spain" : "バルセロナ, スペイン",
            vintage: "2026",
            alcoholByVolume: 4.8,
            price: 850,
            storageLocation: roomLocationName,
            gridRow: 1,
            gridColumn: 1,
            specificMetadataJSON: beerMetaJSON
        )
        let beerLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 6),
            rating: 4.3,
            appearanceNotes: isEn ? "Hazy Pale Gold" : "白濁したペールゴールド",
            appearanceColorHex: "#EBC733",
            aromaTags: isEn ? ["Citrus", "Coriander", "Spice", "Hops"] : ["シトラス", "コリアンダー", "スパイス", "ホップ"],
            sweetness: 2.5,
            saltiness: 0.0,
            acidity: 3.0,
            bitterness: 3.5,
            umami: 2.5,
            tannin: nil,
            body: 3.5,
            balanceTags: isEn ? ["Smooth", "Dry"] : ["スムーズな", "ドライな"],
            finishLength: 3.8,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: isEn ? "Champagne-like sophistication, easy to pair with culinary dishes." : "シャンパンのように華やかで、食事に合わせやすいプレミアム・ホワイトビール。",
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
        print("[Sample Loader] サンプルデータ挿入が完了しました（言語: \(isEn ? "English" : "日本語")）。")
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
