//
//  SettingsViewModel.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import UIKit

/// 設定画面のビジネスロジック・状態管理
@Observable
public final class SettingsViewModel {
    public var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// 現在適用されている言語の表示名を取得する
    public var currentLanguageDisplayName: String {
        let currentCode = Bundle.main.preferredLocalizations.first ?? "ja"
        let locale = Locale(identifier: currentCode)
        return locale.localizedString(forLanguageCode: currentCode) ?? currentCode
    }

    public init() {}

    /// iOSのデバイス設定（アプリ固有の設定画面）を開く
    public func openDeviceSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
