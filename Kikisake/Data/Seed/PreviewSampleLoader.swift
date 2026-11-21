//
//  PreviewSampleLoader.swift
//  Kikisake
//

import SwiftUI
import SwiftData
import os

public enum PreviewSampleLoader {
    private struct DefaultLocationSpec {
        let name: String
        let aliases: [String]
        let type: StorageCategoryType
        let memo: String
        let rows: Int
        let cols: Int
    }

    static var isEnglish: Bool {
        let currentLang = Bundle.main.preferredLocalizations.first
            ?? Locale.current.language.languageCode?.identifier
            ?? "ja"
        return currentLang.hasPrefix("en")
    }

    private static var defaultLocationSpecs: [DefaultLocationSpec] {
        [
            DefaultLocationSpec(
                name: isEnglish ? "Wine Cellar" : "ワインセラー",
                aliases: ["ワインセラー", "Wine Cellar"],
                type: .cellar,
                memo: isEnglish ? "Default Cellar" : "デフォルトセラー",
                rows: 4,
                cols: 6
            ),
            DefaultLocationSpec(
                name: isEnglish ? "Refrigerator" : "冷蔵庫",
                aliases: ["冷蔵庫", "Refrigerator"],
                type: .refrigerator,
                memo: isEnglish ? "For Fresh Sake" : "生酒用",
                rows: 3,
                cols: 4
            ),
            DefaultLocationSpec(
                name: isEnglish ? "Room Temp" : "常温",
                aliases: ["常温", "Room Temp"],
                type: .roomTemp,
                memo: isEnglish ? "Room Temperature Storage" : "常温保管",
                rows: 2,
                cols: 4
            )
        ]
    }

    public static func insertDefaultLocationsIfNeeded(into context: ModelContext) {
        let locationDescriptor = FetchDescriptor<StorageLocation>()
        let existingLocations = (try? context.fetch(locationDescriptor)) ?? []
        let locationNames = Set(existingLocations.map(\.name))

        var needsSave = false
        for spec in defaultLocationSpecs where !locationNames.contains(spec.name) && spec.aliases.allSatisfy({ !locationNames.contains($0) }) {
            let location = StorageLocation(
                name: spec.name,
                type: spec.type,
                memo: spec.memo,
                isGridEnabled: true,
                gridRows: spec.rows,
                gridColumns: spec.cols
            )
            context.insert(location)
            needsSave = true
        }

        if needsSave {
            try? context.save()
            AppLogger.persistence.info("Created default storage locations.")
        }
    }

    static func loadAssetImageData(named name: String) -> Data? {
        guard let uiImage = UIImage(named: name) else {
            AppLogger.persistence.warning("Asset '\(name, privacy: .public)' not found for sample data.")
            return nil
        }
        return uiImage.jpegData(compressionQuality: 0.8)
    }

    @MainActor
    public static func insertSamples(into context: ModelContext) {
        insertDefaultLocationsIfNeeded(into: context)

        let entries = SampleBeverageFactory.makeAll(isEnglish: isEnglish)
        for entry in entries {
            context.insert(entry.item)
            context.insert(entry.log)
        }

        try? context.save()
        AppLogger.persistence.info("Inserted sample data (locale: \(isEnglish ? "en" : "ja", privacy: .public)).")
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
