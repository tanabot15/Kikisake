//  AppState.swift
//  Kikisake

import SwiftUI

/// アプリの外観モードを表す列挙型
public enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "端末の設定に合わせる"
    case light = "ライトモード"
    case dark = "ダークモード"

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// ログ一覧へ引き渡すフィルターの種別
public enum LogFilterType {
    case costEffective
    case willingToRepeat
    case agingPotential
}

/// アプリ全体で共有するグローバルな状態や環境設定を管理するクラス
@Observable
public final class AppState {
    public static let shared = AppState()

    public var selectedTab: Int = 0
    public var isProVersion: Bool = false
    
    // 分析画面等からログ一覧へのフィルター引き渡し用プロパティ
    public var pendingLogFilter: LogFilterType? = nil
    public var pendingAromaTagFilter: String? = nil // ✨ 香りタグの引き渡し用
    
    public var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "saved_has_completed_onboarding")
        }
    }
    
    public var addFlowViewModel: AddFlowViewModel = AddFlowViewModel()
    
    public var openingItem: BeverageItem? {
        didSet {
            if let item = openingItem {
                addFlowViewModel.handleOpeningItem(item)
                selectedTab = 2
                openingItem = nil
            }
        }
    }

    public var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "saved_appearance_mode")
        }
    }

    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "saved_has_completed_onboarding")

        if let savedValue = UserDefaults.standard.string(forKey: "saved_appearance_mode"),
           let mode = AppearanceMode(rawValue: savedValue) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }
    }
}
