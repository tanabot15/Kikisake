//
//  SampleBeverageFactory.swift
//  Kikisake
//

import Foundation

struct SampleBeverageEntry {
    let item: BeverageItem
    let log: TastingLog
}

enum SampleBeverageFactory {
    private static let encoder = JSONEncoder()

    static func makeAll(isEnglish: Bool) -> [SampleBeverageEntry] {
        [
            makeMargaux(isEnglish: isEnglish),
            makeMeursault(isEnglish: isEnglish),
            makeAramasa(isEnglish: isEnglish),
            makeJuyondai(isEnglish: isEnglish),
            makeInedit(isEnglish: isEnglish)
        ]
    }

    private static func encodeJSON<T: Encodable>(_ value: T) -> String? {
        guard let data = try? encoder.encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func imageDataList(named assetName: String) -> [Data]? {
        guard let data = PreviewSampleLoader.loadAssetImageData(named: assetName) else {
            return nil
        }
        return [data]
    }

    private static func makeMargaux(isEnglish: Bool) -> SampleBeverageEntry {
        let cellarName = isEnglish ? "Wine Cellar" : "ワインセラー"
        let metadata = WineSpecificMetadata(
            wineType: isEnglish ? "Red" : "赤",
            grapeVarieties: isEnglish ? "Cabernet Sauvignon, Merlot" : "カベルネ・ソーヴィニヨン, メルロ",
            blendComponents: [
                BlendComponent(variety: "Cabernet Sauvignon", percentage: 87),
                BlendComponent(variety: "Merlot", percentage: 10),
                BlendComponent(variety: "Petit Verdot", percentage: 3)
            ],
            appellation: "Margaux AOC"
        )
        let item = BeverageItem(
            name: "Château Margaux 2015",
            producer: "Château Margaux",
            category: .wine,
            region: isEnglish ? "Bordeaux, France" : "ボルドー, フランス",
            vintage: "2015",
            alcoholByVolume: 13.5,
            price: 85000,
            storageLocation: cellarName,
            gridRow: 1,
            gridColumn: 1,
            imageDatas: imageDataList(named: "sample_wine_1"),
            specificMetadataJSON: encodeJSON(metadata)
        )
        let log = TastingLog(
            date: Date().addingTimeInterval(-86400 * 3),
            rating: 4.9,
            appearanceNotes: isEnglish ? "Raspberry Red" : "ラズベリーレッド",
            appearanceColorHex: "#CC334D",
            aromaTags: isEnglish ? ["Strawberry", "Raspberry", "Blackberry", "Tea"] : ["イチゴ", "ラズベリー", "ブラックベリー", "紅茶"],
            sweetness: 2.0,
            saltiness: 0.0,
            acidity: 4.2,
            bitterness: 2.0,
            umami: 2.5,
            tannin: 4.5,
            body: 4.8,
            balanceTags: isEnglish ? ["Rich", "Full-bodied"] : ["豊潤な", "厚みのある"],
            finishLength: 5.0,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: true,
            memo: isEnglish ? "Overwhelming elegance and complexity. Rich fruit gracefully integrated." : "圧倒的な気品と複雑味。豊かな果実味が美しく溶け込んでいる。",
            isEvaluated: true,
            item: item
        )
        return SampleBeverageEntry(item: item, log: log)
    }

    private static func makeMeursault(isEnglish: Bool) -> SampleBeverageEntry {
        let cellarName = isEnglish ? "Wine Cellar" : "ワインセラー"
        let metadata = WineSpecificMetadata(
            wineType: isEnglish ? "White" : "白",
            grapeVarieties: "Chardonnay",
            blendComponents: [
                BlendComponent(variety: "Chardonnay", percentage: 100)
            ],
            appellation: "Meursault AOC"
        )
        let item = BeverageItem(
            name: "Domaine Leflaive Meursault 2020",
            producer: "Domaine Leflaive",
            category: .wine,
            region: isEnglish ? "Burgundy, France" : "ブルゴーニュ, フランス",
            vintage: "2020",
            alcoholByVolume: 13.0,
            price: 24000,
            storageLocation: cellarName,
            gridRow: 1,
            gridColumn: 2,
            imageDatas: imageDataList(named: "sample_wine_2"),
            specificMetadataJSON: encodeJSON(metadata)
        )
        let log = TastingLog(
            date: Date().addingTimeInterval(-86400 * 5),
            rating: 4.7,
            appearanceNotes: isEnglish ? "Champagne" : "シャンパン",
            appearanceColorHex: "#F4EBC7",
            aromaTags: isEnglish ? ["Citrus", "Green Apple", "Apple", "Pear"] : ["柑橘類", "青リンゴ", "リンゴ", "洋梨"],
            sweetness: 2.0,
            saltiness: 0.0,
            acidity: 4.0,
            bitterness: 1.5,
            umami: 3.0,
            tannin: nil,
            body: 4.2,
            balanceTags: isEnglish ? ["Mellow", "Rich"] : ["まろやかな", "豊潤な"],
            finishLength: 4.6,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: true,
            memo: isEnglish ? "Exquisite balance between texture and crisp minerals. Elegant finish." : "質感と引き締まったミネラルのバランスが絶妙。エレガントな余韻。",
            isEvaluated: true,
            item: item
        )
        return SampleBeverageEntry(item: item, log: log)
    }

    private static func makeAramasa(isEnglish: Bool) -> SampleBeverageEntry {
        let fridgeName = isEnglish ? "Refrigerator" : "冷蔵庫"
        let metadata = SakeSpecificMetadata(
            specificName: isEnglish ? "Tokubetsu Junmai Namagenshu" : "特別純米 生原酒",
            riceVariety: isEnglish ? "Akita Sake Rice" : "秋田県産酒造好適米",
            polishingRate: "65%",
            sakeMeterValue: "+1.0"
        )
        let item = BeverageItem(
            name: "Aramasa No.6 R-type",
            producer: "Aramasa Sake Brewery",
            category: .sake,
            region: isEnglish ? "Akita, Japan" : "秋田県",
            vintage: "2026/04",
            alcoholByVolume: 13.0,
            price: 2400,
            storageLocation: fridgeName,
            gridRow: 1,
            gridColumn: 1,
            imageDatas: imageDataList(named: "sample_sake_1"),
            specificMetadataJSON: encodeJSON(metadata)
        )
        let log = TastingLog(
            date: Date().addingTimeInterval(-86400 * 1),
            rating: 4.7,
            appearanceNotes: isEnglish ? "Colorless & Transparent" : "無色透明",
            appearanceColorHex: "#F2F2F7",
            aromaTags: isEnglish ? ["Yellow Apple", "Pear", "White Peach", "Banana"] : ["黄色いリンゴ", "洋ナシ", "白桃", "バナナ"],
            sweetness: 3.2,
            saltiness: 0.0,
            acidity: 3.8,
            bitterness: 1.5,
            umami: 3.5,
            tannin: nil,
            body: 3.0,
            balanceTags: isEnglish ? ["Juicy", "Mellow"] : ["ジューシーな", "まろやかな"],
            finishLength: 4.2,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: isEnglish ? "Wonderful balance of juicy acidity and elegant sweetness. Exceptional crisp finish." : "ジューシーな酸味と上品な甘みのバランスが素晴らしい。キレも抜群。",
            isEvaluated: true,
            item: item
        )
        return SampleBeverageEntry(item: item, log: log)
    }

    private static func makeJuyondai(isEnglish: Bool) -> SampleBeverageEntry {
        let fridgeName = isEnglish ? "Refrigerator" : "冷蔵庫"
        let metadata = SakeSpecificMetadata(
            specificName: isEnglish ? "Junmai Daiginjo" : "純米大吟醸",
            riceVariety: "山田錦",
            polishingRate: "50%",
            sakeMeterValue: "+2.0"
        )
        let item = BeverageItem(
            name: "Juyondai Junmai Daiginjo",
            producer: "Takagi Shuzo",
            category: .sake,
            region: isEnglish ? "Yamagata, Japan" : "山形県",
            vintage: "2026/02",
            alcoholByVolume: 15.0,
            price: 5500,
            storageLocation: fridgeName,
            gridRow: 1,
            gridColumn: 2,
            imageDatas: imageDataList(named: "sample_sake_2"),
            specificMetadataJSON: encodeJSON(metadata)
        )
        let log = TastingLog(
            date: Date().addingTimeInterval(-86400 * 4),
            rating: 4.9,
            appearanceNotes: isEnglish ? "Pale Yellow" : "微黄色",
            appearanceColorHex: "#FAF5D9",
            aromaTags: isEnglish ? ["Melon", "Burdock", "Almond", "Cooked Rice"] : ["メロン", "ゴボウ", "アーモンド", "炊いた米"],
            sweetness: 3.5,
            saltiness: 0.0,
            acidity: 2.8,
            bitterness: 1.0,
            umami: 4.0,
            tannin: nil,
            body: 3.5,
            balanceTags: isEnglish ? ["Smooth", "Rich"] : ["スムーズな", "豊潤な"],
            finishLength: 4.8,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: isEnglish ? "Exquisite fruity aroma with a luxurious, smooth texture. Exceptional depth." : "芳醇な果実香と圧倒的なめらかさ。気品に満ちた極上の味わい。",
            isEvaluated: true,
            item: item
        )
        return SampleBeverageEntry(item: item, log: log)
    }

    private static func makeInedit(isEnglish: Bool) -> SampleBeverageEntry {
        let roomName = isEnglish ? "Room Temp" : "常温"
        let metadata = BeerSpecificMetadata(
            beerStyle: isEnglish ? "Witbier / White Ale" : "プレミアム・ホワイトビア",
            ibu: "11"
        )
        let item = BeverageItem(
            name: "Inedit Damm",
            producer: "Damm",
            category: .beer,
            region: isEnglish ? "Barcelona, Spain" : "バルセロナ, スペイン",
            vintage: "2026",
            alcoholByVolume: 4.8,
            price: 850,
            storageLocation: roomName,
            gridRow: 1,
            gridColumn: 1,
            imageDatas: imageDataList(named: "sample_beer_1"),
            specificMetadataJSON: encodeJSON(metadata)
        )
        let log = TastingLog(
            date: Date().addingTimeInterval(-86400 * 6),
            rating: 4.3,
            appearanceNotes: isEnglish ? "Golden" : "ゴールデン",
            appearanceColorHex: "#EBC733",
            aromaTags: isEnglish ? ["Citrus", "Grapefruit", "Tropical Fruit", "Green Apple"] : ["シトラス", "グレープフルーツ", "トロピカルフルーツ", "青りんご"],
            sweetness: 2.5,
            saltiness: 0.0,
            acidity: 3.0,
            bitterness: 3.5,
            umami: 2.5,
            tannin: nil,
            body: 3.5,
            balanceTags: isEnglish ? ["Smooth", "Dry"] : ["スムーズな", "ドライな"],
            finishLength: 3.8,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: isEnglish ? "Champagne-like sophistication, easy to pair with culinary dishes." : "シャンパンのように華やかで、食事に合わせやすいプレミアム・ホワイトビール。",
            isEvaluated: true,
            item: item
        )
        return SampleBeverageEntry(item: item, log: log)
    }
}
