//  AppState.swift
//  Kikisake

import SwiftUI

/// アプリの外観モードを表す列挙型
public enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    /// ✨ Localizable.xcstrings が自動検出し、英訳を行えるように直接文字列リテラルを指定
    public var localizedName: String {
        switch self {
        case .system:
            return String(localized: "端末の設定に合わせる")
        case .light:
            return String(localized: "ライトモード")
        case .dark:
            return String(localized: "ダークモード")
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

    /// Pro版（買い切り）の有効フラグ（UserDefaultsに自動永続化）
    public var isProVersion: Bool {
        didSet {
            UserDefaults.standard.set(isProVersion, forKey: "saved_is_pro_version")
        }
    }
    
    // 分析画面等からログ一覧へのフィルター引き渡し用プロパティ
    public var pendingLogFilter: LogFilterType? = nil
    public var pendingAromaTagFilter: String? = nil
    
    public var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "saved_has_completed_onboarding")
        }
    }
    
    public var addFlowViewModel: AddFlowViewModel = AddFlowViewModel()
    
    public var openingItem: BeverageItem? {
        didSet {
            // ✨ 変更された openingItem が存在する場合の処理に修正
            if let targetItem = openingItem {
                addFlowViewModel.handleOpeningItem(targetItem)
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
        self.isProVersion = UserDefaults.standard.bool(forKey: "saved_is_pro_version")

        if let savedValue = UserDefaults.standard.string(forKey: "saved_appearance_mode"),
           let mode = AppearanceMode(rawValue: savedValue) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }
    }
}
