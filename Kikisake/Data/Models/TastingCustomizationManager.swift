//  TastingCustomizationManager.swift
//  Kikisake

import Foundation
import SwiftUI

public struct CustomColorItem: Codable, Identifiable, Hashable {
    public var id: UUID = UUID()
    public var name: String
    public var hex: String
    public var categoryRaw: String // "wine-赤", "sake", "beer" など
    public var isPro: Bool = true
}

public struct CustomAromaItem: Codable, Identifiable, Hashable {
    public var id: UUID = UUID()
    public var categoryTitle: String // "果実", "花・植物", "その他" など
    public var name: String
    public var beverageCategoryRaw: String // "wine", "sake", "beer"
}

@Observable
public final class TastingCustomizationManager {
    public static let shared = TastingCustomizationManager()

    private let balanceKey = "custom_balance_options"
    private let colorKey = "custom_color_options"
    private let aromaKey = "custom_aroma_options"

    public var customBalances: [String] {
        didSet { saveBalances() }
    }
    public var customColors: [CustomColorItem] {
        didSet { saveColors() }
    }
    public var customAromas: [CustomAromaItem] {
        didSet { saveAromas() }
    }

    private init() {
        self.customBalances = UserDefaults.standard.stringArray(forKey: "custom_balance_options") ?? []
        
        if let data = UserDefaults.standard.data(forKey: "custom_color_options"),
           let decoded = try? JSONDecoder().decode([CustomColorItem].self, from: data) {
            self.customColors = decoded
        } else {
            self.customColors = []
        }

        if let data = UserDefaults.standard.data(forKey: "custom_aroma_options"),
           let decoded = try? JSONDecoder().decode([CustomAromaItem].self, from: data) {
            self.customAromas = decoded
        } else {
            self.customAromas = []
        }
    }

    private func saveBalances() {
        UserDefaults.standard.set(customBalances, forKey: balanceKey)
    }

    private func saveColors() {
        if let encoded = try? JSONEncoder().encode(customColors) {
            UserDefaults.standard.set(encoded, forKey: colorKey)
        }
    }

    private func saveAromas() {
        if let encoded = try? JSONEncoder().encode(customAromas) {
            UserDefaults.standard.set(encoded, forKey: aromaKey)
        }
    }
}
