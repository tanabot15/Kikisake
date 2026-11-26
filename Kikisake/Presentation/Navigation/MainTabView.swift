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
    @State private var isShowingAddModeDialog: Bool = false

    public init() {}

    /// タブの選択をインターセプトし、「追加」タップ時にモード選択ポップアップを表示する
    private var tabSelectionBinding: Binding<Int> {
        Binding(
            get: { appState.selectedTab },
            set: { newValue in
                let vm = appState.addFlowViewModel
                let isDirectEntry = vm.isOpeningExistingItem || vm.editingLog != nil

                if newValue == TabItem.add.rawValue && appState.selectedTab != TabItem.add.rawValue && !isDirectEntry {
                    isShowingAddModeDialog = true
                } else {
                    appState.selectedTab = newValue
                }
            }
        )
    }

    public var body: some View {
        TabView(selection: tabSelectionBinding) {
            tabContent(for: .log) { LogView() }
            tabContent(for: .analytics) { AnalyticsView() }
            tabContent(for: .add) { AddFlowCoordinatorView() }
            tabContent(for: .inventory) { InventoryView() }
            tabContent(for: .settings) { SettingsView() }
        }
        .tint(.accentColor)
        .confirmationDialog(
            String(localized: "記録方法を選択"),
            isPresented: $isShowingAddModeDialog,
            titleVisibility: .visible
        ) {
            Button(String(localized: "通常記録（銘柄を入力して記録）")) {
                startAddFlow(mode: .normal)
            }

            Button(String(localized: "ブラインド記録（Kikisakeモード）")) {
                startAddFlow(mode: .blind)
            }

            Button(String(localized: "キャンセル"), role: .cancel) {}
        } message: {
            Text(String(localized: "銘柄を見ながら記録するか、銘柄を伏せてブラインドテイスティングに挑戦するか選択してください。"))
        }
    }

    private func startAddFlow(mode: TastingEntryMode) {
        let vm = appState.addFlowViewModel
        vm.reset()
        vm.entryMode = mode
        vm.currentStep = 1
        appState.selectedTab = TabItem.add.rawValue
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
