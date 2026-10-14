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
                    Label("ログ", systemImage: "long.text.page.and.pencil")
                }
                .tag(0)

            AnalyticsView()
                .tabItem {
                    Label("分析", systemImage: "chart.pie.fill")
                }
                .tag(1)

            AddFlowView()
                .tabItem {
                    Label("追加", systemImage: "plus.circle.fill")
                }
                .tag(2)

            InventoryView()
                .tabItem {
                    Label("セラー", systemImage: "refrigerator.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.accentColor)
    }
}

#Preview {
    MainTabView()
}
