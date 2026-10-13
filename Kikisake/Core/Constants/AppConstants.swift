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
        public static let defaultLocation = "ワインセラー"
        public static let availableLocations = ["ワインセラー", "冷蔵庫", "常温"]
    }
    
    public enum Limit {
        public static let maxFreeLogs = 30
        public static let maxFreeInventory = 10
    }
}
