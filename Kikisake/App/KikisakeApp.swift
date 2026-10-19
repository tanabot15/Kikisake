//
//  KikisakeApp.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// アプリケーションのエントリーポイント
@main
struct KikisakeApp: App {
    private let modelContainerManager = ModelContainerManager.shared
    @Bindable private var appState = AppState.shared

    init() {
        // デバッグビルド（シミュレータ等）の起動時にサンプルデータを自動挿入
        PreviewSampleLoader.insertSamplesIfNeeded(into: modelContainerManager.container.mainContext)
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(modelContainerManager.container)
                .preferredColorScheme(appState.appearanceMode.colorScheme)
                // 初回起動時のみボードビュー（オンボーディング）をシート表示
                .sheet(isPresented: Binding(
                    get: { !appState.hasCompletedOnboarding },
                    set: { appState.hasCompletedOnboarding = !$0 }
                )) {
                    BoardingView(isPresented: Binding(
                        get: { !appState.hasCompletedOnboarding },
                        set: { appState.hasCompletedOnboarding = !$0 }
                    ))
                    .interactiveDismissDisabled(true) // 途中でスワイプして閉じられないように固定
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
