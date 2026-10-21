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

    public var selectedTab: Int = 0
    public var isProVersion: Bool = false
    
    public var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "saved_has_completed_onboarding")
        }
    }
    
    // 追加・登録フロー用の共有ViewModel
    public var addFlowViewModel: AddFlowViewModel = AddFlowViewModel()
    
    public var openingItem: BeverageItem? {
        didSet {
            if let item = openingItem {
                // ボトルが指定されたら、共有ViewModelに即座に反映し、追加タブ（インデックス2）へ移動
                addFlowViewModel.handleOpeningItem(item)
                selectedTab = 2
                // 処理が終わったらクリア
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
