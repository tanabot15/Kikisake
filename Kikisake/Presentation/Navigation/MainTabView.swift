//
//  ContentView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// 5つのタブを統括するメインナビゲーションビュー
public struct MainTabView: View {
    @Bindable private var appState = AppState.shared

    public var body: some View {
        TabView(selection: $appState.selectedTab) {
            LogListView()
                .tabItem {
                    Label {
                        Text("ログ")
                    } icon: {
                        Image(systemName: "waveform.path.ecg.text.clipboard")
                            .environment(\.symbolVariants, appState.selectedTab == 0 ? .fill : .none)
                    }
                }
                .tag(0)

            AnalyticsView()
                .tabItem {
                    Label {
                        Text("分析")
                    } icon: {
                        Image(systemName: "chart.pie")
                            .environment(\.symbolVariants, appState.selectedTab == 1 ? .fill : .none)
                    }
                }
                .tag(1)

            AddFlowView()
                .tabItem {
                    Label {
                        Text("追加")
                    } icon: {
                        Image(systemName: "plus.circle")
                            .environment(\.symbolVariants, appState.selectedTab == 2 ? .fill : .none)
                    }
                }
                .tag(2)

            InventoryView()
                .tabItem {
                    Label {
                        Text("在庫")
                    } icon: {
                        Image(systemName: "refrigerator")
                            .environment(\.symbolVariants, appState.selectedTab == 3 ? .fill : .none)
                    }
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label {
                        Text("設定")
                    } icon: {
                        Image(systemName: "gearshape")
                            .environment(\.symbolVariants, appState.selectedTab == 4 ? .fill : .none)
                    }
                }
                .tag(4)
        }
        .tint(.accentColor)
    }
}

#Preview {
    MainTabView()
}
