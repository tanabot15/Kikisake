//
//  TastingCustomizationManager.swift
//  Kikisake
//

import Foundation
import SwiftUI

public struct CustomColorItem: Codable, Identifiable, Hashable {
    public var id: UUID
    public var name: String
    public var hex: String
    public var categoryRaw: String
    public var isPro: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        hex: String,
        categoryRaw: String,
        isPro: Bool = true
    ) {
        self.id = id
        self.name = name
        self.hex = hex
        self.categoryRaw = categoryRaw
        self.isPro = isPro
    }
}

public struct CustomAromaItem: Codable, Identifiable, Hashable {
    public var id: UUID
    public var categoryTitle: String
    public var name: String
    public var beverageCategoryRaw: String

    public init(
        id: UUID = UUID(),
        categoryTitle: String,
        name: String,
        beverageCategoryRaw: String
    ) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.name = name
        self.beverageCategoryRaw = beverageCategoryRaw
    }
}

@Observable
public final class TastingCustomizationManager {
    public static let shared = TastingCustomizationManager()

    private enum StorageKey {
        static let balanceOptions = "custom_balance_options"
        static let colorOptions = "custom_color_options"
        static let aromaOptions = "custom_aroma_options"
    }

    private let defaults = UserDefaults.standard

    public var customBalances: [String] {
        didSet { saveArray(customBalances, key: StorageKey.balanceOptions) }
    }

    public var customColors: [CustomColorItem] {
        didSet { saveCodable(customColors, key: StorageKey.colorOptions) }
    }

    public var customAromas: [CustomAromaItem] {
        didSet { saveCodable(customAromas, key: StorageKey.aromaOptions) }
    }

    private init() {
        self.customBalances = defaults.stringArray(forKey: StorageKey.balanceOptions) ?? []
        self.customColors = Self.loadCodable([CustomColorItem].self, from: defaults, key: StorageKey.colorOptions) ?? []
        self.customAromas = Self.loadCodable([CustomAromaItem].self, from: defaults, key: StorageKey.aromaOptions) ?? []
    }

    private static func loadCodable<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func saveArray<T>(_ value: [T], key: String) {
        defaults.set(value, forKey: key)
    }

    private func saveCodable<T: Encodable>(_ value: T, key: String) {
        guard let encoded = try? JSONEncoder().encode(value) else { return }
        defaults.set(encoded, forKey: key)
    }
}
