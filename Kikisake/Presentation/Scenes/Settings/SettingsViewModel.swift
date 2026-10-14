//
//  SettingsViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

/// 設定画面のビジネスロジック・状態管理
@Observable
public final class SettingsViewModel {
    public var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    public init() {}
}
