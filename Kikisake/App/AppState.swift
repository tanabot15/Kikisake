//
//  AppState.swift
//  Kikisake
//

import SwiftUI

public enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    public var localizedName: String {
        switch self {
        case .system:
            String(localized: "端末の設定に合わせる")
        case .light:
            String(localized: "ライトモード")
        case .dark:
            String(localized: "ダークモード")
        }
    }
}

public enum LogFilterType {
    case costEffective
    case willingToRepeat
    case agingPotential
}

@Observable
public final class AppState {
    public static let shared = AppState()

    private enum StorageKey {
        static let isProVersion = "saved_is_pro_version"
        static let hasCompletedOnboarding = "saved_has_completed_onboarding"
        static let appearanceMode = "saved_appearance_mode"
    }

    public var selectedTab: Int = 0

    public var isProVersion: Bool {
        didSet {
            UserDefaults.standard.set(isProVersion, forKey: StorageKey.isProVersion)
        }
    }

    public var pendingLogFilter: LogFilterType? = nil
    public var pendingAromaTagFilter: String? = nil

    public var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: StorageKey.hasCompletedOnboarding)
        }
    }

    public var addFlowViewModel: AddFlowViewModel = AddFlowViewModel()

    public var openingItem: BeverageItem? {
        didSet {
            guard let targetItem = openingItem else { return }
            addFlowViewModel.handleOpeningItem(targetItem)
            selectedTab = 2
            openingItem = nil
        }
    }

    public var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: StorageKey.appearanceMode)
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        self.hasCompletedOnboarding = defaults.bool(forKey: StorageKey.hasCompletedOnboarding)
        self.isProVersion = defaults.bool(forKey: StorageKey.isProVersion)

        if let savedValue = defaults.string(forKey: StorageKey.appearanceMode),
           let mode = AppearanceMode(rawValue: savedValue) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }
    }
}
