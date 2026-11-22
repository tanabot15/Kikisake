//
//  MainTabView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// 5つのタブを統括するメインナビゲーションビュー
public struct MainTabView: View {
    private enum TabItem: Int, CaseIterable {
        case log = 0
        case analytics = 1
        case add = 2
        case inventory = 3
        case settings = 4

        var title: LocalizedStringKey {
            switch self {
            case .log: "ログ"
            case .analytics: "分析"
            case .add: "追加"
            case .inventory: "在庫"
            case .settings: "設定"
            }
        }

        var systemImage: String {
            switch self {
            case .log: "waveform.path.ecg.text.clipboard"
            case .analytics: "chart.pie"
            case .add: "plus.circle"
            case .inventory: "refrigerator"
            case .settings: "gearshape"
            }
        }
    }

    @Bindable private var appState = AppState.shared

    public init() {}

    public var body: some View {
        TabView(selection: $appState.selectedTab) {
            tabContent(for: .log) { LogView() }
            tabContent(for: .analytics) { AnalyticsView() }
            tabContent(for: .add) { AddFlowCoordinatorView() }
            tabContent(for: .inventory) { InventoryView() }
            tabContent(for: .settings) { SettingsView() }
        }
        .tint(.accentColor)
    }

    @ViewBuilder
    private func tabContent<Content: View>(for tab: TabItem, @ViewBuilder content: () -> Content) -> some View {
        content()
            .tabItem {
                Label {
                    Text(tab.title)
                } icon: {
                    Image(systemName: tab.systemImage)
                        .environment(\.symbolVariants, appState.selectedTab == tab.rawValue ? .fill : .none)
                }
            }
            .tag(tab.rawValue)
    }
}

#Preview {
    MainTabView()
}
