//
//  AddFlowDraftStore.swift
//  Kikisake
//

import Foundation

/// Codable snapshot used for persisting in-progress add flow drafts.
struct AddFlowDraftData: Codable {
    var currentStep: Int
    var selectedCategoryRaw: String
    var name: String
    var producer: String
    var region: String
    var vintage: String
    var abvString: String
    var priceString: String
    var storageLocation: String
    var isBackgroundRemoved: Bool

    var wineType: String
    var blendComponents: [BlendComponent]
    var appellation: String

    var sakeSpecificName: String
    var riceVariety: String
    var polishingRate: String
    var sakeMeterValue: String

    var beerStyle: String
    var ibu: String

    var appearanceNotes: String
    var appearanceColorHex: String
    var selectedAromaTags: [String]

    var sweetness: Double
    var saltiness: Double
    var acidity: Double
    var bitterness: Double
    var umami: Double
    var tannin: Double
    var body: Double
    var selectedBalanceTags: [String]
    var finishLength: Double

    var rating: Double
    var isCostEffective: Bool
    var isWillingToRepeat: Bool
    var hasAgingPotential: Bool
    var pairing: String
    var memo: String
    var tastingDate: Date
}

struct AddFlowDraftImages {
    var frontImageData: Data?
    var originalImageData: Data?
    var backImageData: Data?
}

/// Manages UserDefaults persistence for AddFlowViewModel drafts.
final class AddFlowDraftStore {
    private let userDefaults: UserDefaults
    private let draftKey = "Kikisake_AddFlow_DraftData_v1"
    private let frontImageDraftKey = "Kikisake_AddFlow_FrontImage_v1"
    private let originalImageDraftKey = "Kikisake_AddFlow_OriginalImage_v1"
    private let backImageDraftKey = "Kikisake_AddFlow_BackImage_v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasDraft: Bool {
        userDefaults.data(forKey: draftKey) != nil
    }

    func save(draft: AddFlowDraftData, images: AddFlowDraftImages) {
        if let encoded = try? JSONEncoder().encode(draft) {
            userDefaults.set(encoded, forKey: draftKey)
        }
        if let frontImg = images.frontImageData {
            userDefaults.set(frontImg, forKey: frontImageDraftKey)
        }
        if let origImg = images.originalImageData {
            userDefaults.set(origImg, forKey: originalImageDraftKey)
        }
        if let backImg = images.backImageData {
            userDefaults.set(backImg, forKey: backImageDraftKey)
        }
    }

    func load() -> (draft: AddFlowDraftData, images: AddFlowDraftImages)? {
        guard let data = userDefaults.data(forKey: draftKey),
              let draft = try? JSONDecoder().decode(AddFlowDraftData.self, from: data) else {
            return nil
        }

        let frontImg = userDefaults.data(forKey: frontImageDraftKey)
        let origImg = userDefaults.data(forKey: originalImageDraftKey) ?? frontImg
        let backImg = userDefaults.data(forKey: backImageDraftKey)

        return (
            draft: draft,
            images: AddFlowDraftImages(
                frontImageData: frontImg,
                originalImageData: origImg,
                backImageData: backImg
            )
        )
    }

    func clear() {
        userDefaults.removeObject(forKey: draftKey)
        userDefaults.removeObject(forKey: frontImageDraftKey)
        userDefaults.removeObject(forKey: originalImageDraftKey)
        userDefaults.removeObject(forKey: backImageDraftKey)
    }
}
