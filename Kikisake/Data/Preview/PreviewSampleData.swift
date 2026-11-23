//
//  PreviewSampleData.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/11/22.
//

import Foundation
import SwiftData
import UIKit

/// SwiftUI #Preview 用の共通サンプルデータおよびインメモリ ModelContainer
@MainActor
public enum PreviewSampleData {
    /// 全モデル（BeverageItem / TastingLog / StorageLocation）とサンプルデータを含むコンテナ
    public static var container: ModelContainer {
        let schema = Schema([
            BeverageItem.self,
            TastingLog.self,
            StorageLocation.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            populateSampleData(into: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create Preview ModelContainer: \(error)")
        }
    }

    /// 各種カード・単体ビューのプレビューで即座に使える代表的なデータセット
    public struct SampleBundle {
        public let wineItem: BeverageItem
        public let wineLog: TastingLog
        public let sakeItem: BeverageItem
        public let sakeLog: TastingLog
        public let beerItem: BeverageItem
        public let beerLog: TastingLog
        public let cellarLocation: StorageLocation
        public let fridgeLocation: StorageLocation
    }

    /// 単体ビュー（TastingCardShareView や Radar / Matrix カード等）向けのサンプル取得
    public static func makeSampleBundle() -> SampleBundle {
        let calendar = Calendar.current
        let now = Date()
        let sampleImage = generatePlaceholderBottleImageData()

        // 1. 保管場所
        let cellar = StorageLocation(
            name: "自宅ワインセラー",
            type: .cellar,
            memo: "14℃設定・長期熟成用",
            isGridEnabled: true,
            gridRows: 4,
            gridColumns: 6
        )

        let fridge = StorageLocation(
            name: "日本酒・ビール用冷蔵庫",
            type: .refrigerator,
            memo: "チルド室 2℃",
            isGridEnabled: false
        )

        // 2. ワイン（固有メタデータ付き）
        let wineMetaJSON = encodeJSON(
            WineSpecificMetadata(
                wineType: "赤",
                grapeVarieties: "カベルネ・ソーヴィニヨン 85%, メルロー 15%",
                blendComponents: [
                    BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 85),
                    BlendComponent(variety: "メルロー", percentage: 15)
                ],
                appellation: "Margaux AOC"
            )
        )

        let wineItem = BeverageItem(
            name: "Château Margaux 2015",
            producer: "Château Margaux",
            category: .wine,
            region: "ボルドー, フランス",
            vintage: "2015",
            alcoholByVolume: 13.5,
            price: 120000,
            storageLocation: cellar.name,
            purchaseDate: calendar.date(byAdding: .month, value: -6, to: now),
            gridRow: 1,
            gridColumn: 2,
            imageDatas: sampleImage.map { [$0] },
            isBackgroundRemoved: true,
            specificMetadataJSON: wineMetaJSON
        )

        let wineLog = TastingLog(
            date: now,
            rating: 4.8,
            appearanceNotes: "深みのあるルビーレッド",
            appearanceColorHex: "#80182B",
            aromaTags: ["カシス", "ヴァニラ", "杉", "スミレ"],
            sweetness: 2.0,
            saltiness: 1.0,
            acidity: 4.0,
            bitterness: 2.0,
            umami: 3.0,
            tannin: 4.5,
            body: 4.6,
            balanceTags: ["豊潤な", "エレガント"],
            finishLength: 4.9,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: true,
            pairing: "和牛フィレのロッシーニ風",
            memo: "圧倒的な気品と複雑味。きめ細やかなタンニンが長い余韻へと続く。",
            isEvaluated: true,
            item: wineItem
        )

        // 3. 日本酒（固有メタデータ付き）
        let sakeMetaJSON = encodeJSON(
            SakeSpecificMetadata(
                specificName: "純米大吟醸",
                riceVariety: "山田錦",
                polishingRate: "35%",
                sakeMeterValue: "+1.0"
            )
        )

        let sakeItem = BeverageItem(
            name: "十四代 七垂二十貫",
            producer: "高木酒造",
            category: .sake,
            region: "山形県",
            vintage: "2026BY",
            alcoholByVolume: 15.0,
            price: 38000,
            storageLocation: fridge.name,
            purchaseDate: calendar.date(byAdding: .day, value: -14, to: now),
            imageDatas: sampleImage.map { [$0] },
            isBackgroundRemoved: true,
            specificMetadataJSON: sakeMetaJSON
        )

        let sakeLog = TastingLog(
            date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
            rating: 4.9,
            appearanceNotes: "クリスタルで透明感のある輝き",
            appearanceColorHex: "#F5F3E7",
            aromaTags: ["白桃", "メロン", "和三盆"],
            sweetness: 3.6,
            saltiness: 1.0,
            acidity: 3.2,
            bitterness: 1.5,
            umami: 4.2,
            tannin: nil,
            body: 3.5,
            balanceTags: ["芳醇", "滑らか"],
            finishLength: 4.5,
            isCostEffective: false,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            pairing: "真鯛の昆布締め",
            memo: "雑味が一切なく、透明感のある甘みと綺麗な酸が調和する。",
            isEvaluated: true,
            item: sakeItem
        )

        // 4. ビール（固有メタデータ付き）
        let beerMetaJSON = encodeJSON(
            BeerSpecificMetadata(
                beerStyle: "West Coast IPA",
                ibu: "65"
            )
        )

        let beerItem = BeverageItem(
            name: "Pliny the Elder",
            producer: "Russian River Brewing",
            category: .beer,
            region: "カリフォルニア, アメリカ",
            vintage: "2026/10",
            alcoholByVolume: 8.0,
            price: 1400,
            storageLocation: fridge.name,
            purchaseDate: calendar.date(byAdding: .day, value: -7, to: now),
            imageDatas: sampleImage.map { [$0] },
            isBackgroundRemoved: false,
            specificMetadataJSON: beerMetaJSON
        )

        let beerLog = TastingLog(
            date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
            rating: 4.5,
            appearanceNotes: "澄んだゴールデンアンバー",
            appearanceColorHex: "#D98A2B",
            aromaTags: ["グレープフルーツ", "松脂", "パッションフルーツ"],
            sweetness: 2.0,
            saltiness: 1.2,
            acidity: 3.0,
            bitterness: 4.5,
            umami: 2.2,
            tannin: nil,
            body: 3.4,
            balanceTags: ["キレがある", "爽快"],
            finishLength: 4.0,
            isCostEffective: true,
            isWillingToRepeat: true,
            hasAgingPotential: false,
            pairing: "スパイシーチキンウィング",
            memo: "鮮烈なホップのアロマとクリーンでドライな苦味のキレが心地よい。",
            isEvaluated: true,
            item: beerItem
        )

        return SampleBundle(
            wineItem: wineItem,
            wineLog: wineLog,
            sakeItem: sakeItem,
            sakeLog: sakeLog,
            beerItem: beerItem,
            beerLog: beerLog,
            cellarLocation: cellar,
            fridgeLocation: fridge
        )
    }

    // MARK: - Private Helpers

    private static func populateSampleData(into context: ModelContext) {
        let bundle = makeSampleBundle()

        context.insert(bundle.cellarLocation)
        context.insert(bundle.fridgeLocation)

        context.insert(bundle.wineItem)
        context.insert(bundle.wineLog)

        context.insert(bundle.sakeItem)
        context.insert(bundle.sakeLog)

        context.insert(bundle.beerItem)
        context.insert(bundle.beerLog)
    }

    private static func encodeJSON<T: Encodable>(_ value: T) -> String? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func generatePlaceholderBottleImageData() -> Data? {
        let size = CGSize(width: 300, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            UIColor(red: 0.16, green: 0.06, blue: 0.09, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: CGRect(x: 90, y: 150, width: 120, height: 410), cornerRadius: 20).fill()

            UIRectFill(CGRect(x: 118, y: 50, width: 64, height: 105))

            UIColor(red: 0.85, green: 0.70, blue: 0.35, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: CGRect(x: 118, y: 35, width: 64, height: 35), cornerRadius: 4).fill()

            UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: CGRect(x: 100, y: 240, width: 100, height: 160), cornerRadius: 6).fill()
        }
        return image.jpegData(compressionQuality: 0.85)
    }
}
