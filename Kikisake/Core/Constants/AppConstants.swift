//
//  AppConstants.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation

/// アプリ全体で使用する定数定義
public enum AppConstants {
    public static let appName = "Kikisake"
    
    public enum Storage {
        public static let defaultStorageName = "ワインセラー"
        public static let defaultLocation = String(localized: String.LocalizationValue("ワインセラー"))
        public static let availableLocations = [
            String(localized: String.LocalizationValue("ワインセラー")),
            String(localized: String.LocalizationValue("冷蔵庫")),
            String(localized: String.LocalizationValue("常温"))
        ]
    }
}
