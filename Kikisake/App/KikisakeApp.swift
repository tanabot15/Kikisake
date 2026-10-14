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

    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(modelContainerManager.container)
                .preferredColorScheme(appState.appearanceMode.colorScheme)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
