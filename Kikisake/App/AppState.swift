//
//  AppState.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// アプリ全体で共有するグローバルな状態や環境設定を管理するクラス
@Observable
public final class AppState {
    public static let shared = AppState()

    /// 現在選択されているメインタブのインデックスやグローバルなフラグ
    public var selectedTab: Int = 0
    public var isProVersion: Bool = false

    private init() {}
}
