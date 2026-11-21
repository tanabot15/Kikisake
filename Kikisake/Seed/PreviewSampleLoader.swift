//  PreviewSampleLoader.swift
//  Kikisake

import SwiftUI
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

    /// 💡 Assetsから画像を安全にロードして Data 型に変換するヘルパー関数
    private static func loadAssetImageData(named name: String) -> Data? {
        if let uiImage = UIImage(named: name) {
            return uiImage.jpegData(compressionQuality: 0.8)
        }
        print("[PreviewSampleLoader] Warning: アセット \"\(name)\" が見つかりませんでした。")
        return nil
    }

    /// サンプルデータを独立挿入（ワイン2本、日本酒2本、ビール1本）
    @MainActor
    public static func insertSamples(into context: ModelContext) {
        insertDefaultLocationsIfNeeded(into: context)

        let encoder = JSONEncoder()
        let isEn = isEnglish

        let cellarLocationName = isEn ? "Wine Cellar" : "ワインセラー"
        let fridgeLocationName = isEn ? "Refrigerator" : "冷蔵庫"
        let roomLocationName = isEn ? "Room Temp" : "常温"

        let wineImg1 = loadAssetImageData(named: "sample_wine_1")
        let wineImg2 = loadAssetImageData(named: "sample_wine_2")
        let sakeImg1 = loadAssetImageData(named: "sample_sake_1")
        let sakeImg2 = loadAssetImageData(named: "sample_sake_2")
        let beerImg  = loadAssetImageData(named: "sample_beer_1")

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
            imageDatas: wineImg1 != nil ? [wineImg1!] : nil,
            specificMetadataJSON: wineMeta1JSON
        )
        let wineLog1 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 3),
            rating: 4.9,
            appearanceNotes: isEn ? "Raspberry Red" : "ラズベリーレッド", // isPro: false の色
            appearanceColorHex: "#CC334D",
            aromaTags: isEn ? ["Strawberry", "Raspberry", "Blackberry", "Tea"] : ["イチゴ", "ラズベリー", "ブラックベリー", "紅茶"], // すべて isPro: false
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
            memo: isEn ? "Overwhelming elegance and complexity. Rich fruit gracefully integrated." : "圧倒的な気品と複雑味。豊かな果実味が美しく溶け込んでいる。",
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
            imageDatas: wineImg2 != nil ? [wineImg2!] : nil,
            specificMetadataJSON: wineMeta2JSON
        )
        let wineLog2 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 5),
            rating: 4.7,
            appearanceNotes: isEn ? "Champagne" : "シャンパン", // isPro: false の色
            appearanceColorHex: "#F4EBC7",
            aromaTags: isEn ? ["Citrus", "Green Apple", "Apple", "Pear"] : ["柑橘類", "青リンゴ", "リンゴ", "洋梨"], // すべて isPro: false
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
            memo: isEn ? "Exquisite balance between texture and crisp minerals. Elegant finish." : "質感と引き締まったミネラルのバランスが絶妙。エレガントな余韻。",
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
            imageDatas: sakeImg1 != nil ? [sakeImg1!] : nil,
            specificMetadataJSON: sakeMeta1JSON
        )
        let sakeLog1 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 1),
            rating: 4.7,
            appearanceNotes: isEn ? "Colorless & Transparent" : "無色透明", // isPro: false の色
            appearanceColorHex: "#F2F2F7",
            aromaTags: isEn ? ["Yellow Apple", "Pear", "White Peach", "Banana"] : ["黄色いリンゴ", "洋ナシ", "白桃", "バナナ"], // すべて isPro: false
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
        // 4. 日本酒 2本目: 十四代 純米大吟醸
        // ==========================================
        let sakeMeta2 = SakeSpecificMetadata(
            specificName: isEn ? "Junmai Daiginjo" : "純米大吟醸",
            riceVariety: "山田錦",
            polishingRate: "50%",
            sakeMeterValue: "+2.0"
        )
        let sakeMeta2JSON = String(data: try! encoder.encode(sakeMeta2), encoding: .utf8)

        let sakeItem2 = BeverageItem(
            name: "Juyondai Junmai Daiginjo",
            producer: "Takagi Shuzo",
            category: .sake,
            region: isEn ? "Yamagata, Japan" : "山形県",
            vintage: "2026/02",
            alcoholByVolume: 15.0,
            price: 5500,
            storageLocation: fridgeLocationName,
            gridRow: 1,
            gridColumn: 2,
            imageDatas: sakeImg2 != nil ? [sakeImg2!] : nil,
            specificMetadataJSON: sakeMeta2JSON
        )
        let sakeLog2 = TastingLog(
            date: Date().addingTimeInterval(-86400 * 4),
            rating: 4.9,
            appearanceNotes: isEn ? "Pale Yellow" : "微黄色", // isPro: false の色
            appearanceColorHex: "#FAF5D9",
            aromaTags: isEn ? ["Melon", "Burdock", "Almond", "Cooked Rice"] : ["メロン", "ゴボウ", "アーモンド", "炊いた米"], // すべて isPro: false
            sweetness: 3.5,
            saltiness: 0.0,
            acidity: 2.8,
            bitterness: 1.0,
            umami: 4.0,
            tannin: nil,
            body: 3.5,
            balanceTags: isEn ? ["Smooth", "Rich"] : ["スムーズな", "豊潤な"],
            finishLength: 4.8,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            memo: isEn ? "Exquisite fruity aroma with a luxurious, smooth texture. Exceptional depth." : "芳醇な果実香と圧倒的なめらかさ。気品に満ちた極上の味わい。",
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
            imageDatas: beerImg != nil ? [beerImg!] : nil,
            specificMetadataJSON: beerMetaJSON
        )
        let beerLog = TastingLog(
            date: Date().addingTimeInterval(-86400 * 6),
            rating: 4.3,
            appearanceNotes: isEn ? "Golden" : "ゴールデン", // isPro: false の色
            appearanceColorHex: "#EBC733",
            aromaTags: isEn ? ["Citrus", "Grapefruit", "Tropical Fruit", "Green Apple"] : ["シトラス", "グレープフルーツ", "トロピカルフルーツ", "青りんご"], // すべて isPro: false
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
