//
//  AppState.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

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

/// アプリ全体で共有するグローバルな状態や環境設定を管理するクラス
@Observable
public final class AppState {
    public static let shared = AppState()

    /// 現在選択されているメインタブのインデックス
    public var selectedTab: Int = 0
    /// プロバージョンフラグ
    public var isProVersion: Bool = false
    
    /// オンボーディングを完了したかどうか（初回のみ表示するためのフラグ）
    public var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "saved_has_completed_onboarding")
        }
    }
    
    /// 在庫から開けるために一時保持するアイテム（セットされると自動的に追加タブへ移動）
    public var openingItem: BeverageItem? {
        didSet {
            if openingItem != nil {
                // 追加タブのインデックス（※Tab 0:ログ, 1:分析, 2:追加, 3:在庫 の場合は 2）
                selectedTab = 2
            }
        }
    }

    /// 外観モード設定（UserDefaultsと連動、デフォルトはシステム）
    public var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "saved_appearance_mode")
        }
    }

    private init() {
        // オンボーディング状態の復元
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "saved_has_completed_onboarding")

        // 外観モード設定の復元
        if let savedValue = UserDefaults.standard.string(forKey: "saved_appearance_mode"),
           let mode = AppearanceMode(rawValue: savedValue) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }
    }
}
